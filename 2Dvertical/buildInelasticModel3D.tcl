wipe 
model basic -ndm 3 -ndf 6 
source DisplayModel3D.tcl;
source DisplayPlane.tcl;
# ------ frame configuration; 
set NStory 1;
set NBay 2;
set NBayZ 0; 
puts "Number of Stories in Y: $NStory Number of bays in X: $NBay Number of bays in Z: $NBayZ" 
set NFrame [expr $NBayZ + 1];
# define GEOMETRY 
# define structure-geometry paramters 
set LCol 7.20; 
set LBeam 13.91; 
set LGird 9.03; 
# define NODAL COORDINATES
set dlt 3.000000e-02;
set Dlevel 10000;
set Dframe 100;
set Djoint 10;
set DjointG 100000;
node 10101 0.00 0.00 0.00;
node 10102 13.91 0.00 0.00;
node 10103 27.81 0.00 0.00;
node 20101 0.00 7.20 0.00;
node 20102 13.91 7.20 0.00;
node 20103 27.81 7.20 0.00;
# define SPRING COORDINATES
node 20111 0.03 7.20 0.00;
node 20121 13.88 7.20 0.00;
node 20112 13.94 7.20 0.00;
node 20122 27.78 7.20 0.00;
# define SPRING Girder COORDINATES
# determine support nodes where ground motions are input, for multiple-support excitation
set iSupportNode ""
for {set frame 1} {$frame <=[expr $NFrame]} {incr frame 1} {
	set level 1
	for {set pier 1} {$pier <= [expr $NBay+1]} {incr pier 1} {
		set nodeID [expr $level*$Dlevel+$frame*$Dframe+$pier]
		lappend iSupportNode $nodeID
	}
}
# determine top nodes
set iTopNode ""
for {set frame 1} {$frame <=[expr $NFrame]} {incr frame 1} {
	set level [expr $NStory+1] 
	for {set pier 1} {$pier <= [expr $NBay+1]} {incr pier 1} {
		set nodeID [expr $level*$Dlevel+$frame*$Dframe+$pier]
		lappend iTopNode $nodeID
	}
}
set SupportNodeFirst [lindex $iSupportNode 0];
set SupportNodeLast [lindex $iSupportNode [expr [llength $iSupportNode]-1]];
set TopNodeFirst [lindex $iTopNode 0];
set TopNodeLast [lindex $iTopNode [expr [llength $iTopNode]-1]]; 
# BOUNDARY CONDITIONS 

fixY 0.0  1 1 1 1 1 1;
fixZ 7.20  0 0 1 1 1 0;
# Define MATERIALS -------------------------------------------------------------
set IDconcCore  1;
set IDconcCover  3;
set IDSteel  2;
# CONCRETE UNCONFINED 
set fc1C  -43860;
set fc1U  -38139;
set eps1U -0.002500;	
set fc2U -11442;	
set eps2U -0.010000;
# CONCRETE CONFINED 
set Ubig 1.e10; 
set Usmall [expr 1/$Ubig]; 
set fc -43860;
set Ec 33721655;
set eps1C -0.002500;
set fc2C -13158;
set eps2C -0.010000;
set lambda 0.005000;
set ftC      0;
set Ets      0;
	set nu 0.2;
	set Gc [expr $Ec/2./[expr 1+$nu]]; 
	set J $Ubig; 
# CONCRETE 
# Core concrete (confined) 
uniaxialMaterial Concrete02 $IDconcCore $fc1U $eps1U $fc2U $eps2U $lambda $ftC $Ets;	# Cover concrete (unconfined) 
# Core concrete (unconfined) 
uniaxialMaterial Concrete02 $IDconcCover $fc1U $eps1U $fc2U $eps2U $lambda $ftC $Ets;	# Cover concrete (unconfined) 
# Reinforcing STEEL 
uniaxialMaterial Steel02 $IDSteel 419455.35 202762635 0.005 20 0.925 0.15; 

