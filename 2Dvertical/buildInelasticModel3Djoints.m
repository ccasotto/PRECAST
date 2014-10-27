function buildInelasticModel3Djoints(asset,action)
	a = pwd;
	
    file = fopen('buildInelasticModel3D.tcl', 'w+');
	fprintf(file,'wipe \n');
    fprintf(file,'model basic -ndm 3 -ndf 6 \n');
    fprintf(file,'source DisplayModel3D.tcl;\n');
    fprintf(file,'source DisplayPlane.tcl;\n');
    	
	fprintf(file,'# ------ frame configuration; \n');
	fprintf(file,'set NStory %i;\n', asset.noStoreys); % number of stories above ground level
	fprintf(file,'set NBay %i;\n', asset.noBays); % number of bays in X direction
	fprintf(file,'set NBayZ %i; \n',asset.noBayZ); % number of bays in Z direction
	fprintf(file,'puts "Number of Stories in Y: $NStory Number of bays in X: $NBay Number of bays in Z: $NBayZ" \n');
	fprintf(file,'set NFrame [expr $NBayZ + 1];\n'); % actually deal with frames in Z direction, as this is an easy extension of the 2d model

	fprintf(file,'# define GEOMETRY \n');
	fprintf(file,'# define structure-geometry paramters \n');
	fprintf(file,'set LCol %2.2f; \n', asset.ColH_ground); % column height (parallel to Y axis)
	fprintf(file,'set LBeam %2.2f; \n', asset.BeamLengths);% beam length (parallel to X axis)
	fprintf(file,'set LGird %2.2f; \n', asset.InterCol);% girder length (parallel to Z axis)
	
	fprintf(file,'# define NODAL COORDINATES\n');
	Dlevel = 10000;
	Dframe = 100;
	Djoint = 10;
	DjointG = 100000;
	dlt = 0.03;
	fprintf(file,'set dlt %i;\n',dlt);
	fprintf(file,'set Dlevel %i;\n',Dlevel); 
	fprintf(file,'set Dframe %i;\n',Dframe); 
	fprintf(file,'set Djoint %i;\n',Djoint); 
	fprintf(file,'set DjointG %i;\n',DjointG); 
	for frame = 1:asset.noBayZ+1
		Z = (frame-1)*asset.InterCol;
		for level = 1:asset.noStoreys+1
		Y = (level-1)*asset.ColH_ground;
			for pier = 1:asset.noBays+1
			X = (pier-1)*asset.BeamLengths;
			nodeID = level*Dlevel+frame*Dframe+pier;
			fprintf(file,'node %i %2.2f %2.2f %2.2f;\n', nodeID, X, Y, Z); % actually define node
			end
		end
	end

	fprintf(file,'# define SPRING COORDINATES\n');
	level = 2;
	Y = (level-1)*asset.ColH_ground;
	for frame = 1:asset.noBayZ+1
		Z = (frame-1)*asset.InterCol;
		for pier = 1:asset.noBays
			X1 = (pier-1)*asset.BeamLengths+dlt;
			X2 = pier*asset.BeamLengths-dlt;
			jointID1 = level*Dlevel+frame*Dframe+pier+Djoint;
			jointID2 = level*Dlevel+frame*Dframe+pier+Djoint*2;
		fprintf(file,'node %i %2.2f %2.2f %2.2f;\n',jointID1, X1, Y, Z); 
		fprintf(file,'node %i %2.2f %2.2f %2.2f;\n',jointID2, X2, Y, Z);
		end
	end
			
	
	fprintf(file,'# define SPRING Girder COORDINATES\n');
	level = 2;
	Y = (level-1)*asset.ColH_ground;
	for frame = 1:asset.noBayZ
		Z1 = (frame-1)*asset.InterCol+dlt;
		Z2 = (frame)*asset.InterCol-dlt;
		for pier = 1:asset.noBays+1
			X = (pier-1)*asset.BeamLengths;
			jointID1 = level*Dlevel+frame*Dframe+pier+DjointG;
			jointID2 = level*Dlevel+frame*Dframe+pier+DjointG*2;
		fprintf(file,'node %i %2.2f %2.2f %2.2f;\n',jointID1, X, Y, Z1); 
		fprintf(file,'node %i %2.2f %2.2f %2.2f;\n',jointID2, X, Y, Z2);
		end
	end
	

