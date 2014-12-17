
%% Chiara Casotto
%  Phd Student, IUSS Pavia
%  Deriving fragility curves for industrial warehouses
clear all
clc
close all
%% Definition of the models
portfolio = [1 100 4];                                                     %the 1st value is the typology; the 2nd the number of buildings we want to produce, the 3rd the seismic coefficient
preCode = 1;                                                               %1 is precode and 2 is PostCode
cnn = 1;                                                                   %1 stands for corbel connection, 2 for "fork" connection
c = [0.2 0.3];
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
    noAsset = 1;
	pdm = variables(lastNGA, noLSs,c);
	while noAsset <= portfolio(typology,2)
        asset = sampleGeometry(portfolio(typology,1),preCode,portfolio(typology,3),c);
        action = computeActions(asset);
        asset = designAsset(asset,action);
		connection = ConnectionLimitState(asset, action);
  		buildInelasticModel3D(asset,action);
		performPO3Dx
		performPO3Dy
 		dir = [1 0 1];
        performPO3D(asset,dir);
		[limit] = Limit3D(asset);	
		counter = 1;
		for j = 1:3:lastNGA
			[noAsset j]
			[maxSteps] = parseAccelerogram3D(j,NGA,2);
			dt = 0.01;
			time = dt:dt:(maxSteps*dt);
			fx = 1; fy = 1; fz = 1;
			units = 'g';
			dynamic3D;
			[output] = processOut(asset);
            [ output ] = NewmarkSlidingBlock3D(output, action, connection.Vb(cnn), asset, dt);
			[DS] = assignDamage3D(output,limit,asset, connection, cnn);
			pdm = BuildDPM(pdm, DS, counter);
% 			if noAsset == 1;
% 				for i = 0:2
% 				acc = dlmread(strcat('gmr',num2str(i),'.tcl'));
% 				time = dt:dt:(length(acc)*dt);
% 				response = Spectrum_v2([time' acc], 0.05, units, 2);
% 				pdm(counter,5+i) = response.Sa;
% 				end
% 			end
			counter = counter+1;
		end
		for i = 1:13
			[noAsset i]
			t = [7 10 22 25 28 31 37 43 52 55 61 76 82];
			m = [1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.4 1.4 1.2 1.2 1.2 1.3 1.3 1.3 1.4 1.4 1.4 1.4 1.2 1.4 1.4 1.4 1.4 1.2 1.2 1 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.2 1.4];
			fz = m(3*(i-1)+1);
			fx = m(3*(i-1)+2);
			fy = m(3*(i-1)+3);
			h = t(i);
			units = 'g';
			[maxSteps] = parseAccelerogram3D(h,NGA,2);
			dynamic3D;
            [output] = processOut(asset);
            [ output ] = NewmarkSlidingBlock3D(output, action, connection.Vb(cnn), asset, dt);
			[DS] = assignDamage3D(output,limit,asset, connection, cnn);
			pdm = BuildDPM(pdm, DS, counter);
% 			if noAsset==1;
% 				for i = 0:2
% 					acc = dlmread(strcat('gmr',num2str(i),'.tcl'));
% 					time = dt:dt:(length(acc)*dt);
% 					response = Spectrum_v2([time' acc], 0.05, units, 2);
% 					pdm(counter,5+i) = response.Sa;
% 				end
% 			end
			counter = counter+1;
		end
 		noAsset = noAsset+1;
	end
	close all
    for fr=1:length(c)
        dlmwrite(strcat('pdm',num2str(typology),'_',num2str(c(fr)),'.tcl'),pdm.TOT{fr},'delimiter','	');
        dlmwrite(strcat('pdmOC',num2str(typology),'_',num2str(c(fr)),'.tcl'),pdm.OC{fr},'delimiter','	');
        dlmwrite(strcat('pdmWO',num2str(typology),'_',num2str(c(fr)),'tcl'),pdm.WO{fr},'delimiter','	');
    end
end


