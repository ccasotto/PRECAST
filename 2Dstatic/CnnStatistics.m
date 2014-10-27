function [ fitCnn, probCnn ] = CnnStatistics( cumDamageStates,noLSs )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
	probCnn = max(cumDamageStates(:,3));
	cumDamageStates = cumDamageStates/probCnn;
	for j=1:2
		[mle(j,1), mle(j,2), mle(j,4)] = fn_mle_pc_probit(cumDamageStates(:,noLSs+1), 100, cumDamageStates(:,j+1)*100);
		mle(j,3) = corr(cumDamageStates(:,j+1),logncdf(cumDamageStates(:,noLSs+1),log(mle(j,1)),(mle(j,2)))).^2;
	end
	mle(:,1)= log(mle(:,1));
% 	fitCnn = leastSquares(cumDamageStates(:,4), cumDamageStates, 2);
	fitCnn = mle(:,1:3);

end

