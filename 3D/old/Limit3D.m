function [ limit ] = Limit3D( asset )

%LIMIT This function computes the limit states for the 3D model
%%   Detailed explanation goes here
	for node = 1:(asset.noBayZ+1)*(asset.noBays+1)
		Disp_po(:,1+((node-1)*3):3+((node-1)*3)) = dlmread(horzcat('nodeDisp_po_n',num2str(node),'.txt'))/asset.ColH_ground;
	end
Vb_po = dlmread('nodeReaction_po.txt');
Vb_po = abs(Vb_po);
SteelX = dlmread('SteelStressStrainX.txt');
SteelY = dlmread('SteelStressStrainY.txt');
i = 2:1:length(Vb_po);
LS2s = zeros(1,size(Vb_po,2)/3);
counter = 1;
	for j= 1:3:size(Vb_po,2)
		dif = (Vb_po(i,j)'-Vb_po(1:length(Vb_po)-1,j)');
		f = find(dif <(-10));
		if numel(f) ~= 0
			Vb_po = Vb_po(1:f(1),:);
			Disp_po = Disp_po(1:f(1),:);
			LS2s(counter) = Disp_po(f(1),j);	
		else LS2s(counter) = Inf;
		end
		dif = (Vb_po(i,j+2)'-Vb_po(1:length(Vb_po)-1,j+2)');
		f = find(dif <(-10));
		if numel(f) ~= 0
			Vb_po = Vb_po(1:f(1),:);
			Disp_po = Disp_po(1:f(1),:);
			LS2s(counter) = Disp_po(f(1),j+2);
		else LS2s(counter) = LS2s(counter);
		end
% 		figure(j)
% 		plot(Disp_po(:,j),Vb_po(:,j));
% 		hold on
% 		plot(Disp_po(:,j+2),Vb_po(:,j+2),'r');
 		counter = counter+1;
	end
	
v1 = 1:3:size(Vb_po,2);
v2 = 3:3:size(Vb_po,2);
DispX = Disp_po(:,v1);
DispY = Disp_po(:,v2);
VbX = sum(Vb_po(:,v1)')';
VbY = sum(Vb_po(:,v2)')';
figure (j+1)
plot(Disp_po(:,1),VbX)
hold on
plot(Disp_po(:,3),VbY,'r')
% First Limit State for each column
limit.LS1 = zeros(1,size(Vb_po,2)/3);
counter = 1;
	for j= 2:2:size(SteelX,2)
		LS1x = DispX((SteelX(:,j) > asset.esy),j/2); %Yielding of steel
		LS1y = DispY((SteelY(:,j) > asset.esy),j/2);
		limit.LS1(counter) = min(LS1x(1),LS1y(1));
		counter = counter+1;
	end
% First Limit State for the whole structure
limit.tot1 = min(limit.LS1);
	
% Second Limit State for each column
	LS220 = zeros(1,size(Vb_po,2)/3);
	counter = 1;
	for j= 1:3:size(Vb_po,2)
		Vbmax = max(Vb_po(:,j));
		Dispmax = Disp_po((Vb_po(:,j) == Vbmax),j);
		DispDec = Disp_po((Disp_po(:,j) > Dispmax(1)),j);
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
		DispDec = Disp_po((Disp_po(:,j+2) > Dispmax(1)),j+2);
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
	DispDec = Disp_po((Disp_po(:,1) > Dispmax(1)),1);
	VbDec = VbX(Disp_po(:,1) > Dispmax(1));
	f = find (VbDec < 0.8*Vbmax);
    if numel(f)==0
        LS220X = Inf;
	else
	LS220X = DispDec (f(1));
	end
%In y	
	Vbmax = max(VbY);
	Dispmax = Disp_po((VbY == Vbmax),3);
	DispDec = Disp_po((Disp_po(:,3) > Dispmax(1)),3);
	VbDec = VbY(Disp_po(:,3) > Dispmax(1));
	f = find (VbDec < 0.8*Vbmax);
    if numel(f)==0
        LS220Y = Inf;
    else
	LS220Y = DispDec (f(1));
	end
	LS2tot = [LS2s LS220X LS220Y 0.03];
	limit.tot2 = min(LS2tot);
	LS2s = [LS2s; LS220; 0.03*ones(1,length(LS2s))];
	limit.LS2 = min(LS2s,[],1);
	plot(limit.tot1*ones(length(Vb_po),1),VbX)
	plot(limit.tot2*ones(length(Vb_po),1),VbX)
end

