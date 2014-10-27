
	fid = fopen('dynamicResult.txt');
	out = textscan(fid,'%2c');
	fclose(fid);
	Dispmax = max(abs(output.disp));
		if out{1,1} == 'OK'
			if Dispmax > limit.LSconnection(2)
			 DS3 = 3;
			elseif Dispmax <= limit.LS1
			DS3 = 1;
			elseif Dispmax <= limit.LS2
			DS3 = 2;
			else
			DS3 = 3;
			end
		else
			if Dispmax > limit.LSconnection(2)
				DS3 = 3;
			elseif Dispmax <= limit.LS1
			DS3 = 1;
			else DS3 = 3;
			end
		end