function asset = sampleGeometryToscana2D(type,preCode,s,c)

    asset.Code = preCode;
    asset.s = s;
	asset.c = c;
 % type 1
 if type == 1
	asset.type = 1;
    asset.noStoreys = 1;
	asset.noBayZ = 0;
    asset.noBays = 2;
    asset.ColH_ground = sampleTruncLognrml(1.9,0.2,4,12,1,1);
    asset.BeamLengths = sampleTruncLognrml(2.7,0.3,8,30,1,1);
    asset.BeamW = 1.5;
	asset.InterCol = sampleTruncNrml(9.0,1.0,8,10,1,1);
	asset.beamA = 0.107;             %sistema beam details
	asset.beamIy = 0.0134;
	asset.beamIz = 0.0002917;
	asset.AGird = 0.107;
	asset.IzGird = 0.0134;
	asset.IyGird = 0.0002917;
% type 2
 else
	asset.type = 2;
    asset.noStoreys = 1;
 	asset.noBays = 4;
	asset.noBayZ = 0;
% 	asset.noBays = round(sampleTruncLognrml(4,5.1,1,8));
    asset.ColH_ground = sampleTruncNrml(6.5,1.3,4,11,1,1); 
    asset.BeamLengths = sampleTruncNrml(8.7,2,8,10,1,1); 
   	asset.InterCol = sampleTruncNrml(16.5,3.7,10,25,1,1);
	asset.BeamW = 1.5;
	asset.beamA = 0.107;%sistema beam details
	asset.beamIy = 0.0134;
	asset.beamIz = 0.0002917;

  end
 
	if asset.BeamLengths <= 18;                                            
        asset.BeamD = 0.2;                                                 %beam width          
        asset.lCorbel = 0.25;                                              % length of the corbel
        asset.Hfork=0.65;                                                  % height of the type b connection (forcella)
	elseif asset.BeamLengths <= 25;
        asset.BeamD = 0.25;
        asset.lCorbel = 0.35;
        asset.Hfork = 0.85;
	else
		asset.BeamD = 0.3;
        asset.lCorbel = 0.45;
        asset.Hfork=0.95;
	end
	asset.ColD = 0.5;
    asset.ColW = 0.5;
    asset.BayL = asset.BeamLengths;
    asset.Es = randomValue('normal',200000,5000,0,inf);
    asset.noHeights = 1;
	asset.colA = asset.ColW.*asset.ColD;
    asset.colI = asset.ColW.*asset.ColD.^3/12;
    
    if preCode == 1
        asset.co = 10;
        popRck = [35 40 45 50];
        popfsk = [180 220];
        asset.Cover = 0.03;
		asset.Rck = randsample(popRck,1);
		asset.Fc = 0.83*asset.Rck;
		asset.ftens = 0;
		asset.esu = 0.01;
		asset.connection = 1;
% 		if asset.noStoreys == 1
% 			asset.connection = randsample([1 0],1,true,[0.7 0.3]); % if asset.connection = 1 the connections are gravity ones
% 		else asset.connection = randsample([1 0],1,true,[0.2 0.8]);
% 		end
    else
        asset.co = 15;
        popRck = [45 50 55];
        popfsk = [220 260];
        asset.Cover = 0.03;
		asset.Rck = randsample(popRck,1);
		asset.Fc = 0.83*asset.Rck;
		asset.ftens = 0;
		asset.connection = 0;
		asset.esu = 0.04;
	end
	
    % Concrete properties (stresses are in MPa, to be converted in kN/m2 in the computations)
	asset.E = 5700*sqrt(asset.Rck);
    asset.ec = 0.0025;
	asset.ecu = 0.0035;
	asset.Fuc = asset.Fc*0.30;
	asset.Et = 0;
	asset.et = 2*asset.ftens/asset.E; 
    asset.euc = 0.005;
	%controllare che confinement dia 1.15, sistema anche gli strains
    asset.Fcc = 1.15*asset.Fc;
    asset.ecc = 0.0025;
    asset.Fucc = asset.Fcc*0.30; 
    asset.eucc = 0.005;
    asset.lambda = 0.5;
    asset.sc = 6+((asset.Rck-15)/4);
    asset.tau0=0.4+(asset.Rck-15)/75;
    asset.tau1=1.4+(asset.Rck-15)/35;
	% Steel properties
	asset.Fy = randsample(popfsk,1);
    asset.sa=asset.Fy;
	asset.esy = asset.Fy/asset.Es;
    asset.b = 0.000;
    asset.espst0 = 0.002;
	%properties of the connection
    asset.fybk=640;
    asset.fubk=800;
    asset.gmm=1.25;
	
end