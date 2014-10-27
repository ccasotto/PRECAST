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
set LCol 6.14; 
set LBeam 9.01; 
set LGird 8.31; 
# define NODAL COORDINATES
set dlt 3.000000e-002;
set Dlevel 10000;
set Dframe 100;
set Djoint 10;
set DjointG 100000;
node 10101 0.00 0.00 0.00;
node 10102 9.01 0.00 0.00;
node 10103 18.01 0.00 0.00;
node 20101 0.00 6.14 0.00;
node 20102 9.01 6.14 0.00;
node 20103 18.01 6.14 0.00;
node 10201 0.00 0.00 8.31;
node 10202 9.01 0.00 8.31;
node 10203 18.01 0.00 8.31;
node 20201 0.00 6.14 8.31;
node 20202 9.01 6.14 8.31;
node 20203 18.01 6.14 8.31;
node 10301 0.00 0.00 16.62;
node 10302 9.01 0.00 16.62;
node 10303 18.01 0.00 16.62;
node 20301 0.00 6.14 16.62;
node 20302 9.01 6.14 16.62;
node 20303 18.01 6.14 16.62;
node 10401 0.00 0.00 24.94;
node 10402 9.01 0.00 24.94;
node 10403 18.01 0.00 24.94;
node 20401 0.00 6.14 24.94;
node 20402 9.01 6.14 24.94;
node 20403 18.01 6.14 24.94;
# define SPRING COORDINATES
node 20111 0.03 6.14 0.00;
node 20121 8.98 6.14 0.00;
node 20112 9.04 6.14 0.00;
node 20122 17.98 6.14 0.00;
node 20211 0.03 6.14 8.31;
node 20221 8.98 6.14 8.31;
node 20212 9.04 6.14 8.31;
node 20222 17.98 6.14 8.31;
node 20311 0.03 6.14 16.62;
node 20321 8.98 6.14 16.62;
node 20312 9.04 6.14 16.62;
node 20322 17.98 6.14 16.62;
node 20411 0.03 6.14 24.94;
node 20421 8.98 6.14 24.94;
node 20412 9.04 6.14 24.94;
node 20422 17.98 6.14 24.94;
# define SPRING Girder COORDINATES
node 120101 0.00 6.14 0.03;
node 220101 0.00 6.14 8.28;
node 120102 9.01 6.14 0.03;
node 220102 9.01 6.14 8.28;
node 120103 18.01 6.14 0.03;
node 220103 18.01 6.14 8.28;
node 120201 0.00 6.14 8.34;
node 220201 0.00 6.14 16.59;
node 120202 9.01 6.14 8.34;
node 220202 9.01 6.14 16.59;
node 120203 18.01 6.14 8.34;
node 220203 18.01 6.14 16.59;
node 120301 0.00 6.14 16.65;
node 220301 0.00 6.14 24.91;
node 120302 9.01 6.14 16.65;
node 220302 9.01 6.14 24.91;
node 120303 18.01 6.14 16.65;
node 220303 18.01 6.14 24.91;
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
set IDconcCover  3;
set IDSteel  2;
# CONCRETE UNCONFINED 
set fc1C  -42953;
set fc1U  -37350;
set eps1U -0.002500;	
set fc2U    -11;	
set eps2U -0.005000;
# CONCRETE CONFINED 
set Ubig 1.e10; 
set Usmall [expr 1/$Ubig]; 
set fc -42953;
set Ec 38236762;
set eps1C -0.002500;
set fc2C    -13;
set eps2C -0.005000;
set lambda 0.500000;
set ftC      0;
set Ets      0;
	set nu 0.2;
	set Gc [expr $Ec/2./[expr 1+$nu]]; 
	set J $Ubig; 
# CONCRETE 
# Core concrete (confined) 
uniaxialMaterial Concrete02 $IDconcCore $fc1C $eps1C $fc2C $eps2C $lambda $ftC $Ets;	# Core concrete (confined) 
# Core concrete (unconfined) 
uniaxialMaterial Concrete02 $IDconcCover $fc1U $eps1U $fc2U $eps2U $lambda $ftC $Ets;	# Cover concrete (unconfined) 
# Reinforcing STEEL 
uniaxialMaterial Steel02 $IDSteel 220000.00 194864073 0.005 20 0.925 0.15; 

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
set HSec 0.600; 
set BSec 0.550; 
set cover 0.030; 
set numBarsTop 4; 
set numBarsBot 4; 
set numBarsIntTot 8; 
set barArea 0.000314; 
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
	# define reinforcing fibers 
