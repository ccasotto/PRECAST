model basic -ndm 2 -ndf 3 
set cover 0.030 
# nodal coordinates:
node 11 0.00 0.00 
node 21 21.96 0.00 
node 31 43.91 0.00 
node 12 0.00 8.19 
node 22 21.96 8.19 
node 32 43.91 8.19 
node 112 0.00 8.19 
node 122 21.96 8.19 
node 222 21.96 8.19 
node 132 43.91 8.19

#masses 
mass 12 14.510 14.510 1e-9 
mass 22 29.021 29.021 1e-9 
mass 32 14.510 14.510 1e-9 

# Fix Nodes 
fix 11 1 1 1 
fix 21 1 1 1 
fix 31 1 1 1 

#DEFINE THE ELEMENTS 
set BeamTransfTag 1 
set ColTransfTag 2 
geomTransf Linear $BeamTransfTag 
geomTransf PDelta $ColTransfTag 
set numBarsCol 2 
set barAreaCol [expr 0.001005/$numBarsCol] 

# Define material properties 
set IDconcCore 1; 
set IDconcU 3; 
set IDSteel 2; 
# CONCRETE 
# Core concrete (unconfined) 
uniaxialMaterial Concrete02  $IDconcCore -44841.82 -0.002500  -13.45  -0.010000 0.500000 0.000000 0.000000; 
# Core concrete (unconfined) 
uniaxialMaterial Concrete02  $IDconcU -44841.82 -0.002500  -13.45  -0.010000 0.500000 0.000000 0.000000;
# Reinforcing steel 
uniaxialMaterial Steel02 $IDSteel 452337 204306282 0.0062 20 0.925 0.15; 
uniaxialMaterial Elastic 100 [expr 500000000*1000];
uniaxialMaterial Elastic 101 5;

# Fiber section properties 
set y1 [expr 0.5000/2.0] 
set z1 [expr 0.5000/2.0] 
set coreY [expr $y1-$cover];
set coreZ [expr $z1-$cover];
set distY [expr $coreY*2/(8-1)]; 
section Fiber 1 {
patch rect $IDconcCore 30 5 [expr $cover-$y1] [expr $cover-$z1] [expr $y1-$cover] [expr $z1-$cover]
patch rect $IDconcCore 30 1  [expr -$y1] [expr $z1-$cover] $y1 $z1
patch rect $IDconcCore 30 1  [expr -$y1] [expr -$z1] $y1 [expr $cover-$z1]
patch rect $IDconcCore  1 5  [expr -$y1] [expr $cover-$z1] [expr $cover-$y1] [expr $z1-$cover]
patch rect $IDconcCore  1 5  [expr $y1-$cover] [expr $cover-$z1] $y1 [expr $z1-$cover]
layer straight $IDSteel $numBarsCol $barAreaCol [expr $y1-$cover] [expr $z1-$cover] [expr $y1-$cover] [expr $cover-$z1]
layer straight $IDSteel $numBarsCol $barAreaCol [expr $cover-$y1] [expr $z1-$cover] [expr $cover-$y1] [expr $cover-$z1]
layer straight $IDSteel 2 0.000154 [expr $y1-$cover-$distY*1] [expr $z1-$cover] [expr $y1-$cover-$distY*1] [expr $cover-$z1]; # Internal layer
layer straight $IDSteel 2 0.000154 [expr $y1-$cover-$distY*2] [expr $z1-$cover] [expr $y1-$cover-$distY*2] [expr $cover-$z1]; # Internal layer
layer straight $IDSteel 2 0.000154 [expr $y1-$cover-$distY*3] [expr $z1-$cover] [expr $y1-$cover-$distY*3] [expr $cover-$z1]; # Internal layer
layer straight $IDSteel 2 0.000154 [expr $y1-$cover-$distY*4] [expr $z1-$cover] [expr $y1-$cover-$distY*4] [expr $cover-$z1]; # Internal layer
layer straight $IDSteel 2 0.000154 [expr $y1-$cover-$distY*5] [expr $z1-$cover] [expr $y1-$cover-$distY*5] [expr $cover-$z1]; # Internal layer
layer straight $IDSteel 2 0.000154 [expr $y1-$cover-$distY*6] [expr $z1-$cover] [expr $y1-$cover-$distY*6] [expr $cover-$z1]; # Internal layer
}

set np 4
#element connectivity 
element nonlinearBeamColumn 1 11 12 $np 1 $ColTransfTag
element nonlinearBeamColumn 2 21 22 $np 1 $ColTransfTag
element nonlinearBeamColumn 3 31 32 $np 1 $ColTransfTag
element zeroLength 1112 112 12 -mat 100 100 101 -dir 1 2 3
element zeroLength 1122 122 22 -mat 100 100 101 -dir 1 2 3
element zeroLength 1222 22 222 -mat 100 100 101 -dir 1 2 3
element zeroLength 1132 132 32 -mat 100 100 101 -dir 1 2 3
element elasticBeamColumn 101 112 122 0.107000 33721655 0.013400 $BeamTransfTag 
element elasticBeamColumn 102 222 132 0.107000 33721655 0.013400 $BeamTransfTag 

# define GRAVITY 
pattern Plain 1 Linear {
   load  12   0.0  -263.7 0.0
   load  22   0.0  -527.4 0.0
   load  32   0.0  -263.7 0.0
}
set pi [expr 2.0*asin(1.0)];
set lambda [eigen  4];
set T [list [expr 2.0*$pi/pow([lindex $lambda 0],0.5)] [expr 2.0*$pi/pow([lindex $lambda 1],0.5)] [expr 2.0*$pi/pow([lindex $lambda 2],0.5)] [expr 2.0*$pi/pow([lindex $lambda 3],0.5)]]
     set outfile [open "period.txt" w]
     puts $outfile $T 
puts "T = $T s"

set Tol 1.0e-5; 
set NstepGravity 20; 
set DGravity [expr 1./$NstepGravity]; 
system BandGeneral
constraints Plain
numberer Plain
test NormDispIncr $Tol 10 3
algorithm Newton
integrator LoadControl $DGravity
analysis Static
analyze $NstepGravity 

puts "Done!"