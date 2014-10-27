function [ DS ] = assignDamage3D( output,limit,asset )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fid = fopen('dynamicResult.txt');
out = textscan(fid,'%2c');
fclose(fid);
if out{1,1} == 'OK'
	ds4 = 0;
	for i=1:size(output.DispX,2)                          %i is the number of column
		if min(output.Vfr(:,i)) < max(output.Ved(:,i))    %connection failure (solo in X o composizione delle due?)
			ds4 = ds4+1;
		end
	end

	if ds4 ~= 0
		DSx = 3;
	elseif	max(output.DispX) > limit.tot2
		DSx = 3;
	elseif max(output.DispX) > limit.tot1
		DSx = 2;
	else DSx = 1;
	end

	if	max(output.DispY) > limit.tot2
		DSy = 3;
	elseif max(output.DispY) > limit.tot1
		DSy = 2;
	else DSy = 1;
	end
else
	if max(abs(output.DispX))/asset.ColH_ground < limit.tot1
		DSx = 1;
	else
		DSx = 3;
	end
	if max(abs(output.DispY))/asset.ColH_ground < limit.tot1
		DSy = 1;
	else
		DSy = 3;
	end
end
DS = max(DSx,DSy);
end

