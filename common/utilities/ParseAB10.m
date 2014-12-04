function [ filelist,t,M,d ] = ParseAB10(recordName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

	[data,metadata] = xlsread(recordName);
	filelist = {};
	M = [];
	d = [];
	t = [];
	l = 0;
	for i = 1:length(data)
		if data(i,9) <= 6.5
			if data(i,29) <= 30
			if data(i,26) < 3
				l = l+1;
				filename = metadata(i,35);
				t = [t; data(i,37)];
				M = [M; data(i,9)];
				d = [d; data(i,29)];
				filelist{l} = horzcat(filename{1,1},'.smc.rm.bp.a.pad');
			end
			end
		end	
	end

				

end

