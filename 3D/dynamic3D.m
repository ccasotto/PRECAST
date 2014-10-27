file = fopen('dynamic.tcl', 'w+');
fprintf(file,'source buildInelasticModel3D.tcl;\n');
fprintf(file,'source DisplayModel3D.tcl;\n');
fprintf(file,'source DisplayPlane.tcl;\n');
fprintf(file,'puts "Gravity Analysis Completed"\n');
fprintf(file,'loadConst -time 0.0\n');

fprintf(file,'set maxSteps %5.0f\n',maxSteps);
fprintf(file,'set dt %1.3f \n',dt);
fprintf(file,'# SET RECORDERS \n');
fprintf(file,'#Create a recorder to monitor nodal displacements \n');
node = 1;
for  frame = 1:asset.noBayZ+1
	for pier = 1:asset.noBays+1
		level = 2;
		TopNode(node) = level*10000+frame*100+pier;
		node = node+1;
	end
end
	  
for node = 1:(asset.noBayZ+1)*(asset.noBays+1)
	fprintf(file,'recorder Node -file nodeDisp_dynamic_');
	fprintf(file,'n%i',node);
	fprintf(file,'.txt -node %i -dof 1 2 3 disp \n',TopNode(node));
end
fprintf(file,'recorder Node -file nodeReaction_dynamic.txt -nodeRange $SupportNodeFirst $SupportNodeLast -dof 1 2 3 4 5 6 reaction \n');
fprintf(file,'recorder Element -file ForceCol_dynamic.txt -eleRange $ColumnFirst $ColumnLast localForce;\n');
fprintf(file,'recorder Element -file DeformCol_dynamic.txt -eleRange $ColumnFirst $ColumnLast section 1 deformation;\n');
% fprintf(file,'recorder Element -file CStressCol_F1.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber -$coreY $coreZ $IDconcCore stressStrain;\n' );
% fprintf(file,'recorder Element -file CStressCol_F2.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber -$coreY -$coreZ $IDconcCore stressStrain;\n' );
% fprintf(file,'recorder Element -file CStressCol_F3.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber $coreY -$coreZ $IDconcCore stressStrain;\n' );
% fprintf(file,'recorder Element -file CStressCol_F4.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber $coreY $coreZ $IDconcCore stressStrain;\n' );
% fprintf(file,'recorder Element -file SStressCol_F1.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber -$coreY $coreZ $IDSteel stressStrain;\n' );
% fprintf(file,'recorder Element -file SStressCol_F2.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber -$coreY -$coreZ $IDSteel stressStrain;\n' );
% fprintf(file,'recorder Element -file SStressCol_F3.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber $coreY -$coreZ $IDSteel stressStrain;\n' );
% fprintf(file,'recorder Element -file SStressCol_F4.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber $coreY $coreZ $IDSteel stressStrain;\n' );

TF = strcmp(units,'cm/s/s');
if TF == 1
	factor = 0.01;
else TF2 = strcmp(units,'m/s/s');
	if TF2 == 1
	factor = 1; %the units are in m/s/s
	else factor = 9.81; %the units are g
	end
end

fprintf(file,'set IDloadTag 400;	# for uniformSupport excitation\n');
fprintf(file,'set iGMfile "gmr0.tcl gmr1.tcl gmr2.tcl" ;		# ground-motion filenames, should be different files\n');
fprintf(file,'set iGMdirection "2 1 3";			# ground-motion direction\n');
fprintf(file,'set iGMfact "%1.2f %1.2f %1.2f"; \n', factor*fz,factor*fx,factor*fy);

fprintf(file,'foreach GMdirection $iGMdirection GMfile $iGMfile GMfact $iGMfact {\n');
fprintf(file,'	incr IDloadTag;\n');
fprintf(file,'	set AccelSeries "Series -dt $dt -filePath $GMfile -factor  $GMfact";		# time series information\n');
fprintf(file,'	pattern UniformExcitation  $IDloadTag  $GMdirection -accel  $AccelSeries  ;	# create Unifform excitation\n');
fprintf(file,'}\n');