fiber 0.2700 0.2450 $barArea $IDSteel; # Top fiber
fiber -0.2700 0.2450 $barArea $IDSteel; # Bottom fiber
fiber 0.2700 0.0817 $barArea $IDSteel; # Top fiber
fiber -0.2700 0.0817 $barArea $IDSteel; # Bottom fiber
fiber 0.2700 -0.0817 $barArea $IDSteel; # Top fiber
fiber -0.2700 -0.0817 $barArea $IDSteel; # Bottom fiber
fiber 0.2700 -0.2450 $barArea $IDSteel; # Top fiber
fiber -0.2700 -0.2450 $barArea $IDSteel; # Bottom fiber
fiber  0.0900 0.2450 $barArea $IDSteel; # left fiber
fiber  0.0900 -0.2450 $barArea $IDSteel; # right fiber
fiber  -0.0900 0.2450 $barArea $IDSteel; # left fiber
fiber  -0.0900 -0.2450 $barArea $IDSteel; # right fiber
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
		element nonlinearBeamColumn 3020211 20201 20211 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020221 20221 20202 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020212 20202 20212 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020222 20222 20203 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020311 20301 20311 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020321 20321 20302 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020312 20302 20312 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020322 20322 20303 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020411 20401 20411 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020421 20421 20402 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020412 20402 20412 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 3020422 20422 20403 $numIntgrPts $SpringSecTag $IDBeamTransf 
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
		element nonlinearBeamColumn 4120103 20103 120103 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4210103 220103 20203  $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4120201 20201 120201 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4210201 220201 20301  $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4120202 20202 120202 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4210202 220202 20302  $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4120203 20203 120203 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4210203 220203 20303  $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4120301 20301 120301 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4210301 220301 20401  $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4120302 20302 120302 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4210302 220302 20402  $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4120303 20303 120303 $numIntgrPts $SpringSecTag $IDBeamTransf 
		element nonlinearBeamColumn 4210303 220303 20403  $numIntgrPts $SpringSecTag $IDBeamTransf 
#MASSES 
mass 20101 10.042 10.042 10.042 1e-9 1e-9 1e-9 
mass 20102 20.084 20.084 20.084 1e-9 1e-9 1e-9 
mass 20103 10.042 10.042 10.042 1e-9 1e-9 1e-9 
mass 20201 18.432 18.432 18.432 1e-9 1e-9 1e-9 
mass 20202 36.863 36.863 36.863 1e-9 1e-9 1e-9 
mass 20203 18.432 18.432 18.432 1e-9 1e-9 1e-9 
mass 20301 18.432 18.432 18.432 1e-9 1e-9 1e-9 
mass 20302 36.863 36.863 36.863 1e-9 1e-9 1e-9 
mass 20303 18.432 18.432 18.432 1e-9 1e-9 1e-9 
mass 20401 10.042 10.042 10.042 1e-9 1e-9 1e-9 
mass 20402 20.084 20.084 20.084 1e-9 1e-9 1e-9 
mass 20403 10.042 10.042 10.042 1e-9 1e-9 1e-9 
# define GRAVITY 
pattern Plain 1 Linear {
load 20101 0. 0. 0. 0. 0. 0. 
load 20102 0. [expr -197.023 + (-98.512)*2] 0. 0. 0. 0. 
load 20103 0. 0. 0. 0. 0. 0. 
load 20201 0. 0. 0. 0. 0. 0. 
load 20202 0. [expr -361.628 + (-180)*2] 0. 0. 0. 0. 
load 20203 0. 0. 0. 0. 0. 0. 
load 20301 0. 0 0. 0. 0. 0. 
load 20302 0. [expr -361.628 + (-180)*2] 0. 0. 0. 0. 
load 20303 0. 0 0. 0. 0. 0. 
load 20401 0. 0 0. 0. 0. 0. 
load 20402 0. [expr -197.023 + (-98.512)*2] 0. 0. 0. 0. 
load 20403 0. 0 0. 0. 0. 0. 
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

recorder Node -file nodeEigen1_n2.txt -node 20102 -dof 1 2 3 "eigen 1" 
recorder Node -file nodeEigen2_n2.txt -node 20102 -dof 1 2 3 "eigen 2" 
recorder Node -file nodeEigen1_n5.txt -node 20202 -dof 1 2 3 "eigen 1" 
recorder Node -file nodeEigen2_n5.txt -node 20202 -dof 1 2 3 "eigen 2" 
recorder Node -file nodeEigen1_n8.txt -node 20302 -dof 1 2 3 "eigen 1" 
recorder Node -file nodeEigen2_n8.txt -node 20302 -dof 1 2 3 "eigen 2" 
recorder Node -file nodeEigen1_n11.txt -node 20402 -dof 1 2 3 "eigen 1" 
recorder Node -file nodeEigen2_n11.txt -node 20402 -dof 1 2 3 "eigen 2" 

puts goGravity 
# Gravity-analysis parameters -- load-controlled static analysis 
set Tol 1.0e-8; 
set NstepGravity 1; 
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