source buildInelasticModel3D.tcl
loadConst -time 0.0 
set IDctrlNode 20101 
# Definizione degli output
recorder Node -file nodeDispX_po_n1.txt -node 20101 -dof 1 disp 
recorder Node -file nodeDispX_po_n2.txt -node 20102 -dof 1 disp 
recorder Node -file nodeDispX_po_n3.txt -node 20103 -dof 1 disp 
recorder Node -file nodeDispX_po_n4.txt -node 20201 -dof 1 disp 
recorder Node -file nodeDispX_po_n5.txt -node 20202 -dof 1 disp 
recorder Node -file nodeDispX_po_n6.txt -node 20203 -dof 1 disp 
recorder Node -file nodeDispX_po_n7.txt -node 20301 -dof 1 disp 
recorder Node -file nodeDispX_po_n8.txt -node 20302 -dof 1 disp 
recorder Node -file nodeDispX_po_n9.txt -node 20303 -dof 1 disp 
recorder Node -file nodeDispX_po_n10.txt -node 20401 -dof 1 disp 
recorder Node -file nodeDispX_po_n11.txt -node 20402 -dof 1 disp 
recorder Node -file nodeDispX_po_n12.txt -node 20403 -dof 1 disp 
recorder Node -file nodeReactionX_po.txt -nodeRange $SupportNodeFirst $SupportNodeLast -dof 1 reaction;
recorder Element -file SteelStressStrainXX.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber -$coreY -$coreZ $IDSteel stressStrain; 
recorder Element -file ConcreteStressStrainXX.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber $coreY 0 $IDconcCore stressStrain;

# Definizione dei carichi laterali
   pattern Plain  2  Linear {
 sp 20101 1 0.0020 
 sp 20102 1 0.0020 
 sp 20103 1 0.0020 
 sp 20201 1 0.0020 
 sp 20202 1 0.0020 
 sp 20203 1 0.0020 
 sp 20301 1 0.0020 
 sp 20302 1 0.0020 
 sp 20303 1 0.0020 
 sp 20401 1 0.0020 
 sp 20402 1 0.0020 
 sp 20403 1 0.0020 
}

# Definizione di alcune delle variabili utilizzate durante analisi 
 set nSteps 300;
set dirSpost 1;
set Tol 1.0e-5;
# Definizione delle opzioni di analisi 
constraints Transformation 
integrator LoadControl 1 
test NormDispIncr  $Tol     500      
algorithm  Newton -initial     
numberer  RCM  
system  BandGeneral
analysis Static

     set outfile [open "periodX.txt" w]
for {set i 1} {$i <= $nSteps} {incr i 1} {

set ok [analyze 1];
if {$ok != 0} {
puts "Trying Newton with Initial Tangent ..";
test NormDispIncr   $Tol 500 0
algorithm Newton -initial

set ok [analyze 1]
if {$ok == 0} {
test NormDispIncr  1.0e-5     500;
algorithm Newton
}

}
if {$ok != 0} {
puts "Trying Broyden .."
algorithm Broyden 8
set ok [analyze 1 ]
if {$ok == 0} {
test NormDispIncr  1.0e-5     500;
algorithm Newton
}

}
if {$ok != 0} {
puts "Trying NewtonWithLineSearch .."
algorithm NewtonLineSearch 0.8 
set ok [analyze 1]
if {$ok == 0} {
test NormDispIncr  1.0e-5     500;
algorithm Newton
}	
}
}; # end if

if {$ok == 0} {
puts "Done!"
}
