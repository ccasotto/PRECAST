function [ DS,dsx,dsy ] = assignDamage2D( output,limit,asset )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fid = fopen('dynamicResult.txt');
out = textscan(fid,'%2c');
fclose(fid);
if out{1,1} == 'OK'
	ds = zeros(size(output.DispX,2),4);                   %ds shows the limit state for each column
	ds1 = 0;
	ds2 = 0;
	ds3 = 0;
	ds4 = 0;
	for i=1:size(output.DispX,2)                          %i is the number of column
		if min(output.Vfr(:,i)) < max(output.Ved(:,i))    %connection failure (solo in X o composizione delle due?)
			ds(i,3) = 1;
			ds(i,4) = 1;
			ds4 = ds4+1;
		elseif max(abs(output.DispX(:,i)))/asset.ColH_ground < limit.LS1
			ds(i,1) = 1;
			ds1 = ds1+1;
		elseif max(abs(output.DispX(:,i)))/asset.ColH_ground < limit.LS2
			ds(i,2) = 1;
			ds2 = ds2+1;
		else
			ds(i,3) = 1;
			ds3 = ds3+1;
		end
	end
	if ds4 ~= 0
		DSx = 3;
	elseif	ds3/((asset.noBays+1)*(asset.noBayZ+1)) >= 0.3  %criterion given by Ishan (for 2D analysis)
		DSx = 3;
	elseif ds3 ~= 0
		DSx = 2;
	elseif	ds2 ~= 0
		DSx = 2;
	else 
		DSx = 1;
	end	
else
	if max(abs(output.DispX(:,i)))/asset.ColH_ground < limitx.LS1
		DSx = 1;
	else
		DSx = 3;
	end
end
	dsx=ds;
if out{1,1} == 'OK'
	ds = zeros(size(output.Vfr,2),3);                                      %ds shows the limit state for each column
	ds1 = 0;
	ds2 = 0;
	ds3 = 0;
	ds4 = 0;
	for i=1:size(output.Vfr,2)%i is the number of column
		if max(abs(output.DispY(:,i)))/asset.ColH_ground < limity.LS1
			ds(i,1) = 1;
			ds1 = ds1+1;
		elseif max(abs(output.DispY(:,i)))/asset.ColH_ground < limity.LS2
			ds(i,2) = 1;
			ds2 = ds2+1;
		else
			ds(i,3) = 1;
			ds3 = ds3+1;
		end
	end
	if ds4 ~= 0
		DSy = 3;
	elseif	ds3/((asset.noBays+1)*(asset.noBayZ+1)) >= 0.3                 %criterion given by Ishan (for 2D analysis)
		DSy = 3;
	elseif ds3 ~= 0
		DSy = 2;
	elseif	ds2 ~= 0
		DSy = 2;
	else 
		DSy = 1;
	end	
else
	if max(abs(output.DispY(:,i)))/asset.ColH_ground < limity.LS1
		DSy = 1;
	else
		DSy = 3;
	end
end
	dsy=ds;
	DS = max(DSx,DSy);
end

