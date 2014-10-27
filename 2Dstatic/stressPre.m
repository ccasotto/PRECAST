function [ scu,ssd ] = stressPre(M,N,As,b,h,d1,co)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    ro=As/(b*h);
    J=(b*h^3)/12+2*co*As*((h/2-d1)^2);
    W=J/(b/2);
    scu=N/(b*h*(1+co*ro)^2)+M/W;%stress in the concrete %Verification of the stresses for small eccentricity 
    ssd=(-N/(b*h*(1+co*ro)^2)+M/W)*co;%stresses in the steel

end

