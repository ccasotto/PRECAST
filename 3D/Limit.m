function [ limit ] = Limit( asset )

%LIMIT This function computes the limit states for the 3D model
%%   Detailed explanation goes here
VbX_po = dlmread('nodeReactionX_po.txt');
VbY_po = dlmread('nodeReactionY_po.txt');

	for node = 1:(asset.noBayZ+1)*(asset.noBays+1)
		Disp_poX(:,node) = dlmread(horzcat('nodeDispX_po_n',num2str(node),'.txt'))/asset.ColH_ground;
	end
	for node = 1:(asset.noBayZ+1)*(asset.noBays+1)
		Disp_poY(:,node) = dlmread(horzcat('nodeDispY_po_n',num2str(node),'.txt'))/asset.ColH_ground;
	end	
% 	for node = 1:(asset.noBayZ+1)*(asset.noBays+1)
% 		EigenVectors1(:,1+((node-1)*3):3+((node-1)*3)) = dlmread(horzcat('nodeEigen1_n',num2str(node),'.txt'));
% 		EigenVectors2(:,1+((node-1)*3):3+((node-1)*3)) = dlmread(horzcat('nodeEigen2_n',num2str(node),'.txt'));
% 	end

VbX = sum(VbX_po')';
VbY = sum(VbY_po')';	
SteelX = dlmread('SteelStressStrainXX.txt');
SteelY = dlmread('SteelStressStrainYY.txt');
f=find(SteelX(:,2) > asset.esy);
limit.LS1X = Disp_poX(f(1),1); %Yielding of steel
limit.Vb1X = VbX(f(1));
limit.pX = f(1);
f=find(SteelY(:,2) > asset.esy);
limit.LS1Y = Disp_poY(f(1),1);
limit.Vb1Y = VbY(f(1)); 
limit.pY = f(1);
end

