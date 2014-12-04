function [ pdm ] = BuildDPM( pdm, DS, counter )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

pdm.TOT(counter,DS.DS) = pdm.TOT(counter,DS.DS)+1;
pdm.WO(counter,DS.WO) = pdm.WO(counter,DS.WO)+1;
pdm.OC(counter,DS.OC) = pdm.OC(counter,DS.OC)+1;

end