fprintf(file,'# determine support nodes where ground motions are input, for multiple-support excitation\n');
fprintf(file,'set iSupportNode ""\n');
fprintf(file,'for {set frame 1} {$frame <=[expr $NFrame]} {incr frame 1} {\n');
fprintf(file,'	set level 1\n');
fprintf(file,'	for {set pier 1} {$pier <= [expr $NBay+1]} {incr pier 1} {\n');
fprintf(file,'		set nodeID [expr $level*$Dlevel+$frame*$Dframe+$pier]\n');
fprintf(file,'		lappend iSupportNode $nodeID\n');
fprintf(file,'	}\n');
fprintf(file,'}\n');

fprintf(file,'# determine top nodes\n');
fprintf(file,'set iTopNode ""\n');
fprintf(file,'for {set frame 1} {$frame <=[expr $NFrame]} {incr frame 1} {\n');
fprintf(file,'	set level [expr $NStory+1] \n');
fprintf(file,'	for {set pier 1} {$pier <= [expr $NBay+1]} {incr pier 1} {\n');
fprintf(file,'		set nodeID [expr $level*$Dlevel+$frame*$Dframe+$pier]\n');
fprintf(file,'		lappend iTopNode $nodeID\n');
fprintf(file,'	}\n');
fprintf(file,'}\n');

fprintf(file,'set SupportNodeFirst [lindex $iSupportNode 0];\n');
fprintf(file,'set SupportNodeLast [lindex $iSupportNode [expr [llength $iSupportNode]-1]];\n');
fprintf(file,'set TopNodeFirst [lindex $iTopNode 0];\n');
fprintf(file,'set TopNodeLast [lindex $iTopNode [expr [llength $iTopNode]-1]]; \n');
	
fprintf(file,'# BOUNDARY CONDITIONS \n');
fprintf(file,'\n');
fprintf(file,'fixY 0.0  1 1 1 1 1 1;\n');% fix all Y=0.0 nodes
fprintf(file,'fixZ %2.2f  0 0 1 1 1 0;\n',asset.ColH_ground);% fix all Y=0.0 nodes

fprintf(file,'# Define MATERIALS -------------------------------------------------------------\n');
fprintf(file,'set IDconcCore  1;\n');	% material numbers for recorder (this stressstrain recorder will be blank, as this is an elastic section)
fprintf(file,'set IDconcCover  3;\n');
fprintf(file,'set IDSteel  2;\n');
fprintf(file,'# CONCRETE UNCONFINED \n');
fprintf(file,'set fc1C  %6.0f;\n',-asset.Fcc*1000);
fprintf(file,'set fc1U  %6.0f;\n',-asset.Fc*1000); % UNCONFINED concrete (todeschini parabolic model), maximum stress
fprintf(file,'set eps1U %1.6f;	\n',-asset.ec); % strain at maximum strength of unconfined concrete
fprintf(file,'set fc2U %6.0f;	\n',-asset.Fuc*1000); % ultimate stress
fprintf(file,'set eps2U %1.6f;\n', -asset.euc); % strain at ultimate stress
fprintf(file,'# CONCRETE CONFINED \n');
fprintf(file,'set Ubig 1.e10; \n'); % a really large number
fprintf(file,'set Usmall [expr 1/$Ubig]; \n'); % a really small number
fprintf(file,'set fc %6.0f;\n',-asset.Fcc*1000); % concrete nominal compressive strength
fprintf(file,'set Ec %6.0f;\n',asset.E*1000); % concrete Young's Modulus
fprintf(file,'set eps1C %1.6f;\n',-asset.ecc); %strain at maximum stress
fprintf(file,'set fc2C %6.0f;\n',-asset.Fucc*1000); % ultimate stress
fprintf(file,'set eps2C %1.6f;\n',-asset.eucc) ;% strain at ultimate stress
fprintf(file,'set lambda %1.6f;\n',asset.lambda);
fprintf(file,'set ftC %6.0f;\n',asset.ftens*1000); % tensile strength +tension
fprintf(file,'set Ets %6.0f;\n',asset.Et); % tension softening stiffness
fprintf(file,'	set nu 0.2;\n'); % Poisson's ratio
fprintf(file,'	set Gc [expr $Ec/2./[expr 1+$nu]]; \n'); % Torsional stiffness Modulus
fprintf(file,'	set J $Ubig; \n'); % set large torsional stiffness
    fprintf(file,'# CONCRETE \n');
	if asset.Code == 1
        fprintf(file,'# Core concrete (confined) \n');
 		fprintf(file,'uniaxialMaterial Concrete02 $IDconcCore $fc1U $eps1U $fc2U $eps2U $lambda $ftC $Ets;	# Cover concrete (unconfined) \n');
	else
		fprintf(file,'# Core concrete (confined) \n');
 		fprintf(file,'uniaxialMaterial Concrete02 $IDconcCore $fc1C $eps1C $fc2C $eps2C $lambda $ftC $Ets;	# Core concrete (confined) \n');
	end
	fprintf(file,'# Core concrete (unconfined) \n');
	fprintf(file,'uniaxialMaterial Concrete02 $IDconcCover $fc1U $eps1U $fc2U $eps2U $lambda $ftC $Ets;	# Cover concrete (unconfined) \n');
    fprintf(file,'# Reinforcing STEEL \n');
    fprintf(file,'uniaxialMaterial Steel02 $IDSteel %6.2f %6.0f 0.005 20 0.925 0.15; \n',asset.Fy*1000,asset.Es*1000);  
    fprintf(file,'\n');
	
