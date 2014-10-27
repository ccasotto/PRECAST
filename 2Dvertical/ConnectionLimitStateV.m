function connection = ConnectionLimitState_v2( asset , action)
%ConnectionLimitState The function defines the base shear that causes a
%failure of the connections
connection.Vb = zeros(1,2);
connection.LS = zeros(1,2);
%Case 1: Bolted beam-column connection
    Ab=action.colShear*1000/2/(0.5*asset.fubk/asset.gmm);                                            %area of the bolts in mm^2
    Ab20=245;
    Ab22=303;
    Ab24=353;
    if Ab<Ab20;
        Ab=Ab20; %area and diameter of the bolts
        dnom=20;
    elseif Ab<Ab22;
        Ab=Ab22;
        dnom=22;
    else Ab<Ab24;
        Ab=Ab24;
        dnom=24;
	end
%% Case 1: Corbel	
    bcorb = asset.ColD; %width of the corbel
    hcorb = asset.lCorbel +0.1;
    heff = 0.12; %anchorage length
    c1 = asset.lCorbel/2-0.05; %distance to the border of the corbel in x direction
    c2 =(bcorb-asset.BeamD)/2+(asset.BeamD/3); %distance to the border of the corbel in y direction
    if c2>1.5*c1;
       Acv=(4.5*(c1)^2);
    else c2=c2;
        Acv=1.5*(c1)*(1.5*c1+c2);
    end
    %failure of the steel
    Vrks=(Ab*2*0.5*asset.fubk)/1000; %resistance due to the bolts
    %Failure for pryout of the concrete
    Nrkc0=(7.2*sqrt(asset.Rck)*(heff*1000)^1.5)/1000;
    Nrkc=2*Nrkc0;
    %Failure of the boundary of the corbel
    pv=0.7+0.3*(c2/(1.5*c1));
    phv=(1.5*c1*1000/(hcorb)^(1/3));
    if phv>=1;
        phv=phv;
    else phv=1;
    end
    pav=1;
    pecv=1;
    pucrv=1.2;
    Vrkc0=(0.45*sqrt(dnom)*(heff*1000/dnom)^0.2*sqrt(asset.Rck)*(c1*1000)^1.5)/1000;
    A0cv=(4.5*(c1)^2);
    Vrkc=Vrkc0*Acv/A0cv*pav*pecv*pucrv;
    
   	%friction restistance
	
	if asset.Code == 1
		if asset.connection == 1
		connection.Vb(1) = 0;
		connection.LS(1) = asset.lCorbel/2;
		else Vrk = [Vrks Nrkc Vrkc];
			connection.Vb(1) = min(Vrk);
			connection.LS(1) = asset.lCorbel/2;
		end
	else Vrk = [Vrks Nrkc Vrkc];
		connection.Vb(1) = min(Vrk);
		connection.LS(1) = asset.lCorbel/2;
	end
    clear Ab20 Ab22 Ab24 Acv A0cv Vrkc0 Nrkc0 c1 c2 heff bcorb hcorb lcorb pv phv pav pecv pucrv;
    
%% Case 2:"Forcella"(Fork)
    %properties of the connections
    SpF = (asset.ColD-asset.BeamD)/2;                                                         %length of the flanges
    %SpF = 0.12;
	if SpF <0.25;
        SpF = SpF;
    else Spf = 0.25;
    end
    Lf = asset.ColW;                                                       %length of the fork
    c1 = asset.ColW/2-0.1;   %prima era 0.05, ho cambiato                  %distance from the border
    %c1 = 0.10;
	c2 = asset.Hfork/2-0.1;
	A0cv = 2*1.5*c1*min(1.5*c1,SpF); % in mq
    if c2 > 1.5*c1;
		c2 = 1.5*c1;
		Acv = 2*1.5*c1*min(1.5*c1,SpF); %in mq
	else
		c2 = c2;
        Acv = (1.5*c1+c2)*min(1.5*c1,SpF);
    end
    %failure of the steel
    Vrksf = (Ab*2*0.5*asset.fubk)/1000;
    %failure of the boundary of the fork
    pv = 0.7+0.3*(c2/(1.5*c1));
    phv = (1.5*c1*1000/(SpF)^(1/3));
    if phv>=1;
        phv=phv;
    else phv=1;
    end
    pav = 1;
    pecv = 1;
    pucrv = 1.2;
    Vrkc0 =(0.45*sqrt(dnom)*(SpF*1000/dnom)^0.2*sqrt(asset.Rck)*(c1*1000)^1.5)/1000;
 	Vrkcf = Vrkc0*Acv/A0cv*pav*pecv*pucrv;
   	%friction restistance

	if asset.Code == 1
		if asset.connection == 1
		connection.Vb(2) = 0;
		connection.LS(2) = asset.ColW/2;
		else Vrk = [Vrksf Vrkcf];
			connection.Vb(2) = min(Vrk);
			connection.LS(2) = asset.ColW/2;
		end
	else Vrk = [Vrksf Vrkcf];
		connection.Vb(2) = min(Vrk);
		connection.LS(2) = asset.ColW/2;
	end

end

