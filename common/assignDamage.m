function [ DS ] = assignDamage( output,asset,limit,connection,cnn)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fid = fopen('dynamicResult.txt');
out = textscan(fid,'%2c');
fclose(fid);
ds4 = zeros(length(asset.c));
oc4 = zeros(length(asset.c));

if out{1,1} == 'OK'
    %% Complete dynamic analysis
    
    for fr=1:length(asset.c)
        for j=1:1+asset.noBays
            if j == 1 || j == asset.noBays+1
                a = 1;
            else a = 2;
            end
            if sum((abs(output.V(:,j)/a) - (output.axial(:,j)*asset.c(fr)/a + connection.Vb(cnn)))./abs(abs(output.V(:,j)/a)-(output.axial(:,j)*asset.c(fr)/a + connection.Vb(cnn))))/size(output.disp,1)>-1     %connection failure (solo in X o composizione delle due?)
                if output.slide{fr}(j)>=connection.LS(cnn)
                    ds4(fr) = ds4(fr)+1;
                    oc4(fr) = oc4(fr)+1;
                end
            end
        end
        
        % Total Damage 
        if ds4(fr) ~= 0
            DS.DS(fr) = 3;
        elseif max(abs(output.disp)) <= limit.LS1
            DS.DS(fr) = 1;
        elseif max(abs(output.disp)) <= limit.LS2
            DS.DS(fr) = 2;
        else
            DS.DS(fr) = 3;
        end
        
        % Only connection
        if oc4(fr) ~= 0
            DS.OC(fr) = 3;
        else DS.OC(fr) = 1;
        end
        
    end
    
    % Damage wo connection failure
    if max(abs(output.disp)) <= limit.LS1
        DS.WO = 1;
        elseif max(abs(output.disp)) <= limit.LS2
        DS.WO = 2;
        else
        DS.WO = 3;
    end
    
    
else
    %% Non convergence dynamic analysis
    
    for fr=1:length(asset.c)
        for j=1:1+asset.noBays
            if j == 1 || j == asset.noBays+1
                a = 1;
            else a = 2;
            end
            if sum((abs(output.V(:,j)/a) - (output.axial(:,j)*asset.c(fr)/a + connection.Vb(cnn)))./abs(abs(output.V(:,j)/a)-(output.axial(:,j)*asset.c(fr)/a + connection.Vb(cnn))))/size(output.disp,1)>-1     %connection failure (solo in X o composizione delle due?)
                if output.slide{fr}(j)>=connection.LS(cnn)
                    ds4(fr) = ds4(fr)+1;
                    oc4(fr) = oc4(fr)+1;
                end
            end
        end
        
        % Total damage
        if ds4(fr) ~= 0
            DS.DS(fr) = 3;
        elseif max(abs(output.disp)) <= limit.LS1
            DS.DS(fr) = 1;
        else DS.DS(fr) = 3;
        end

        % Connection failure only
        if oc4(fr) ~= 0
            DS.OC(fr) = 3;
        else DS.OC(fr) = 1;
        end
        
    end
    
    % Damage wo connection failure
    if max(abs(output.disp)) <= limit.LS1
        DS.WO = 1;
    else DS.WO = 3;
    end
    
end
	
end

