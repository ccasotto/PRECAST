wipe 
model basic -ndm 3 -ndf 6 
source DisplayModel3D.tcl;
source DisplayPlane.tcl;
# ------ frame configuration; 
set NStory 1;
set NBay 1;
set NBayZ 1; 
puts "Number of Stories in Y: $NStory Number of bays in X: $NBay Number of bays in Z: $NBayZ" 
set NFrame [expr $NBayZ + 1];
# define GEOMETRY 
# define structure-geometry paramters 
set LCol 9.53; 
set LBeam 21.69; 
set LGird 8.94; 
# define NODAL COORDINATES
set dlt 3.000000e-002;
set Dlevel 10000;
set Dframe 100;
set Djoint 10;
set DjointG 100000;
node 10101 0.00 0.00 0.00;
node 10102 21.69 0.00 0.00;
node 20101 0.00 9.53 0.00;
node 20102 21.69 9.53 0.00;
node 10201 0.00 0.00 8.94;
node 10202 21.69 0.00 8.94;
node 20201 0.00 9.53 8.94;
node 20202 21.69 9.53 8.94;
# define SPRING COORDINATES
node 20111 0.03 9.53 0.00;
node 20121 21.66 9.53 0.00;
node 20211 0.03 9.53 8.94;
node 20221 21.66 9.53 8.94;
# define SPRING Girder COORDINATES
node 120101 0.00 9.53 0.03;
node 220101 0.00 9.53 8.91;
node 120102 21.69 9.53 0.03;
node 220102 21.69 9.53 8.91;
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
# BOUNDARY CONDITIONS 
fixY 0.0  1 1 1 1 1 1;
# Define MATERIALS -------------------------------------------------------------
set IDconcCore  1;
set IDconcCover  3;
set IDSteel  2;
# CONCRETE UNCONFINED 
set fc1U  -29050;
set eps1U -0.002500;	
set fc2U     -9;	
set eps2U -0.005000;
# CONCRETE CONFINED 
set Ubig 1.e10; 
set Usmall [expr 1/$Ubig]; 
set fc -33407;
set Ec 33721655;
set eps1C -0.002500;
set fc2C    -10;
set eps2C -0.005000;
set lambda 0.500000;
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
uniaxialMaterial Steel02 $IDSteel 220000.00 203573715 0.005 20 0.925 0.15; 

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
set numBarsTop 3; 
set numBarsBot 3; 
set numBarsIntTot 2; 
set barAreaTop 0.000314; 
set barAreaBot 0.000314; 
set barAreaInt 0.000314; 
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
	# define reinforcing layers 
	layer straight $IDSteel $numBarsInt $barAreaInt  -$coreY $coreZ $coreY $coreZ;	# intermediate skin reinf. +z
	layer straight $IDSteel $numBarsInt $barAreaInt  -$coreY -$coreZ $coreY -$coreZ;	# intermediate skin reinf. -z
	layer straight $IDSteel $numBarsTop $barAreaTop $coreY $coreZ $coreY -$coreZ;	# top layer reinfocement
	layer straight $IDSteel $numBarsBot $barAreaBot  -$coreY $coreZ  -$coreY -$coreZ;	# bottom layer reinforcement
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
		element nonlinearBeamColumn 3020211 20201 20211 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020221 20221 20202 $numIntgrPts $SpringSecTag $IDBeamTransf 
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
		element nonlinearBeamColumn 4120101 20101 120101 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4210101 220101 20201  $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4120102 20102 120102 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4210102 220102 20202  $numIntgrPts $SpringSecTag $IDBeamTransf 
#MASSES 
mass 20101 25.935 25.935 25.935 1e-9 1e-9 1e-9 
mass 20102 25.935 25.935 25.935 1e-9 1e-9 1e-9 
mass 20202 25.935 25.935 25.935 1e-9 1e-9 1e-9 
mass 20202 25.935 25.935 25.935 1e-9 1e-9 1e-9 
# define GRAVITY 
pattern Plain 1 Linear {
load 20101 0. -254.421 0. 0. 0. 0. 
load 20102 0. -254.421 0. 0. 0. 0. 
load 20202 0. -254.421 0. 0. 0. 0. 
load 20202 0. -254.421 0. 0. 0. 0. 
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

puts "$ColumnFirst $ColumnLast"
puts "Done!"