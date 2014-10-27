function [ OC3 ] = assignDamageOC03( output,asset,limit,connection,cnn)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

	ds4 = 0;
	for i=1:(asset.noBays+1):size(output.disp,2)   %i is the number of column
		for j=i:i+asset.noBays
			if sum((abs(output.V(:,j)) - (output.axial(:,i)*0.3 + connection.Vb(cnn)))./abs(abs(output.V(:,j))-(output.axial(:,i)*0.3+ connection.Vb(cnn))))/size(output.disp,1)>-1     %connection failure (solo in X o composizione delle due?)
				ds4 = ds4+1;
			end
		end
	end

	if ds4 ~= 0
		OC3 = 3;
	else OC3 = 1;
	end

end

