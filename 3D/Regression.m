clc
clear all
close all
a = pwd;
noLSs = 3;
type = 1;
code = 2;
s = 12;
c = 02;
IMLsX = dlmread('IMLsX.tcl');
IMLsY = dlmread('IMLsY.tcl');
pdm = dlmread(horzcat(a,'\results\1_6\pdm21.tcl'));
T=0.5:0.1:4;
% Tm = 13;
% pdm(:,4)=IMLs(:,Tm);
Tx = 1;
t1 = find(T>Tx);
T1 = t1(1)-1;
t2=find(T>T(T1)*1.5);
T2=t2(1)-1;
t3=find(T>T(T1)*2);
T3 = t3(1)-1;
SaT1 = (IMLsX(:,T1).*IMLsY(:,T1)).^0.5;
SaT2 = (IMLsX(:,T2).*IMLsY(:,T2)).^0.5;
SaT3 = (IMLsX(:,T3).*IMLsY(:,T3)).^0.5;
IMLs = SaT1.*(SaT2./SaT1).^(1/3).*(SaT3./SaT1).^(1/3);

% IMLsx = IMLsX(:,T1).*(IMLsX(:,T2)./IMLsX(:,T1)).^(1/3).*(IMLsX(:,T3)./IMLsX(:,T1)).^(1/3);
% IMLsy = IMLsY(:,T1).*(IMLsY(:,T2)./IMLsY(:,T1)).^(1/3).*(IMLsY(:,T3)./IMLsY(:,T1)).^(1/3);
% IMLs = (IMLsx.^2+IMLsy.^2).^0.5;
% IMLs = (IMLsX.^2+IMLsY.^2).^0.5;
% CAVX = dlmread('CAVX.tcl');
% CAVY = dlmread('CAVY.tcl');
% IMLs = (CAVX.^2 + CAVY.^2).^0.5;

pdm(:,4) = IMLs;
[DPM] = DamageProbabilityMatrix (pdm, noLSs);
cumDamageStates = fragility(DPM, noLSs);
iml=0.01:DPM(length(DPM),4)/length(DPM):DPM(length(DPM),4);

	for j=1:2
		[mle(j,1), mle(j,2), mle(j,4)] = fn_mle_pc_probit(DPM(:,noLSs+1), 100, cumDamageStates(:,j+1)*100);
		mle(j,3) = corr(cumDamageStates(:,j+1),logncdf(DPM(:,noLSs+1),log(mle(j,1)),(mle(j,2)))).^2;
	end
	
stats = mle;
stats(:,1)=log(stats(:,1));
stats(:,4)=stats(:,4)/100;

figure(1)
hold on
plot1 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
plot3 = plot(iml,logncdf(iml,stats(2,1),stats(2,2)));

pdm = dlmread(horzcat(a,'\results\1_6\pdm31.tcl'));
pdm(:,4) = IMLs;
[DPM] = DamageProbabilityMatrix (pdm, noLSs);
cumDamageStates = fragility(DPM, noLSs);
iml=0.01:DPM(length(DPM),4)/length(DPM):DPM(length(DPM),4);

	for j=1:2
		[mle(j,1), mle(j,2), mle(j,4)] = fn_mle_pc_probit(DPM(:,noLSs+1), 100, cumDamageStates(:,j+1)*100);
		mle(j,3) = corr(cumDamageStates(:,j+1),logncdf(DPM(:,noLSs+1),log(mle(j,1)),(mle(j,2)))).^2;
	end
	
stats = mle;
stats(:,1)=log(stats(:,1));
stats(:,4)=stats(:,4)/100;
% 
% %Print connections comparison
plot2 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
plot4 = plot(iml,logncdf(iml,stats(2,1),stats(2,2)));
set(plot1,'Marker','+','Color',[0 0 0],'DisplayName','Data 1');
set(plot2,'Marker','*','Color',[0 0 0],'DisplayName','Data 2');
set(plot3,'LineWidth',2,'Color',[0 0 0],'LineStyle','--','DisplayName','collapse f.c.=0.2');
set(plot4,'LineWidth',2,'Color',[0 0 0],'LineStyle','-','DisplayName','Collapse f.c.=0.3');
xlabel('IMpw [cm/s/s]');
ylabel('Probability of Exceedance Connection Collapse');
legend('show')
box off
legend boxoff
% 
% fpat=horzcat(a,'\results\fragilityCurves');
% fnam=horzcat('fragilityConnectionsComparison',num2str(type),'_',num2str(code),'_',num2str(s),'.fig');
% saveas(gcf,[fpat,filesep,fnam],'fig')
% fnam=horzcat('fragilityConnectionsComparison',num2str(type),'_',num2str(code),'_',num2str(s),'.bmp');	 
% saveas(gcf,[fpat,filesep,fnam],'bmp')

%Print fragility for the two limit states
figure(3)
hold on
plot1 = plot(DPM(:,4),cumDamageStates(:,2),'LineStyle','none');
plot2 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
plot3 = plot(iml,logncdf(iml,stats(1,1),stats(1,2)));
plot4 = plot(iml,logncdf(iml,stats(2,1),stats(2,2)));
set(plot1,'Marker','*','Color',[0 0 1],'DisplayName','LS1');
set(plot2,'Marker','+','Color',[1 0 0],'DisplayName','LS2');
set(plot3,'LineWidth',2,'Color',[0 0 1],'LineStyle','-','DisplayName','yielding');
set(plot4,'LineWidth',2,'Color',[1 0 0],'LineStyle','-','DisplayName','collapse');
xlabel('IMpw [cm/s^2]','FontSize',14);
ylabel('Probability of Exceedance','FontSize',14);
legend('show');
box off
legend boxoff

% fpat=horzcat(a,'\results\fragilities');
% fnam=horzcat('fragility2trail03',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'DV.fig');
% saveas(gcf,[fpat,filesep,fnam],'fig')
% fnam=horzcat('fragility2trail03',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'DV.bmp');	 
% saveas(gcf,[fpat,filesep,fnam],'bmp')

dlmwrite('statsDV12trail-1-6-03.tcl',stats,'delimiter','	');


