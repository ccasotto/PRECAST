source buildInelasticModel.tcl
loadConst -time 0.0 
# Definizione degli output
recorder Node -file tmp/nodeDisp_po.txt -node 52 -dof 1 disp
recorder Node -file tmp/nodeReaction_po.txt -node 11 21 31 41 51 -dof 1 reaction 
recorder Element -file tmp/SteelStressStrain.txt -ele 1 section 1 fiber [expr -$cover+$y1] [expr $z1-$cover] $IDSteel stressStrain; 
recorder Element -file tmp/ConcreteStressStrain.txt -ele 1 section 1 fiber [expr $cover-$y1] 0 $IDconcCore stressStrain;
recorder Element -file tmp/ForceCol.txt -ele 2 globalForce;

# Definizione dei carichi laterali
   pattern Plain  2  Linear {
 load   12 10 0. 0.  
 load   22 10 0. 0.  
 load   32 10 0. 0.  
 load   42 10 0. 0.  
 load   52 10 0. 0.  
}

# Definizione di alcune delle variabili utilizzate durante analisi 
 set incrSpost 0.001;
 set nSteps 300;
set Tol 1.0e-5;
# Definizione delle opzioni di analisi 
constraints Transformation 
integrator DisplacementControl 12 1 $incrSpost 
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