# Define SECTIONS -------------------------------------------------------------
# define section tags:
set ColSecTag 1
set BeamSecTag 2
set GirdSecTag 3
set ColSecTagFiber 4
set SecTagTorsion 70
set SpringSecTag 70
# Section Properties:
set factor 0.0001 
# ELASTIC section
section Elastic $GirdSecTag $Ec 0.107000 0.013400 0.000292 $Gc $J 
section Elastic $BeamSecTag $Ec 0.107000 0.013400 0.000292 $Gc $J 
section Elastic $SpringSecTag [expr $Ec*1] [expr 0.107000*100] [expr 0.013400*$factor] [expr 0.000292*$factor] [expr $Gc*1] [expr $J*1]
# FIBER section
set HSec 0.500; 
set BSec 0.500; 
set cover 0.030; 
set numBarsTop 6; 
set numBarsBot 6; 
set numBarsIntTot 12; 
set barArea 0.000113; 
set barAreaInt 0.000113; 
set nfCoreY 13; 
set nfCoreZ 13; 
set nfCoverY 1; 
set nfCoverZ 1; 
set coverY [expr $HSec/2.0];
set coverZ [expr $BSec/2.0];
set coreY [expr $coverY-$cover];
set coreZ [expr $coverZ-$cover];
set numBarsInt [expr $numBarsIntTot/2];
# Define the fiber section 
section fiberSec $ColSecTagFiber { 
	# Define the core patch 
	patch quadr $IDconcCore $nfCoreZ $nfCoreY -$coreY $coreZ -$coreY -$coreZ $coreY -$coreZ $coreY $coreZ 
	# Define the four cover patches 
	patch quadr $IDconcCover 2 $nfCoverY -$coverY $coverZ -$coreY $coreZ $coreY $coreZ $coverY $coverZ 
	patch quadr $IDconcCover 2 $nfCoverY -$coreY -$coreZ -$coverY -$coverZ $coverY -$coverZ $coreY -$coreZ 
	patch quadr $IDconcCover $nfCoverZ 2 -$coverY $coverZ -$coverY -$coverZ -$coreY -$coreZ -$coreY $coreZ 
	patch quadr $IDconcCover $nfCoverZ 2 $coreY $coreZ $coreY -$coreZ $coverY -$coverZ $coverY $coverZ 
	# define reinforcing fibers 
fiber 0.2200 0.2200 $barArea $IDSteel; # Top fiber
fiber -0.2200 0.2200 $barArea $IDSteel; # Bottom fiber
fiber 0.2200 0.1320 $barArea $IDSteel; # Top fiber
fiber -0.2200 0.1320 $barArea $IDSteel; # Bottom fiber
fiber 0.2200 0.0440 $barArea $IDSteel; # Top fiber
fiber -0.2200 0.0440 $barArea $IDSteel; # Bottom fiber
fiber 0.2200 -0.0440 $barArea $IDSteel; # Top fiber
fiber -0.2200 -0.0440 $barArea $IDSteel; # Bottom fiber
fiber 0.2200 -0.1320 $barArea $IDSteel; # Top fiber
fiber -0.2200 -0.1320 $barArea $IDSteel; # Bottom fiber
fiber 0.2200 -0.2200 $barArea $IDSteel; # Top fiber
fiber -0.2200 -0.2200 $barArea $IDSteel; # Bottom fiber
fiber  0.1320 0.2200 $barArea $IDSteel; # left fiber
fiber  0.1320 -0.2200 $barArea $IDSteel; # right fiber
fiber  0.0440 0.2200 $barArea $IDSteel; # left fiber
fiber  0.0440 -0.2200 $barArea $IDSteel; # right fiber
fiber  -0.0440 0.2200 $barArea $IDSteel; # left fiber
fiber  -0.0440 -0.2200 $barArea $IDSteel; # right fiber
fiber  -0.1320 0.2200 $barArea $IDSteel; # left fiber
fiber  -0.1320 -0.2200 $barArea $IDSteel; # right fiber
}; 
	# assign torsional Stiffness for 3D Model 
