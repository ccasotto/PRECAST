function [ result ] = sampleTruncLognrml(mean,std,A,B,n,m)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
result = ones(n,m)*inf;
    for i=1:n
        for j=1:m
            while result(i,j) < A || result(i,j) > B
                result(i,j) = lognrnd(mean,std);
            end
        end
    end

end

