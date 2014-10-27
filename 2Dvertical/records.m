%% Chiara Casotto
% This script derives information about the records used in the fragility
% analysis, such as name, station, and Intensity Measure quantities
clc
clear
a=pwd;
NGA = dir(horzcat(a,'/NGArecords/'));
ev = [];
T = 1.3;
T = [0.05	0.06	0.07	0.08	0.09	0.1	0.11	0.12	0.13	0.14	0.15	0.16	0.17	0.18	0.19	0.2	0.21	0.22	0.23	0.24	0.25	0.26	0.27	0.28	0.29	0.3	0.31	0.32	0.33	0.34	0.35	0.36	0.37	0.38	0.39	0.4	0.41	0.42	0.43	0.44	0.45	0.46	0.47	0.48	0.49	0.5	0.51	0.52	0.53	0.54	0.55	0.56	0.57	0.58	0.59	0.6	0.61	0.62	0.63	0.64	0.65	0.66	0.67	0.68	0.69	0.7	0.71	0.72	0.73	0.74	0.75	0.76	0.77	0.78	0.79	0.8	0.81	0.82	0.83	0.84	0.85	0.86	0.87	0.88	0.89	0.9	0.91	0.92	0.93	0.94	0.95	0.96	0.97	0.98	0.99	1	1.01	1.02	1.03	1.04	1.05	1.06	1.07	1.08	1.09	1.1	1.11	1.12	1.13	1.14	1.15	1.16	1.17	1.18	1.19	1.2	1.21	1.22	1.23	1.24	1.25	1.26	1.27	1.28	1.29	1.3	1.31	1.32	1.33	1.34	1.35	1.36	1.37	1.38	1.39	1.4	1.41	1.42	1.43	1.44	1.45	1.46	1.47	1.48	1.49	1.5	1.51	1.52	1.53	1.54	1.55	1.56	1.57	1.58	1.59	1.6	1.61	1.62	1.63	1.64	1.65	1.66	1.67	1.68	1.69	1.7	1.71	1.72	1.73	1.74	1.75	1.76	1.77	1.78	1.79	1.8	1.81	1.82	1.83	1.84	1.85	1.86	1.87	1.88	1.89	1.9	1.91	1.92	1.93	1.94	1.95	1.96	1.97	1.98	1.99	2	2.01	2.02	2.03	2.04	2.05	2.06	2.07	2.08	2.09	2.1	2.11	2.12	2.13	2.14	2.15	2.16	2.17	2.18	2.19	2.2	2.21	2.22	2.23	2.24	2.25	2.26	2.27	2.28	2.29	2.3	2.31	2.32	2.33	2.34	2.35	2.36	2.37	2.38	2.39	2.4	2.41	2.42	2.43	2.44	2.45	2.46	2.47	2.48	2.49	2.5	2.51	2.52	2.53	2.54	2.55	2.56	2.57	2.58	2.59	2.6	2.61	2.62	2.63	2.64	2.65	2.66	2.67	2.68	2.69	2.7	2.71	2.72	2.73	2.74	2.75	2.76	2.77	2.78	2.79	2.8	2.81	2.82	2.83	2.84	2.85	2.86	2.87	2.88	2.89	2.9	2.91	2.92	2.93	2.94	2.95	2.96	2.97	2.98	2.99	3	3.01	3.02	3.03	3.04	3.05	3.06	3.07	3.08	3.09	3.1	3.11	3.12	3.13	3.14	3.15	3.16	3.17	3.18	3.19	3.2	3.21	3.22	3.23	3.24	3.25	3.26	3.27	3.28	3.29	3.3	3.31	3.32	3.33	3.34	3.35	3.36	3.37	3.38	3.39	3.4	3.41	3.42	3.43	3.44	3.45	3.46	3.47	3.48	3.49	3.5	3.51	3.52	3.53	3.54	3.55	3.56	3.57	3.58	3.59	3.6	3.61	3.62	3.63	3.64	3.65	3.66	3.67	3.68	3.69	3.7	3.71	3.72	3.73	3.74	3.75	3.76	3.77	3.78	3.79	3.8	3.81	3.82	3.83	3.84	3.85	3.86	3.87	3.88	3.89	3.9	3.91	3.92	3.93	3.94	3.95	3.96	3.97	3.98	3.99	4	4.01	4.02	4.03	4.04	4.05	4.06	4.07	4.08	4.09	4.1	4.11	4.12	4.13	4.14	4.15	4.16	4.17	4.18	4.19	4.2	4.21	4.22	4.23	4.24	4.25	4.26	4.27	4.28	4.29	4.3	4.31	4.32	4.33	4.34	4.35	4.36	4.37	4.38	4.39	4.4	4.41	4.42	4.43	4.44	4.45	4.46	4.47	4.48	4.49	4.5	4.51	4.52	4.53	4.54	4.55	4.56	4.57	4.58	4.59	4.6	4.61	4.62	4.63	4.64	4.65	4.66	4.67	4.68	4.69	4.7	4.71	4.72	4.73	4.74	4.75	4.76	4.77	4.78	4.79	4.8	4.81	4.82	4.83	4.84	4.85	4.86	4.87	4.88	4.89	4.9	4.91	4.92	4.93	4.94	4.95	4.96	4.97	4.98	4.99	5	5.01	5.02	5.03	5.04	5.05	5.06	5.07	5.08	5.09	5.1	5.11	5.12	5.13	5.14	5.15	5.16	5.17	5.18	5.19	5.2	5.21	5.22	5.23	5.24	5.25	5.26	5.27	5.28	5.29	5.3	5.31	5.32	5.33	5.34	5.35	5.36	5.37	5.38	5.39	5.4	5.41	5.42	5.43	5.44	5.45	5.46	5.47	5.48	5.49	5.5	5.51	5.52	5.53	5.54	5.55	5.56	5.57	5.58	5.59	5.6	5.61	5.62	5.63	5.64	5.65	5.66	5.67	5.68	5.69	5.7	5.71	5.72	5.73	5.74	5.75	5.76	5.77	5.78	5.79	5.8	5.81	5.82	5.83	5.84	5.85	5.86	5.87	5.88	5.89	5.9	5.91	5.92	5.93	5.94	5.95	5.96	5.97	5.98	5.99	6	6.01	6.02	6.03	6.04	6.05	6.06	6.07	6.08	6.09	6.1	6.11	6.12	6.13	6.14	6.15	6.16	6.17	6.18	6.19	6.2	6.21	6.22	6.23	6.24	6.25	6.26	6.27	6.28	6.29	6.3	6.31	6.32	6.33	6.34	6.35	6.36	6.37	6.38	6.39	6.4	6.41	6.42	6.43	6.44	6.45	6.46	6.47	6.48	6.49	6.5	6.51	6.52	6.53	6.54	6.55	6.56	6.57	6.58	6.59	6.6	6.61	6.62	6.63	6.64	6.65	6.66	6.67	6.68	6.69	6.7	6.71	6.72	6.73	6.74	6.75	6.76	6.77	6.78	6.79	6.8	6.81	6.82	6.83	6.84	6.85	6.86	6.87	6.88	6.89	6.9	6.91	6.92	6.93	6.94	6.95	6.96	6.97	6.98	6.99	7	7.01	7.02	7.03	7.04	7.05	7.06	7.07	7.08	7.09	7.1	7.11	7.12	7.13	7.14	7.15	7.16	7.17	7.18	7.19	7.2	7.21	7.22	7.23	7.24	7.25	7.26	7.27	7.28	7.29	7.3	7.31	7.32	7.33	7.34	7.35	7.36	7.37	7.38	7.39	7.4	7.41	7.42	7.43	7.44	7.45	7.46	7.47	7.48	7.49	7.5	7.51	7.52	7.53	7.54	7.55	7.56	7.57	7.58	7.59	7.6	7.61	7.62	7.63	7.64	7.65	7.66	7.67	7.68	7.69	7.7	7.71	7.72	7.73	7.74	7.75	7.76	7.77	7.78	7.79	7.8	7.81	7.82	7.83	7.84	7.85	7.86	7.87	7.88	7.89	7.9	7.91	7.92	7.93	7.94	7.95	7.96	7.97	7.98	7.99	8	8.01	8.02	8.03	8.04	8.05	8.06	8.07	8.08	8.09	8.1	8.11	8.12	8.13	8.14	8.15	8.16	8.17	8.18	8.19	8.2	8.21	8.22	8.23	8.24	8.25	8.26	8.27	8.28	8.29	8.3	8.31	8.32	8.33	8.34	8.35	8.36	8.37	8.38	8.39	8.4	8.41	8.42	8.43	8.44	8.45	8.46	8.47	8.48	8.49	8.5	8.51	8.52	8.53	8.54	8.55	8.56	8.57	8.58	8.59	8.6	8.61	8.62	8.63	8.64	8.65	8.66	8.67	8.68	8.69	8.7	8.71	8.72	8.73	8.74	8.75	8.76	8.77	8.78	8.79	8.8	8.81	8.82	8.83	8.84	8.85	8.86	8.87	8.88	8.89	8.9	8.91	8.92	8.93	8.94	8.95	8.96	8.97	8.98	8.99	9	9.01	9.02	9.03	9.04	9.05	9.06	9.07	9.08	9.09	9.1	9.11	9.12	9.13	9.14	9.15	9.16	9.17	9.18	9.19	9.2	9.21	9.22	9.23	9.24	9.25	9.26	9.27	9.28	9.29	9.3	9.31	9.32	9.33	9.34	9.35	9.36	9.37	9.38	9.39	9.4	9.41	9.42	9.43	9.44	9.45	9.46	9.47	9.48	9.49	9.5	9.51	9.52	9.53	9.54	9.55	9.56	9.57	9.58	9.59	9.6	9.61	9.62	9.63	9.64	9.65	9.66	9.67	9.68	9.69	9.7	9.71	9.72	9.73	9.74	9.75	9.76	9.77	9.78	9.79	9.8	9.81	9.82	9.83	9.84	9.85	9.86	9.87	9.88	9.89	9.9	9.91	9.92	9.93	9.94	9.95	9.96	9.97	9.98	9.99	10]
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
   IMLs(j,:) = [response.Sa'];
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
   [record] = processAccelerogram(NGA(2+h,1).name,2);
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
