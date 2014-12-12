function [ pdm ] = variables( lastNGA,noLSs,c )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    for fr =1:length(c)
        pdm.TOT{fr} = zeros(lastNGA/3+13,noLSs);
        pdm.WO{fr} = zeros(lastNGA/3+13,noLSs);
        pdm.OC{fr} = zeros(lastNGA/3+13,noLSs);
    end

end

