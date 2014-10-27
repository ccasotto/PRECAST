function [output] = processdata( asset,chord,maxSteps )
%processsata This function process the results of the dynamic analysis
%   All the results are expressed in terms of each column and each
%   direction

	output.force = dlmread('ForceCol_dynamic.txt');
	output.Reaction = dlmread('nodeReaction_dynamic.txt');
	output.disp = dlmread('nodeDisp_dynamic.txt');
	output.def = dlmread('DeformCol_dynamic.txt');
	
	% Stress-Strain outputs
	for corner = 1:4
		output.Cstress(1+maxSteps*(corner-1):maxSteps*corner,1:(asset.noBays+1)*(asset.noBayZ+1)*2) = dlmread(horzcat('CStressCol_F',num2str(corner),'.txt'));
		output.Sstress(1+maxSteps*(corner-1):maxSteps*corner,1:(asset.noBays+1)*(asset.noBayZ+1)*2) = dlmread(horzcat('SStressCol_F',num2str(corner),'.txt'));
	end
	strain = 2:2:size(output.Cstress,2);
	output.CStrain = output.Cstress(:,strain);
	output.SStrain = output.Sstress(:,strain);
	
	% Displacements
% 	for frame = 1:asset.noBayZ+1
% 		output.Disp(1+maxSteps*(frame-1):maxSteps*frame,1:9) = dlmread(horzcat('nodeDisp_dynamic_f',num2str(frame),'.txt'));
% 	end
	piers = asset.noBays+1;
	for frame = 1:asset.noBayZ+1
		output.Disp(1:maxSteps,1+(frame-1)*piers*3:piers*frame*3) = dlmread(horzcat('nodeDisp_dynamic_f',num2str(frame),'.txt'));
	end
	x = 1:3:size(output.Disp,2);
	y = 3:3:size(output.Disp,2);
	z = x+1;
	output.DispX = output.Disp(:,x);    %X displacement for all the columns, for all the frames(one below the other) 
	output.DispY = output.Disp(:,y);
	output.DispZ = output.Disp(:,z);
	
	% Internal Actions
	n = 1:12:size(output.force,2);
	axial = output.force(:,n);
	output.Vfr = axial*asset.c;
	v1 = 2:12:size(output.force,2);
	v2 = 3:12:size(output.force,2);
	output.Vx = output.force(:,v1);
	output.Vy = output.force(:,v2);
	output.Ved = sqrt((output.force(:,v1)).^2+(output.force(:,v2)).^2);
	e = 1:4:size(output.def,2);
	fx = e+1;
	fy = e+2;
	
	% Deformations and chord rotations
	output.defe = output.def(:,e);
	output.deffx = output.def(:,fx);
	output.deffy = output.def(:,fy);
	for i = 1:size(output.deffx,2)
		output.rotX(:,i) = chord.zyX + (abs(output.deffx(:,i))-chord.PyX)*chord.LplX*(1-0.5*chord.LplX/asset.ColH_ground);
		f = find(abs(output.deffx(:,i))<=chord.PyX);
		output.rotX(f,i) = abs(output.deffx(f,i)*asset.ColH_ground/3+0.0013*(1+1.5*asset.ColW/asset.ColH_ground)+0.13*output.deffx(f,i)*asset.barA*asset.Fy/sqrt(asset.Fc));
		output.rotY(:,i) = chord.zyY + (abs(output.deffy(:,i))-chord.PyY)*chord.LplY*(1-0.5*chord.LplY/asset.ColH_ground);
		f = find(abs(output.deffy(:,i))<=chord.PyY);
		output.rotY(f,i) = abs(output.deffy(f,i)*asset.ColH_ground/3+0.0013*(1+1.5*asset.ColD/asset.ColH_ground)+0.13*output.deffy(f,i)*asset.barA*asset.Fy/sqrt(asset.Fc));
	end

end

