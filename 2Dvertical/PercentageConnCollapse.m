clc
clear all
close all
a = pwd;
s = [4 6 9 12];
c = 3;
%% 1_4
perc=zeros(2,length(s));
for type = 1:2
	counter = 1;
	while counter <length(s)+1
	OC = dlmread(horzcat(a,'/results/',num2str(type),'_',num2str(s(counter)),'/pdmOC',num2str(c),'1.tcl'));
    cnn_collapse = OC(:,3);
    mean_perc = mean(cnn_collapse)/100;
    perc(type,counter)=mean_perc;
	counter = counter +1;
    end
end

dlmwrite('Percentage.txt',perc,'delimiter','	')
