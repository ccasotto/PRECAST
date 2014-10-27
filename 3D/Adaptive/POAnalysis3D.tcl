source buildInelasticModel3D.tcl
loadConst -time 0.0 
set IDctrlNode 20101 
# Definizione degli output
set SupportNodeFirst [lindex $iSupportNode 0];						# ID: first support node
set SupportNodeLast [lindex $iSupportNode [expr [llength $iSupportNode]-1]];			# ID: last support node
recorder Node -file nodeDisp_po.txt -node $IDctrlNode -dof 1 3 disp
recorder Node -file nodeReaction_po.txt -nodeRange $SupportNodeFirst $SupportNodeLast -dof 1 3 reaction;
recorder Element -file BeamForce.txt -ele 1020101 globalForce;
recorder Element -file ColForce.txt -ele 20100 globalForce;
recorder Element -file ColDef.txt -ele 20100 section 1 deformation;
recorder Element -file GirderForce.txt -ele 2020101 globalForce;
recorder Element -file SteelStressStrainX.txt -eleRange 20100 20102 section 1 fiber -$coreY -$coreZ $IDSteel stressStrain; 
recorder Element -file ConcreteStressStrainX.txt -eleRange 20100 20102 section 1 fiber $coreY 0 $IDconcCore stressStrain;
recorder Element -file SteelStressStrainY.txt -ele 20100 section 1 fiber $coreY $coreZ $IDSteel stressStrain; 
recorder Element -file ConcreteStressStrainY.txt -ele 20100 section 1 fiber 0 -$coreZ $IDconcCore stressStrain;
recorder Element -file ConcreteStressStrainYC.txt -ele 20100 section 1 fiber 0 -$coverZ $IDconcCover stressStrain;

# Definizione dei carichi laterali
   pattern Plain  2  Linear {
 load 20101 5 0 0 0. 0. 0.  
 load 20102 5 0 0 0. 0. 0.  
 load 20201 5 0 0 0. 0. 0.  
 load 20202 5 0 0 0. 0. 0.  
}
   pattern Plain  3  Linear {
 load 20101 0 0 5 0. 0. 0.  
 load 20102 0 0 5 0. 0. 0.  
 load 20201 0 0 5 0. 0. 0.  
 load 20202 0 0 5 0. 0. 0.  
}
# Definizione di alcune delle variabili utilizzate durante analisi 
 set incrSpost 0.001;
 set nSteps 200;
set dirSpost 1 
set Tol 1.0e-5;
# Definizione delle opzioni di analisi 
constraints Transformation 
integrator DisplacementControl $IDctrlNode $dirSpost $incrSpost 
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
