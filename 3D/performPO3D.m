function performPO3D(asset,dir)
    a=pwd;
    file = fopen('POAnalysis3D.tcl', 'w+');
    fprintf(file,'source buildInelasticModel3D.tcl\n');
 	fprintf(file,'loadConst -time 0.0 \n');
	fprintf(file,'set IDctrlNode %i \n',(asset.noStoreys+1)*10000+101);
	fprintf(file,'# Definizione degli output\n');
	node = 1;
for  frame = 1:asset.noBayZ+1
	for pier = 1:asset.noBays+1
		level = 2;
		TopNode(node) = level*10000+frame*100+pier;
		node = node+1;
	end
end
	  
for node = 1:(asset.noBayZ+1)*(asset.noBays+1)
	fprintf(file,'recorder Node -file nodeDisp_po_');
	fprintf(file,'n%i',node);
	fprintf(file,'.txt -node %i -dof 1 2 3 disp \n',TopNode(node));
end
	fprintf(file,'recorder Node -file nodeReaction_po.txt -nodeRange $SupportNodeFirst $SupportNodeLast -dof 1 2 3 reaction;\n');
% 	fprintf(file,'recorder Element -file BeamForce.txt -ele 1020101 globalForce;\n');
	fprintf(file,'recorder Element -file ColForce.txt -ele 20100 globalForce;\n');
	fprintf(file,'recorder Element -file ColDef.txt -ele 20100 section 1 deformation;\n');
% 	fprintf(file,'recorder Element -file GirderForce.txt -ele 2020101 globalForce;\n');	
	fprintf(file,'recorder Element -file SteelStressStrainX.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber -$coreY -$coreZ $IDSteel stressStrain; \n');
    fprintf(file,'recorder Element -file ConcreteStressStrainX.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber $coreY 0 $IDconcCore stressStrain;\n');
    fprintf(file,'recorder Element -file SteelStressStrainY.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber $coreY $coreZ $IDSteel stressStrain; \n');
    fprintf(file,'recorder Element -file ConcreteStressStrainY.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber 0 -$coreZ $IDconcCore stressStrain;\n');
	fprintf(file,'\n');
	
	incrX = 0.001;
	incrY = incrX*(asset.ColW/asset.ColD)^2;
	
	fprintf(file,'# Definizione dei carichi laterali\n');
	fprintf(file,'   pattern Plain  2  Linear {\n');
	for level = 2:asset.noStoreys+1
		for frame=1:(asset.noBayZ+1)
			for pier = 1:asset.noBays+1;
			fprintf(file,' sp %i %i %1.4f \n',level*10000+frame*100+pier, dir(1)*1, incrX);
			fprintf(file,' sp %i %i %1.4f \n',level*10000+frame*100+pier, dir(3)*3, incrY);
			end
		end
	end
	fprintf(file,'}\n');
    fprintf(file,'\n');
	
% 	fprintf(file,'   pattern Plain  3  Linear {\n');
% 	for level = 2:asset.noStoreys+1
% 		for frame=1:(asset.noBayZ+1)
% 			for pier = 1:asset.noBays+1;
% 			fprintf(file,' sp %i %i %1.4f \n',level*10000+frame*100+pier, dir(3)*3, incrY);
% 			end
% 		end
% 	end
% 	fprintf(file,'}\n');
%     fprintf(file,'\n');
	
	fprintf(file,'# Definizione di alcune delle variabili utilizzate durante analisi \n');
	fprintf(file,' set nSteps %i;\n', 0.035*asset.ColH_ground/incrX*dir(1));
	fprintf(file,'set dirSpost %i;\n', dir(1));
 	fprintf(file,'set Tol 1.0e-5;\n');
    fprintf(file,'# Definizione delle opzioni di analisi \n');
    fprintf(file,'constraints Transformation \n');
	fprintf(file,'integrator LoadControl 1 \n');
%     fprintf(file,'integrator DisplacementControl $IDctrlNode $dirSpost $incrSpost \n');
    fprintf(file,'test NormDispIncr  $Tol     500      \n'); 
    fprintf(file,'algorithm  Newton -initial     \n');
    fprintf(file,'numberer  RCM  \n');
    fprintf(file,'system  BandGeneral\n');
    fprintf(file,'analysis Static\n');
	fprintf(file,'\n');
	fprintf(file,'     set outfile [open "period.txt" w]\n');
	
	fprintf(file,'for {set i 1} {$i <= $nSteps} {incr i 1} {\n');
	fprintf(file,'\n');
	fprintf(file,'set ok [analyze 1];\n');
			fprintf(file,'if {$ok != 0} {\n');
			fprintf(file,'puts "Trying Newton with Initial Tangent ..";\n');
				fprintf(file,'test NormDispIncr   $Tol 500 0\n');
				fprintf(file,'algorithm Newton -initial\n');
				fprintf(file,'\n');
				
				fprintf(file,'set ok [analyze 1]\n');
				fprintf(file,'if {$ok == 0} {\n');
				fprintf(file,'test NormDispIncr  1.0e-5     500;\n');
				fprintf(file,'algorithm Newton\n');
				fprintf(file,'}\n');
				fprintf(file,'\n');
				
			fprintf(file,'}\n');
			fprintf(file,'if {$ok != 0} {\n');
				fprintf(file,'puts "Trying Broyden .."\n');
				fprintf(file,'algorithm Broyden 8\n');
				fprintf(file,'set ok [analyze 1 ]\n');
				fprintf(file,'if {$ok == 0} {\n');
				fprintf(file,'test NormDispIncr  1.0e-5     500;\n');
				fprintf(file,'algorithm Newton\n');
				fprintf(file,'}\n');
				fprintf(file,'\n');
				
			fprintf(file,'}\n');
			fprintf(file,'if {$ok != 0} {\n');
				fprintf(file,'puts "Trying NewtonWithLineSearch .."\n');
				fprintf(file,'algorithm NewtonLineSearch 0.8 \n');
				fprintf(file,'set ok [analyze 1]\n');
				fprintf(file,'if {$ok == 0} {\n');
				fprintf(file,'test NormDispIncr  1.0e-5     500;\n');
				fprintf(file,'algorithm Newton\n');
				fprintf(file,'}	\n');			
			fprintf(file,'}\n');

	fprintf(file,'}; # end if\n');
	fprintf(file,'\n');
	
			fprintf(file,'set numsMode 4;\n');
		fprintf(file,'set pi [expr 2.0*asin(1.0)];\n');
		fprintf(file,'set lambda [eigen fullGenLapack 3];\n');
		fprintf(file,'set T [list [expr 2.0*$pi/pow([lindex $lambda 0],0.5)] [expr 2.0*$pi/pow([lindex $lambda 1],0.5)] [expr 2.0*$pi/pow([lindex $lambda 2],0.5)]]\n');
		fprintf(file,'puts $outfile $T\n');
		
	fprintf(file,'if {$ok == 0} {\n');
	fprintf(file,'puts "Done!"\n');
	fprintf(file,'}\n');
	fclose(file);
    eval(['!',a,'\OpenSees.exe',' ','POAnalysis3D.tcl']) 
	
end