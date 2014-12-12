function [ output ] = NewmarkSlidingBlock3D( output, action, Vbconnection, asset, dt )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    for fr=1:length(asset.c)
        for i=1:size(output.axial,2)
            if rem(i,asset.noBays+1)<=1; b = 1; else b = 2; end
            if i >asset.noBays+1 && i < asset.noBayZ*(asset.noBays+1); mass = action.massInt; else mass = action.massExt; end
            ay = (output.axial(:,i)/b*asset.c(fr) + Vbconnection)/mass;
            %plot(ay); hold on; plot(output.acc(:,i),'r');
            accX{i} = output.accX(ay<output.accX(:,i),i);
            accXy{i} = ay(ay<output.accX(:,i));
            
            accY{i} = output.accY(ay<output.accY(:,i),i);
            accYy{i} = ay(ay<output.accY(:,i));            
            
            for j=1:length(accXy{i})
                velX{i}(j) = sum(accX{i}(1:j)-accXy{i}(1:j))*dt;
            end
            for j=1:length(accYy{i})
                velY{i}(j) = sum(accY{i}(1:j)-accYy{i}(1:j))*dt;
            end
            if isempty(accXy{i}); output.slideX{fr}(i) = 0; else output.slideX{fr}(i) = sum(velX{i})*dt; end
            if isempty(accYy{i}); output.slideY{fr}(i) = 0; else output.slideY{fr}(i) = sum(velY{i})*dt; end
        end
    end
    
end
