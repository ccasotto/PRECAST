clc
clear all
close all
a = pwd;
noLSs = 3;
type = 2;
code = 2;
s = 9;
c = 2;
IMLsX = dlmread('IMLsX.tcl');
IMLsY = dlmread('IMLsY.tcl');
IMLs = (IMLsX.*IMLsY).^0.5;
pdm = dlmread(horzcat(a,'\results\',num2str(type),'_',num2str(s),'\pdm',num2str(c),'1.tcl'));
T=0.5:0.1:4;
[ LS1, LS2, LSmean, T1, T2, Tm, fit ] = Correlation3D( pdm, IMLs, T);

figure(1)
plot(T,LS1);
hold on
plot(T,LS2,'r');
plot(T,LSmean,'k');
plot(T(T1),min(LS2):0.01:1,'--b');
plot(T(T2),min(LS2):0.01:1,'--r');
plot(T(Tm),min(LS2):0.01:1,'--k');
legend('LS1','LS2','mean')
xlabel('Period [s]');
ylabel('Correlation')
box off
legend boxoff
T(Tm)
% 
% fpat=horzcat(a,'\results\periods');
% fnam=horzcat('PeriodNew',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'.fig');
% saveas(gcf,[fpat,filesep,fnam],'fig')
% fnam=horzcat('PeriodNew',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'.bmp');	 
% saveas(gcf,[fpat,filesep,fnam],'bmp')

pdm(:,4)=IMLs(:,Tm);
[DPM] = DamageProbabilityMatrix (pdm, noLSs);
cumDamageStates = fragility(DPM, noLSs);
iml=1:DPM(length(DPM),4)/length(DPM):DPM(length(DPM),4);

figure(2)
hold on
plot1 = plot(DPM(:,4),cumDamageStates(:,2),'LineStyle','none');
plot2 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
plot3 = plot(iml,logncdf(iml,fit.MLE(1,1),fit.MLE(1,2)));
plot4 = plot(iml,logncdf(iml,fit.MLE(2,1),fit.MLE(2,2)));
set(plot1,'Marker','*','Color',[0 0 1],'DisplayName','LS1');
set(plot2,'Marker','+','Color',[1 0 0],'DisplayName','LS2');
set(plot3,'LineWidth',2,'Color',[0 0 1],'LineStyle','-','DisplayName','PoE yielding');
set(plot4,'LineWidth',2,'Color',[1 0 0],'LineStyle','-','DisplayName','PoE flexural collape');
xlabel('Sa(Topt) [cm/s^2]','FontSize',14);
ylabel('Probability of Exceedance','FontSize',14);
legend1 = legend('LS1','LS2','PoE yielding','PoE flexural collape');
set(legend1,'FontSize',12,'Location','SouthEast');
box off
legend boxoff

% fpat=horzcat(a,'\results\fragilityCurves');
% fnam=horzcat('fragilityConnection',num2str(type),'_',num2str(s),'_',num2str(c),'.fig');
% saveas(gcf,[fpat,filesep,fnam],'fig')
% fnam=horzcat('fragilityConnection',num2str(type),'_',num2str(s),'_',num2str(c),'.bmp');	 
% saveas(gcf,[fpat,filesep,fnam],'bmp')

figure(3) %Comparison 0.2-0.3
hold on
plot1 = plot(iml,logncdf(iml,fit.MLE(2,1),fit.MLE(2,2)));
plot2 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
pdm = dlmread(horzcat(a,'\results\2_9\pdm31.tcl'));

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
y = logncdf(iml,fit.MLE(2,1),fit.MLE(2,2));
plot5 = plot(iml,y);
plot4 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
set(plot1,'LineWidth',2,'Color',[0 0 0],'LineStyle','-','DisplayName','friction 0.2');
set(plot2,'Marker','+','Color',[0 0 0],'DisplayName','Data 0.2');
set(plot5,'LineWidth',2,'Color',[0 0 1],'LineStyle','--','DisplayName','friction 0.3');
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

dlmwrite('stats.tcl',fit.MLE,'delimiter','	');
