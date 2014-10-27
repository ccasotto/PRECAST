clc
clear all
close all
a = pwd;
noLSs=3;
type = 1;
code = 1;
s = 4;
c=3;
IMLs=dlmread('IMLsX.tcl');
	pdmTOT = dlmread(horzcat(a,'/results/',num2str(type),'_',num2str(s),'/pdm',num2str(c),'1.tcl'));
 	pdmCnn = dlmread(horzcat(a,'/results/',num2str(type),'_',num2str(s),'/pdmOC',num2str(c),'1.tcl'));
 	pdm = dlmread(horzcat(a,'/results/',num2str(type),'_',num2str(s),'/pdmWO1.tcl'));
T=0.5:0.1:4;
[ LS1, LS2, LSmean, maxLSmean, T1, T2, Tm, fit] = Correlation( pdm, IMLs,T); %correlation based on flexural collapse
T(Tm)
pdm(:,4)=IMLs(:,Tm);
[DPM] = DamageProbabilityMatrix (pdm, noLSs);
cumDamageStates = fragility(DPM, noLSs);
pdmCnn(:,4) = IMLs(:,Tm);
[DPMCnn] = DamageProbabilityMatrix (pdmCnn, noLSs);
cumDamageStatesCnn = fragility(DPMCnn, noLSs);
cumDamageStatesCnn(:,4) = DPM(:,4);
pdmTOT(:,4)=IMLs(:,Tm);
[DPMTOT] = DamageProbabilityMatrix (pdmTOT, noLSs);
cumDamageStatesTOT = fragility(DPMTOT, noLSs);
[fitCnn, probCnn] = CnnStatistics( cumDamageStatesCnn,noLSs );
iml=1:DPM(length(DPM),4)/length(DPM):DPM(length(DPM),4);
	y = logncdf(iml,fit.MLE(2,1),fit.MLE(2,2));
	ycnn = logncdf(iml,fitCnn(2,1),fitCnn(2,2));
	ytot = y*(1-probCnn) + ycnn*probCnn;
fitCnn
%% Plots
figure1 = figure;
axes1 = axes('Parent',figure1);
box(axes1,'on');
hold(axes1,'all');
plot(T,LS1,'b','Marker','*');
hold on
plot(T,LS2,'r','Marker','+');
plot(T,LSmean,'k','LineStyle','--');
plot(T(T1),min(LS2):0.001:max(LS1),'b','DisplayName','LS1');
plot(T(T2),min(LS2):0.001:max(LS2),'r','DisplayName','LS2');
plot(T(Tm),min(LS2):0.001:maxLSmean,'k','DisplayName','mean');
legend1 = legend('LS1','LS2','mean')
set(legend1,'FontSize',14, 'Location','SouthEast');
xlabel('Period [s]','FontSize',14);
ylabel('Correlation','FontSize',14)
legend boxoff
box off

figure (2)
hold on
plot1 = plot(iml,[ ycnn*probCnn; y*(1-probCnn); ytot]);
plot2 = plot(DPM(:,4),cumDamageStatesTOT(:,3),'LineStyle','none');
set(plot1(1),'LineWidth',2,'Color',[0 0 1],'LineStyle',':','DisplayName','PoE connection collapse');
set(plot1(2),'LineWidth',0.5,'Color',[0 0 1],'LineStyle','--','DisplayName','PoE flexural collape');
set(plot1(3),'LineWidth',2,'DisplayName','PoE total','Color',[0 0 0],'MarkerSize',6);
set(plot2,'Marker','+','Color',[0 0 0],'DisplayName','LS2');
legend1 = legend('PoE connection collapse','PoE flexural collape','PoE total');
set(legend1,'FontSize',12,'Location','SouthEast')
xlabel('Sa(Topt) [cm/s^2]','FontSize',14)
ylabel('Probability of Exceedance','FontSize',14)
legend boxoff
box off

fpat=horzcat(a,'\results\collapse');
fnam=horzcat('collapseSa',num2str(type),'_',num2str(s),'_',num2str(c),'.fig');
saveas(gcf,[fpat,filesep,fnam],'fig')
fnam=horzcat('collapseTOTSa',num2str(type),'_',num2str(s),'_',num2str(c),'.bmp');	 
saveas(gcf,[fpat,filesep,fnam],'bmp')

figure(3)
hold on
plot1 = plot(DPM(:,4),cumDamageStates(:,2),'LineStyle','none');
plot2 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
plot3 = plot(iml,logncdf(iml,fit.MLE(1,1),fit.MLE(1,2)));
plot4 = plot(iml,logncdf(iml,fit.MLE(2,1),fit.MLE(2,2)));
set(plot1,'Marker','*','Color',[0 0 1],'DisplayName','LS1');
set(plot2,'Marker','+','Color',[1 0 0],'DisplayName','LS2');
set(plot3,'LineWidth',2,'Color',[0 0 1],'LineStyle','-','DisplayName','PoE yielding');
set(plot4,'LineWidth',2,'Color',[1 0 0],'LineStyle','-','DisplayName','PoE flexural collape');
xlabel('Sa(Tmean) [cm/s/s]','FontSize',14);
ylabel('Probability of Exceedance','FontSize',14);
legend('show','FontSize',12);
box off
legend boxoff

% fpat=horzcat(a,'\results\fragilityCurves');
% fnam=horzcat('fragility',num2str(type),'_',num2str(code),'_',num2str(s),'.fig');
% saveas(gcf,[fpat,filesep,fnam],'fig')
% fnam=horzcat('fragility',num2str(type),'_',num2str(code),'_',num2str(s),'.bmp');	 
% saveas(gcf,[fpat,filesep,fnam],'bmp')

dlmwrite('stats.tcl',fit.MLE,'delimiter','	');
dlmwrite('statsCnn.tcl',fitCnn,'delimiter','	');
