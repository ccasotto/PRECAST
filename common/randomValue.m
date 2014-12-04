function [value] = randomValue(dist,mean,stddev,A,B)

     value = -inf;
       
    while value < A || value > B

        if strcmp(dist,'normal')    
            value = normrnd(mean,stddev);
        
        elseif strcmp(dist,'lognormal')
            mu = log((mean^2)/sqrt(stddev^2+mean^2));
            sigma = sqrt(log(stddev^2/(mean^2)+1));
            
            value = lognrnd(mu,sigma);
        
        elseif strcmp(dist,'gamma')
            betha = (stddev)^2/mean;
            alpha = mean/betha;
            value = gamrnd(alpha,betha);
            
        end
    end
        
