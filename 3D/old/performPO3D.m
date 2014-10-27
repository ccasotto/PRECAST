function performPO3D(asset,dir)
    a=pwd;
    file = fopen('POAnalysis3D.tcl', 'w+');
    fprintf(file,'source buildInelasticModel3D.tcl\n');
	fprintf(file,'fixY $LCol  %i 0 %i %i 0 %i;\n',dir(3)*1,dir(1)*1,dir(1)*1,dir(3)*1);% fix all Y=0.0 nodes
 	fprintf(file,'loadConst -time 0.0 \n');
	fprintf(file,'set IDctrlNode %i \n',(asset.noStoreys+1)*10000+101);
	fprintf(file,'# Definizione degli output\n');
	fprintf(file,'set SupportNodeFirst [lindex $iSupportNode 0];						# ID: first support node\n');
	fprintf(file,'set SupportNodeLast [lindex $iSupportNode [expr [llength $iSupportNode]-1]];			# ID: last support node\n');
    fprintf(file,'recorder Node -file nodeDisp_po.txt -node $IDctrlNode -dof %i disp\n', dir(1)*1+dir(2)*2+dir(3)*3);
	fprintf(file,'recorder Node -file nodeReaction_po.txt -nodeRange $SupportNodeFirst $SupportNodeLast -dof %i reaction;\n',dir(1)*1+dir(2)*2+dir(3)*3);
	fprintf(file,'recorder Element -file BeamForce.txt -ele 1020101 globalForce;\n');
	fprintf(file,'recorder Element -file ColForce.txt -ele 20100 globalForce;\n');
	fprintf(file,'recorder Element -file ColDef.txt -ele 20100 section 1 deformation;\n');
	fprintf(file,'recorder Element -file GirderForce.txt -ele 2020101 globalForce;\n');	
	fprintf(file,'recorder Element -file SteelStressStrainX.txt -eleRange 20100 20102 section 1 fiber -$coreY -$coreZ $IDSteel stressStrain; \n');
    fprintf(file,'recorder Element -file ConcreteStressStrainX.txt -eleRange 20100 20102 section 1 fiber $coreY 0 $IDconcCore stressStrain;\n');
    fprintf(file,'recorder Element -file SteelStressStrainY.txt -ele 20100 section 1 fiber $coreY $coreZ $IDSteel stressStrain; \n');
    fprintf(file,'recorder Element -file ConcreteStressStrainY.txt -ele 20100 section 1 fiber 0 -$coreZ $IDconcCore stressStrain;\n');
    fprintf(file,'recorder Element -file ConcreteStressStrainYC.txt -ele 20100 section 1 fiber 0 -$coverZ $IDconcCover stressStrain;\n');
	
	fprintf(file,'\n');
	
	fprintf(file,'# Definizione dei carichi laterali\n');
	fprintf(file,'   pattern Plain  2  Linear {\n');
	for level = 2:asset.noStoreys+1
		for frame=1:(asset.noBayZ+1)
			for pier = 1:asset.noBays+1;
			fprintf(file,' load %i %i %i %i 0. 0. 0.  \n',level*10000+frame*100+pier, dir(1)*5,dir(2)*1,dir(3)*1);
		end
		end
	end
	fprintf(file,'}\n');
    fprintf(file,'\n');
	
	fprintf(file,'# Definizione di alcune delle variabili utilizzate durante analisi \n');
    fprintf(file,' set incrSpost 0.001;\n');
	fprintf(file,' set nSteps %i;\n', 300*dir(1)+300*dir(3));
	fprintf(file,'set dirSpost %i;\n', dir(1)*1+dir(2)*2+dir(3)*3);
 	fprintf(file,'set Tol 1.0e-5;\n');
    fprintf(file,'# Definizione delle opzioni di analisi \n');
    fprintf(file,'constraints Transformation \n');
    fprintf(file,'integrator DisplacementControl $IDctrlNode $dirSpost $incrSpost \n');
    fprintf(file,'test NormDispIncr  $Tol     500      \n'); 
    fprintf(file,'algorithm  Newton -initial     \n');
    fprintf(file,'numberer  RCM  \n');
    fprintf(file,'system  BandGeneral\n');
    fprintf(file,'analysis Static\n');
	fprintf(file,'\n');
	
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
	
	fprintf(file,'if {$ok == 0} {\n');
	fprintf(file,'puts "Done!"\n');
	fprintf(file,'}\n');
	fclose(file);
    eval(['!',a,'\OpenSees.exe',' ','POAnalysis3D.tcl']) 
	
end