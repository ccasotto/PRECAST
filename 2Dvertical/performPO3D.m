function performPO3D(asset)
    a=pwd;
    file = fopen('POAnalysis3D.tcl', 'w+');
    fprintf(file,'source buildInelasticModel3D.tcl\n');
    fprintf(file,'source DisplayModel2D.tcl\n');
    fprintf(file,'source DisplayPlane.tcl\n');
	fprintf(file,'set IDctrlNode %i \n',(asset.noStoreys+1)*10000+101);
 	fprintf(file,'loadConst -time 0.0 \n');
	fprintf(file,'# Definizione degli output\n');
	node = [];

	frame = 1;
	for pier = 1:asset.noBays+1
		level = 2;
		TopNode(pier) = level*10000+frame*100+pier;
	end
	  
for node = 1:(asset.noBayZ+1)*(asset.noBays+1)
	fprintf(file,'recorder Node -file nodeDisp_po_');
	fprintf(file,'n%i',node);
	fprintf(file,'.txt -node %i -dof 1 disp \n',TopNode(node));
end
	fprintf(file,'recorder Node -file nodeReaction_po.txt -nodeRange $SupportNodeFirst $SupportNodeLast -dof 1 reaction;\n');
	fprintf(file,'recorder Element -file SteelStressStrain.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber -$coreY -$coreZ $IDSteel stressStrain; \n');
    fprintf(file,'recorder Element -file ConcreteStressStrain.txt -eleRange $ColumnFirst $ColumnLast section 1 fiber $coreY 0 $IDconcCore stressStrain;\n');
    fprintf(file,'recorder Element -file ForceColSec4.txt -ele 20100 globalForce;\n');
	fprintf(file,'\n');
	
	fprintf(file,'# Definizione dei carichi laterali\n');
	fprintf(file,'   pattern Plain  2  Linear {\n');
	for level = 2:asset.noStoreys+1
		for frame=1:(asset.noBayZ+1)
			for pier = 1:asset.noBays+1;
			fprintf(file,' load %i 10 0.0 0.0 0.0 0.0 0.0 \n',level*10000+frame*100+pier);
			end
		end
	end
	fprintf(file,'}\n');
    fprintf(file,'\n');
		
	fprintf(file,'# Definizione di alcune delle variabili utilizzate durante analisi \n');
    fprintf(file,' set incrSpost 0.001;\n');
	if asset.ColH_ground < 10
		fprintf(file,' set nSteps 300;\n');
	else
		fprintf(file,' set nSteps 450;\n');
	end
 	fprintf(file,'set Tol 1.0e-5;\n');
    fprintf(file,'# Definizione delle opzioni di analisi \n');
    fprintf(file,'constraints Transformation \n');
    fprintf(file,'integrator DisplacementControl $IDctrlNode 1 $incrSpost \n');
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
    eval(['!',a,'/OpenSees',' ','POAnalysis3D.tcl']) 
	
end