function [ WO ] = assignDamageWoConnection( output,limit )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
	fid = fopen('dynamicResult.txt');
	out = textscan(fid,'%2c');
	fclose(fid);
			if out{1,1} == 'OK'
			if max(abs(output.disp)) <= limit.LS1
			WO = 1;
			elseif max(abs(output.disp)) <= limit.LS2
			WO = 2;
			else
			WO = 3;
			end
		else
			if max(abs(output.disp)) <= limit.LS1
			WO = 1;
			else WO = 3;
			end
		end

end