fprintf(file,'# Define SECTIONS -------------------------------------------------------------\n');

fprintf(file,'# define section tags:\n');
fprintf(file,'set ColSecTag 1\n');
fprintf(file,'set BeamSecTag 2\n');
fprintf(file,'set GirdSecTag 3\n');
fprintf(file,'set ColSecTagFiber 4\n');
fprintf(file,'set SecTagTorsion 70\n');
fprintf(file,'set SpringSecTag 70\n');
fprintf(file,'# Section Properties:\n');
fprintf(file,'set factor 0.0001 \n');
fprintf(file,'# ELASTIC section\n');
fprintf(file,'section Elastic $GirdSecTag $Ec %1.6f %1.6f %1.6f $Gc $J \n',asset.AGird, asset.IzGird, asset.IyGird);
fprintf(file,'section Elastic $BeamSecTag $Ec %1.6f %1.6f %1.6f $Gc $J \n', asset.beamA, asset.beamIy, asset.beamIz);
fprintf(file,'section Elastic $SpringSecTag [expr $Ec*1] [expr %2.6f*100] [expr %2.6f*$factor] [expr %2.6f*$factor] [expr $Gc*1] [expr $J*1]\n',asset.beamA, asset.beamIy, asset.beamIz);

	fprintf(file,'# FIBER section\n');
	HSec = asset.ColW;
	BSec = asset.ColD;
	coreY = HSec/2-asset.Cover;
	coreZ = BSec/2-asset.Cover;
	distZ = coreZ*2/(asset.noBars-1);
	distY = coreY*2/(asset.noBars-1);
	noBarsInt = (asset.noBars);

	fprintf(file,'set HSec %1.3f; \n',asset.ColW); % - depth of section, along local-y axis
	fprintf(file,'set BSec %1.3f; \n',asset.ColD); % - width of section, along local-z axis
	fprintf(file,'set cover %1.3f; \n',asset.Cover); %- distance from section boundary to neutral axis of reinforcement
	fprintf(file,'set numBarsTop %i; \n', asset.noBars); %- number of reinforcing bars in the top layer
	fprintf(file,'set numBarsBot %i; \n', asset.noBars); %- number of reinforcing bars in the bottom layer
	fprintf(file,'set numBarsIntTot %i; \n', noBarsInt*2); %TOTAL number of reinforcing bars on the intermediate layers, symmetric about z axis and 2 bars per layer-- needs to be an even integer
	fprintf(file,'set barArea %1.6f; \n', asset.AsBar); %- cross-sectional area of each reinforcing bar in top layer
	fprintf(file,'set barAreaInt %1.6f; \n', asset.AsBar);%- cross-sectional area of each reinforcing bar in intermediate layer 
	fprintf(file,'set nfCoreY 13; \n'); %- number of fibers in the core patch in the y direction
	fprintf(file,'set nfCoreZ 13; \n'); % number of fibers in the core patch in the z direction
	fprintf(file,'set nfCoverY 1; \n'); %- number of fibers in the cover patches with long sides in the y direction
	fprintf(file,'set nfCoverZ 1; \n'); %- number of fibers in the cover patches with long sides in the z direction
    
	fprintf(file,'set coverY [expr $HSec/2.0];\n');%		# The distance from the section z-axis to the edge of the cover concrete -- outer edge of cover concrete
	fprintf(file,'set coverZ [expr $BSec/2.0];\n');%		# The distance from the section y-axis to the edge of the cover concrete -- outer edge of cover concrete
	fprintf(file,'set coreY [expr $coverY-$cover];\n');%		# The distance from the section z-axis to the edge of the core concrete --  edge of the core concrete/inner edge of cover concrete
	fprintf(file,'set coreZ [expr $coverZ-$cover];\n');%		# The distance from the section y-axis to the edge of the core concrete --  edge of the core concrete/inner edge of cover concrete
	fprintf(file,'set numBarsInt [expr $numBarsIntTot/2];\n');%	# number of intermediate bars per side

	fprintf(file,'# Define the fiber section \n');
	fprintf(file,'section fiberSec $ColSecTagFiber { \n');
	fprintf(file,'	# Define the core patch \n');
	fprintf(file,'	patch quadr $IDconcCore $nfCoreZ $nfCoreY -$coreY $coreZ -$coreY -$coreZ $coreY -$coreZ $coreY $coreZ \n');
	   
	fprintf(file,'	# Define the four cover patches \n');
	fprintf(file,'	patch quadr $IDconcCover 2 $nfCoverY -$coverY $coverZ -$coreY $coreZ $coreY $coreZ $coverY $coverZ \n');
	fprintf(file,'	patch quadr $IDconcCover 2 $nfCoverY -$coreY -$coreZ -$coverY -$coverZ $coverY -$coverZ $coreY -$coreZ \n');
	fprintf(file,'	patch quadr $IDconcCover $nfCoverZ 2 -$coverY $coverZ -$coverY -$coverZ -$coreY -$coreZ -$coreY $coreZ \n');
	fprintf(file,'	patch quadr $IDconcCover $nfCoverZ 2 $coreY $coreZ $coreY -$coreZ $coverY -$coverZ $coverY $coverZ \n');

	fprintf(file,'	# define reinforcing fibers \n');
	for i = 0:(asset.noBars-1)
		fprintf(file,'fiber %1.4f %1.4f $barArea $IDSteel; # Top fiber\n' ,coreY,coreZ - distZ*i);
		fprintf(file,'fiber %1.4f %1.4f $barArea $IDSteel; # Bottom fiber\n',-coreY,coreZ - distZ*i);
	end
	for i = 1:(noBarsInt-2)
		fprintf(file,'fiber  %1.4f %1.4f $barArea $IDSteel; # left fiber\n' , coreY-distY*i, coreZ);
		fprintf(file,'fiber  %1.4f %1.4f $barArea $IDSteel; # right fiber\n', coreY-distY*i, -coreZ);
	end
	fprintf(file,'}; \n'); %end of section definition
	
	fprintf(file,'	# assign torsional Stiffness for 3D Model \n'); 
	fprintf(file,'uniaxialMaterial Elastic $SecTagTorsion $Ubig \n'); 
	fprintf(file,'section Aggregator $ColSecTag $SecTagTorsion T -section $ColSecTagFiber \n');
	
	fprintf(file,'# define ELEMENTS\n'); 
	fprintf(file,'# set up geometric transformations of element\n'); 
	fprintf(file,'set IDColTransf 1; # all columns\n'); 
	fprintf(file,'set IDBeamTransf 2; # all beams\n'); 
	fprintf(file,'set IDGirdTransf 3; # all girds\n'); 
	fprintf(file,'geomTransf PDelta  $IDColTransf  0 0 -1;\n'); 		%	# orientation of column stiffness affects bidirectional response.
	fprintf(file,'geomTransf Linear $IDBeamTransf 0 1 0\n'); 
	fprintf(file,'geomTransf Linear $IDGirdTransf 1 0 0\n'); 
	
	fprintf(file,'# Define Column ELEMENTS\n');
	fprintf(file,'set numIntgrPts 4;\n');%	# number of Gauss integration points for nonlinear curvature distribution
	fprintf(file,'# columns\n');
	fprintf(file,'set iColumns ""\n');
	fprintf(file,'set N0col [expr 10000-1];	\n');%# column element numbers
	fprintf(file,'set level 0\n');
	fprintf(file,'for {set frame 1} {$frame <=[expr $NFrame]} {incr frame 1} {\n');
	fprintf(file,'for {set level 1} {$level <=$NStory} {incr level 1} {\n');
	fprintf(file,'	for {set pier 1} {$pier <= [expr $NBay+1]} {incr pier 1} {\n');
	fprintf(file,'		set elemID [expr $N0col  +$level*$Dlevel + $frame*$Dframe+$pier]\n');
	fprintf(file,'		set nodeI [expr  $level*$Dlevel + $frame*$Dframe+$pier]\n');
	fprintf(file,'		set nodeJ  [expr  ($level+1)*$Dlevel + $frame*$Dframe+$pier]\n');
	fprintf(file,'		element nonlinearBeamColumn $elemID $nodeI $nodeJ $numIntgrPts $ColSecTag $IDColTransf;	\n');%	# columns
	fprintf(file,'		lappend iColumns $elemID \n');
	fprintf(file,'	}\n');
	fprintf(file,'}\n');
	fprintf(file,'}\n');
	
	ColumnFirst = 9999  +1*Dlevel + 1*Dframe+1;
	ColumnLast = 9999  + asset.noStoreys*Dlevel + (asset.noBayZ+1)*Dframe+(asset.noBays+1);
	
	fprintf(file,'# beams -- parallel to X-axis\n');
	fprintf(file,'set N0beam 1000000;	# beam element numbers\n');
	fprintf(file,'for {set frame 1} {$frame <=[expr $NFrame]} {incr frame 1} {\n');
	fprintf(file,'for {set level 2} {$level <=[expr $NStory+1]} {incr level 1} {\n');
	fprintf(file,'	for {set bay 1} {$bay <= $NBay} {incr bay 1} {\n');
	fprintf(file,'		set elemID [expr $N0beam +$level*$Dlevel + $frame*$Dframe+ $bay]\n');
	fprintf(file,'		set nodeI [expr $level*$Dlevel + $frame*$Dframe+ $bay+$Djoint]\n');
	fprintf(file,'		set nodeJ  [expr $level*$Dlevel + $frame*$Dframe+ $bay+$Djoint*2]\n');
	fprintf(file,'		element elasticBeamColumn $elemID $nodeI $nodeJ %1.6f $Ec $Gc $J %1.6f %1.6f $IDBeamTransf; \n',asset.beamA, asset.beamIy, asset.beamIz);
	fprintf(file,'	}\n');
	fprintf(file,'}\n');
	fprintf(file,'}\n');

	fprintf(file,'# springs -- parallel to beams\n');
	NoSpringX = 3000000;
	for frame = 1:asset.noBayZ+1;
		for level = 2:asset.noStoreys+1
			for bay = 1:asset.noBays
				elemID1 = NoSpringX+level*Dlevel + frame*Dframe + bay+Djoint;
				nodeI1 = level*Dlevel + frame*Dframe+ bay;
				nodeJ1 = level*Dlevel + frame*Dframe+ bay+ Djoint;
				elemID2 = NoSpringX+level*Dlevel + frame*Dframe + bay+Djoint*2;	
				nodeI2 = level*Dlevel + frame*Dframe+ bay+Djoint*2;
				nodeJ2 = level*Dlevel + frame*Dframe+ bay+1;	
	fprintf(file,'		element nonlinearBeamColumn %i %i %i $numIntgrPts $SpringSecTag $IDBeamTransf \n',elemID1, nodeI1, nodeJ1);
	fprintf(file,'		element nonlinearBeamColumn %i %i %i $numIntgrPts $SpringSecTag $IDBeamTransf \n',elemID2, nodeI2, nodeJ2 );
			end
		end
	end

	fprintf(file,'# girders -- parallel to Z-axis\n');
	fprintf(file,'set N0gird 2000000;	# gird element numbers\n');
	fprintf(file,'for {set frame 1} {$frame <=[expr $NFrame-1]} {incr frame 1} {\n');
	fprintf(file,'for {set level 2} {$level <=[expr $NStory+1]} {incr level 1} {\n');
	fprintf(file,'	for {set bay 1} {$bay <= $NBay+1} {incr bay 1} {\n');
	fprintf(file,'		set elemID [expr $N0gird + $level*$Dlevel +$frame*$Dframe+ $bay]\n');
	fprintf(file,'		set nodeI [expr   $level*$Dlevel + $frame*$Dframe+ $bay+ $DjointG]\n');
	fprintf(file,'		set nodeJ  [expr  $level*$Dlevel + $frame*$Dframe+ $bay +$DjointG*2]\n');
	fprintf(file,'		element elasticBeamColumn $elemID $nodeI $nodeJ %1.6f $Ec $Gc $J %1.6f %1.6f $IDGirdTransf;	\n',asset.AGird, asset.IzGird, asset.IyGird);	
	fprintf(file,'	}\n');
	fprintf(file,'}\n');
	fprintf(file,'}\n');
	
	fprintf(file,'# springs -- parallel to girders\n');
	NoSpringZ = 4000000;
	for  frame = 1:1:asset.noBayZ
		for level = 2:1:asset.noStoreys+1
			for	bay = 1:1:asset.noBays+1;
			elemID1 = NoSpringZ+level*Dlevel+frame*Dframe+bay+DjointG;
			nodeI1 = level*Dlevel+frame*Dframe+bay;
			nodeJ1 = level*Dlevel+frame*Dframe+bay+DjointG;
			elemID2 = NoSpringZ+(level-1)*Dlevel+frame*Dframe+bay+DjointG*2;
			nodeI2 = level*Dlevel+frame*Dframe+bay+DjointG*2;
			nodeJ2 = level*Dlevel+(frame+1)*Dframe+bay;
			fprintf(file,'		element nonlinearBeamColumn %i %i %i $numIntgrPts $SpringSecTag $IDBeamTransf \n',elemID1,nodeI1,nodeJ1 );
			fprintf(file,'		element nonlinearBeamColumn %i %i %i  $numIntgrPts $SpringSecTag $IDBeamTransf \n',elemID2,nodeI2,nodeJ2);
			end
		end
	end

   fprintf(file,'#MASSES \n');
   for level = 1:asset.noStoreys
	frame = 1;
		if asset.noBays > 1
			pier = 1;
			fprintf(file,'mass %i %2.3f %2.3f %2.3f 1e-9 1e-9 1e-9 \n',(level+1)*10000+frame*100+pier,action.massExt,action.massExt,action.massExt);
			for pier = 2:(asset.noBays);
				fprintf(file,'mass %i %2.3f %2.3f %2.3f 1e-9 1e-9 1e-9 \n',(level+1)*10000+frame*100+pier,action.massExt*2,action.massExt*2,action.massExt*2);
			end
			pier = (asset.noBays+1);
            fprintf(file,'mass %i %2.3f %2.3f %2.3f 1e-9 1e-9 1e-9 \n',(level+1)*10000+frame*100+pier,action.massExt,action.massExt,action.massExt);
		else
			for pier = 1:asset.noBays+1;
				fprintf(file,'mass %i %2.3f %2.3f %2.3f 1e-9 1e-9 1e-9 \n',(level+1)*10000+frame*100+pier,action.massExt,action.massExt,action.massExt);
			end
		end

    fprintf(file,'# define GRAVITY \n');
	fprintf(file,'pattern Plain 1 Linear {\n');
