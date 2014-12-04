function [ limit ] = Limit3D( asset )

%LIMIT This function computes the limit states for the 3D model
%   Detailed explanation goes here
	for node = 1:(asset.noBayZ+1)*(asset.noBays+1)
		Disp_po(:,1+((node-1)*3):3+((node-1)*3)) = dlmread(horzcat('nodeDisp_po_n',num2str(node),'.txt'))/asset.ColH_ground;
	end
Vb_po = dlmread('nodeReaction_po.txt');
Vb_po = abs(Vb_po);
ConcreteX = dlmread('ConcreteStressStrainX.txt');
ConcreteY = dlmread('ConcreteStressStrainX.txt');
SteelX = dlmread('SteelStressStrainX.txt');
SteelY = dlmread('SteelStressStrainY.txt');
LS2s = zeros(1,size(Vb_po,2)/3);
counter = 1;
	for j= 1:3:size(Vb_po,2)
		i = 2:1:length(Vb_po);
		h = 1:1:length(Vb_po)-1;
		dif = [Vb_po(1,j) (Vb_po(i,j)'-Vb_po(h,j)')];
		p = dif(i).*dif(1:(length(i)));
		f = find(dif <(-5));
		z = find(p<0);
		if numel(f) ~= 0
			Vb_po = Vb_po(1:f(1),:);
			Disp_po = Disp_po(1:f(1),:);
			SteelX = SteelX(1:f(1),:);
			SteelY = SteelY(1:f(1),:);
			LS2s(counter) = Disp_po(f(1),j);	
		else LS2s(counter) = Inf;
		end
% 		if numel(z) > 1
% 			Vb_po = Vb_po(1:z(2),:);
% 			Disp_po = Disp_po(1:z(2),:);
% 			LS2s(counter) = Disp_po(z(2),j);	
% 		else LS2s(counter) = Inf;
% 		end 
		i = 2:1:length(Vb_po);
		h = 1:1:length(Vb_po)-1;
		dif = (Vb_po(i,j+2)'-Vb_po(h,j+2)');
		p = dif(2:length(dif)).*dif(1:(length(dif)-1));
		f = find(dif <(-5));
		z = find(p<0);
		if numel(f) ~= 0
			Vb_po = Vb_po(1:f(1),:);
			Disp_po = Disp_po(1:f(1),:);
			SteelX = SteelX(1:f(1),:);
			SteelY = SteelY(1:f(1),:);
			LS2s(counter) = Disp_po(f(1),j+2);
		else LS2s(counter) = LS2s(counter);
		end
% 		if numel(z) > 1
% 			Vb_po = Vb_po(1:z(2),:);
% 			Disp_po = Disp_po(1:z(2),:);
% 			LS2s(counter) = Disp_po(z(2),j+2);	
% 		else LS2s(counter) = Inf;
% 		end 
 		counter = counter+1;
	end
