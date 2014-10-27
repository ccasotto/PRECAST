%% Chiara Casotto
% This script derives information about the records used in the fragility
% analysis, such as name, station, and Intensity Measure quantities
clc
clear
a=pwd;

NGA = dir(horzcat(a,'/NGArecords/'));
ev = [];
PGA = [];
num = 1;
for T = 0.57;%0.5:0.2:4
	for j = 1:length(NGA)-2
	a = pwd;
   data=importdata(strcat(a,'/NGArecords/',NGA(2+j,1).name),' ',4);
   NGA(2+j,1).name
   metadata=data.textdata;
   name = metadata{2,1};
   record = textscan(metadata{2},'%s','delimiter','    ','multipleDelimsAsOne',1);
   eq = record{1}(1);
   country = record{1}(2);
   data = record{1}(3);
   Station = record{1}(5);
   ev = [ev; NGA(2+j,1).name eq country data Station];
   units = 'g';
   [record] = parseAccelerogram(NGA(2+j,1).name,2);
   PGA = [PGA; max(abs((record(:,2))))];
   response = Spectrum_v2(record, 0.05, units, T);
   IMLs(j,num) = [response.Sa];
	end

	for i = 1:39
	c = [7 8 9 10 11 12 22 23 24 25 26 27 28 29 30 31 32 33 37 38 39 43 44 45 52 53 54 55 56 57 61 62 63 76 77 78 82 83 84];
	m = [1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.4 1.4 1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.4 1.4 1.4 1.2 1.4 1.4 1.4 1.4 1.2 1.2 1 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.2 1.4]; %multipliers factor for scaling the records
	h = c(i);
	a = pwd;
   data=importdata(strcat(a,'/NGArecords/',NGA(2+h,1).name),' ',4);
   NGA(2+h,1).name
   metadata=data.textdata;
   name = metadata{2,1};
   record = textscan(metadata{2},'%s','delimiter','    ','multipleDelimsAsOne',1);
   eq = record{1}(1);
   country = record{1}(2);
   data = record{1}(3);
   Station = record{1}(5);
   ev = [ev; NGA(2+j,1).name eq country data Station];

   units = 'g';
   [record] = processAccelerogram(NGA(2+h,1).name,2);
   PGA = [PGA; max(abs((record(:,2))))];
   response = Spectrum_v2(record, 0.05, units, T);
   IMLs(j+i,num) = [response.Sa*m(i)];
   
	end
	num = num+1;
end

counter = 1;
for k = 1:3:length(IMLs)
IMLsX(counter,:) = IMLs(k+1,:);
IMLsY(counter+1,:) = IMLs(k+2,:);
evXY(counter,:) = ev(k+1,:);
evXY(counter+1,:) = ev(k+2,:);
counter = counter+2;
end

IMLs = IMLsXY;
%dlmwrite('IMLs.tcl',IMLs,'delimiter','	');
SaX = sort(IMLs(:,1));
PGAX = sort(IMLs(:,1));
no = 1:length(IMLs);
figure
hold on
plot(no,SaX,'ko')
figure
hold on
plot(no,PGAX,'ko')
