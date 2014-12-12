function [output] = processOut( asset )
%processsata This function process the results of the dynamic analysis
%   All the results are expressed in terms of each column and each
%   direction

	output.force = dlmread('tmp/ForceCol_dynamic.txt');
	output.Reaction = dlmread('tmp/nodeReaction_dynamic.txt');
	output.def = dlmread('tmp/DeformCol_dynamic.txt');
	
	% Stress-Strain outputs
% 	for corner = 1:4
% 		output.Cstress(1+maxSteps*(corner-1):maxSteps*corner,1:(asset.noBays+1)*(asset.noBayZ+1)*2) = dlmread(horzcat('CStressCol_F',num2str(corner),'.txt'));
% 		output.Sstress(1+maxSteps*(corner-1):maxSteps*corner,1:(asset.noBays+1)*(asset.noBayZ+1)*2) = dlmread(horzcat('SStressCol_F',num2str(corner),'.txt'));
% 	end
% 	strain = 2:2:size(output.Cstress,2);
% 	output.CStrain = output.Cstress(:,strain);
% 	output.SStrain = output.Sstress(:,strain);
	
	% Displacements
	for node = 1:(asset.noBayZ+1)*(asset.noBays+1)
		output.Disp(:,1+((node-1)*3):3+((node-1)*3)) = dlmread(horzcat('tmp/nodeDisp_dynamic_n',num2str(node),'.txt'));
    end
	x = 1:3:size(output.Disp,2);
	y = 3:3:size(output.Disp,2);
	z = x+1;
	output.DispX = output.Disp(:,x)/asset.ColH_ground;    %X displacement for all the columns, for all the frames(one below the other) 
	output.DispY = output.Disp(:,y)/asset.ColH_ground;
	output.DispZ = output.Disp(:,z)/asset.ColH_ground;
	output.Dist = (output.DispX.^2 + output.DispY.^2).^0.5;
	
    output.accX = dlmread('tmp/nodeAccX_dynamic.txt');
    output.accY = dlmread('tmp/nodeAccY_dynamic.txt');
	% Internal Actions
	n = 1:12:size(output.force,2);
	output.axial = output.force(:,n);
    for fr = 1:length(asset.c)
        output.Vfr{fr} = output.axial*asset.c(fr);
    end
	v1 = 2:12:size(output.force,2);
	v2 = 3:12:size(output.force,2);
	output.Vx = output.force(:,v1);
	output.Vy = output.force(:,v2);
	output.Ved = sqrt((output.force(:,v1)).^2+(output.force(:,v2)).^2);
	
end

