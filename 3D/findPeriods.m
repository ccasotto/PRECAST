portfolio = [1 100 6];                                                      %the 1st value is the typology; the 2nd the number of buildings we want to produce, the 3rd the seismic coefficient
preCode = 1;                                                               %1 is precode and 2 is PostCode
cnn = 1;                                                                   %1 stands for corbel connection, 2 for "fork" connection
noTypologies = size(portfolio,1);
noLSs = 3;                                                                 %number of limit states
a = pwd;
c = 0.2;
T = [];
%% Analyses
for typology = 1:noTypologies
    noAsset = 1;
	while noAsset <= portfolio(typology,2)
        asset = sampleGeometryToscana3D(portfolio(typology,1),preCode,portfolio(typology,3),c);
        action = computeActions3D(asset);
        asset = designAsset(asset,action);
  		buildInelasticModel3Djoints(asset,action);
		performPO3Dx
		performPO3D(asset,[1 0 1]);
		[limit] = Limit(asset);
		t = dlmread('period.txt')
   		T = [T;t(limit.pY)];
		noAsset = noAsset+1;
end
  Tls = mean(T);
 end


