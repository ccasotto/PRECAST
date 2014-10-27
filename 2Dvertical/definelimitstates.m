	
Steel = dlmread('SteelStressStrain.txt');
Concrete = dlmread('ConcreteStressStrain.txt');
Vb_po = dlmread('nodeReaction_po.txt');
DispPo = dlmread('nodeDisp_po_n1.txt')/asset.ColH_ground;
VbPo = sum(abs(Vb_po'))';
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
LS2s = [LS220 0.03];  	
limit.LS1 = LS1s;
limit.Vb1 = VbPo(DispPo == limit.LS1);
limit.LS2 = min(LS2s);
f=find(DispPo >= limit.LS2);
limit.Vb2 = VbPo(f(1));

