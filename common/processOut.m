function [ output ] = processOut( asset, constant )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

output.disp = dlmread('tmp/nodeDisp_dynamic.txt')/asset.ColH_ground;
Vb = dlmread('tmp/nodeReaction_dynamic.txt');
n= 2:2:size(Vb,2);
if constant == 1
    output.axial = ones(length(Vb),1)*Vb(1,n)*asset.fv;
else
    output.axial = Vb(:,n);
end 
output.V = Vb(:,n-1);
output.acc = dlmread('tmp/nodeAcc_dynamic.txt');
end

