function buildInelasticModel(asset,action)
a = pwd;
    file = fopen('buildInelasticModel.tcl', 'w+');
    fprintf(file,'model basic -ndm 2 -ndf 3 \n');
    fprintf(file,'source DisplayModel2D.tcl;\n');
    fprintf(file,'source DisplayPlane.tcl;\n');
    fprintf(file,'set cover %2.3f \n',asset.Cover);
    	
    fprintf(file,'# nodal coordinates:\n');
    for storey=1:asset.noStoreys+1
        for column=1:asset.noBays+1
            fprintf(file,'node %i%i %2.2f %2.2f \n',column,storey,asset.BeamLengths*(column-1),asset.ColH_ground*(storey-1));
        end
    end
	storey = asset.noStoreys+1;
	for column=1:asset.noBays+1
		fprintf(file,'node 1%i%i %2.2f %2.2f \n',column,storey,asset.BeamLengths*(column-1),asset.ColH_ground*(storey-1));
		fprintf(file,'equalDOF  %i%i 1%i%i 1 2; \n',column,storey,column,storey);
	end
		
   fprintf(file,'#masses \n');  
   for storey=1:asset.noStoreys
   if asset.noBays > 1
           for column = 1;
               fprintf(file,'mass %i%i %2.3f 1e-9 1e-9 \n',column,storey+1,action.massExt);
           end
           for column = 2:(asset.noBays);
            fprintf(file,'mass %i%i %2.3f 1e-9 1e-9 \n',column,storey+1,action.massExt*2);
           end
           for column = (asset.noBays+1);
               fprintf(file,'mass %i%i %2.3f 1e-9 1e-9 \n',column,storey+1,action.massExt);
           end
   else
        for column = 1:asset.noBays+1;
            fprintf(file,'mass %i%i %2.3f 1e-9 1e-9 \n',column,storey+1,action.massExt);
        end
   end
   end
    fprintf(file,'\n');
    fprintf(file,'# Fix Nodes \n');
        for column=1:asset.noBays+1
            fprintf(file,'fix %i%i 1 1 1 \n',column,1);
        end
    fprintf(file,'\n');

    fprintf(file,'#DEFINE THE ELEMENTS \n');
	fprintf(file,'set BeamTransfTag 1 \n');
	fprintf(file,'set ColTransfTag 2 \n');
    fprintf(file,'geomTransf Linear $BeamTransfTag \n');
	fprintf(file,'geomTransf PDelta $ColTransfTag \n');
	fprintf(file,'set numBarsCol 2 \n');
	fprintf(file,'set barAreaCol [expr %1.6f/$numBarsCol] \n',asset.colSteelAreaNeg)
    fprintf(file,'\n');
	
	fprintf(file,'# Define material properties \n');
	fprintf(file,'set IDconcCore 1; \n');
	fprintf(file,'set IDconcU 3; \n');
	fprintf(file,'set IDSteel 2; \n');
    fprintf(file,'# CONCRETE \n');
	if asset.Code == 1
        fprintf(file,'# Core concrete (unconfined) \n');
		fprintf(file,'uniaxialMaterial Concrete02  $IDconcCore %6.2f %2.6f  %6.2f  %2.6f %2.6f %2.6f %2.6f; \n',-asset.Fc*1000,-asset.ec,-asset.Fuc, -asset.euc,asset.lambda,asset.ftens*1000,asset.Et);
	else
		fprintf(file,'# Core concrete (confined) \n');
		fprintf(file,'uniaxialMaterial Concrete02  $IDconcCore %6.2f %2.6f  %6.2f  %2.6f %2.6f %2.6f %2.6f; \n',-asset.Fcc*1000,-asset.ecc,-asset.Fucc, -asset.eucc,asset.lambda,asset.ftens*1000,asset.Et);
	end
	fprintf(file,'# Core concrete (unconfined) \n');
	fprintf(file,'uniaxialMaterial Concrete02  $IDconcU %6.2f %2.6f  %6.2f  %2.6f %2.6f %2.6f %2.6f;\n',-asset.Fc*1000,-asset.ec,-asset.Fuc, -asset.euc,asset.lambda,asset.ftens*1000,asset.Et);
    fprintf(file,'# Reinforcing steel \n');
    fprintf(file,'uniaxialMaterial Steel02 $IDSteel %6.0f %6.0f %6.4f 20 0.925 0.15; \n',asset.Fy*1000,asset.Es*1000,asset.b);  
    fprintf(file,'\n');
	
    fprintf(file,'# Fiber section properties \n');
    for i=1:asset.noHeights
        fprintf(file,'set y1 [expr %1.4f/2.0] \n',asset.ColW);
        fprintf(file,'set z1 [expr %1.4f/2.0] \n',asset.ColD);
		fprintf(file,'set coreY [expr $y1-$cover];\n');%		# The distance from the section z-axis to the edge of the core concrete --  edge of the core concrete/inner edge of cover concrete
		fprintf(file,'set coreZ [expr $z1-$cover];\n');%
		fprintf(file,'set distY [expr $coreY*2/(%i-1)]; \n', asset.noBars);
        fprintf(file,'section Fiber %i {\n',i);
        fprintf(file,'patch rect $IDconcCore 30 5 [expr $cover-$y1] [expr $cover-$z1] [expr $y1-$cover] [expr $z1-$cover]\n');
        fprintf(file,'patch rect $IDconcCore 30 1  [expr -$y1] [expr $z1-$cover] $y1 $z1\n');
        fprintf(file,'patch rect $IDconcCore 30 1  [expr -$y1] [expr -$z1] $y1 [expr $cover-$z1]\n');
        fprintf(file,'patch rect $IDconcCore  1 5  [expr -$y1] [expr $cover-$z1] [expr $cover-$y1] [expr $z1-$cover]\n');
        fprintf(file,'patch rect $IDconcCore  1 5  [expr $y1-$cover] [expr $cover-$z1] $y1 [expr $z1-$cover]\n');
        fprintf(file,'layer straight $IDSteel $numBarsCol $barAreaCol [expr $y1-$cover] [expr $z1-$cover] [expr $y1-$cover] [expr $cover-$z1]\n');
        fprintf(file,'layer straight $IDSteel $numBarsCol $barAreaCol [expr $cover-$y1] [expr $z1-$cover] [expr $cover-$y1] [expr $cover-$z1]\n');
		for i = 1:(asset.noBars-2)
			fprintf(file,'layer straight $IDSteel 2 %2.6f [expr $y1-$cover-$distY*%i] [expr $z1-$cover] [expr $y1-$cover-$distY*%i] [expr $cover-$z1]; # Internal layer\n',asset.AsBar, i, i);
		end
        fprintf(file,'}  \n');   
        fprintf(file,'\n');  
	end
	np=4;
    fprintf(file,'set np %i\n',np);
    fprintf(file,'#element connectivity \n');
    for storey=1:asset.noStoreys
        for column=1:asset.noBays+1
            fprintf(file,'element nonlinearBeamColumn %i %i%i %i%i $np 1 $ColTransfTag\n',column,column,storey,column,storey+1);%1 solo perchè ho solo un piano 
			%fprintf(file,'element zeroLength 10%i%i %i%i %i%i -mat 100 -dir 3 \n',column,storey+1,column,storey+1,column,storey+1);
        end
        for column=1:asset.noBays;
            fprintf(file,'element elasticBeamColumn %i 1%i%i 1%i%i %2.0f %2.6f %2.6f $BeamTransfTag \n',column+100, column,storey+1,column+1,storey+1,asset.E*1000, asset.beamA,asset.beamIy);
        end
	end
    fprintf(file,'\n');
		
    fprintf(file,'# define GRAVITY \n');
    fprintf(file,'pattern Plain 1 Linear {\n');
    for storey=1:asset.noStoreys
        if asset.noBays > 1
            for column = 1         
            fprintf(file,'   load  %i%i   0.0  %3.1f 0.0\n',column,storey+1,-action.massExt*9.81);
            end
            for column = 2:asset.noBays;
            fprintf(file,'   load  %i%i   0.0  %3.1f 0.0\n',column,storey+1,-action.massExt*2*9.81);
            end
            for column = asset.noBays+1          
            fprintf(file,'   load  %i%i   0.0  %3.1f 0.0\n',column,storey+1,-action.massExt*9.81);
            end

        else
            for column = 1:asset.noBays+1;
            fprintf(file,'   load  %i%i   0.0  %3.1f 0.0\n',column,storey+1,-action.massExt*9.81);
            end
        end
    end    
    fprintf(file,'}\n');
	
	fprintf(file,'set pi [expr 2.0*asin(1.0)];\n');   
    fprintf(file,'set lambda [eigen  4];\n');
    fprintf(file,'set T [list [expr 2.0*$pi/pow([lindex $lambda 0],0.5)] [expr 2.0*$pi/pow([lindex $lambda 1],0.5)] [expr 2.0*$pi/pow([lindex $lambda 2],0.5)] [expr 2.0*$pi/pow([lindex $lambda 3],0.5)]]\n');  
    fprintf(file,'     set outfile [open "period.txt" w]\n');
    fprintf(file,'     puts $outfile $T \n');
    fprintf(file,'puts "T = $T s"\n');
	fprintf(file,'\n');
	
    fprintf(file,'# display deformed shape:\n');
    fprintf(file,'set ViewScale 5;\n');
    fprintf(file,'DisplayModel2D DeformedShape $ViewScale ;\n');
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
    eval(['!',a,'/OpenSees',' ','buildInelasticModel.tcl']) 
end