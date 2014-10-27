model basic -ndm 2 -ndf 3 
source DisplayModel2D.tcl;
source DisplayPlane.tcl;
set cover 0.030 
# nodal coordinates:
node 11 0.00 0.00 
node 21 13.55 0.00 
node 31 27.10 0.00 
node 12 0.00 6.19 
node 22 13.55 6.19 
node 32 27.10 6.19 
node 112 0.00 6.19 
equalDOF  12 112 1 2; 
node 122 13.55 6.19 
equalDOF  22 122 1 2; 
node 132 27.10 6.19 
equalDOF  32 132 1 2; 
#masses 
mass 12 15.922 1e-9 1e-9 
mass 22 31.844 1e-9 1e-9 
mass 32 15.922 1e-9 1e-9 

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
set barAreaCol [expr 0.000804/$numBarsCol] 

# Define material properties 
set IDconcCore 1; 
set IDconcU 3; 
set IDSteel 2; 
# CONCRETE 
# Core concrete (confined) 
uniaxialMaterial Concrete02  $IDconcCore -57756.49 -0.002500  -17.33  -0.005000 0.500000 0.000000 0.000000; 
# Core concrete (unconfined) 
uniaxialMaterial Concrete02  $IDconcU -50223.03 -0.002500  -15.07  -0.005000 0.500000 0.000000 0.000000;
# Reinforcing steel 
uniaxialMaterial Steel02 $IDSteel 422085 198513375 0.0064 20 0.925 0.15; 

# Fiber section properties 
set y1 [expr 0.5000/2.0] 
set z1 [expr 0.5000/2.0] 
set coreY [expr $y1-$cover];
set coreZ [expr $z1-$cover];
set distY [expr $coreY*2/(4-1)]; 
section Fiber 1 {
patch rect $IDconcCore 30 5 [expr $cover-$y1] [expr $cover-$z1] [expr $y1-$cover] [expr $z1-$cover]
patch rect $IDconcCore 30 1  [expr -$y1] [expr $z1-$cover] $y1 $z1
patch rect $IDconcCore 30 1  [expr -$y1] [expr -$z1] $y1 [expr $cover-$z1]
patch rect $IDconcCore  1 5  [expr -$y1] [expr $cover-$z1] [expr $cover-$y1] [expr $z1-$cover]
patch rect $IDconcCore  1 5  [expr $y1-$cover] [expr $cover-$z1] $y1 [expr $z1-$cover]
layer straight $IDSteel $numBarsCol $barAreaCol [expr $y1-$cover] [expr $z1-$cover] [expr $y1-$cover] [expr $cover-$z1]
layer straight $IDSteel $numBarsCol $barAreaCol [expr $cover-$y1] [expr $z1-$cover] [expr $cover-$y1] [expr $cover-$z1]
layer straight $IDSteel 2 0.000201 [expr $y1-$cover-$distY*1] [expr $z1-$cover] [expr $y1-$cover-$distY*1] [expr $cover-$z1]; # Internal layer
layer straight $IDSteel 2 0.000201 [expr $y1-$cover-$distY*2] [expr $z1-$cover] [expr $y1-$cover-$distY*2] [expr $cover-$z1]; # Internal layer
}  

set np 4
#element connectivity 
element nonlinearBeamColumn 1 11 12 $np 1 $ColTransfTag
element nonlinearBeamColumn 2 21 22 $np 1 $ColTransfTag
element nonlinearBeamColumn 3 31 32 $np 1 $ColTransfTag
element elasticBeamColumn 101 112 122 40305087 0.107000 0.013400 $BeamTransfTag 
element elasticBeamColumn 102 122 132 40305087 0.107000 0.013400 $BeamTransfTag 

# define GRAVITY 
pattern Plain 1 Linear {
   load  12   0.0  -156.2 0.0
   load  22   0.0  -312.4 0.0
   load  32   0.0  -156.2 0.0
}
set pi [expr 2.0*asin(1.0)];
set lambda [eigen  4];
set T [list [expr 2.0*$pi/pow([lindex $lambda 0],0.5)] [expr 2.0*$pi/pow([lindex $lambda 1],0.5)] [expr 2.0*$pi/pow([lindex $lambda 2],0.5)] [expr 2.0*$pi/pow([lindex $lambda 3],0.5)]]
     set outfile [open "period.txt" w]
     puts $outfile $T 
puts "T = $T s"

# display deformed shape:
set ViewScale 5;
DisplayModel2D DeformedShape $ViewScale ;
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