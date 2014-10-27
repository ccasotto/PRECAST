
%% Chiara Casotto
%  Phd Student, IUSS Pavia
%  Deriving fragility curves for industrial warehouses
clear all
clc
%close all
%% Definition of the models
portfolio = [1 100 9];                                                     %the 1st value is the typology; the 2nd the number of buildings we want to produce, the 3rd the seismic coefficient
preCode = 2;                                                               %1 is precode and 2 is PostCode
cnn = 1;
friction = [0.2 0.3];                                                      %1 stands for corbel connection, 2 for "fork" connection
noTypologies = size(portfolio,1);
noLSs = 3;                                                                 %number of limit states

%% Seismic input
a = pwd;
NGA = dir(horzcat(a,'\NGArecords'));                                       %NGA Peer database
lastNGA = length(NGA)-2;

%% Analyses
for typology = 1:noTypologies
	pdm = zeros(lastNGA/3+13,3);
	pdm3= zeros(lastNGA/3+13,3);
	pdmWO = zeros(lastNGA/3+13,3);
	pdmOC = zeros(lastNGA/3+13,3);
	pdmOC3 = zeros(lastNGA/3+13,3);
	DSpt = zeros(portfolio(typology,2),4);
    noAsset = 1;
	limit.results02 = 0;
	limit.results03 = 0;
    pushovers = zeros(500,portfolio(typology,2)*2);
    while noAsset <= portfolio(typology,2)
        noAsset
        asset = sampleGeometry2D_v2(portfolio(typology,1),preCode,portfolio(typology,3),friction);
        action = computeActions(asset);
        asset = designAsset(asset,action);
        buildInelasticModel(asset,action);
        performPO(asset);
			%DispPo = dlmread('nodeDisp_po.txt')/asset.ColH_ground;
            DispPo = dlmread('nodeDisp_po.txt');
			Reactions = dlmread('nodeReaction_po.txt');
			VbPo = -sum(Reactions');
            pushovers(1:length(DispPo),noAsset*2-1:noAsset*2) = [DispPo VbPo'];
 		connection = ConnectionLimitState_v2(asset ,action);
 		definelimitstates;
% 		plotPushover(DispPo,VbPo,limit.LS1,limit.Vb1,limit.LS2,limit.Vb2,limit.LSconnection(1),limit.Vbconnection(1));
%   		counter = 1;
% 		for j = 1:3:lastNGA
% 			[noAsset j]
% 			[maxSteps] = parseAccelerogram3D(j,NGA,2);
% 			 dt = 0.01;
% 			 units = 'g';
% 				fx =1;
% 				dynamic;
%  				[output] = processOut( asset );
%  				assignDamage;
% 				assignDamage03;
%  				assignDamageWoConnection;
%  				[OC] = assignDamageOC(output,limit);
% 				[OC3] = assignDamageOC3(output,limit);
% 				pdm(counter,DS) = pdm(counter,DS)+1;
% 				pdm3(counter,DS3) = pdm3(counter,DS3)+1;
% 				pdmWO(counter,WO) = pdmWO(counter,WO)+1;
% 				pdmOC(counter,OC) = pdmOC(counter,OC)+1;
% 				pdmOC3(counter,OC3) = pdmOC3(counter,OC3)+1;
% 				counter = counter+1;
% 		end
% 		
% 		for i = 1:13
% 			t = [7 10 22 25 28 31 37 43 52 55 61 76 82];
% 			m = [1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.4 1.4 1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.4 1.4 1.4 1.2 1.4 1.4 1.4 1.4 1.2 1.2 1 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.2 1.4];
% 			h = t(i);
% 			[maxSteps] = parseAccelerogram3D(h,NGA,2);
% 			dt = 0.01;
% 			units = 'g';
% 				fx = m(3*(i-1)+2);
% 				dynamic;
% 				[output] = processOut( asset );
% 				assignDamage;
% 				assignDamage03;
%  				assignDamageWoConnection;
%  				[OC] = assignDamageOC(output,limit);
% 				[OC3] = assignDamageOC3(output,limit);
% 				pdm(counter,DS) = pdm(counter,DS)+1;
% 				pdm3(counter,DS3) = pdm3(counter,DS3)+1;
% 				pdmWO(counter,WO) = pdmWO(counter,WO)+1;
% 				pdmOC(counter,OC) = pdmOC(counter,OC)+1;
% 				pdmOC3(counter,OC3) = pdmOC3(counter,OC3)+1;
% 				counter = counter+1;
%  		end
% 		dlmwrite('pdm2.tcl',pdm,'delimiter','	');
% 		dlmwrite('pdm3.tcl',pdm3,'delimiter','	');
% 		dlmwrite('pdmWO.tcl',pdmWO,'delimiter','	');
% 		dlmwrite('pdmOC2.tcl',pdmOC,'delimiter','	');
% 		dlmwrite('pdmOC3.tcl',pdmOC3,'delimiter','	');
% 		dlmwrite('DSpt.tcl',DSpt,'delimiter','	');
 		noAsset = noAsset+1;
    end
end