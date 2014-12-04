function [ DPM ] = DamageProbabilityMatrix( pdm, noLSs )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
	A = pdm(:,noLSs+1);
	B = pdm(:,1:noLSs);
	[As, IX] = sort(A);
	Bs = B(IX,:);
	DPM = [Bs As];

	for i = 1 : size(DPM,1)
		DPM(i,1:noLSs) = DPM(i,1:noLSs)/sum(DPM(i,1:noLSs));
	end
end

