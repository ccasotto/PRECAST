model basic -ndm 2 -ndf 3 
set cover 0.030 
# nodal coordinates:
node 11 0.00 0.00 
node 21 8.90 0.00 
node 31 17.80 0.00 
node 41 26.70 0.00 
node 51 35.60 0.00 
node 12 0.00 6.39 
node 22 8.90 6.39 
node 32 17.80 6.39 
node 42 26.70 6.39 
node 52 35.60 6.39 
node 112 0.00 6.39 
node 122 8.90 6.39 
node 222 8.90 6.39 
node 132 17.80 6.39 
node 232 17.80 6.39 
node 142 26.70 6.39 
node 242 26.70 6.39 
node 152 35.60 6.39 
#masses 
mass 12 17.666 17.666 1e-9 
mass 22 35.332 35.332 1e-9 
mass 32 35.332 35.332 1e-9 
mass 42 35.332 35.332 1e-9 
mass 52 17.666 17.666 1e-9 

# Fix Nodes 
fix 11 1 1 1 
fix 21 1 1 1 
fix 31 1 1 1 
fix 41 1 1 1 
fix 51 1 1 1 

#DEFINE THE ELEMENTS 
set BeamTransfTag 1 
set ColTransfTag 2 
geomTransf Linear $BeamTransfTag 
geomTransf PDelta $ColTransfTag 
set numBarsCol 2 
set barAreaCol [expr 0.001005/$numBarsCol] 

# Define MATERIALS -------------------------------------------------------------
set IDconcCore  1;
set IDSteel  2;
# CONCRETE UNCONFINED 
set fc  -55234;
set eps -0.002500;	
set fc2 -16570;	
set eps2 -0.010000;
set Ec 42272331;
set Ubig 1.e10; 
set Usmall [expr 1/$Ubig]; 
set lambda 0.005000;
set ftC    0.0;
set Ets    0.0;
 
# CONCRETE 
uniaxialMaterial Concrete01 $IDconcCore $fc $eps $fc2 $eps2;	
# STEEL 
# Reinforcing STEEL 
uniaxialMaterial Steel02 $IDSteel 522168.86 201517604 0.005 20 0.925 0.15; 
uniaxialMaterial Elastic 100 [expr 500000000*1000];
uniaxialMaterial Elastic 101 5;

# Fiber section properties 
# Fiber section properties 
set y1 [expr 0.5500/2.0] 
set z1 [expr 0.5000/2.0] 
set coreY [expr $y1-$cover];
set coreZ [expr $z1-$cover];
set distY [expr $coreY*2/(5-1)]; 
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
layer straight $IDSteel 2 0.000201 [expr $y1-$cover-$distY*3] [expr $z1-$cover] [expr $y1-$cover-$distY*3] [expr $cover-$z1]; # Internal layer
}  

set np 4
#element connectivity 
element nonlinearBeamColumn 1 11 12 $np 1 $ColTransfTag
element zeroLength 1112 112 12 -mat 100 100 101 -dir 1 2 3
element nonlinearBeamColumn 2 21 22 $np 1 $ColTransfTag
element zeroLength 1122 122 22 -mat 100 100 101 -dir 1 2 3
element zeroLength 1222 22 222 -mat 100 100 101 -dir 1 2 3
element nonlinearBeamColumn 3 31 32 $np 1 $ColTransfTag
element zeroLength 1132 132 32 -mat 100 100 101 -dir 1 2 3
element zeroLength 1232 32 232 -mat 100 100 101 -dir 1 2 3
element nonlinearBeamColumn 4 41 42 $np 1 $ColTransfTag
element zeroLength 1142 142 42 -mat 100 100 101 -dir 1 2 3
element zeroLength 1242 42 242 -mat 100 100 101 -dir 1 2 3
element nonlinearBeamColumn 5 51 52 $np 1 $ColTransfTag
element zeroLength 1152 152 52 -mat 100 100 101 -dir 1 2 3
element elasticBeamColumn 101 112 122 0.290000 42272331 0.022000 $BeamTransfTag 
element elasticBeamColumn 102 222 132 0.290000 42272331 0.022000 $BeamTransfTag 
element elasticBeamColumn 103 232 142 0.290000 42272331 0.022000 $BeamTransfTag 
element elasticBeamColumn 104 242 152 0.290000 42272331 0.022000 $BeamTransfTag 

# define GRAVITY 
pattern Plain 1 Linear {
   load  12   0.0  -173.3 0.0
   load  22   0.0  -346.6 0.0
   load  32   0.0  -346.6 0.0
   load  42   0.0  -346.6 0.0
   load  52   0.0  -173.3 0.0
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