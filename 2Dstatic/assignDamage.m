
	fid = fopen('dynamicResult.txt');
	out = textscan(fid,'%2c');
	fclose(fid);
	Dispmax = max(abs(output.disp));
	Vbmax = max(abs(output.Vb));
		if out{1,1} == 'OK'
			if Dispmax > limit.LSconnection(1)
			 DS = 3;
			 DSpt(noAsset,4) = DSpt(noAsset,4)+1;
			elseif Dispmax <= limit.LS1
			DS = 1;
			elseif Dispmax <= limit.LS2
			DS = 2;
			else
			DS = 3;
			end
		else
			if Dispmax > limit.LSconnection(1)
				DS = 3;
				DSpt(noAsset,4) = DSpt(noAsset,4)+1;
			elseif Dispmax <= limit.LS1
			DS = 1;
			else DS = 3;
			end
		end
		DSpt(noAsset,DS) = DSpt(noAsset,DS)+1;
		f = find(DispPo > Dispmax);
		if numel(f) == 0
			Vbmax = limit.Vb2;
			Dispmax = limit.LS2;
		else Vbmax = VbPo(f(1));
		end
		plot(Dispmax,Vbmax,'b*');


