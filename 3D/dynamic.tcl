source buildInelasticModel3D.tcl;
source DisplayModel3D.tcl;
source DisplayPlane.tcl;
puts "Gravity Analysis Completed"
loadConst -time 0.0
set maxSteps  3627
set dt 0.010 
# SET RECORDERS 
#Create a recorder to monitor nodal displacements 
recorder Node -file tmp/nodeDisp_dynamic_n1.txt -node 20101 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_dynamic_n2.txt -node 20102 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_dynamic_n3.txt -node 20103 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_dynamic_n4.txt -node 20201 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_dynamic_n5.txt -node 20202 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_dynamic_n6.txt -node 20203 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_dynamic_n7.txt -node 20301 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_dynamic_n8.txt -node 20302 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_dynamic_n9.txt -node 20303 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_dynamic_n10.txt -node 20401 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_dynamic_n11.txt -node 20402 -dof 1 2 3 disp 
recorder Node -file tmp/nodeDisp_dynamic_n12.txt -node 20403 -dof 1 2 3 disp 
recorder Node -file tmp/nodeAccX_dynamic.txt -node 20101  20102  20103  20201  20202  20203  20301  20302  20303  20401  20402  20403 -dof 1 accel 
recorder Node -file tmp/nodeAccY_dynamic.txt -node 20101  20102  20103  20201  20202  20203  20301  20302  20303  20401  20402  20403 -dof 3 accel 
recorder Node -file tmp/nodeReaction_dynamic.txt -nodeRange $SupportNodeFirst $SupportNodeLast -dof 1 2 3 4 5 6 reaction 
recorder Element -file tmp/ForceCol_dynamic.txt -eleRange $ColumnFirst $ColumnLast localForce;
recorder Element -file tmp/DeformCol_dynamic.txt -eleRange $ColumnFirst $ColumnLast section 1 deformation;
set IDloadTag 400;	# for uniformSupport excitation
set iGMfile "gmr0.tcl gmr1.tcl gmr2.tcl" ;		# ground-motion filenames, should be different files
set iGMdirection "2 1 3";			# ground-motion direction
set iGMfact "9.81 9.81 9.81"; 
foreach GMdirection $iGMdirection GMfile $iGMfile GMfact $iGMfact {
	incr IDloadTag;
	set AccelSeries "Series -dt $dt -filePath $GMfile -factor  $GMfact";		# time series information
	pattern UniformExcitation  $IDloadTag  $GMdirection -accel  $AccelSeries  ;	# create Unifform excitation
}
# set damping based on first eigen mode
	set pi [expr 2.0*asin(1.0)];						# Definition of pi
set nEigenI 1;										# mode i = 1
set nEigenJ 2;										# mode j = 2
set lambdaN [eigen [expr $nEigenJ]];				    # eigenvalue analysis for nEigenJ modes
set lambdaI [lindex $lambdaN [expr 0]];				# eigenvalue mode i = 1
set lambdaJ [lindex $lambdaN [expr $nEigenJ-1]];	    # eigenvalue mode j = 2
set w1 [expr pow($lambdaI,0.5)];					    # w1 (1st mode circular frequency)
set w2 [expr pow($lambdaJ,0.5)];					    # w2 (2nd mode circular frequency)
set T1 [expr 2.0*$pi/$w1];							# 1st mode period of the structure
set T2 [expr 2.0*$pi/$w2];							# 2nd mode period of the structure
set zeta 0.02;					# percentage of critical damping
set a0 [expr $zeta*2.0/($w1)];	# mass damping coefficient based on first and second modes
rayleigh 0.0 0.0 0.0 $a0;
set ok 0 
# create the analysis
constraints Plain
numberer Plain
system BandGeneral
test NormDispIncr 1.0e-3  800  
algorithm Newton
integrator Newmark 0.5 0.25
analysis Transient;
set step 1
while {$ok == 0} { 
	set ok [analyze 1 $dt]
	# if the analysis fails try initial tangent iteration 
	if {$ok != 0} { 
	    puts "regular newton failed .. lets try an initail stiffness for this step" 
	    test NormDispIncr 1.0e-3  800  
	    algorithm ModifiedNewton -initial 
	    set ok [analyze 1 0.01000] 
	    if {$ok == 0} {puts "that worked .. back to regular newton"} 
	    test NormDispIncr 1.0e-3  100 
	    algorithm Newton 
	} 
	set step [expr $step+1]
	if {$step > $maxSteps} { 
	    break
	}
} 
set outfile [open "dynamicResult.txt" w]
if {$ok != 0} { 
     puts $outfile "KO" 
     puts "Dynamic Analysis Failed" 
}
if {$ok == 0} { 
     puts $outfile "OK" 
     puts "Dynamic Analysis Completed" 
}
