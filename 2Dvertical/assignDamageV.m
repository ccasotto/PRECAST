function [ DS ] = assignDamageV( output,asset,limit,connection,cnn)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fid = fopen('dynamicResult.txt');
out = textscan(fid,'%2c');
fclose(fid);
if out{1,1} == 'OK'
	ds4 = 0;

	for i=1:(asset.noBays+1):size(output.disp,2)   %i is the number of column
		for j=i:i+asset.noBays
			if sum((abs(output.V(:,j)) - (output.axial(:,i)*asset.c + connection.Vb(cnn)))./abs(abs(output.V(:,j))-(output.axial(:,i)*asset.c + connection.Vb(cnn))))/size(output.disp,1)>-1     %connection failure (solo in X o composizione delle due?)
				ds4 = ds4+1;
			end
		end
	end
	
	if ds4 ~= 0
		DS = 3;
	elseif max(abs(output.disp)) <= limit.LS1
		DS = 1;
	elseif max(abs(output.disp)) <= limit.LS2
		DS = 2;
	else
		DS = 3;
	end
else
	ds4 = 0;
	for i=1:(asset.noBays+1):size(output.disp,2)   %i is the number of column
		for j=i:i+asset.noBays
			if sum((output.V(:,j) - (output.axial(:,i)*asset.c + connection.Vb(cnn)))./abs(output.V(:,j)-(output.axial(:,i)*asset.c + connection.Vb(cnn))))/size(output.disp,1)>-1     %connection failure (solo in X o composizione delle due?)
				ds4 = ds4+1;
			end
		end
	end
	if ds4 ~= 0
		DS = 3;
	elseif max(abs(output.disp)) <= limit.LS1
		DS = 1;
	else DS = 3;
	end
end
end

