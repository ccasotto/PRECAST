function [ limit ] = LimitV( asset )

%LIMIT This function computes the limit states for the 3D model
%%   Detailed explanation goes here
Vb_po = dlmread('nodeReaction_po.txt');

	for node = 1:(asset.noBayZ+1)*(asset.noBays+1)
		Disp_po(:,node) = dlmread(horzcat('nodeDisp_po_n',num2str(node),'.txt'))/asset.ColH_ground;
	end

Vb = sum(Vb_po')';
Steel = dlmread('SteelStressStrain.txt');
f = find(Steel(:,2) > asset.esy);
limit.LS1 = Disp_po(f(1),1); %Yielding of steel
limit.Vb1 = Vb(f(1)); 

end

