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
set LCol 7.37; 
set LBeam 19.67; 
set LGird 9.42; 
# define NODAL COORDINATES
set dlt 3.000000e-02;
set Dlevel 10000;
set Dframe 100;
set Djoint 10;
set DjointG 100000;
node 10101 0.00 0.00 0.00;
node 10102 19.67 0.00 0.00;
node 10103 39.34 0.00 0.00;
node 20101 0.00 7.37 0.00;
node 20102 19.67 7.37 0.00;
node 20103 39.34 7.37 0.00;
node 10201 0.00 0.00 9.42;
node 10202 19.67 0.00 9.42;
node 10203 39.34 0.00 9.42;
node 20201 0.00 7.37 9.42;
node 20202 19.67 7.37 9.42;
node 20203 39.34 7.37 9.42;
node 10301 0.00 0.00 18.84;
node 10302 19.67 0.00 18.84;
node 10303 39.34 0.00 18.84;
node 20301 0.00 7.37 18.84;
node 20302 19.67 7.37 18.84;
node 20303 39.34 7.37 18.84;
node 10401 0.00 0.00 28.26;
node 10402 19.67 0.00 28.26;
node 10403 39.34 0.00 28.26;
node 20401 0.00 7.37 28.26;
node 20402 19.67 7.37 28.26;
node 20403 39.34 7.37 28.26;
# define SPRING COORDINATES
node 20111 0.03 7.37 0.00;
node 20121 19.64 7.37 0.00;
node 20112 19.70 7.37 0.00;
node 20122 39.31 7.37 0.00;
node 20211 0.03 7.37 9.42;
node 20221 19.64 7.37 9.42;
node 20212 19.70 7.37 9.42;
node 20222 39.31 7.37 9.42;
node 20311 0.03 7.37 18.84;
node 20321 19.64 7.37 18.84;
node 20312 19.70 7.37 18.84;
node 20322 39.31 7.37 18.84;
node 20411 0.03 7.37 28.26;
node 20421 19.64 7.37 28.26;
node 20412 19.70 7.37 28.26;
node 20422 39.31 7.37 28.26;
# define SPRING Girder COORDINATES
node 120101 0.00 7.37 0.03;
node 220101 0.00 7.37 9.39;
node 120102 19.67 7.37 0.03;
node 220102 19.67 7.37 9.39;
node 120103 39.34 7.37 0.03;
node 220103 39.34 7.37 9.39;
node 120201 0.00 7.37 9.45;
node 220201 0.00 7.37 18.81;
node 120202 19.67 7.37 9.45;
node 220202 19.67 7.37 18.81;
node 120203 39.34 7.37 9.45;
node 220203 39.34 7.37 18.81;
node 120301 0.00 7.37 18.87;
node 220301 0.00 7.37 28.23;
node 120302 19.67 7.37 18.87;
node 220302 19.67 7.37 28.23;
node 120303 39.34 7.37 18.87;
node 220303 39.34 7.37 28.23;
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
set fc1C  -60040;
set fc1U  -52208;
set eps1U -0.002500;	
set fc2U    -16;	
set eps2U -0.005000;
# CONCRETE CONFINED 
set Ubig 1.e10; 
set Usmall [expr 1/$Ubig]; 
set fc -60040;
set Ec 40305087;
set eps1C -0.002500;
set fc2C    -18;
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
uniaxialMaterial Steel02 $IDSteel 501839.93 202950140 0.0124 20 0.925 0.15; 

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
set HSec 0.550; 
set BSec 0.550; 
set cover 0.030; 
set numBarsTop 5; 
set numBarsBot 5; 
