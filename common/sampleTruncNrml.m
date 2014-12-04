function result = sampleTruncNrml(mean,std,A,B,n,m)
%Sampletruncnrml sample from a truncated normal distribution
%   Detailed explanation goes here

result = ones(n,m)*inf;
    for i=1:n
        for j=1:m
            while result(i,j) < A || result(i,j) > B
                result(i,j) = normrnd(mean,std);
            end
        end
    end
end

