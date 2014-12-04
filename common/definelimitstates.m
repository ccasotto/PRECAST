% Read results from pushover analysis
Steel = dlmread('tmp/SteelStressStrain.txt');
Concrete = dlmread('tmp/ConcreteStressStrain.txt');
ForceCol = dlmread('tmp/ForceCol.txt');
Vb_po = dlmread('tmp/nodeReaction_po.txt');

% Top drift and Total Base shear
DispPo = dlmread('tmp/nodeDisp_po.txt')/asset.ColH_ground;
VbPo = sum(abs(Vb_po'))';

%This is to remove non convergent part of the pushover curve
i = 2:1:length(VbPo);
dif = (VbPo(i)'-VbPo(1:length(VbPo)-1)');
f = find(dif <(-10));
if numel(f) ~= 0
	VbPo = VbPo(1:f(1));
	DispPo = DispPo(1:f(1));
	LS2s = DispPo(f(1));	
else LS2s = [];
end

%Yielding limit state
f = find (Steel(:,2) > asset.esy);
LS1s = DispPo(f(1)); %Yielding of steel

Vbmax = max(VbPo);
Dispmax = DispPo(VbPo == Vbmax);
DispDec = DispPo(DispPo > Dispmax(1));
VbDec = VbPo(DispPo > Dispmax(1));
f = find (VbDec < 0.8*Vbmax);
if numel(f)==0
    Vb20 = Inf;
    LS220 = Inf;
else
    Vb20 = VbDec(f(1));
    LS220 = DispDec (f(1));
end
LS2s = [LS2s LS220 0.03];

% Summary of limit states	
limit.LS1 = LS1s;
limit.Vb1 = VbPo(DispPo == limit.LS1);
limit.LS2 = min(LS2s);
f=find(DispPo >= limit.LS2);
limit.Vb2 = VbPo(f(1));

