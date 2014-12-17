function [ pdm ] = BuildDPM( pdm, DS, counter )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    for fr=1:length(DS.DS)
        pdm.TOT{fr}(counter,DS.DS(fr)) = pdm.TOT{fr}(counter,DS.DS(fr))+1;
        pdm.OC{fr}(counter,DS.OC(fr)) = pdm.OC{fr}(counter,DS.OC(fr))+1;
        pdm.WO{fr}(counter,DS.WO) = pdm.WO{fr}(counter,DS.WO)+1;
    end
end

