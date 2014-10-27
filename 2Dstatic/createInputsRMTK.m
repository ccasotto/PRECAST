%% Chiara Casotto
%  Phd Student, IUSS Pavia
%  Deriving inputs for industrial warehouses
% Pavia, 17-October-2014

clear all
clc
close all

%% Definition of the models
geometry = 0; % print geometric configurations
RMTK = 1; % print inputs for RMTK
% portfolio = [typology (1 or 2), buildings to produce, seismic coefficient (4, 6, 9 or 12)]
portfolio = [1 100 9];
% preCode = 1 means pre-code, preCode = 2 means low-code
preCode = [2];
% cnn = 1 stands for corbel connection, cnn = 2 for "fork" connection
cnn = 1;
% c friction coefficient
c = 0.2;
noTypologies = size(portfolio,1);
%number of limit states
noLSs = 2;

%% Seismic input
a = pwd;
%NGA Peer database
NGA = dir(horzcat(a,'\NGArecords'));
lastNGA = length(NGA)-2;
limit.results02 = 0;	
limit.results03 = 0;
beta = zeros(1,noLSs);
blg_prms = zeros(portfolio(2)+1,6);
disp_push = zeros(1+portfolio(2),2+500);
react_push = zeros(portfolio(2)+1,1+500);
LSs = [];

%% Analyses

for typology = 1:noTypologies
    noAsset = 1;
    %file = fopen(horzcat('buildings_type',num2str(portfolio(typology,1)),'_',num2str(portfolio(typology,3)),'.tcl'), 'w+');
    while noAsset <= portfolio(typology,2)
        % sample the geometric properties according to typology and code
        asset = sampleGeometry2D_v2(portfolio(typology,1),preCode(typology),portfolio(typology,3),c);
        % compute actions
        action = computeActions(asset);
        % design the sections
        asset = designAsset(asset,action);       
        buildInelasticModel(asset,action);
        performPO(asset);
        DispPo = dlmread('nodeDisp_po.txt')/asset.ColH_ground;
        Reactions = dlmread('nodeReaction_po.txt');
        VbPo = -sum(Reactions');
        % connection capacity
        connection = ConnectionLimitState_v2(asset ,action);
        definelimitstates;
        T = dlmread('period.txt');
        T = T(1);
        DispPo = dlmread('nodeDisp_po.txt');
        blg_prms(noAsset+1,:) = [noAsset T 1 1/portfolio(2) 1 asset.ColH_ground];
        disp_push(noAsset+1,1:2+length(DispPo)) = [noAsset 1 DispPo'];
        react_push(noAsset+1,1:1+length(VbPo)) = [noAsset VbPo];
        LSs = [LSs; noAsset limit.LS1 limit.LS2; noAsset beta];
        noAsset = noAsset+1;
    end
    %xlswrite(horzcat('building_parameters',num2str(typology),'.csv'),blg_prms)
    %xlswrite(horzcat('displacements_pushover',num2str(typology),'.csv'),disp_push)
    %xlswrite(horzcat('reactions_pushover',num2str(typology),'.csv'),react_push)
    xlswrite(horzcat('limits',num2str(typology),'.csv'),LSs)
end



