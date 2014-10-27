
%% Chiara Casotto
%  Phd Student, IUSS Pavia
%  Deriving fragility curves for industrial warehouses
clear all
clc
%close all
%% Definition of the models
portfolio = [1 100 4];                                                      %the 1st value is the typology; the 2nd the number of buildings we want to produce, the 3rd the seismic coefficient
preCode = 1;                                                               %1 is precode and 2 is PostCode
cnn = 1;
c = 0.2;                                                                   %1 stands for corbel connection, 2 for "fork" connection
noTypologies = size(portfolio,1);
noLSs = 3;                                                                 %number of limit states

%% Seismic input
a = pwd;
NGA = dir(horzcat(a,'/NGArecords'));                                       %NGA Peer database
lastNGA = length(NGA)-2;

%% Analyses
for typology = 1:noTypologies
	pdm = zeros(lastNGA/3+13,3);
	pdm3 = zeros(lastNGA/3+13,3);    
	pdmWO = zeros(lastNGA/3+13,3);
    pdmOC = zeros(lastNGA/3+13,3);
    pdmOC3 = zeros(lastNGA/3+13,3);
	DSpt = zeros(portfolio(typology,2),4);
    noAsset = 1;
     while noAsset <= portfolio(typology,2)
        asset = sampleGeometry2D_v2(portfolio(typology,1),preCode,portfolio(typology,3),c);
        action = computeActions(asset);
        asset = designAsset(asset,action);
 		buildInelasticModel3Djoints(asset,action);
 		performPO3D(asset);
		connection = ConnectionLimitStateV(asset ,action);
		definelimitstates;
	   	PlotPushover;
 		counter = 1;
		for j = 1:3:lastNGA
			[noAsset j]
			[maxSteps] = parseAccelerogram3D(j,NGA,2);
			 dt = 0.01;
			 time = dt:dt:(maxSteps*dt);
			 units = 'g';
			 	fx =1;
				fz = 1;
				fy = 0;
				dynamic3D;
				[output] = processOut( asset );
% 				figure (2)
% 				plot(time,output.axial(:,1)*asset.c)
% 				hold on
% 				plot(time,abs(output.V(:,2)),'r')
% 				close
				[DS] = assignDamageV(output,asset,limit,connection,cnn);
                [DS3] = assignDamageV3(output,asset,limit,connection,cnn);
				[WO] = assignDamageWoConnection(output,limit);
                [OC] = assignDamageOC(output,asset,limit,connection,cnn);
                [OC3] = assignDamageOC03(output,asset,limit,connection,cnn);
				pdm(counter,DS) = pdm(counter,DS)+1;
                pdm3(counter,DS3) = pdm3(counter,DS3)+1;
				pdmWO(counter,WO) = pdmWO(counter,WO)+1;
                pdmOC(counter,OC) = pdmOC(counter,OC)+1;
                pdmOC3(counter,OC3) = pdmOC3(counter,OC3)+1;
				counter = counter+1;
		end
		for i = 1:13
			t = [7 10 22 25 28 31 37 43 52 55 61 76 82];
			m = [1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.4 1.4 1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.4 1.4 1.4 1.2 1.4 1.4 1.4 1.4 1.2 1.2 1 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.2 1.4];
			h = t(i);
			[maxSteps] = parseAccelerogram3D(h,NGA,2);
			dt = 0.01;
			units = 'g';
				fz = m(3*(i-1)+1);
				fx = m(3*(i-1)+2);
				fy = 0;
				dynamic3D;
				[output] = processOut( asset );
				[DS] = assignDamageV(output,asset,limit,connection,cnn);
                [DS3] = assignDamageV3(output,asset,limit,connection,cnn);
				[WO] = assignDamageWoConnection(output,limit);
                [OC] = assignDamageOC(output,asset,limit,connection,cnn);
                [OC3] = assignDamageOC03(output,asset,limit,connection,cnn);
				pdm(counter,DS) = pdm(counter,DS)+1;
                pdm3(counter,DS3) = pdm3(counter,DS3)+1;
				pdmWO(counter,WO) = pdmWO(counter,WO)+1;
                pdmOC(counter,OC) = pdmOC(counter,OC)+1;
                pdmOC3(counter,OC3) = pdmOC3(counter,OC3)+1;
                counter = counter+1;
                
		end
		noAsset = noAsset+1;
		dlmwrite(strcat('pdm2',num2str(typology),'.tcl'),pdm,'delimiter','	');
		dlmwrite(strcat('pdm3',num2str(typology),'.tcl'),pdm3,'delimiter','	');
		dlmwrite(strcat('pdmOC',num2str(typology),'.tcl'),pdmOC,'delimiter','	');
		dlmwrite(strcat('pdmOC3',num2str(typology),'.tcl'),pdmOC3,'delimiter','	');
		dlmwrite(strcat('pdmWO',num2str(typology),'.tcl'),pdmWO,'delimiter','	');
		dlmwrite(strcat('DSpt',num2str(typology),'.tcl'),DSpt,'delimiter','	');
	end
end

%% PostProcessing the results for fragility curves



