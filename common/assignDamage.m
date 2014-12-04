function [ DS ] = assignDamage( output,asset,limit,connection,cnn)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fid = fopen('dynamicResult.txt');
out = textscan(fid,'%2c');
fclose(fid);

if out{1,1} == 'OK'
    %% Complete dynamic analysis
    % Total Damage
	ds4 = 0;

    for j=1:1+asset.noBays
        if j == 1 || j == asset.noBays+1
            a = 1;
        else a = 2;
        end
        if sum((abs(output.V(:,j)/a) - (output.axial(:,j)*asset.c/a + connection.Vb(cnn)))./abs(abs(output.V(:,j)/a)-(output.axial(:,j)*asset.c/a + connection.Vb(cnn))))/size(output.disp,1)>-1     %connection failure (solo in X o composizione delle due?)
            if output.slide(j)>=connection.LS(cnn)
                ds4 = ds4+1;
            end
        end
    end
	
	if ds4 ~= 0
		DS.DS = 3;
	elseif max(abs(output.disp)) <= limit.LS1
		DS.DS = 1;
	elseif max(abs(output.disp)) <= limit.LS2
		DS.DS = 2;
	else
		DS.DS = 3;
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
    % Total damage
	ds4 = 0;
    for j=1:1+asset.noBays
        if j == 1 || j == asset.noBays
            a = 1;
        else a = 2;
        end
        if sum((abs(output.V(:,j)/a) - (output.axial(:,j)*asset.c/a + connection.Vb(cnn)))./abs(abs(output.V(:,j)/a)-(output.axial(:,j)*asset.c/a + connection.Vb(cnn))))/size(output.disp,1)>-1     %connection failure (solo in X o composizione delle due?)
            if output.slide(j)>=connection.LS(cnn)
                ds4 = ds4+1;
            end
        end
    end
    
	if ds4 ~= 0
		DS.DS = 3;
	elseif max(abs(output.disp)) <= limit.LS1
		DS.DS = 1;
	else DS.DS = 3;
    end
    % Damage wo connection failure
    if max(abs(output.disp)) <= limit.LS1
        DS.WO = 1;
    else DS.WO = 3;
    end
end
    %% Connection failure only
	oc4 = 0;
    for j=1:1+asset.noBays
        if j == 1 || j == asset.noBays+1
            a = 1;
        else a = 2;
        end
        if sum((abs(output.V(:,j)/a) - (output.axial(:,j)*asset.c/a + connection.Vb(cnn)))./abs(abs(output.V(:,j)/a)-(output.axial(:,j)*asset.c/a + connection.Vb(cnn))))/size(output.disp,1)>-1     %connection failure (solo in X o composizione delle due?)
            if output.slide(j)>=connection.LS(cnn)
               oc4 = oc4+1;
            end 
        end
    end
	
	if oc4 ~= 0
		DS.OC = 3;
	else DS.OC = 1;
    end
    
end

