function [rotx, roty ] = rotate_single_history(x,y, theta )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if size(x,2) > 1
    x = x(:,2);
    y = y(:,2);
end

theta = theta .* (pi/180);
number_angles = length(theta);

nstep = size(x,1);

rotx = zeros(nstep, number_angles);
roty = zeros(nstep, number_angles);

for i = 1:number_angles %#ok<FORPF>
    rotx(:,i) = (cos(theta(i)) .* x) + (sin(theta(i)) .* y);
    roty(:,i) = (-sin(theta(i)) .* x) + (cos(theta(i)) .* y); 
end


end

