wipe 
model basic -ndm 3 -ndf 6 
source DisplayModel3D.tcl;
source DisplayPlane.tcl;
# ------ frame configuration; 
set NStory 1;
set NBay 2;
set NBayZ 3; 
puts "Number of Stories in Y: $NStory Number of bays in X: $NBay Number of bays in Z: $NBayZ" 
set NFrame [expr $NBayZ + 1];
# define GEOMETRY 
# define structure-geometry paramters 
set LCol 7.44; 
set LBeam 25.79; 
set LGird 9.86; 
# define NODAL COORDINATES
set Dlevel 10000;
set Dframe 100;
set Djoint 10;
set DjointG 100000;
node 10101 0.00 0.00 0.00;
node 10102 25.79 0.00 0.00;
node 10103 51.59 0.00 0.00;
node 20101 0.00 7.44 0.00;
node 20102 25.79 7.44 0.00;
node 20103 51.59 7.44 0.00;
node 10201 0.00 0.00 9.86;
node 10202 25.79 0.00 9.86;
node 10203 51.59 0.00 9.86;
node 20201 0.00 7.44 9.86;
node 20202 25.79 7.44 9.86;
node 20203 51.59 7.44 9.86;
node 10301 0.00 0.00 19.72;
node 10302 25.79 0.00 19.72;
node 10303 51.59 0.00 19.72;
node 20301 0.00 7.44 19.72;
node 20302 25.79 7.44 19.72;
node 20303 51.59 7.44 19.72;
node 10401 0.00 0.00 29.59;
node 10402 25.79 0.00 29.59;
node 10403 51.59 0.00 29.59;
node 20401 0.00 7.44 29.59;
node 20402 25.79 7.44 29.59;
node 20403 51.59 7.44 29.59;
# define SPRING COORDINATES
node 20111 0.00 7.44 0.00;
node 20121 25.79 7.44 0.00;
equalDOF 20101 20111 1 2 3 4 5 
equalDOF 20102 20121 1 2 3 4 5 
node 20112 25.79 7.44 0.00;
node 20122 51.59 7.44 0.00;
equalDOF 20102 20112 1 2 3 4 5 
equalDOF 20103 20122 1 2 3 4 5 
node 20211 0.00 7.44 9.86;
node 20221 25.79 7.44 9.86;
equalDOF 20201 20211 1 2 3 4 5 
equalDOF 20202 20221 1 2 3 4 5 
node 20212 25.79 7.44 9.86;
node 20222 51.59 7.44 9.86;
equalDOF 20202 20212 1 2 3 4 5 
equalDOF 20203 20222 1 2 3 4 5 
node 20311 0.00 7.44 19.72;
node 20321 25.79 7.44 19.72;
equalDOF 20301 20311 1 2 3 4 5 
equalDOF 20302 20321 1 2 3 4 5 
node 20312 25.79 7.44 19.72;
node 20322 51.59 7.44 19.72;
equalDOF 20302 20312 1 2 3 4 5 
equalDOF 20303 20322 1 2 3 4 5 
node 20411 0.00 7.44 29.59;
node 20421 25.79 7.44 29.59;
equalDOF 20401 20411 1 2 3 4 5 
equalDOF 20402 20421 1 2 3 4 5 
node 20412 25.79 7.44 29.59;
node 20422 51.59 7.44 29.59;
equalDOF 20402 20412 1 2 3 4 5 
equalDOF 20403 20422 1 2 3 4 5 
# define SPRING Girder COORDINATES
node 120101 0.00 7.44 0.00;
node 220101 0.00 7.44 9.86;
equalDOF 20101 120101 1 2 3 5 6
equalDOF 20201 220101 1 2 3 5 6
node 120102 25.79 7.44 0.00;
node 220102 25.79 7.44 9.86;
equalDOF 20102 120102 1 2 3 5 6
equalDOF 20202 220102 1 2 3 5 6
node 120103 51.59 7.44 0.00;
node 220103 51.59 7.44 9.86;
equalDOF 20103 120103 1 2 3 5 6
equalDOF 20203 220103 1 2 3 5 6
node 120201 0.00 7.44 9.86;
node 220201 0.00 7.44 19.72;
equalDOF 20201 120201 1 2 3 5 6
equalDOF 20301 220201 1 2 3 5 6
node 120202 25.79 7.44 9.86;
node 220202 25.79 7.44 19.72;
equalDOF 20202 120202 1 2 3 5 6
equalDOF 20302 220202 1 2 3 5 6
node 120203 51.59 7.44 9.86;
node 220203 51.59 7.44 19.72;
equalDOF 20203 120203 1 2 3 5 6
equalDOF 20303 220203 1 2 3 5 6
node 120301 0.00 7.44 19.72;
node 220301 0.00 7.44 29.59;
equalDOF 20301 120301 1 2 3 5 6
equalDOF 20401 220301 1 2 3 5 6
node 120302 25.79 7.44 19.72;
node 220302 25.79 7.44 29.59;
equalDOF 20302 120302 1 2 3 5 6
equalDOF 20402 220302 1 2 3 5 6
node 120303 51.59 7.44 19.72;
node 220303 51.59 7.44 29.59;
equalDOF 20303 120303 1 2 3 5 6
equalDOF 20403 220303 1 2 3 5 6
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
# Define MATERIALS -------------------------------------------------------------
set IDconcCore  1;
set IDSteel  2;
# CONCRETE UNCONFINED 
set fc1  -41001;
set eps1 -0.002500;	
set fc2    -12;	
set eps2 -0.010000;
set Ubig 1.e10; 
set Usmall [expr 1/$Ubig]; 
set Ec 36049965;
set lambda 0.005000;
set ftC      0;
set Ets      0;
set nu 0.2;
set Gc [expr $Ec/2./[expr 1+$nu]]; 
set J $Ubig; 
# CONCRETE 
# Core concrete (unconfined) 
uniaxialMaterial Concrete02 $IDconcCore $fc1 $eps1 $fc2 $eps2 $lambda $ftC $Ets;	# Cover concrete (unconfined) 
# Reinforcing STEEL 
uniaxialMaterial Steel02 $IDSteel 264477.67 201593826 0.0033 20 0.925 0.15; 

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
set cover 0.030; 
set barArea 0.000154; 
set nfCoreY 13; 
set nfCoreZ 13; 
set nfCoverY 1; 
set nfCoverZ 1; 
set coverY 0.2500;
set coverZ 0.2500;
set coreY [expr $coverY-$cover];
set coreZ [expr $coverZ-$cover];
# Define the fiber section 
section fiberSec $ColSecTagFiber { 
	# Define the core patch 
	patch quadr $IDconcCore $nfCoreZ $nfCoreY -$coreY $coreZ -$coreY -$coreZ $coreY -$coreZ $coreY $coreZ 
	# Define the four cover patches 
	patch quadr $IDconcCore 2 $nfCoverY -$coverY $coverZ -$coreY $coreZ $coreY $coreZ $coverY $coverZ 
	patch quadr $IDconcCore 2 $nfCoverY -$coreY -$coreZ -$coverY -$coverZ $coverY -$coverZ $coreY -$coreZ 
	patch quadr $IDconcCore $nfCoverZ 2 -$coverY $coverZ -$coverY -$coverZ -$coreY -$coreZ -$coreY $coreZ 
	patch quadr $IDconcCore $nfCoverZ 2 $coreY $coreZ $coreY -$coreZ $coverY -$coverZ $coverY $coverZ 
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
		puts "$elemID $nodeI $nodeJ"
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
		puts "$elemID $nodeI $nodeJ"
	}
}
}
# girders -- parallel to Z-axis
set N0gird 2000000;	# gird element numbers
for {set frame 1} {$frame <=[expr $NFrame-1]} {incr frame 1} {
for {set level 2} {$level <=[expr $NStory+1]} {incr level 1} {
	for {set bay 1} {$bay <= $NBay+1} {incr bay 1} {
		set elemID [expr $N0gird + $level*$Dlevel +$frame*$Dframe+ $bay]
		set nodeI [expr   $level*$Dlevel + $frame*$Dframe+ $bay+ $DjointG]
		set nodeJ  [expr  $level*$Dlevel + $frame*$Dframe+ $bay +$DjointG*2]
		element elasticBeamColumn $elemID $nodeI $nodeJ 0.107000 $Ec $Gc $J 0.013400 0.000292 $IDGirdTransf;	
		puts "$elemID $nodeI $nodeJ"
	}
}
}
#MASSES 
mass 20101 36.123 36.123 36.123 1e-9 1e-9 1e-9 
mass 20102 72.247 72.247 72.247 1e-9 1e-9 1e-9 
mass 20103 36.123 36.123 36.123 1e-9 1e-9 1e-9 
mass 20201 62.386 62.386 62.386 1e-9 1e-9 1e-9 
mass 20202 124.773 124.773 124.773 1e-9 1e-9 1e-9 
mass 20203 62.386 62.386 62.386 1e-9 1e-9 1e-9 
mass 20301 62.386 62.386 62.386 1e-9 1e-9 1e-9 
mass 20302 124.773 124.773 124.773 1e-9 1e-9 1e-9 
mass 20303 62.386 62.386 62.386 1e-9 1e-9 1e-9 
mass 20401 36.123 36.123 36.123 1e-9 1e-9 1e-9 
mass 20402 72.247 72.247 72.247 1e-9 1e-9 1e-9 
mass 20403 36.123 36.123 36.123 1e-9 1e-9 1e-9 
# define GRAVITY 
pattern Plain 1 Linear {
load 20101 0. -354.370 0. 0. 0. 0. 
load 20102 0. -708.739 0. 0. 0. 0. 
load 20103 0. -354.370 0. 0. 0. 0. 
load 20201 0. -612.009 0. 0. 0. 0. 
load 20202 0. -1224.019 0. 0. 0. 0. 
load 20203 0. -612.009 0. 0. 0. 0. 
load 20301 0. -612.009 0. 0. 0. 0. 
load 20302 0. -1224.019 0. 0. 0. 0. 
load 20303 0. -612.009 0. 0. 0. 0. 
load 20401 0. -354.370 0. 0. 0. 0. 
load 20402 0. -708.739 0. 0. 0. 0. 
load 20403 0. -354.370 0. 0. 0. 0. 
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