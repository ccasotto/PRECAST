clc
clear all
close all
% a = pwd;
% Cnn1 = 0.75;
% Cnn2 =0.01;
% fits = dlmread(horzcat(a,'\fits\fits.txt'));
% stats = fits(17,2:3);
% stats= [3.7 0.44];
% iml=1:5:800;
% plot3 = plot(iml,logncdf(iml,stats(1,1),stats(1,2)));
% set(plot3,'Color',[1 0 0],'Linewidth',1);
% y = logncdf(iml,stats(1,1),stats(1,2));
% f1 = find(y>Cnn1);
% f2 = find(y>Cnn2);
% Sa1 = iml(f1(1));
% Sa2 = iml(f2(1));

u=1;
for comb=0:3;%0=116,1=126,2=129,3=1212
	for cnn = 1:4 %1=c0.2,2=c0.3,3=f0.2,4=f0.3
	a = pwd;
	type = 3;
	name = horzcat(a,'\fits\type',num2str(type),'.txt');
	iml = 1:5:800;
	fits = dlmread(name);
	perc = fits(4*comb+cnn,6)
	stats = fits(4*comb+cnn,:);
	y = logncdf(iml,stats(1,1),stats(1,2));
	f = find(iml<stats(1,3));
	ycnn(f) = logncdf(iml(f),stats(1,4),stats(1,5));
	ycnn(length(f)+1:length(iml)) = stats(1,6);
	ytot = y*(1-perc) + ycnn;
		
	figure(u)
	plot1 = plot(iml,[ycnn; y*(1-perc); ytot]);
	set(plot1(1),'LineWidth',0.5,'Color',[0 0 1],'LineStyle',':','DisplayName','PoE connection collapse');
	set(plot1(2),'LineWidth',0.5,'Color',[0 0 1],'LineStyle','--','DisplayName','PoE flexural collape');
	set(plot1(3),'LineWidth',2,'DisplayName','PoE total','Color',[0 0 0],'MarkerSize',6);
	legend('PoE connection collapse','PoE flexural collape','PoE total')
	xlabel('Sa(Tmean) [cm/s/s]')
	ylabel('Probability of Exceedance')
	legend boxoff
	box off
	 fpat='C:\Users\chiaretta\Documents\PHD\THESIS\Analyses\2DstaticOld\results\collapse';
     fnam=horzcat('collapse',num2str(type),'_',num2str(u),'.fig');
     saveas(gcf,[fpat,filesep,fnam],'fig')
     fnam=horzcat('collapse',num2str(type),'_',num2str(u),'.bmp');	 
	 saveas(gcf,[fpat,filesep,fnam],'bmp')
	 u=u+1;
	end
end