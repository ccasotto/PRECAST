
%% Chiara Casotto
%  Phd Student, IUSS Pavia
%  Deriving fragility curves for industrial warehouses

clear all
clc
close all

%% Definition of the models
portfolio = [2 100 4];                                                     %the 1st value is the typology; the 2nd the number of buildings we want to produce, the 3rd the seismic coefficient
preCode = 1;                                                               %1 is precode and 2 is PostCode
cnn = 1;                                                                   %1 stands for corbel connection, 2 for "fork" connection
c = 0.2;
noTypologies = size(portfolio,1);
noLSs = 3; %number of limit states
constant = 0; % if vertical acceleration is an input constant = 0 else = 1;
fv = 0.6;% factor reducing axial load to account for vertical acceleration;

%% Seismic input
NGA = dir(horzcat('../NGArecords')); %NGA Peer database
lastNGA = length(NGA)-2;
addpath('../common/');

%% Analyses
for typology = 1:noTypologies
    pdm = variables(lastNGA, noLSs);
    noAsset = 1;
    while noAsset <= portfolio(typology,2)
        asset = sampleGeometry2D(portfolio(typology,1),preCode,portfolio(typology,3),c);
        asset.fv = fv; 
        action = computeActions(asset);
        asset = designAsset(asset,action);
        buildInelasticModel(asset,action);
        performPO(asset);
 		connection = ConnectionLimitState(asset ,action);
 		definelimitstates;
        PlotPushover;
        counter = 1;
 		for j = 1:3:lastNGA
 			[noAsset j]
 			[maxSteps] = parseAccelerogram3D(j,NGA,1);
 			dt = 0.01;
 			units = 'g';
 			fx =1;
            if constant == 1; fz = 0; else fz = 1; end
 			dynamic;
  			[output] = processOut( asset, constant );
            [output] = NewmarkSlidingBlock(output, action, connection.Vb(cnn), asset, dt); 
            close
  			[ DS ] = assignDamage( output, asset, limit, connection, cnn);
            pdm = BuildDPM(pdm, DS, counter);
 			counter = counter+1;
 		end
 		
		for i = 1:13
			t = [7 10 22 25 28 31 37 43 52 55 61 76 82];
			m = [1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.4 1.4 1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.4 1.4 1.4 1.2 1.4 1.4 1.4 1.4 1.2 1.2 1 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.2 1.4];
			h = t(i);
			[maxSteps] = parseAccelerogram3D(h,NGA,1);
			dt = 0.01;
			units = 'g';
            fx = m(3*(i-1)+2);
            if constant == 1; fz = 0; else fz = 1; end
            dynamic;
            [output] = processOut( asset, constant );
            [output] = NewmarkSlidingBlock(output, action, connection.Vb(cnn), asset, dt); 
            close
            [ DS ] = assignDamage( output, asset, limit, connection, cnn);
            pdm = BuildDPM(pdm, DS, counter);
            counter = counter+1;
        end
 		noAsset = noAsset+1;
    end
    dlmwrite(strcat('pdm',num2str(typology),'.tcl'),pdm.TOT,'delimiter','	');
    dlmwrite(strcat('pdmOC',num2str(typology),'.tcl'),pdm.OC,'delimiter','	');
    dlmwrite(strcat('pdmWO',num2str(typology),'.tcl'),pdm.WO,'delimiter','	');
end