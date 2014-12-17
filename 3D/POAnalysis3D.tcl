source buildInelasticModel3D.tcl
loadConst -time 0.0 
set IDctrlNode 20101 
# Definizione degli output
recorder Node -file tmp/nodeDisp_po_n1.txt -node 20101 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_po_n2.txt -node 20102 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_po_n3.txt -node 20103 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_po_n4.txt -node 20201 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_po_n5.txt -node 20202 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_po_n6.txt -node 20203 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_po_n7.txt -node 20301 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_po_n8.txt -node 20302 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_po_n9.txt -node 20303 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_po_n10.txt -node 20401 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_po_n11.txt -node 20402 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_po_n12.txt -node 20403 -dof 1 2 3 disp 
recorder Node -file tmp/nodeReaction_po.txt -nodeRange $SupportNodeFirst $SupportNodeLast -dof 1 2 3 reaction;
recorder Element -file tmp/ColForce.txt -ele 20100 globalForce;
recorder Element -file tmp/ColDef.txt -ele 20100 section 1 deformation;
recorder Element -file tmp/SteelStressStrainX.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber -$coreY -$coreZ $IDSteel stressStrain; 
recorder Element -file tmp/ConcreteStressStrainX.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber $coreY 0 $IDconcCore stressStrain;
recorder Element -file tmp/SteelStressStrainY.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber $coreY $coreZ $IDSteel stressStrain; 
recorder Element -file tmp/ConcreteStressStrainY.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber 0 -$coreZ $IDconcCore stressStrain;

# Definizione dei carichi laterali
   pattern Plain  2  Linear {
 sp 20101 1 0.0010 
 sp 20101 3 0.0010 
 sp 20102 1 0.0010 
 sp 20102 3 0.0010 
 sp 20103 1 0.0010 
 sp 20103 3 0.0010 
 sp 20201 1 0.0010 
 sp 20201 3 0.0010 
 sp 20202 1 0.0010 
 sp 20202 3 0.0010 
 sp 20203 1 0.0010 
 sp 20203 3 0.0010 
 sp 20301 1 0.0010 
 sp 20301 3 0.0010 
 sp 20302 1 0.0010 
 sp 20302 3 0.0010 
 sp 20303 1 0.0010 
 sp 20303 3 0.0010 
 sp 20401 1 0.0010 
 sp 20401 3 0.0010 
 sp 20402 1 0.0010 
 sp 20402 3 0.0010 
 sp 20403 1 0.0010 
 sp 20403 3 0.0010 
}

# Definizione di alcune delle variabili utilizzate durante analisi 
 set nSteps 2.551890e+02;
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

     set outfile [open "period.txt" w]
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
