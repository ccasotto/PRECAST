%% Chiara Casotto
% This script derives information about the records used in the fragility
% analysis, such as name, station, and Intensity Measure quantities
clc
clear
a=pwd;
NGA = dir(horzcat(a,'\NGArecords\'));
ev = [];
num = 1;
for T = 2%0.5:0.1:4
	counter = 1;
for j = 1:length(NGA)-2
	data=importdata(strcat(a,'/NGArecords/',NGA(2+j,1).name),' ',4);
   NGA(2+j,1).name;
   metadata=data.textdata;
   name = metadata{2,1};
   record = textscan(metadata{2},'%s','delimiter','    ','multipleDelimsAsOne',1);
   eq = record{1}(1);
   country = record{1}(2);
   data = record{1}(3);
   Station = record{1}(5);
   ev = [ev; NGA(2+j,1).name eq country data Station];
   units = 'g';
   [record] = processAccelerogram(NGA(2+j,1).name,2,1);
   dt = record(2,1);
   response = Spectrum_v2(record, 0.05, units, T);
   %AI = pi/(2*9.81)*sum(((record(:,2)*9.81).^2))*dt;
   %CAV = sum(abs(record(:,2)))*dt;
   IMLs(counter,num) = [response.Sa];
   %IMLs(counter,:) = [CAV];
   counter = counter+1;
end

for i = 1:39
	c = [7 8 9 10 11 12 22 23 24 25 26 27 28 29 30 31 32 33 37 38 39 43 44 45 52 53 54 55 56 57 61 62 63 76 77 78 82 83 84];
	f = [1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.4 1.4 1.2 1.2 1.2 1.3 1.3 1.3 1.4 1.4 1.4 1.4 1.2 1.4 1.4 1.4 1.4 1.2 1.2 1 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.5 1.4 1.2 1.4];
	h = c(i);
	a = pwd;
   data=importdata(strcat(a,'/NGArecords/',NGA(2+h,1).name),' ',4);
   NGA(2+h,1).name;
   metadata=data.textdata;
   name = metadata{2,1};
   record = textscan(metadata{2},'%s','delimiter','    ','multipleDelimsAsOne',1);
   eq = record{1}(1);
   country = record{1}(2);
   data = record{1}(3);
   Station = record{1}(5);
   ev = [ev; NGA(2+j,1).name eq country data Station];
   units = 'g';
   [record] = processAccelerogram(NGA(2+h,1).name,2,1);
   dt = record(2,1);
   %AI = pi/(2*9.81)*sum(((record(:,2)*9.81).^2))*dt;
   %CAV = sum(abs(record(:,2)))*dt;
   response = Spectrum_v2(record, 0.05, units, T);
   IMLs(counter,num) = [response.Sa*f(i)];
   %IMLs(counter,:) = [CAV];   
   counter = counter+1;
end
num = num+1;
end
z = 1:3:length(IMLs);
x = 2:3:length(IMLs);
y = 3:3:length(IMLs);
IMLsZ = IMLs(z,:);
IMLsX = IMLs(x,:);
IMLsY = IMLs(y,:);
SaX = sort(IMLsX(:,1));
PGAX = sort(IMLsX(:,2));
SaY = sort(IMLsY(:,1));
PGAY = sort(IMLsY(:,2));
AIX = IMLsX(:,1);
AIY = IMLsY(:,1);
AIZ = IMLsZ(:,1);
CAVX = IMLsX(:,1);
CAVY = IMLsY(:,1);
CAVZ = IMLsZ(:,1);
no = 1:length(IMLsX);
figure (1)
hold on
plot(no,SaX,'ko')
% plot(no,SaY,'bo')
plot(no,SaY,'ro')
legend('Sax','Say')
xlabel('n. records')
ylabel('Spectral Acceleration [cm/s^2]')
box off
legend boxoff
figure
hold on
plot(no,PGAX,'ko')
% plot(no,PGAY,'bo')
plot(no,PGAY,'ro')
legend('PGAx','PGAy)')
xlabel('n. records')
ylabel('PGA [g]')
box off
legend boxoff
% dlmwrite('AIX.tcl',AIX,'delimiter','	');
% dlmwrite('AIY.tcl',AIY,'delimiter','	');
% dlmwrite('AIZ.tcl',AIZ,'delimiter','	');
dlmwrite('IMLsX.tcl',IMLsX,'delimiter','	');
dlmwrite('IMLsY.tcl',IMLsY,'delimiter','	');
dlmwrite('IMLsZ.tcl',IMLsZ,'delimiter','	');