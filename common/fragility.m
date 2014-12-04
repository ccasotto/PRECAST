function [ cumDamageStates ] = fragility( DPM, noLSs )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for i = 1:length(DPM)
	for j = 1: noLSs
		cumDamageStates(i,j) = sum(DPM(i,j:noLSs));
	end
end

end

