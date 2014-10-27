function [ theta,beta ] = Correlation_MLE( IM, noAsset, cumDamageStates)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
	%num data is the number of buildings for each damage state: 
	% 1=yielding 2= collapse
	theta = zeros(1,2);
	beta = zeros(1,2);
		for i = 1:2;
		[theta(i), beta(i)] = fn_mle_pc(IM, noAsset, cumDamageStates(:,i+1));
		end
end