for level = 1:asset.noStoreys
		frame = 1;
		if asset.noBays > 1
			pier = 1;
			fprintf(file,'load %i 0. %2.3f 0. 0. 0. 0. \n',(level+1)*10000+frame*100+pier,-action.massExt*9.81);
			for pier = 2:(asset.noBays);
				fprintf(file,'load %i 0. %2.3f 0. 0. 0. 0. \n',(level+1)*10000+frame*100+pier,-action.massExt*2*9.81);
			end
			pier = (asset.noBays+1);
            fprintf(file,'load %i 0. %2.3f 0. 0. 0. 0. \n',(level+1)*10000+frame*100+pier,-action.massExt*9.81);
		else
			for pier = 1:asset.noBays+1;
				fprintf(file,'load %i 0. %2.3f 0. 0. 0. 0. \n',(level+1)*10000+frame*100+pier,-action.massExt*9.81);
			end
		end
end
      fprintf(file,'}\n');
	  
      fprintf(file,'# Define RECORDERS -------------------------------------------------------------\n'); 	  
      fprintf(file,'set FreeNodeID [expr $NFrame*$Dframe+($NStory+1)*$Dlevel+($NBay+1)];					# ID: free node\n'); 
      fprintf(file,'set SupportNodeFirst [lindex $iSupportNode 0];						# ID: first support node\n'); 
      fprintf(file,'set SupportNodeLast [lindex $iSupportNode [expr [llength $iSupportNode]-1]];			# ID: last support node\n'); 
	  fprintf(file,'set ColumnFirst [lindex $iColumns 0];\n'); 
      fprintf(file,'set ColumnLast [lindex $iColumns [expr [llength $iColumns]-1]];')   
	
    fprintf(file,'# EIGENVALUES \n');
	fprintf(file,'set pi [expr 2.0*asin(1.0)];\n');   
    fprintf(file,'set lambda [eigen  4];\n');
    fprintf(file,'set T [list [expr 2.0*$pi/pow([lindex $lambda 0],0.5)] [expr 2.0*$pi/pow([lindex $lambda 1],0.5)] [expr 2.0*$pi/pow([lindex $lambda 2],0.5)] [expr 2.0*$pi/pow([lindex $lambda 3],0.5)]]\n');  
    fprintf(file,'     set outfile [open "period.txt" w]\n');
    fprintf(file,'     puts $outfile $T \n');
    fprintf(file,'puts "T = $T s"\n');
	fprintf(file,'\n');
	
	% Eigenvectors
