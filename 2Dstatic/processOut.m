function [ output ] = processOut( asset )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
	output.disp = dlmread('nodeDisp_dynamic.txt')/asset.ColH_ground;
	output.Vb = dlmread('nodeReaction_dynamic.txt');
end

