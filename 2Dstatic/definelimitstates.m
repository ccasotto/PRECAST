	
	Steel = dlmread('SteelStressStrain.txt');
	Concrete = dlmread('ConcreteStressStrain.txt');
	ForceCol = dlmread('ForceColSec4.txt');
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
     	
	% LS di connessioni
		f = find(ForceCol(:,4) > connection.Vb(cnn));
		if numel(f) == 0
		limit.LSconnection(1) = inf;
		limit.Vbconnection(1) = inf;
		else 
		limit.Vbconnection(1) = VbPo(f(1));
		limit.LSconnection(1) = DispPo(f(1));
        limit.results02 = limit.results02+1;
		% here I am comparing the disp with maximum displacement sustainable by the connection if onlr friction is considered
		end
		
		f = find(ForceCol(:,4) > connection.Vb(cnn+2));
		if numel(f) == 0
		limit.LSconnection(2) = inf;
		limit.Vbconnection(2) = inf;
		else 
		limit.Vbconnection(2) = VbPo(f(1));
		limit.LSconnection(2) = DispPo(f(1));
        limit.results03 = limit.results03+1;
		% here I am comparing the disp with maximum displacement sustainable by the connection if onlr friction is considered
		end
	
	limit.LS1 = LS1s;
	limit.Vb1 = VbPo(DispPo == limit.LS1);
	limit.LS2 = min(LS2s);
    f=find(DispPo >= limit.LS2);
	limit.Vb2 = VbPo(f(1));