v1 = 1:3:size(Vb_po,2);
v2 = 3:3:size(Vb_po,2);
DispX = Disp_po(:,v1);
DispY = Disp_po(:,v2);
Disp = (DispX.^2 + DispY.^2).^0.5;
VbX = sum(Vb_po(:,v1)')';
VbY = sum(Vb_po(:,v2)')';
plot(DispX(:,1),VbX,'b');
hold on
plot(DispY(:,1),VbY,'r');
clear j h z f 
% First Limit State for each column
fsx = find(SteelX(:,2) > asset.esy);
fsy = find(SteelY(:,2) > asset.esy);
f1 = [fsx(1) fsy(1)];
limit.LS1 = Disp(min(f1),1);
		
% First Limit State for the whole structure
limit.tot1 = min(limit.LS1);
	
% Second Limit State for each column
	LS220 = zeros(1,size(Vb_po,2)/3);
	counter = 1;
	for j= 1:3:size(Vb_po,2)
		Vbmax = max(Vb_po(:,j));
		Dispmax = Disp_po((Vb_po(:,j) == Vbmax),j);
		DispDec = Disp((Disp_po(:,j) > Dispmax(1)),counter);
		VbDec = Vb_po((Disp_po(:,j) > Dispmax(1)),j);
		f = find (VbDec < 0.8*Vbmax);
		if numel(f)==0
			Vb20x = Inf;
			LS220x = Inf;
		else
		Vb20x = VbDec(f(1));
		LS220x = DispDec (f(1));
		end
		Vbmax = max(Vb_po(:,j+2));
		Dispmax = Disp_po((Vb_po(:,j+2) == Vbmax),j+2);
		DispDec = Disp((Disp_po(:,j+2) > Dispmax(1)),counter);
		VbDec = Vb_po((Disp_po(:,j+2) > Dispmax(1)),j+2);
		f = find (VbDec < 0.8*Vbmax);
		if numel(f)==0
			Vb20y = Inf;
			LS220y = Inf;
		else
		Vb20y = VbDec(f(1));
		LS220y = DispDec (f(1));
		end
		LS220(counter) = min(LS220x,LS220y);
		counter = counter+1;
	end

% Second Limit State for the whole structure
%In X
	Vbmax = max(VbX);
	Dispmax = Disp_po((VbX == Vbmax),1);
	DispDec = Disp((Disp_po(:,1) > Dispmax(1)),1);
	VbDec = VbX(Disp_po(:,1) > Dispmax(1));
	f = find (VbDec < 0.8*Vbmax);
    if numel(f)==0
        LS220X = Inf;
	else
	LS220X = DispDec (f(1));
	end
	LS03x = Disp((DispX(:,1) > 0.03),1);
	if numel(LS03x)==0
        LS03x = Inf;
    end
%In y	
	Vbmax = max(VbY);
	Dispmax = Disp_po((VbY == Vbmax),3);
	DispDec = Disp((Disp_po(:,3) > Dispmax(1)),3);
	VbDec = VbY(Disp_po(:,3) > Dispmax(1));
	f = find (VbDec < 0.8*Vbmax);
    if numel(f)==0
        LS220Y = Inf;
    else
	LS220Y = DispDec (f(1));
	end
	LS03y = Disp((DispY(:,1) > 0.03),1);
	if numel(LS03y)==0
        LS03y = Inf;
    end
	LS03s = [LS03x(1) LS03y(1) 0.03];
	LS03 = min(LS03s);
	
	LS2tot = [LS2s LS220X LS220Y LS03]; % in the diagonal direction, composition of the 2 directions
	limit.tot2 = min(LS2tot);
	LS2s = [LS2s; LS220; 0.03*ones(1,length(LS2s))];
	limit.LS2 = min(LS2s,[],1);
% 	plot(limit.tot1*ones(length(Vb_po),1),VbX)
% 	plot(limit.tot2*ones(length(Vb_po),1),VbX)
	
%% Limits in the two directions separately
% In X
	for node = 1:(asset.noBayZ+1)*(asset.noBays+1)
		DispXX(:,node) = dlmread(horzcat('nodeDispX_po_n',num2str(node),'.txt'))/asset.ColH_ground;
	end
	VbXX = dlmread('nodeReactionX_po.txt');
	VbXX = sum(abs(VbXX'))';
	SteelXX = dlmread('SteelStressStrainXX.txt');
% First Limit State for the whole structure
	counter = 1;
	for j= 2:2:size(SteelXX,2)
		LS1x = DispXX((SteelXX(:,j) > asset.esy),j/2); %Yielding of steel
		dX1(counter) = LS1x(1);
		counter = counter+1;
	end
	limit.dX1 = min(dX1);
	
% Second Limit State for the whole structure
	Vbmax = max(VbXX(:,1));
	Dispmax = DispXX((VbXX(:,1) == Vbmax),1);
	DispDec = DispXX((DispXX(:,1) > Dispmax(1)),1);
	VbDec = VbXX(DispXX(:,1) > Dispmax(1));
	f = find (VbDec < 0.8*Vbmax);
    if numel(f)==0
        limit.dX2 = 0.03;
	else
	limit.dX2 = min(DispDec (f(1)),0.03);
	end

% In Y
	for node = 1:(asset.noBayZ+1)*(asset.noBays+1)
		DispYY(:,node) = dlmread(horzcat('nodeDispY_po_n',num2str(node),'.txt'))/asset.ColH_ground;
	end
	VbYY = dlmread('nodeReactionY_po.txt');
	VbYY = sum(abs(VbYY'));
	SteelYY = dlmread('SteelStressStrainYY.txt');
% First Limit State for the whole structure
	counter = 1;
	for j= 2:2:size(SteelYY,2)
		LS1y = DispYY((SteelYY(:,j) > asset.esy),j/2); %Yielding of steel
		dY1(counter) = LS1y(1);
		counter = counter+1;
	end
	limit.dY1 = min(dY1);
	
% 	dY1 = DispYY((SteelYY(:,2) > asset.esy),1); %Yielding of steel	
% 	limit.dY1 = dY1(1);
% Second limit state for whole structure
	Vbmax = max(VbYY(:,1));
	Dispmax = DispYY((VbYY(:,1) == Vbmax),1);
	DispDec = DispYY((DispYY(:,1) > Dispmax(1)),1);
	VbDec = VbYY(DispYY(:,1) > Dispmax(1));
	f = find (VbDec < 0.8*Vbmax);
    if numel(f)==0
        limit.dY2 = 0.03;
	else
	limit.dY2 = min(DispDec (f(1)),0.03);
	end
	
end

