function [rotated_spectra, PF, SaGMRotD50, SaGMRotD100, SaGMRotI50] = rotate_time_history(accel_x, accel_y, theta)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Convert Angles to radians
theta = theta .* (pi / 180);
% Pre-allocate output
number_angles = length(theta);
number_periods = size(accel_x, 2);
rotated_spectra = zeros(number_angles, number_periods);

for i = 1:number_angles %#ok<FORPF>
    % Apply rotationjhy
    accel_rot_x = (cos(theta(i)) .* accel_x) + (sin(theta(i)) .* accel_y);
    accel_rot_y = (-sin(theta(i)) .* accel_x) + (cos(theta(i)) .* accel_y);
    rotated_spectra(i,:) = sqrt(max(abs(accel_rot_x),[],1) .* max(abs(accel_rot_y),[],1));
end

% SaGMRotD
SaGMRotD50 = median(rotated_spectra,1);
SaGMRotD100 = max(rotated_spectra,[],1);

% Penalty Function
PF = zeros(number_angles,1);
for i = 1:number_angles
    PF(i) = (1./number_periods) .* sum(((rotated_spectra(i,:) ./ SaGMRotD50) - 1.).^2);
end
[minPF, PFloc] = min(PF);
SaGMRotI50 = rotated_spectra(PFloc,:);

