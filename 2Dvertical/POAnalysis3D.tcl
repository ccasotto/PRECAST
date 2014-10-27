source buildInelasticModel3D.tcl
source DisplayModel2D.tcl
source DisplayPlane.tcl
set IDctrlNode 20101 
loadConst -time 0.0 
# Definizione degli output
recorder Node -file nodeDisp_po_n1.txt -node 20101 -dof 1 disp 
recorder Node -file nodeDisp_po_n2.txt -node 20102 -dof 1 disp 
recorder Node -file nodeDisp_po_n3.txt -node 20103 -dof 1 disp 
recorder Node -file nodeReaction_po.txt -nodeRange $SupportNodeFirst $SupportNodeLast -dof 1 reaction;
recorder Element -file SteelStressStrain.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber -$coreY -$coreZ $IDSteel stressStrain; 
recorder Element -file ConcreteStressStrain.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber $coreY 0 $IDconcCore stressStrain;
recorder Element -file ForceColSec4.txt -ele 20100 globalForce;

# Definizione dei carichi laterali
   pattern Plain  2  Linear {
 load 20101 10 0.0 0.0 0.0 0.0 0.0 
 load 20102 10 0.0 0.0 0.0 0.0 0.0 
 load 20103 10 0.0 0.0 0.0 0.0 0.0 
}

# Definizione di alcune delle variabili utilizzate durante analisi 
 set incrSpost 0.001;
 set nSteps 300;
set Tol 1.0e-5;
# Definizione delle opzioni di analisi 
constraints Transformation 
integrator DisplacementControl $IDctrlNode 1 $incrSpost 
test NormDispIncr  $Tol     500      
algorithm  Newton -initial     
numberer  RCM  
system  BandGeneral
analysis Static

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
