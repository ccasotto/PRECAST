function [ DS,ds ] = assignDamageChord( output, chord, asset )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fid = fopen('dynamicResult.txt');
out = textscan(fid,'%2c');
fclose(fid);
if out{1,1} == 'OK'
	ds = zeros(size(output.Vfr,2),4);                                      %ds shows the limit state for each column
	ds1 = 0;
	ds2 = 0;
	ds3 = 0;
	ds4 = 0;
	for i=1:size(output.Vfr,2) %i is the number of column
		if min(output.Vfr(:,i)) < max(output.Ved(:,i))                     %connection failure
			ds(i,3) = 1;
			ds(i,4) = 1;
			ds4 = ds4+1;
		elseif	max(((output.deffx(:,i)/chord.PyX).^2+(output.deffy(:,i)/chord.PyY).^2).^0.5) <= 1
			ds(i,1) = 1;
			ds1 = ds1+1;
		elseif max(((output.deffx(:,i)/chord.PuX).^2+(output.deffy(:,i)/chord.PuY).^2).^0.5) <= 1
			ds(i,2) = 1;
			ds2 = ds2+1;
		else
			ds(i,3) = 1;
			ds3 = ds3+1;
		end
	end

	if ds4 ~= 0
		DS = 3;
	elseif ds3/((asset.noBays+1)*(asset.noBayZ+1)) >= 0.3 %criterion given by Ishan (for 2D analysis)
		DS = 3;
	elseif ds3 ~= 0
		DS = 2;
	elseif	ds2 ~= 0
		DS = 2;
	else 
		DS = 1;
	end
else
	if max(((output.deffx(:,i)/chord.PyX).^2+(output.deffy(:,i)/chord.PyY).^2).^0.5) <= 1
		DS = 1;
	else
		DS = 3;
	end
end

end

