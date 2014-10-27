function [response, time_series, acceleration, velocity, displacement] = ...
    Spectrum_v2(time_hist, damping, units, Periods)

% -----------------------------------------------------------------------% 
%                                                                        % 
%           This program creates the Elastic Response Spectra            %  
%                        (Sa, PSa, Sv, PSv and Sd)                       %
%              for the inputing a ground motion record                   %
%                                                                        %
%                 Lu?s Macedo @ Rose School - November 2009              %
%                                      %                                 %
%                 Adapted & Vectorised by Graeme Weatherill,             %
%                      GEM Model Facility - September 2012               %
%
%   Inputs - time_hist: Acceleration record [time, acceleration]
%              damping: Fractional Coefficient of Damping
%                units: Units of acceleration 'g' | 'm/s/s' | {'cm/s/s'}
%              Periods: Spectral Periods (if not defined then default will
%                       be (2 * delta_t: 0.01: 4)
% 
%  Outputs - response: Data structure with:  
%                    .period: Spectral Periods (s)
%                    .Sa: Spectral Acceleration (cm/s/s)
%                    .Sv: Spectral Velocity (cm/s)
%                    .Sd: Spectral Displacement (cm)
%                    .PSa: Pseudospectral Acceleration (cm/s/s)
%                    .PSv: Pseudospectral Velocity (cm/s)
%
%          time_series: Data structure with:
%                    .time: Time (s)
%                    .acceleration: Acceleration (cm/s/s)
%                    .velocity: Velocity (cm/s)
%                    .displacement: Displacement (cm)
%
%         acceleration: Acceleration time histories [Number Time-steps, number Periods) 
%             velocity: Velocity time histories [Number Time-steps, number Periods)
%         displacement: Displacement time histories [Number Time-steps, number Periods)
%------------------------------------------------------------------------% 
if nargin < 4
    Periods = (2*(time_hist(1,2) - time_hist(1,1)): 0.01: 4);
    if nargin < 3
        units = 'cm/s/s';
    end
end
nper = length(Periods);
if size(Periods,1) > size(Periods,2);
    Periods = Periods';
end

% STARTING PROCESSING DATA
M=1;  % Hard-coded unit mass     
time = time_hist(:,1);
switch units
    case 'g'
        accel = time_hist(:, 2) .* 981.;
    case 'm/s/s'
        accel = time_hist(:, 2) .*100;
    otherwise
        accel = time_hist(:, 2);
end
dt=time(2)-time(1);              %Time Interval for numerical integration
nt=length(accel);

%% VELOCITIES AND DISPLACEMENTS TIMER SERIES USING NUMERICAL INTEGRATION
time_series.time = time;
time_series.velocity= dt.*cumtrapz(accel);
time_series.displacement= dt.*cumtrapz(time_series.velocity); 

%% RESPONSE SPECTRUM USING NEWMARK EXPLICIT METHOD
% Pre-allocation
velocity = zeros(nt,nper);
acceleration = zeros(nt,nper);
displacement = zeros(nt,nper);
at= zeros(nt,nper);

% Initial conditions    
wn= (2*pi)./ Periods;
C=damping*2*M*wn;    
K=(((2*pi)./Periods).^2).*M;
acceleration(1,:) = (1/M).*(-M.*accel(1,1) - (C .* velocity(1,:)) - ...
    (K .* displacement(1,:)));
at(1,:) = accel(1,1) + acceleration(1,:);
% Newmark-beta Integration
for j = 2:nt
    displacement(j,:) = displacement(j-1,:) + (dt .* velocity(j-1,:)) + ...
        (((dt ^ 2) / 2.) .* acceleration(j-1,:));
    acceleration(j,:) = (1./ (M + dt * 0.5 * C)) .* ...
        (-M .* accel(j) - K .* displacement(j,:) - C .* ...
        (velocity(j-1,:) + (dt * 0.5) .* acceleration(j-1,:)));
    velocity(j,:) = velocity(j-1,:) + dt .* (0.5 .* acceleration(j-1,:) + ...
        0.5 .* acceleration(j,:));
    at(j,:) = accel(j) + acceleration(j,:);
end
time_series.acceleration = accel;
response.period = Periods';
response.Sd = max(abs(displacement))';
response.Sa = max(abs(at))';
response.Sv = max(abs(velocity))';
% Pseudo-spectral Acceleration
response.PSa = ((wn' .^ 2.) .* response.Sd);
response.PSv = (wn' .* response.Sd);
return
end
    