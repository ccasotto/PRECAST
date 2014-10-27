function [ OC ] = assignDamageOC( output,limit )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 	fid = fopen('dynamicResult.txt');
	out = textscan(fid,'%2c');
	fclose(fid);
	Dispmax = max(abs(output.disp));
	Vbmax = max(abs(output.Vb));
		if out{1,1} == 'OK'
			if Dispmax > limit.LSconnection(1)
			 OC = 3;
			else
			OC = 1;
			end
		else
			if Dispmax > limit.LSconnection(1)
				OC = 3;
			else 
			OC = 1;
			end
		end

end

