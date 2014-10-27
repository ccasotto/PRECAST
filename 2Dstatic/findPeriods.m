clc
clear all
close all
portfolio = [2 100 6];
preCode = 1;
cnn=1;
noTypologies = size(portfolio,1);
typology = 1;
Tls = zeros(noTypologies,1);
LSs = zeros(portfolio(1,2),2);
friction = [0.2 0.3];

for typology = 1:noTypologies
 noAsset = 1;
 T = [];
 L1=[];
 	limit.results02 = 0;
	limit.results03 = 0;
	action.axial = [];
while noAsset <= portfolio(typology,2)
        asset = sampleGeometryToscana2D(portfolio(typology,1),preCode,portfolio(typology,3),friction);
        action = computeActions(asset,action);
        asset = designAsset(asset,action);
		buildInelasticModel(asset,action);
        performPO(asset);
			DispPo = dlmread('nodeDisp_po.txt')/asset.ColH_ground;
			Reactions = dlmread('nodeReaction_po.txt');
			VbPo = -sum(Reactions');
		connection = ConnectionLimitState_v2(asset ,action);
		definelimitstates;
		%PlotPushover;
		M = action.massIntNode*max((asset.noBays-1),1) + action.massExtNode*asset.noBays;
		Sd1 = limit.LS1*(asset.ColH_ground);
		Sa1 = limit.Vb1/M;
		t1 = 2*pi*sqrt(Sd1/Sa1);
		mu = limit.LS2/limit.LS1;
		t2 = t1*sqrt(mu);
% 		Ky = limit.Vb1/limit.LS1;
% 		Kls = limit.Vb2/limit.LS2;
% 		t2 = t1*sqrt(Ky/Kls);
%  		PoPeriod;
% 		pause(0.5)
%  		t = dlmread('period.txt');
   		T = [T;t1 t2];
% 		L1=[L1; limit.Vb1];
%  		LSs(noAsset,1:2)=[limit.LS1 limit.LS2];
		noAsset = noAsset+1;
end
  Tls = mean(T)
 %LS = mean(LSs,1);
end


