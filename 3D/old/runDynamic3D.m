!
%% Chiara Casotto
%  Phd Student, IUSS Pavia
%  Deriving fragility curves for industrial warehouses
clear all
clc
close all
%% Definition of the models
portfolio = [1 1 6];                                                      %the 1st value is the typology; the 2nd the number of buildings we want to produce, the 3rd the seismic coefficient
preCode = 1;                                                               %1 is precode and 2 is PostCode
cnn = 1;                                                                   %1 stands for corbel connection, 2 for "fork" connection
noTypologies = size(portfolio,1);
noLSs = 3;                                                                 %number of limit states
a = pwd;
c = 0.2;

%% Seismic input
NGA = dir(horzcat(a,'\NGArecords'));
lastNGA = length(NGA)-2;
%% Analyses
for typology = 1:noTypologies
    noAsset = 1;
	pdm = zeros(lastNGA/3+13,3);
	pdm3 = zeros(lastNGA/3+13,3);
	pdmOC = zeros(lastNGA/3+13,3);
	pdmOC3 = zeros(lastNGA/3+13,3);
	pdmWO = zeros(lastNGA/3+13,3);
	while noAsset <= portfolio(typology,2)
        asset = sampleGeometry3D(portfolio(typology,1),preCode,portfolio(typology,3),c);
        action = computeActions3D(asset);
        asset = designAsset(asset,action);
  		buildInelasticModel3Djoints(asset,action);
 		dir = [1 0 1];
        performPO3D(asset,dir);
		[limit] = Limit3D(asset);
		counter = 1;
		for j = 1:3:lastNGA
			[maxSteps] = parseAccelerogram3D(j,NGA,2);
			dt = 0.01;
			time = dt:dt:(maxSteps*dt);
			fx = 1; %multipliers to scale the records
			fy = 1;
			fz = 1;
			units = 'g';
			dynamic3D;	
			[output] = processdata(asset);
			[DS] = assignDamage3D(output,limit,asset);
			[DS3] = assignDamage3D3(output,limit,asset);
			[OC] = assignDamageOC(output);
			[OC3] = assignDamageOC3(output);
			[WO] = assignDamageWO(output,limit,asset);
			pdm(counter,DS) = pdm(counter,DS)+1;
			pdm3(counter,DS3) = pdm3(counter,DS3)+1;
			pdmOC(counter,OC) = pdmOC(counter,OC)+1;
			pdmOC3(counter,OC3) = pdmOC3(counter,OC3)+1;
			pdmWO(counter,WO) = pdmWO(counter,WO)+1;
			for i = 0:2
				acc = dlmread(strcat('gmr',num2str(i),'.tcl'));
				time = dt:dt:(length(acc)*dt);
				response = Spectrum_v2([time' acc], 0.05, units, 2);
				pdm(counter,4+i) = response.Sa;
			end
			counter = counter+1;
		end
		for i = 1:13
			t = [7 10 22 25 28 31 37 43 52 55 61 76 82];
			m = [1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.4 1.4 1.2 1.2 1.2 1.3 1.3 1.3 1.4 1.4 1.4 1.4 1.2 1.4 1.4 1.4 1.4 1.2 1.2 1 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.2 1.4];
			fz = m(3*(i-1)+1);
			fx = m(3*(i-1)+2);
			fy = m(3*(i-1)+3);
			h = t(i);
			units = 'g';
			[maxSteps] = parseAccelerogram3D(h,NGA,2);
			dynamic3D;
			[output] = processdata(asset);
			[DS] = assignDamage3D(output,limit,asset);
			[DS3] = assignDamage3D3(output,limit,asset);
			[OC] = assignDamageOC(output);
			[OC3] = assignDamageOC3(output);
			[WO] = assignDamageWO(output,limit,asset);
			pdm(counter,DS) = pdm(counter,DS)+1;
			pdm3(counter,DS3) = pdm3(counter,DS3)+1;
			pdmOC(counter,OC) = pdmOC(counter,OC)+1;
			pdmOC3(counter,OC3) = pdmOC3(counter,OC3)+1;
			pdmWO(counter,WO) = pdmWO(counter,WO)+1;
			for i = 0:2
				acc = dlmread(strcat('gmr',num2str(i),'.tcl'));
				time = dt:dt:(length(acc)*dt);
				response = Spectrum_v2([time' acc], 0.05, units, 2);
				pdm(counter,4+i) = response.Sa;
			end
			counter = counter+1;
		end
 		noAsset = noAsset+1;
	end
	close all
	dlmwrite(strcat('pdm',num2str(typology),'.tcl'),pdm,'delimiter','	');
	dlmwrite(strcat('pdm3',num2str(typology),'.tcl'),pdm3,'delimiter','	');
	dlmwrite(strcat('pdmOC',num2str(typology),'.tcl'),pdmOC,'delimiter','	');
	dlmwrite(strcat('pdmOC3',num2str(typology),'.tcl'),pdmOC3,'delimiter','	');
	dlmwrite(strcat('pdmWO',num2str(typology),'.tcl'),pdmWO,'delimiter','	');
end


