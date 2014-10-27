function [ OC3 ] = assignDamageOC3( output,limit )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 	fid = fopen('dynamicResult.txt');
	out = textscan(fid,'%2c');
	fclose(fid);
	Dispmax = max(abs(output.disp));
		if out{1,1} == 'OK'
			if Dispmax > limit.LSconnection(2)
			 OC3 = 3;
			else
			OC3 = 1;
			end
		else
			if Dispmax > limit.LSconnection(2)
				OC3 = 3;
			else 
			OC3 = 1;
			end
		end

end

