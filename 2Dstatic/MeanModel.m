function MeanModel(Next)
a = pwd;
    file = fopen('MeanModel.tcl', 'w+');
    fprintf(file,'model basic -ndm 2 -ndf 3 \n');
    fprintf(file,'source DisplayModel2D.tcl;\n');
    fprintf(file,'source DisplayPlane.tcl;\n');
    fprintf(file,'set cover 0.3 \n');
    	
    fprintf(file,'# nodal coordinates:\n');
    for storey=1:2
        for column=1:3
            fprintf(file,'node %i%i %2.2f %2.2f \n',column,storey,20*(column-1),7.5*(storey-1));
        end
    end
    fprintf(file,'\n');
    
   fprintf(file,'#masses \n');  

    fprintf(file,'mass 11 %2.3f 1e-9 1e-9 \n',Next/9.81);
    fprintf(file,'mass 22 %2.3f 1e-9 1e-9 \n',Next*2/9.81);
    fprintf(file,'mass 32 %2.3f 1e-9 1e-9 \n',Next/9.81);
  
    fprintf(file,'\n');
    fprintf(file,'# Fix Nodes \n');
	fprintf(file,'fix 11 1 1 1 \n');
	fprintf(file,'fix 21 1 1 1 \n');
	fprintf(file,'fix 31 1 1 1 \n');
    fprintf(file,'\n');

    fprintf(file,'#DEFINE THE ELEMENTS \n');
	fprintf(file,'set BeamTransfTag 1 \n');
	fprintf(file,'set ColTransfTag 2 \n');
    fprintf(file,'geomTransf Linear $BeamTransfTag \n');
	fprintf(file,'geomTransf PDelta $ColTransfTag \n');
	fprintf(file,'set numBarsCol 2 \n');
	fprintf(file,'set barAreaCol [expr 0.001295/$numBarsCol] \n')
    fprintf(file,'\n');
	
	fprintf(file,'# Define material properties \n');
	fprintf(file,'set IDconcCore 1; \n');
	fprintf(file,'set IDconcU 3; \n');
	fprintf(file,'set IDreinf 2; \n');
    fprintf(file,'# CONCRETE \n');
    fprintf(file,'# Core concrete (unconfined) \n');
	fprintf(file,'uniaxialMaterial Concrete02  $IDconcCore -33200.00 -0.002500   -9.96  -0.005000 0.500000 0.000000 0.000000; \n');
	fprintf(file,'# Core concrete (unconfined) \n');
	fprintf(file,'uniaxialMaterial Concrete02  $IDconcU -33200.00 -0.002500   -9.96  -0.005000 0.500000 0.000000 0.000000;\n');
    fprintf(file,'# Reinforcing steel \n');
    fprintf(file,'uniaxialMaterial Steel02 $IDreinf 220000.00 209111058 0.005 20 0.925 0.15; \n');  
    fprintf(file,'\n');
	
    fprintf(file,'# Fiber section properties \n');

        fprintf(file,'set y1 [expr %1.4f/2.0] \n',0.55);
        fprintf(file,'set z1 [expr %1.4f/2.0] \n',0.5);
        fprintf(file,'section Fiber 1 {\n');
        fprintf(file,'patch rect $IDconcCore 30 5 [expr $cover-$y1] [expr $cover-$z1] [expr $y1-$cover] [expr $z1-$cover]\n');
        fprintf(file,'patch rect $IDconcCore 30 1  [expr -$y1] [expr $z1-$cover] $y1 $z1\n');
        fprintf(file,'patch rect $IDconcCore 30 1  [expr -$y1] [expr -$z1] $y1 [expr $cover-$z1]\n');
        fprintf(file,'patch rect $IDconcCore  1 5  [expr -$y1] [expr $cover-$z1] [expr $cover-$y1] [expr $z1-$cover]\n');
        fprintf(file,'patch rect $IDconcCore  1 5  [expr $y1-$cover] [expr $cover-$z1] $y1 [expr $z1-$cover]\n');
        fprintf(file,'layer straight $IDreinf $numBarsCol $barAreaCol [expr $y1-$cover] [expr $z1-$cover] [expr $y1-$cover] [expr $cover-$z1]\n');
        fprintf(file,'layer straight $IDreinf $numBarsCol $barAreaCol [expr $cover-$y1] [expr $z1-$cover] [expr $cover-$y1] [expr $cover-$z1]\n');
        fprintf(file,'}  \n');   
        fprintf(file,'\n');  

	np=4;
    fprintf(file,'set np %i\n',np);
    fprintf(file,'#element connectivity \n');
            fprintf(file,'element nonlinearBeamColumn 1 11 12 $np 1 $ColTransfTag\n');%1 solo perch� ho solo un piano 
            fprintf(file,'element nonlinearBeamColumn 2 21 22 $np 1 $ColTransfTag\n');%1 solo perch� ho solo un piano 
            fprintf(file,'element nonlinearBeamColumn 3 31 32 $np 1 $ColTransfTag\n');%1 solo perch� ho solo un piano 
            fprintf(file,'element elasticBeamColumn 101 12 22 36049965 0.430000 0.110000 $BeamTransfTag \n');
             fprintf(file,'element elasticBeamColumn 102 22 32 36049965 0.430000 0.110000 $BeamTransfTag \n');

    fprintf(file,'\n');
		
    fprintf(file,'# define GRAVITY \n');
    fprintf(file,'pattern Plain 1 Linear {\n');       
            fprintf(file,'   load  11   0.0  %3.1f 0.0\n',Next);
            fprintf(file,'   load  22   0.0  %3.1f 0.0\n',Next*2);          
            fprintf(file,'   load  32   0.0  %3.1f 0.0\n',Next);
   
    fprintf(file,'}\n');
	
%     fprintf(file,'# display deformed shape:\n');
%     fprintf(file,'set ViewScale 5;\n');
%     fprintf(file,'DisplayModel2D DeformedShape $ViewScale ;\n');
	fprintf(file,'set Tol 1.0e-5; \n');
	fprintf(file,'set NstepGravity 20; \n');
	fprintf(file,'set DGravity [expr 1./$NstepGravity]; \n');
    fprintf(file,'system BandGeneral\n');
    fprintf(file,'constraints Plain\n');
    fprintf(file,'numberer Plain\n');
    fprintf(file,'test NormDispIncr $Tol 10 3\n');
    fprintf(file,'algorithm Newton\n');
    fprintf(file,'integrator LoadControl $DGravity\n');
    fprintf(file,'analysis Static\n');
    fprintf(file,'analyze $NstepGravity \n');
	fprintf(file,'\n');

	fprintf(file,'puts "Done!"');
    fclose(file);
    eval(['!',a,'\OpenSees.exe',' ','MeanModel.tcl']) 
end