uniaxialMaterial Elastic $SecTagTorsion $Ubig 
section Aggregator $ColSecTag $SecTagTorsion T -section $ColSecTagFiber 
# define ELEMENTS
# set up geometric transformations of element
set IDColTransf 1; # all columns
set IDBeamTransf 2; # all beams
set IDGirdTransf 3; # all girds
geomTransf PDelta  $IDColTransf  0 0 -1;
geomTransf Linear $IDBeamTransf 0 1 0
geomTransf Linear $IDGirdTransf 1 0 0
# Define Column ELEMENTS
set numIntgrPts 4;
# columns
set iColumns ""
set N0col [expr 10000-1];	
set level 0
for {set frame 1} {$frame <=[expr $NFrame]} {incr frame 1} {
for {set level 1} {$level <=$NStory} {incr level 1} {
	for {set pier 1} {$pier <= [expr $NBay+1]} {incr pier 1} {
		set elemID [expr $N0col  +$level*$Dlevel + $frame*$Dframe+$pier]
		set nodeI [expr  $level*$Dlevel + $frame*$Dframe+$pier]
		set nodeJ  [expr  ($level+1)*$Dlevel + $frame*$Dframe+$pier]
		element nonlinearBeamColumn $elemID $nodeI $nodeJ $numIntgrPts $ColSecTag $IDColTransf;	
		lappend iColumns $elemID 
	}
}
}
# beams -- parallel to X-axis
set N0beam 1000000;	# beam element numbers
for {set frame 1} {$frame <=[expr $NFrame]} {incr frame 1} {
for {set level 2} {$level <=[expr $NStory+1]} {incr level 1} {
	for {set bay 1} {$bay <= $NBay} {incr bay 1} {
		set elemID [expr $N0beam +$level*$Dlevel + $frame*$Dframe+ $bay]
		set nodeI [expr $level*$Dlevel + $frame*$Dframe+ $bay+$Djoint]
		set nodeJ  [expr $level*$Dlevel + $frame*$Dframe+ $bay+$Djoint*2]
		element elasticBeamColumn $elemID $nodeI $nodeJ 0.107000 $Ec $Gc $J 0.013400 0.000292 $IDBeamTransf; 
	}
}
}
# springs -- parallel to beams
		element nonlinearBeamColumn 3020111 20101 20111 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020121 20121 20102 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020112 20102 20112 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020122 20122 20103 $numIntgrPts $SpringSecTag $IDBeamTransf 
# girders -- parallel to Z-axis
set N0gird 2000000;	# gird element numbers
for {set frame 1} {$frame <=[expr $NFrame-1]} {incr frame 1} {
for {set level 2} {$level <=[expr $NStory+1]} {incr level 1} {
	for {set bay 1} {$bay <= $NBay+1} {incr bay 1} {
		set elemID [expr $N0gird + $level*$Dlevel +$frame*$Dframe+ $bay]
		set nodeI [expr   $level*$Dlevel + $frame*$Dframe+ $bay+ $DjointG]
		set nodeJ  [expr  $level*$Dlevel + $frame*$Dframe+ $bay +$DjointG*2]
		element elasticBeamColumn $elemID $nodeI $nodeJ 0.107000 $Ec $Gc $J 0.013400 0.000292 $IDGirdTransf;	
	}
}
}
# springs -- parallel to girders
#MASSES 
mass 20101 16.028 16.028 16.028 1e-9 1e-9 1e-9 
mass 20102 32.057 32.057 32.057 1e-9 1e-9 1e-9 
mass 20103 16.028 16.028 16.028 1e-9 1e-9 1e-9 
# define GRAVITY 
pattern Plain 1 Linear {
load 20101 0. -157.238 0. 0. 0. 0. 
load 20102 0. -314.476 0. 0. 0. 0. 
load 20103 0. -157.238 0. 0. 0. 0. 
}
# Define RECORDERS -------------------------------------------------------------
set FreeNodeID [expr $NFrame*$Dframe+($NStory+1)*$Dlevel+($NBay+1)];					# ID: free node
set SupportNodeFirst [lindex $iSupportNode 0];						# ID: first support node
set SupportNodeLast [lindex $iSupportNode [expr [llength $iSupportNode]-1]];			# ID: last support node
set ColumnFirst [lindex $iColumns 0];
set ColumnLast [lindex $iColumns [expr [llength $iColumns]-1]];# EIGENVALUES 
set pi [expr 2.0*asin(1.0)];
set lambda [eigen  4];
set T [list [expr 2.0*$pi/pow([lindex $lambda 0],0.5)] [expr 2.0*$pi/pow([lindex $lambda 1],0.5)] [expr 2.0*$pi/pow([lindex $lambda 2],0.5)] [expr 2.0*$pi/pow([lindex $lambda 3],0.5)]]
     set outfile [open "period.txt" w]
     puts $outfile $T 
puts "T = $T s"

puts goGravity 
# Gravity-analysis parameters -- load-controlled static analysis 
# display deformed shape:
set ViewScale 5;
DisplayModel3D DeformedShape $ViewScale ;
set Tol 1.0e-8; 
set NstepGravity 20; 
set DGravity [expr 1./$NstepGravity]; 
system BandGeneral
constraints Plain ;  # how it handles boundary conditions
numberer Plain
test NormDispIncr $Tol 10 3
algorithm Newton
integrator LoadControl $DGravity
analysis Static
analyze $NstepGravity 

puts "Done!"