
%% Chiara Casotto
%  Phd Student, IUSS Pavia
%  Deriving fragility curves for industrial warehouses
clear all
clc
%close all
%% Definition of the models
portfolio = [1 5 4];                                                     %the 1st value is the typology; the 2nd the number of buildings we want to produce, the 3rd the seismic coefficient
preCode = 1;                                                               %1 is precode and 2 is PostCode
cnn = 1;
friction = [0.2 0.3];                                                      %1 stands for corbel connection, 2 for "fork" connection
noTypologies = size(portfolio,1);
noLSs = 3;                                                                 %number of limit states

%% Seismic input
a = pwd;
NGA = dir(horzcat(a,'\NGArecords'));                                       %NGA Peer database
lastNGA = length(NGA)-2;

disp_push = [];
reac_push = [];
blg_prm = [];
lim = [];
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
        T = dlmread('period.txt');
        disp_push = [noAsset 1 DispPo'];
        reac_push = [noAsset VbPo];
        blg_prm = [noAsset T(1) 1 asset.ColH_ground];
        dlmwrite(horzcat('displacements_pushover',num2str(noAsset),'.csv'),disp_push)
        dlmwrite(horzcat('reactions_pushover',num2str(noAsset),'.csv'),reac_push)
        dlmwrite(horzcat('building_parameters',num2str(noAsset),'.csv'),blg_prm)
 		noAsset = noAsset+1;
    end
end