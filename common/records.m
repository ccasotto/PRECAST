%% Chiara Casotto
% This script derives information about the records used in the fragility
% analysis, such as name, station, and Intensity Measure quantities
clc
clear
a=pwd;
NGA = dir('../NGArecords/');
ev = [];
T = 0.1:0.1:4;
for j = 1:length(NGA)-2
	a = pwd;
%    data=importdata(strcat(a,'/NGArecords/',NGA(2+j,1).name),' ',4);
%    metadata=data.textdata;
%    name = metadata{2,1};
%    record = textscan(metadata{2},'%s','delimiter','    ','multipleDelimsAsOne',1);
%    eq = record{1}(1);
%    country = record{1}(2);
%    data = record{1}(3);
%    Station = record{1}(5);
%    ev = [ev; NGA(2+j,1).name eq country data Station];
   units = 'g';
   [record] = parseAccelerogram(NGA(2+j,1).name,2);
   response = Spectrum_v2(record, 0.05, units, T);
   IMLs(j,:) = response.Sa';
end
   
for i = 1:39
	c = [7 8 9 10 11 12 22 23 24 25 26 27 28 29 30 31 32 33 37 38 39 43 44 45 52 53 54 55 56 57 61 62 63 76 77 78 82 83 84];
	f = [1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.4 1.4 1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.4 1.4 1.4 1.2 1.4 1.4 1.4 1.4 1.2 1.2 1 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.2 1.4]; %multipliers factor for scaling the records
	h = c(i);
	a = pwd;
%    data=importdata(strcat(a,'/NGArecords/',NGA(2+h,1).name),' ',4);
%    metadata=data.textdata;
%    name = metadata{2,1};
%    record = textscan(metadata{2},'%s','delimiter','    ','multipleDelimsAsOne',1);
%    eq = record{1}(1);
%    country = record{1}(2);
%    data = record{1}(3);
%    Station = record{1}(5);
%    ev = [ev; NGA(2+j,1).name eq country data Station];
   units = 'g';
   [record] = parseAccelerogram(NGA(2+h,1).name,2);
   response = Spectrum_v2(record, 0.05, units, T);
   IMLs(j+i,:) = [response.Sa'*f(i)];
end

z = 1:3:size(IMLs,1);
x = 2:3:size(IMLs,1);
y = 3:3:size(IMLs,1);
IMLsZ = IMLs(z,:);
IMLsX = IMLs(x,:);
IMLsY = IMLs(y,:);
MEANX = mean(IMLsX,1);
SaX = sort(IMLsX(:,1));
PGAX = sort(IMLsX(:,2));
SaY = sort(IMLsY(:,1));
PGAY = sort(IMLsY(:,2));
SaZ = sort(IMLsZ(:,1));
PGAZ = sort(IMLsZ(:,2));
no = 1:length(IMLsX);
figure
hold on
plot(no,SaX,'ko')
plot(no,SaY,'bo')
plot(no,SaZ,'ro')
figure
hold on
plot(no,PGAX,'ko')
plot(no,PGAY,'bo')
plot(no,PGAZ,'ro')
dlmwrite('IMLsX.tcl',IMLsX,'delimiter','	');
dlmwrite('IMLsY.tcl',IMLsY,'delimiter','	');
dlmwrite('IMLsZ.tcl',IMLsZ,'delimiter','	');
