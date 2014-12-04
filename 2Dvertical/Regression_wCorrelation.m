clc
clear all
close all
a = pwd;
noLSs=3;
type = 1;
code = 1;
s = 4;
c=02;
addpath('../common/');
IMLsX=dlmread('IMLsX.tcl');
IMLs = IMLsX;

pdm = dlmread('./../Results/pdm1.tcl');
%pdm=pdm(1:56,:); IMLs = IMLs(1:56,:);
T = 0.1:0.1:4;
[ LS1, LS2, LSmean, T1, T2, Tm, fit ] = Correlation( pdm, IMLs,T);
T(Tm)
pdm(:,4)=IMLs(:,Tm);
[DPM] = DamageProbabilityMatrix (pdm, noLSs);
cumDamageStates = fragility(DPM, noLSs);
pdm(:,4) = IMLs(:,Tm);
iml=1:DPM(length(DPM),4)/length(DPM):DPM(length(DPM),4);
y = logncdf(iml,fit.MLE(2,1),fit.MLE(2,2));
fit.MLE(2,3)
%% Plots
figure(1)
plot(T,LS1);
hold on
plot(T,LS2,'r');
plot(T,LSmean,'k');
plot(T(T1),min(LS2):0.01:1,'--b');
plot(T(T2),min(LS2):0.01:1,'--r');
plot(T(Tm),min(LS2):0.01:1,'--k');
legend1=legend('LS1','LS2','mean');
set(legend1,'Fontsize',14,'Location','SouthEast')
xlabel('Period [s]');
ylabel('Correlation')
legend boxoff
box off
% 
% fpat=horzcat(a,'\results\Periods');
% fnam=horzcat('periods',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'.fig');
% saveas(gcf,[fpat,filesep,fnam],'fig')
% fnam=horzcat('periods',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'.bmp');	 
% saveas(gcf,[fpat,filesep,fnam],'bmp')

figure (2)
hold on
plot1 = plot(iml,y);
plot2 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
set(plot1(1),'LineWidth',2,'Color',[0 0 0],'LineStyle','-','DisplayName','PoE collapse');
set(plot2,'Marker','+','Color',[0 0 0],'DisplayName','LS2');
legend1=legend('LS2');
set(legend1,'Fontsize',12,'Location','SouthEast')
xlabel('Sa(Topt) [cm/s^2]','FontSize',14);
ylabel('Probability of Exceedance','FontSize',14);
legend boxoff
box off

figure(4)
hold on
plot1 = plot(DPM(:,4),cumDamageStates(:,2),'LineStyle','none');
plot2 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
plot3 = plot(iml,logncdf(iml,fit.MLE(1,1),fit.MLE(1,2)));
plot4 = plot(iml,logncdf(iml,fit.MLE(2,1),fit.MLE(2,2)));
set(plot1,'Marker','*','Color',[0 0 1],'DisplayName','LS1');
set(plot2,'Marker','+','Color',[1 0 0],'DisplayName','LS2');
set(plot3,'LineWidth',2,'Color',[0 0 1],'LineStyle','-','DisplayName','yielding');
set(plot4,'LineWidth',2,'Color',[1 0 0],'LineStyle','-','DisplayName','collape');
xlabel('Sa(Topt) [cm/s^2]','FontSize',14);
ylabel('Probability of Exceedance','FontSize',14);
legend1=legend('show');
set(legend1,'Fontsize',12,'Location','SouthEast')
box off
legend boxoff

% fpat=horzcat(a,'\results\collapse');
% fnam=horzcat('collapseWOSa',num2str(type),'_',num2str(s),'_',num2str(c),'.fig');
% saveas(gcf,[fpat,filesep,fnam],'fig')
% fnam=horzcat('collapseWOSa',num2str(type),'_',num2str(s),'_',num2str(c),'.bmp');	 
% saveas(gcf,[fpat,filesep,fnam],'bmp')

figure(3) %Comparison
hold on
plot1 = plot(iml,logncdf(iml,fit.MLE(2,1),fit.MLE(2,2)));
plot2 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');

pdm = dlmread('./../ResultsOld/resultsVertical/1_4/pdm21.tcl');
%pdm=pdm(1:56,:);
pdm(:,4)=IMLs(:,Tm);
[DPM] = DamageProbabilityMatrix (pdm, noLSs);
cumDamageStates = fragility(DPM, noLSs);
	for j=1:2
		[mle(j,1), mle(j,2), mle(j,4)] = fn_mle_pc_probit(DPM(:,noLSs+1), 100, cumDamageStates(:,j+1)*100);
		mle(j,3) = corr(cumDamageStates(:,j+1),logncdf(DPM(:,noLSs+1),log(mle(j,1)),(mle(j,2)))).^2;
    end
fit.MLE = mle;
fit.MLE(:,1) = log(fit.MLE(:,1));
fit.MLE(:,4) = fit.MLE(:,4)/100;
fit.MLE(2,3)
y = logncdf(iml,fit.MLE(2,1),fit.MLE(2,2));
plot5 = plot(iml,y);
plot4 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
set(plot1,'LineWidth',2,'Color',[0 0 0],'LineStyle','-','DisplayName','w sliding');
set(plot2,'Marker','+','Color',[0 0 0],'DisplayName','Data 0.2');
set(plot5,'LineWidth',2,'Color',[0 0 1],'LineStyle','--','DisplayName','w/o sliding');
set(plot4,'Marker','o','Color',[0 0 1],'DisplayName','Data 0.3');
legend1=legend('show');
set(legend1,'Fontsize',12,'Location','SouthEast');
xlabel('Sa(Topt) [cm/s^2]','Fontsize',14)
ylabel('PoE Collapse','Fontsize',14)
legend boxoff
box off

% fpat=horzcat(a,'\results\collapse');
% fnam=horzcat('Comparison02-03',num2str(type),'_',num2str(s),'_',num2str(c),'.fig');
% saveas(gcf,[fpat,filesep,fnam],'fig')
% fnam=horzcat('Comparison02-03',num2str(type),'_',num2str(s),'_',num2str(c),'.bmp');	 
% saveas(gcf,[fpat,filesep,fnam],'bmp')



% fpat=horzcat(a,'\results\fragilityCurves');
% fnam=horzcat('fragility',num2str(type),'_',num2str(code),'_',num2str(s),'.fig');
% saveas(gcf,[fpat,filesep,fnam],'fig')
% fnam=horzcat('fragility',num2str(type),'_',num2str(code),'_',num2str(s),'.bmp');	 
% saveas(gcf,[fpat,filesep,fnam],'bmp')

%fpat=horzcat(a,'\results\',horzcat(num2str(type),'_',num2str(code),'_',num2str(s)'));
dlmwrite(horzcat('stats',num2str(type),'_',num2str(code),'_',num2str(s),'Sa(T).tcl'),fit.MLE,'delimiter','	');
