	fid = fopen('dynamicResult.txt');
	out = textscan(fid,'%2c');
	fclose(fid);
	Dispmax = max(abs(output.disp));
		if out{1,1} == 'OK'
			if Dispmax <= limit.LS1
			WO = 1;
			elseif Dispmax <= limit.LS2
			WO = 2;
			else
			WO = 3;
			end
		else
			if Dispmax <= limit.LS1
			WO = 1;
			else WO = 3;
			end
		end

		f = find(DispPo > Dispmax);
		if numel(f) == 0
			Vbmax = limit.Vb2
			Dispmax = limit.LS2
		else Vbmax = VbPo(f(1));
		end
% 		plot(Dispmax,Vbmax,'b*');