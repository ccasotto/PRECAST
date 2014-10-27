    a=pwd; 
	file = fopen('MeanPO.tcl', 'w+');
    fprintf(file,'source MeanModel.tcl \n');
    fprintf(file,'source DisplayModel2D.tcl\n');
    fprintf(file,'source DisplayPlane.tcl\n');
		
	   fprintf(file,'loadConst -time 0.0 \n');
	fprintf(file,'# Definizione degli output\n');
	    node = [];
    for i=1:3
	   node = [node i*10+1];
	end
    fprintf(file,'recorder Node -file DispMean.txt -node 32 -dof 1 disp\n');
	fprintf(file,'recorder Element -file ForceColSec4.txt -ele 2 globalForce;\n');
    fprintf(file,'\n');
 
	fprintf(file,'# Definizione dei carichi laterali\n');
	fprintf(file,'   pattern Plain  2  Linear {\n');
	for storey = 1:1
		for column = 1:3
        fprintf(file,' load   %i%i 10 0. 0.  \n',column,storey+1);
		end
	end
	fprintf(file,'}\n');
    fprintf(file,'\n');
	
	fprintf(file,'# Definizione di alcune delle variabili utilizzate durante analisi \n');
    fprintf(file,' set incrSpost 0.001;\n');
 	fprintf(file,' set nSteps 200;\n');
	fprintf(file,'set Tol 1.0e-5;\n');
    fprintf(file,'# Definizione delle opzioni di analisi \n');
    fprintf(file,'constraints Transformation \n');
    fprintf(file,'integrator DisplacementControl 12 1 $incrSpost \n');
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
    eval(['!',a,'\OpenSees.exe',' ','MeanPO.tcl'])