function [ DS] = assignDamage3D( output,limit,asset, connection, cnn)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fid = fopen('dynamicResult.txt');
out = textscan(fid,'%2c');
fclose(fid);
ds4 = zeros(length(asset.c));
oc4 = zeros(length(asset.c));

if out{1,1} == 'OK'
         
    for fr=1:length(asset.c)
        for j=1:(asset.noBays+1)*(asset.noBayZ+1)                      %i is the number of column
            if rem(j,asset.noBays+1)<=1; a = 1; else a = 2; end
            if sum((abs(output.Vx(:,j)/a) - (output.axial(:,j)*asset.c(fr)/a + connection.Vb(cnn)))./abs(abs(output.Vx(:,j)/a)-(output.axial(:,j)*asset.c(fr)/a + connection.Vb(cnn))))/size(output.DispX,1)>-1     %connection failure (solo in X o composizione delle due?)
                if output.slideX{fr}(j)>=connection.LS(cnn)
                    ds4(fr) = ds4(fr)+1;
                    oc4(fr) = oc4(fr)+1;
                end
            end
            if sum((abs(output.Vy(:,j)/a) - (output.axial(:,j)*asset.c(fr)/a + connection.Vb(cnn)))./abs(abs(output.Vy(:,j)/a)-(output.axial(:,j)*asset.c(fr)/a + connection.Vb(cnn))))/size(output.DispX,1)>-1     %connection failure (solo in X o composizione delle due?)
                if output.slideY{fr}(j)>=connection.LS(cnn)
                    ds4(fr) = ds4(fr)+1;
                    oc4(fr) = oc4(fr)+1;
                end
            end
        end

        if ds4(fr) ~= 0
            D = 3;
        elseif	max(output.Dist) > limit.tot2 
            D = 3;
        elseif max(output.Dist) > limit.tot1 
            D = 2;
        else D = 1;
        end
        if	max(output.DispX) > limit.dX2
            DSx = 3;
        elseif max(output.DispX) > limit.dX1
            DSx = 2;
        else DSx = 1;
        end
        if	max(output.DispY) > limit.dY2
            DSy = 3;
        elseif max(output.DispY) > limit.dY1
            DSy = 2;
        else DSy = 1;
        end
        DSs(fr,:) = [D DSx DSy];
    end
    
	if	max(output.Dist) > limit.tot2 
		WO = 3;
	elseif max(output.Dist) > limit.tot1 
		WO = 2;
	else WO = 1;
	end
	if	max(output.DispX) > limit.dX2
		WOx = 3;
	elseif max(output.DispX) > limit.dX1
		WOx = 2;
	else WOx = 1;
	end
	if	max(output.DispY) > limit.dY2
		WOy = 3;
	elseif max(output.DispY) > limit.dY1
		WOy = 2;
	else WOy = 1;
	end
	WOs = [WO WOx WOy];
	
else
    for fr=1:length(asset.c)
        for j=1:(asset.noBays+1)*(asset.noBayZ+1)                      %i is the number of column
            if rem(j,asset.noBays+1)<=1; a = 1; else a = 2; end
            if sum((abs(output.Vx(:,j)/a) - (output.axial(:,j)*asset.c(fr)/a + connection.Vb(cnn)))./abs(abs(output.Vx(:,j)/a)-(output.axial(:,j)*asset.c(fr)/a + connection.Vb(cnn))))/size(output.DispX,1)>-1     %connection failure (solo in X o composizione delle due?)
                if output.slideX{fr}(j)>=connection.LS(cnn)
                    ds4(fr) = ds4(fr)+1;
                    oc4(fr) = oc4(fr)+1;
                end
            end
            if sum((abs(output.Vy(:,j)/a) - (output.axial(:,j)*asset.c(fr)/a + connection.Vb(cnn)))./abs(abs(output.Vy(:,j)/a)-(output.axial(:,j)*asset.c(fr)/a + connection.Vb(cnn))))/size(output.DispX,1)>-1     %connection failure (solo in X o composizione delle due?)
                if output.slideY{fr}(j)>=connection.LS(cnn)
                    ds4(fr) = ds4(fr)+1;
                    oc4(fr) = oc4(fr)+1;
                end
            end
        end

        if ds4(fr) ~= 0
            D = 3;
        elseif max(abs(output.Dist)) < limit.tot1
            D = 1;
        else
            D = 3;
        end
        DSs(fr,:) = D;
    end
	if max(abs(output.Dist)) < limit.tot1
		WO = 1;
	else
		WO = 3;
	end
	WOs = WO;
	
end
    for fr=1:length(asset.c)
        if oc4(fr) ~= 0
            DS.OC(fr) = 3;
        else DS.OC(fr) = 1;
        end
		
        DS.DS(fr) = max(DSs(fr,:));
    end
	DS.WO = max(WOs);

end

