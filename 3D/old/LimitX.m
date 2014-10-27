function [ limitx ] = LimitX( asset, chord )

%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
	
	Disp_po = dlmread('nodeDisp_po.txt')/asset.ColH_ground;
	Reaction_po = dlmread('nodeReaction_po.txt');
	Vb_po = -sum(Reaction_po');
	i = 2:1:length(Vb_po);
	dif = (Vb_po(i)'-Vb_po(1:length(Vb_po)-1)');
	f = find(dif <(-10));
	if numel(f) ~= 0
		Vb_po = Vb_po(1:f(1));
		Disp_po = Disp_po(1:f(1));
		LS2s = Disp_po(f(1));	
	else LS2s = [];
	end
	
	beam = dlmread('BeamForce.txt');
	col=dlmread('ColForce.txt');
	gird=dlmread('GirderForce.txt');
	Steel = dlmread('SteelStressStrainX.txt');
	Concrete = dlmread('ConcreteStressStrainX.txt');
	%Yielding limit state
	f = find (Steel(:,2) > asset.esy);
	limitx.LS1 = Disp_po(f(1)); %Yielding of steel
	
	%Collapse limit state
if asset.Code == 1
	Vbmax = max(Vb_po);
	Dispmax = Disp_po(Vb_po == Vbmax);
	DispDec = Disp_po(Disp_po > Dispmax);
	VbDec = Vb_po(Disp_po > Dispmax);
	f = find (VbDec < 0.8*Vbmax);
    if numel(f)==0
        Vb20 = Inf;
        LS220 = Inf;
    else
	Vb20 = VbDec(f(1));
	LS220 = DispDec (f(1));
    end
    LS2s = [LS2s LS220];
else
		f = find(Concrete(:,2) < -asset.ecu);
	if numel(f) == 0
		LS2c = inf;
	else LS2c = Disp_po(f(1)); %failure of the concrete
	end
	f = find(Steel(:,2) > asset.esu);
	if numel(f) == 0;
		LS2ss = inf;
	else LS2ss = Disp_po(f(1)); %failure of the steel
    end
    LS2s = [LS2s LS2c LS2ss];
end
	limitx.LS2 = min(LS2s);
%Chord Rotation limit states	
		
	figure(1)
	plot(Disp_po,Vb_po)
	hold on
	x = 1:0.5:max(Vb_po);
	plot(limitx.LS1,x,'g')
	plot(limitx.LS2,x,'g')
	plot(chord.zyX,x,'r')
	plot(chord.zX,x,'r')
% 	legend('Pushover','LS1 es=ey','LS2 Vb=80% Vbmax','LS1 cr=cry','LS2 cr=cru')
	xlabel('Chord Rotation-Drift')
	ylabel('Total Base Shear [kN]')
	legend boxoff
	box off

end

