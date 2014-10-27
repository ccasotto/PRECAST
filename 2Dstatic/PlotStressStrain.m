function [ output_args ] = PlotStressStrain( input_args )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

C = dlmread('ConcreteStressStrain.txt');
figure(1)
plot(-C(:,2),-C(:,1),'green','LineWidth',2);
grid on

figure(2)
S = dlmread('SteelStressStrain.txt');
plot(S(:,2),S(:,1),'red','LineWidth',2);
grid on

end

