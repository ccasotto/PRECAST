function [ output ] = NewmarkSlidingBlock( output, action, Vbconnection, asset, dt )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    figure
    for i=1:size(output.axial,2)
        if i == 1 || i == asset.noBays+1; b = 1; else b = 2; end
        ay = (output.axial(:,i)/b*asset.c + Vbconnection)/(action.massExt);
        %plot(ay); hold on; plot(output.acc(:,i),'r');
        acc{i} = output.acc(ay<output.acc(:,i),i);
        accy{i} = ay(ay<output.acc(:,i));
        for j=1:length(accy{i})
            vel{i}(j) = sum(acc{i}(1:j)-accy{i}(1:j))*dt;
        end
        if isempty(accy{i}); output.slide(i) = 0; else output.slide(i) = sum(vel{i})*dt; end
    end
    
end
