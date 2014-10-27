function [ LS1, LS2, LSmean, T1, T2, Tm, fit ] = Correlation_MLE( pdm, IMLs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
	R=zeros(72,4);
	counts = 1;
	for i=1:2:72
	IMLsLS1=IMLs(:,counts);
	type = 2;
	pdm(:,4)=IMLsLS1;
	noLSs = 3;
	[DPM] = DamageProbabilityMatrix (pdm, noLSs);
	%Intensity measure level we want to use, 1=PGA in g, 2=Sa(T), 3=Sd(T)
	%IMLs in cm/s/s
	cumDamageStates = fragility(DPM, noLSs);
	stats = leastSquares(DPM(:,noLSs+1), cumDamageStates, type);
	R(i:(i+1),1:4) = stats;
	counts=counts+1;
	end
	i=1:2:72;
	LS1=R(i,3);
	LS2=R(i+1,3);
	T1=find(LS1==max(LS1));
	T2=find(LS2==max(LS2));
	LSmean=(LS1+LS2)/2;
	Tm=(find(LSmean==max(LSmean)));
	fit=zeros(2,4);
	fit(1,1:4) = R(Tm*2-1,:);
	fit(2,1:4) = R(Tm*2,:);
	
	pdm(:,4)=IMLs(:,Tm);
	[DPM] = DamageProbabilityMatrix (pdm, noLSs);
end