% 		node = 1;
% for  frame = 1:asset.noBayZ+1
% 	for pier = 1:asset.noBays+1
% 		level = 2;
% 		TopNode(node) = level*10000+frame*100+pier;
% 		node = node+1;
% 	end
% end
% 	  
% for node = 1:(asset.noBayZ+1)*(asset.noBays+1)
% 	fprintf(file,'recorder Node -file nodeEigen1_');
% 	fprintf(file,'n%i',node);
% 	fprintf(file,'.txt -node %i -dof 1 2 3 "eigen 1" \n',TopNode(node));
% 	fprintf(file,'recorder Node -file nodeEigen2_');
% 	fprintf(file,'n%i',node);
% 	fprintf(file,'.txt -node %i -dof 1 2 3 "eigen 2" \n',TopNode(node));
% end
	
	fprintf(file,'puts goGravity \n');
	fprintf(file,'# Gravity-analysis parameters -- load-controlled static analysis \n');
    fprintf(file,'# display deformed shape:\n');
    fprintf(file,'set ViewScale 5;\n');
    fprintf(file,'DisplayModel3D DeformedShape $ViewScale ;\n');
	fprintf(file,'set Tol 1.0e-8; \n');
	fprintf(file,'set NstepGravity 20; \n');
	fprintf(file,'set DGravity [expr 1./$NstepGravity]; \n');
    fprintf(file,'system BandGeneral\n');
    fprintf(file,'constraints Plain ;  # how it handles boundary conditions\n');
    fprintf(file,'numberer Plain\n');
    fprintf(file,'test NormDispIncr $Tol 10 3\n');
    fprintf(file,'algorithm Newton\n');
    fprintf(file,'integrator LoadControl $DGravity\n');
    fprintf(file,'analysis Static\n');
    fprintf(file,'analyze $NstepGravity \n');
	fprintf(file,'\n');
 	fprintf(file,'puts "Done!"');
    fclose(file);
    eval(['!',a,'/OpenSees',' ','buildInelasticModel3D.tcl']) 
end