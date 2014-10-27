function [ LS1, LS2, LSmean, T1, T2, Tm, fit ] = Correlation3D( pdm, IMLs, T)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

	for i=1:1:length(T)
	IML = IMLs(:,i);%IMLs= Sa in cm/s/s
	pdm(:,4)=IML;
	noLSs = 3;
	[DPM] = DamageProbabilityMatrix (pdm, noLSs);
	cumDamageStates = fragility(DPM, noLSs);
	for j=1:2
		[mle(j,1), mle(j,2), mle(j,4)] = fn_mle_pc_probit(DPM(:,noLSs+1), 100, cumDamageStates(:,j+1)*100);
		mle(j,3) = corr(cumDamageStates(:,j+1),logncdf(DPM(:,noLSs+1),log(mle(j,1)),(mle(j,2)))).^2;
	end
 	S(1+2*(i-1):2*i,1:4) = mle;
	end
	S(:,1)=log(S(:,1));
	S(:,4)=S(:,4)/100;
	i=1:2:length(S);
	LS1=S(i,3);
	LS2=S(i+1,3);
	T1=find(LS1==max(LS1));
	T2=find(LS2==max(LS2));
	LSmean=(LS1+LS2)/2;
	Tm=(find(LSmean==max(LSmean)));
	fit.MLE(1,1:3) = S(Tm*2-1,1:3);
	fit.MLE(2,1:3) = S(Tm*2,1:3);

end

