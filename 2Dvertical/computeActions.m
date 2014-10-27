function action = computeActions(asset)
    PPg = 2.4;															   %lateral beam self weight
if asset.type == 1
	G = 1.3;%sampleTruncNrml(1.3,0.1,0.0,3.0,1,1);                              %permanent load
	Q1 = 0.5;%sampleTruncNrml(0.5,0.15,0.0,2,1,1);                              %accidental load
	PPr = 2.4;                                                             %roof weight in kN/m
    %self weight of the beam kN/m
    if asset.BeamLengths<=16;
        PPt=3.6;                                                           
    elseif asset.BeamLengths<=22;
        PPt=5.2;
    elseif asset.BeamLengths<=24;
        PPt=6.85;
    elseif asset.BeamLengths<=28;
        PPt=7.5;
    else PPt=8.55;
    end
    %total gravity load
    action.massInt=(asset.BeamLengths/2*PPt+asset.InterCol*(PPg)+asset.BeamLengths/2*asset.InterCol*(PPr+G+0.33*(Q1)))/9.81;  %internal frame (lateral column)
	action.massExt=(asset.BeamLengths/2*PPt+asset.InterCol/2*(PPg)+asset.BeamLengths/2*asset.InterCol/2*(PPr+G+0.33*(Q1)))/9.81; %external frame (lateral column)

elseif asset.type == 2	
	G = sampleTruncNrml(1.3,0.1,0.0,3.0,1,1);                              %permanent load
	Q1 = sampleTruncNrml(0.5,0.15,0.0,2,1,1);                              %accidental load
	if asset.InterCol <= 20;
        PPr = 2.9;%kN/m2
    else PPr = 1.63;%kN/m2
    end
    %self weight of the beam kN/m
    if asset.BeamLengths <= 16;
        PPt = 4;                                                           
    elseif asset.BeamLengths <= 22;
        PPt = 6;
    elseif asset.BeamLengths <= 24;
        PPt = 7.5;
    elseif asset.BeamLengths <= 28;
        PPt = 8;
    else PPt = 9.5;
	end
    %total gravity load
    action.massInt=(asset.BeamLengths/2*PPt+asset.InterCol*(PPg)+asset.BeamLengths/2*asset.InterCol*(PPr+G+0.33*(Q1)))/9.81;    %mass in ton                       %seismic action
    action.massExt=(asset.BeamLengths/2*PPt+asset.InterCol/2*(PPg)+asset.BeamLengths/2*asset.InterCol/2*(PPr+G+0.33*(Q1)))/9.81; %mass in ton
	
elseif asset.type == 3
	G = sampleTruncNrml(1.3,0.1,0.0,3.0,1,1);                              %permanent load
	Q1 = sampleTruncNrml(0.5,0.15,0.0,2,1,1);                              %accidental load
    PPr=2.4;                                                               %roof self weight
	%self weight of the beam kN/m
    if asset.BeamLengths <= 16;
        PPt = 2.6;                                                           
    elseif asset.BeamLengths <= 22;
        PPt = 4.2;
    elseif asset.BeamLengths <= 24;
        PPt = 5.85;
    elseif asset.BeamLengths <= 28;
        PPt = 6.5;
    else PPt = 7.55;
	end
    %total gravity load
    action.massInt=(asset.BeamLengths/2*PPt+asset.InterCol*(PPg)+asset.BeamLengths/2*asset.InterCol*(PPr+G+0.33*(Q1)))/9.81;  %internal frame (lateral column)
	action.massExt=(asset.BeamLengths/2*PPt+asset.InterCol/2*(PPg)+asset.BeamLengths/2*asset.InterCol/2*(PPr+G+0.33*(Q1)))/9.81; %external frame (lateral column)

else %type == 4
	PPr = 2.4;
    G = sampleTruncNrml(4,1,0.0,7,1,1);                                    %permanent load
	Q1 = sampleTruncNrml(5,1.3,0.0,9,1,1);                                 %accidental load
end

    action.colLoad = action.massInt*2*9.81;
    %admissible tensions
    Jfr = asset.ColD^4/12;                                                 %Inertia moment of the frame
    K =(asset.noBays+1)*3*0.4*asset.E*1000*Jfr/(asset.ColH_ground^3);                                    %lateral stiffness of the frame, E is reduced by 50% for cracking
    T = 2*pi*sqrt((asset.noBays+1)*action.massInt*(asset.noBays*2)/K);
    %Seismic Input
    e=1;
    g=1;
    be=1;
    c = (asset.s-2)/100;
    if T > 0.8;
        R = 0.862/T^(2/3);
    else R = 1;
    end
    Chi = R*c*e*g*be; 
    action.F = action.massInt*2*Chi*9.81;                                                         %seismic lateral load on one column
    action.colLoadvert = c*action.colLoad*2;    %vertical acceleration contribution (DM 3-3-75)
    action.colLoad = action.colLoad+action.colLoadvert;
	action.colLoadExt = action.massExt*9.81 *(1-0.4); %this is for the connection only not how they use dto design
    if asset.Code == 1
        action.colShear = action.F;
        action.colM=action.colShear*asset.ColH_ground;
        action.beamNegM = 0;
        action.beamPosM = 0;
    else %amplification of the action for second order effects
        l=2*asset.ColH_ground/(asset.ColD/sqrt(12));
        lmb=dlmread('lmb.txt');
     while l>140;
        asset.ColD = asset.ColD+0.05;
        l=2*asset.ColH_ground/(asset.ColD/sqrt(12));        
     end
        J=(asset.ColD^4)/12;
        Ncr=pi^2*(0.5*asset.E*1000)*J/(4*asset.ColH_ground^2);
        C=1/(1-(action.colLoad/Ncr));
        l=ceil(l/10)*10;
        w=lmb(find(lmb(:,1)==l),2);
        action.colLoad = w*action.colLoad;
        action.colShear = C*action.F;
        action.colM = action.colShear*asset.ColH_ground;
    end

end