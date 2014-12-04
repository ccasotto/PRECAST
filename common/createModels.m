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
beta = zeros(1,noLSs);
blg_prms = zeros(portfolio(2)+1,1+500);
disp_push = zeros(1+portfolio(2)*asset.noStorey,2+500);
react_push = zeros(portfolio(2)+1,1+500);
LSs = [];
%% Seismic input
a = pwd;
%NGA Peer database
NGA = dir(horzcat(a,'\NGArecords'));
lastNGA = length(NGA)-2;
limit.results02 = 0;	
limit.results03 = 0;
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
        % connection capacity
        
            
        if geometry
            geom = [noAsset; asset.noStoreys; asset.noBays; asset.ColH_ground; asset.BeamLengths; asset.InterCol];
            sec = [asset.ColD; asset.ColW; asset.colSteelAreaNeg; asset.noBars; asset.AsBar; asset.Cover; asset.beamA; asset.beamIy; asset.beamIz; asset.AGird; asset.IyGird; asset.IzGird];
            matC = [asset.Rck; asset.E; asset.Fc; asset.Fuc; asset.ec; asset.euc; asset.Fcc; asset.Fucc; asset.ecc; asset.eucc];
            matS = [asset.Es; asset.Fy; asset.esy; asset.lambda];
            load = [action.massInt; action.massExt];
            conn = [action.colLoadExt*asset.c; connection.Vb(cnn)];

            data(:,noAsset) = [geom; sec; matC; matS; load; conn];

            xlswrite(horzcat('buildings_type',num2str(portfolio(typology,1)),'_',num2str(portfolio(typology,3)),'.xls'),data)
            %fprintf(file,'%s \n',data);
            %fclose(file)
        elseif RMTK
            buildInelasticModel(asset,action);
            performPO(asset);
            DispPo = dlmread('nodeDisp_po.txt');
			Reactions = dlmread('nodeReaction_po.txt');
			VbPo = -sum(Reactions');
            connection = ConnectionLimitState_v2(asset ,action);
            definelimitstates;
            T = dlmread('period.txt');
            T = T(1);
            blg_prms(noAsset+1,:) = [noAsset T 1 1/portfolio(2) 1 asset.ColH_ground];
            disp_push(noAsset+1,:) = [noAsset 1 DispPo'];
            react_push(noAsset+1,:) = [noAsset VbPo];
            LSs = [LSs; noAsset limit.LS1 limit.LS2; noAsset beta];
        end
        noAsset = noAsset+1;
    end
end
xlswrite('building_parameters.csv',blg_prms)
xlswrite('displacements_pushover.csv',disp_push)
xlswrite('reactions_pushover.csv',reac_push)
xlswrite('limit.csv',LSs)


