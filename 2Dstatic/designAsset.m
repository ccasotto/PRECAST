function asset = designAsset( asset, action)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    %Eulerian Critic load
    Jcr=(action.colLoad*4*asset.ColH_ground^2)/(pi^2*0.5*asset.E*1000);                                    %The Young modulus has been reducted by 0.4
    bcr=(Jcr*12)^0.25;
    if asset.ColD > bcr;
        asset.ColD = asset.ColD;
    else asset.ColD = round2((bcr*100),5)/10^2;
    end
    %Compression-flexure for small eccentricity
    ec = action.colM/action.colLoad;
    scc=action.colLoad/(asset.ColD^2)*(1+6*ec/asset.ColD);
    while scc/1000 > asset.sc;
        asset.ColD = asset.ColD+0.05;
        scc = action.colLoad/(asset.ColD^2)*(1+6*ec/asset.ColD);
    end
    %shear
    bv = sqrt(action.colShear/(4/5*asset.tau0*1000));
    if asset.ColD > bv;
        asset.ColD = asset.ColD;
    else asset.ColD = round2((bv*100),5)/10^2;
    end
    asset.ColW = asset.ColD;
    clear e g be c Chi Nvert F2 Ncr J Jcr Jfr bcr bv BE bi w C l lmb;
     
    %properties of the section
    co = asset.co;
    sc = asset.sc;
    sa = asset.sa;
    b = asset.ColD;
    h = asset.ColW;
    d1 = asset.Cover;
    k = (co*sc)/(co*sc+sa);
    dlt = d1/(h-d1);

if asset.Code == 1
	%% Precode design
	%X direction
	rt = dlmread('rt.txt'); %computation of the reinforcement using the parameters in tables rt
    [Asx,d] = reinforcement(action.colM, b, dlt, asset.sa, asset.Rck, co, k, rt);
    h = d+d1;
    if h < b;
       h = b;
    else h = round2((h*100),5)/10^2;
	end
	
    [scu,ssd ]=stressPre(action.colM,action.colLoad,Asx,b,h,d1,co);%Verification of the stresses for small and big eccentricity

    while (scu/1000) > sc || (ssd/1000) > sa
        ro = 4*Asx/(b*h);
        if ro > 0.06
            h = h+0.05;
        else Asx = Asx+asset.AsBar;
        end
        [scu,ssd] = stressPre(action.colM,action.colLoad,Asx,b,h,d1,co);
    end
    %y direction
    [Asy,d]=reinforcement(action.colM,h,dlt,asset.sa,asset.Rck,co,k,rt);
    b2=d+d1;
    if b2<b;
       b=b;
    else b=round2((b2*100),5)/10^2;
    end

    [scu,ssd]=stressPre(action.colM,action.colLoad,Asy,h,b,d1,co);
    while (scu/1000)>sc || (ssd/1000)>sa
        ro=4*Asy/(b*h);
        if ro>0.06
            b=b+0.05;
        else Asy=Asy+asset.AsBar;
        end
        [scu,ssd]=stressPre(action.colM,action.colLoad,Asy,h,b,d1,co);
    end    
    %final properties of the section
    As=max(Asx,Asy);
    Astot=4*As;
    ro=Astot/(b*h);
    while ro>0.06
        b=b+0.05;
        ro=Astot/(b*h);
    end
    while ro<0.003
        As=As+asset.AsBar;
        ro=(4*As)/(b*h);
	end    
    %final properties of the section
    asset.noBars = ceil(As/asset.AsBar);
    As = asset.noBars*asset.AsBar;
    clear mu r1 t1 r t dlt d Asx Asy Jx Jy z W b2;
  
    asset.ColD = b;
    asset.ColW = h;
    [asset.colSteelAreaNeg] = As;
    [asset.colSteelAreaPos] = As;
	
	%% Postcode design
else
	rt=dlmread('rtPst.txt');
    [Asx,d] = reinforcement(action.colM, b, dlt, asset.sa, asset.Rck, co, k, rt);
    h = d+d1;
    if h < b;
       h = b;
    else h = round2((h*100),5)/10^2;
    end
    %Verification of the stresses for small and big eccentricity
    [scu,ssd,hu]=stress(action.colM,action.colLoad,Asx,b,h,d1,co);
    while (scu/1000)>sc || (ssd/1000)>sa
        ro=4*Asx/(b*h);
        if ro>0.06
            h=h+0.05;
        else Asx=Asx+asset.AsBar;
        end
        [scu,ssd,hu]=stress(action.colM,action.colLoad,Asx,b,h,d1,co);
    end
    %y direction
	[Asy,d]=reinforcement(action.colM,h,dlt,asset.sa,asset.Rck,co,k,rt);
    b2 = d+d1;
    if b2 < b;
       b = b;
    else b = round2((b2*100),5)/10^2;
    end
    %Verification of the stresses for small and big eccentricity
    [scu,ssd,hu]=stress(action.colM,action.colLoad,Asy,h,b,d1,co);
    while (scu/1000)>sc || (ssd/1000)>sa
        ro=4*Asy/(b*h);
        if ro>0.06
            b=b+0.05;
        else Asy=Asy+asset.AsBar;
        end
        [scu,ssd,hu]=stress(action.colM,action.colLoad,Asy,h,b,d1,co);
    end    
    %Shear
	tau = action.colShear/(0.9*b*hu);
    if (tau/1000) < asset.tau0
        p = 0.24;
        fh = 0.008;
    else rov = tau/(sa*1000);
        fh = 0.012;
        Astr=2*(fh/2)^2*pi;
        p = (round1(Astr/(rov*b)*100,5))/100;
    end
    %final properties of the section
    As = max(Asx,Asy);
    Astot = 4*As;
    ro = Astot/(b*h);
    while ro > 0.06
        b = b+0.05;
        ro = Astot/(b*h);
    end
    while ro < 0.003
        As = As+asset.AsBar;
        ro = (4*As)/(b*h);
    end    
    p = min(p);
    fh = min(fh);
	asset.noBars = ceil(As/asset.AsBar);
    As = asset.noBars*asset.AsBar;
    %displacement verification
    Jx=(b*h^3)/12+2*co*As*(h/2-d1)^2;
    Jy=(h*b^3)/12+2*co*As*(b/2-d1)^2;
    Jc=min(Jx,Jy);
    kc=3*0.4*asset.E*1000*Jc/asset.ColH_ground^3;
    D=action.F/kc;
   %metti condizione su spostamento
    clear scu ssd hu mu dlt d d1 Asx Asy z;
    asset.ColD = b;
    asset.ColW = h;
    asset.colSteelAreaNeg = As;
    asset.colSteelAreaPos = As;
	end
end

