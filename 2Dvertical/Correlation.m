function [ LS1, LS2, LSmean, T1, T2, Tm, fit ] = Correlation( pdm, IMLs,T)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
	R=zeros(length(T)*2,2);
	counts = 1;
	for i=1:2:length(T)*2
	IMLsLS1=IMLs(:,counts);
	type = 2;
	pdm(:,4)=IMLsLS1;
	noLSs = 3;
	[DPM] = DamageProbabilityMatrix (pdm, noLSs);
	%Intensity measure level we want to use, 1=PGA in g, 2=Sa(T), 3=Sd(T)
	%IMLs in cm/s/s
	cumDamageStates = fragility(DPM, noLSs);
% 	stats = leastSquares(DPM(:,noLSs+1), cumDamageStates, type);
% 	R(i:(i+1),1:4) = stats;
	for j=1:2
		[mle(j,1), mle(j,2), mle(j,4)] = fn_mle_pc_probit(DPM(:,noLSs+1), 100, cumDamageStates(:,j+1)*100);
		mle(j,3) = corr(cumDamageStates(:,j+1),logncdf(DPM(:,noLSs+1),log(mle(j,1)),(mle(j,2)))).^2;
	end
 	S(i:(i+1),1:4) = mle;
	counts=counts+1;
	end
	S(:,1)=log(S(:,1));
	S(:,4)=S(:,4)/100;
	i=1:2:length(T)*2;
% 	LS1=R(i,3);
% 	LS2=R(i+1,3);
% 	T1=find(LS1==max(LS1));
% 	T2=find(LS2==max(LS2));
% 	LSmean=(LS1+LS2)/2;
% 	Tm=(find(LSmean==max(LSmean)));
% 	fit=zeros(2,4);
% 	fit.LSE(1,1:4) = R(Tm*2-1,:);
% 	fit.LSE(2,1:4) = R(Tm*2,:);
	
	LS1=S(i,3);
	LS2=S(i+1,3);
	T1=find(LS1==max(LS1));
	T2=find(LS2==max(LS2));
	LSmean=(LS1+LS2)/2;
	Tm=(find(LSmean==max(LSmean)));
	fit.MLE(1,1:3) = S(Tm*2-1,1:3);
	fit.MLE(2,1:3) = S(Tm*2,1:3);

end