fprintf(file,'# set damping based on first eigen mode\n');
fprintf(file,'	set pi [expr 2.0*asin(1.0)];						# Definition of pi\n');
fprintf(file,'set nEigenI 1;										# mode i = 1\n');
fprintf(file,'set nEigenJ 2;										# mode j = 2\n');
fprintf(file,'set lambdaN [eigen [expr $nEigenJ]];				    # eigenvalue analysis for nEigenJ modes\n');
fprintf(file,'set lambdaI [lindex $lambdaN [expr 0]];				# eigenvalue mode i = 1\n');
fprintf(file,'set lambdaJ [lindex $lambdaN [expr $nEigenJ-1]];	    # eigenvalue mode j = 2\n');
fprintf(file,'set w1 [expr pow($lambdaI,0.5)];					    # w1 (1st mode circular frequency)\n');
fprintf(file,'set w2 [expr pow($lambdaJ,0.5)];					    # w2 (2nd mode circular frequency)\n');
fprintf(file,'set T1 [expr 2.0*$pi/$w1];							# 1st mode period of the structure\n');
fprintf(file,'set T2 [expr 2.0*$pi/$w2];							# 2nd mode period of the structure\n');

fprintf(file,'set zeta 0.02;					# percentage of critical damping\n');
fprintf(file,'set a0 [expr $zeta*2.0/($w1)];	# mass damping coefficient based on first and second modes\n');
% fprintf(file,'set a1 [expr $zeta*2.0/($w1)];	# stiffness damping coefficient based on first and second modes\n');
% fprintf(file,'puts $a0 \n');
% fprintf(file,'puts $a1 \n');
fprintf(file,'rayleigh 0.0 0.0 0.0 $a0;\n');

fprintf(file,'set ok 0 \n');
fprintf(file,'# create the analysis\n');

fprintf(file,'constraints Plain\n');
fprintf(file,'numberer Plain\n');
fprintf(file,'system BandGeneral\n');
fprintf(file,'test NormDispIncr 1.0e-3  800  \n');
fprintf(file,'algorithm Newton\n');
fprintf(file,'integrator Newmark 0.5 0.25\n');
fprintf(file,'analysis Transient;\n');
fprintf(file,'set step 1\n');

fprintf(file,'while {$ok == 0} { \n');
fprintf(file,'	set ok [analyze 1 $dt]\n');
fprintf(file,'	# if the analysis fails try initial tangent iteration \n');
fprintf(file,'	if {$ok != 0} { \n');
fprintf(file,'	    puts "regular newton failed .. lets try an initail stiffness for this step" \n');
fprintf(file,'	    test NormDispIncr 1.0e-3  800  \n');
fprintf(file,'	    algorithm ModifiedNewton -initial \n');
fprintf(file,'	    set ok [analyze 1 %1.5f] \n',dt);
fprintf(file,'	    if {$ok == 0} {puts "that worked .. back to regular newton"} \n');
fprintf(file,'	    test NormDispIncr 1.0e-3  100 \n');
fprintf(file,'	    algorithm Newton \n');
fprintf(file,'	} \n');

fprintf(file,'	if {$ok != 0} { \n');
fprintf(file,'	algorithm NewtonLineSearch 0.8\n');
fprintf(file,'	    set ok [analyze 1 $dt] \n');
fprintf(file,'	    if {$ok == 0} {puts "that worked .. back to regular newton"} \n');
fprintf(file,'	    test NormDispIncr 1.0e-3  100 \n');
fprintf(file,'	    algorithm Newton \n');
fprintf(file,'	} \n');

fprintf(file,'	if {$ok != 0} { \n');
fprintf(file,'	algorithm Broyden\n');
fprintf(file,'	test NormDispIncr 1.0e-4 50 0 \n');
fprintf(file,'	    set ok [analyze 1 $dt] \n');
fprintf(file,'	    if {$ok == 0} {puts "that worked .. back to regular newton"} \n');
fprintf(file,'	    test NormDispIncr 1.0e-3  100 \n');
fprintf(file,'	    algorithm Newton \n');
fprintf(file,'	} \n');

fprintf(file,'	set step [expr $step+1]\n');
fprintf(file,'	if {$step > $maxSteps} { \n');
fprintf(file,'	    break\n');
fprintf(file,'	}\n');
fprintf(file,'} \n');

fprintf(file,'set outfile [open "dynamicResult.txt" w]\n');

fprintf(file,'if {$ok != 0} { \n');
fprintf(file,'     puts $outfile "KO" \n');
fprintf(file,'     puts "Dynamic Analysis Failed" \n');
fprintf(file,'}\n'); 

fprintf(file,'if {$ok == 0} { \n');
fprintf(file,'     puts $outfile "OK" \n');
fprintf(file,'     puts "Dynamic Analysis Completed" \n');
fprintf(file,'}\n'); 
fclose(file);
eval(['!',a,'\OpenSees.exe',' ','dynamic.tcl']) 
