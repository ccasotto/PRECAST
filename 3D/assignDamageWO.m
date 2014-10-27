function [ DS,ds ] = assignDamageWO( output,limit)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fid = fopen('dynamicResult.txt');
out = textscan(fid,'%2c');
fclose(fid);
if out{1,1} == 'OK'
	if	max(output.Dist) > limit.tot2 
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
	if max(abs(output.Dist)) < limit.tot1
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

