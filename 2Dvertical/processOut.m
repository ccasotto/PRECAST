function [ output ] = processOut( asset )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
	output.disp = dlmread('nodeDisp_dynamic.txt')/asset.ColH_ground;
% 	plot(0.01:0.01:length(output.disp)*0.01,output.disp,'r')
	Vb = dlmread('nodeReaction_dynamic.txt');
	n= 2:2:size(Vb,2);
	output.axial = Vb(:,n);
	output.V = Vb(:,n-1);	

end

