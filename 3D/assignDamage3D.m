function [ DS,ds ] = assignDamage3D( output,limit,asset, connection, cnn)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fid = fopen('dynamicResult.txt');
out = textscan(fid,'%2c');
fclose(fid);
if out{1,1} == 'OK'
	ds4 = 0;

	for i=1:(asset.noBays+1):size(output.DispX,2)                      %i is the number of column
		for j=i:i+asset.noBays
			if sum((output.Ved(:,j) - (output.Vfr(:,i) + connection.Vb(cnn)))./abs(output.Ved(:,j)-(output.Vfr(:,i)+ connection.Vb(cnn))))/size(output.DispX,1)>-1     %connection failure (solo in X o composizione delle due?)
				ds4 = ds4+1;
			end
		end
	end
	
	if ds4 ~= 0
		DS = 3;
	elseif	max(output.Dist) > limit.tot2 
		DS = 3;
	elseif max(output.Dist) > limit.tot1 
		DS = 2;
	else DS = 1;
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
	DSs = [DS DSx DSy];
	dss = [1 2 3];
else
	ds4 = 0;
	for i=1:(asset.noBays+1):size(output.DispX,2)       
		for j=i:i+asset.noBays
			if sum((output.Ved(:,j) - output.Vfr(:,i))./abs(output.Ved(:,j)-output.Vfr(:,i)))/size(output.DispX,1)>-1    %connection failure (solo in X o composizione delle due?)
				ds4 = ds4+1;
			end
		end
	end
	if ds4 ~= 0
		DS = 3;
	elseif max(abs(output.Dist)) < limit.tot1
		DS = 1;
	else
		DS = 3;
	end
	DSs = DS;
	dss = 4;
end
	DS = max(DSs);
	ds = dss(DSs==DS);
	ds = ds(1);
end

