function performPO(asset)
    a=pwd;
    file = fopen('POAnalysis.tcl', 'w+');
    fprintf(file,'source buildInelasticModel.tcl\n');
	
 	fprintf(file,'loadConst -time 0.0 \n');
	fprintf(file,'# Definizione degli output\n');
	    node = [];
    for i=1 : asset.noBays+1
	   node = [node i*10+1];
	end
    fprintf(file,'recorder Node -file tmp/nodeDisp_po.txt -node %i%i -dof 1 disp\n',asset.noBays+1,asset.noStoreys+1);
    fprintf(file,'recorder Node -file tmp/nodeReaction_po.txt -node ');
	node=sprintf('%d ',node);
    fprintf(file,node);
    fprintf(file,'-dof 1 reaction \n');
    fprintf(file,'recorder Element -file tmp/SteelStressStrain.txt -ele 1 section 1 fiber [expr -$cover+$y1] [expr $z1-$cover] $IDSteel stressStrain; \n');
    fprintf(file,'recorder Element -file tmp/ConcreteStressStrain.txt -ele 1 section 1 fiber [expr $cover-$y1] 0 $IDconcCore stressStrain;\n');
	fprintf(file,'recorder Element -file tmp/ForceCol.txt -ele 2 globalForce;\n');
    fprintf(file,'\n');
	
	fprintf(file,'# Definizione dei carichi laterali\n');
	fprintf(file,'   pattern Plain  2  Linear {\n');
	for storey = 1:asset.noStoreys
		for column = 1:asset.noBays+1
        fprintf(file,' load   %i%i 10 0. 0.  \n',column,storey+1);
		end
	end
	fprintf(file,'}\n');
    fprintf(file,'\n');
	
	fprintf(file,'# Definizione di alcune delle variabili utilizzate durante analisi \n');
    fprintf(file,' set incrSpost 0.001;\n');
 	if asset.ColH_ground < 10
 	fprintf(file,' set nSteps 300;\n');
	else
	fprintf(file,' set nSteps 500;\n');
	end
 	fprintf(file,'set Tol 1.0e-5;\n');
    fprintf(file,'# Definizione delle opzioni di analisi \n');
    fprintf(file,'constraints Transformation \n');
    fprintf(file,'integrator DisplacementControl 1%i 1 $incrSpost \n',asset.noStoreys+1);
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
    eval(['!../OpenSees',' ','POAnalysis.tcl']) 
	
end