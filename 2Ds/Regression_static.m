clc
clear all
close all
a = pwd;
noLSs=3;
type = 1;
code = 1;
s = 6;
c=02;
IMLs=dlmread('IMLsX.tcl');
pdmTOT = dlmread(horzcat(a,'\results\1_4\pdm3.tcl'));
pdmCnn = dlmread(horzcat(a,'\results\1_4\pdmOC3.tcl'));
pdm = dlmread(horzcat(a,'\results\1_4\pdmWO.tcl'));
T=0.5:0.1:4;
Tel = 1.4;
t1 = find(T>Tel);
T1 = t1(1)-1;
t2=find(T>T(T1)*1.5);
T2=t2(1)-1;
t3=find(T>T(T1)*2);
T3 = t3(1)-1;
pdm(:,4)=IMLs(:,T1).*(IMLs(:,T2)./IMLs(:,T1)).^(1/3).*(IMLs(:,T3)./IMLs(:,T1)).^(1/3);

[DPM] = DamageProbabilityMatrix (pdm, noLSs);
cumDamageStates = fragility(DPM, noLSs);
	for j=1:2
		[mle(j,1), mle(j,2), mle(j,4)] = fn_mle_pc_probit(DPM(:,noLSs+1), 100, cumDamageStates(:,j+1)*100);
		mle(j,3) = corr(cumDamageStates(:,j+1),logncdf(DPM(:,noLSs+1),log(mle(j,1)),(mle(j,2)))).^2;
	end
stats = mle;
stats(:,1)=log(stats(:,1));
stats(:,4)=stats(:,4)/100;

pdmCnn(:,4) = IMLs(:,T1);
[DPMCnn] = DamageProbabilityMatrix (pdmCnn, noLSs);
cumDamageStatesCnn = fragility(DPMCnn, noLSs);
cumDamageStatesCnn(:,4) = DPM(:,4);
pdmTOT(:,4)=IMLs(:,T1);
[DPMTOT] = DamageProbabilityMatrix (pdmTOT, noLSs);
cumDamageStatesTOT = fragility(DPMTOT, noLSs);
[fitCnn, probCnn] = CnnStatistics( cumDamageStatesCnn,noLSs );
iml=1:DPM(length(DPM),4)/length(DPM):DPM(length(DPM),4);
	y = logncdf(iml,stats(2,1),stats(2,2));
	ycnn = logncdf(iml,fitCnn(2,1),fitCnn(2,2));
	ytot = y*(1-probCnn) + ycnn*probCnn;

figure (1)
hold on
plot1 = plot(iml,[ ycnn*probCnn; y*(1-probCnn); ytot]);
plot2 = plot(DPM(:,4),cumDamageStatesTOT(:,3),'LineStyle','none');
set(plot1(1),'LineWidth',2,'Color',[0 0 1],'LineStyle',':','DisplayName','connection collapse');
set(plot1(2),'LineWidth',0.5,'Color',[0 0 1],'LineStyle','--','DisplayName','flexural collape');
set(plot1(3),'LineWidth',2,'DisplayName','PoE total','Color',[0 0 0],'MarkerSize',6);
set(plot2,'Marker','+','Color',[0 0 0],'DisplayName','LS2');
legend('PoE connection collapse','PoE flexural collape','PoE total')
xlabel('IMpw [cm/s^2]','FontSize',14)
ylabel('Probability of Exceedance','FontSize',14)
legend boxoff
box off

% fpat=horzcat(a,'\results\collapse');
% fnam=horzcat('collapse',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'.fig');
% saveas(gcf,[fpat,filesep,fnam],'fig')
% fnam=horzcat('collapse',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'.bmp');	 
% saveas(gcf,[fpat,filesep,fnam],'bmp')

figure(2)
hold on
plot1 = plot(DPM(:,4),cumDamageStates(:,2),'LineStyle','none');
plot2 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
plot3 = plot(iml,logncdf(iml,stats(1,1),stats(1,2)));
plot4 = plot(iml,logncdf(iml,stats(2,1),stats(2,2)));
set(plot1,'Marker','*','Color',[0 0 1],'DisplayName','LS1');
set(plot2,'Marker','+','Color',[1 0 0],'DisplayName','LS2');
set(plot3,'LineWidth',2,'Color',[0 0 1],'LineStyle','-','DisplayName','yielding');
set(plot4,'LineWidth',2,'Color',[1 0 0],'LineStyle','-','DisplayName','flexural collape');
xlabel('IMpw [cm/s^2]','FontSize',14);
ylabel('Probability of Exceedance','FontSize',14);
legend('show');
box off
legend boxoff

% fpat=horzcat(a,'\results\fragilityCurves');
% fnam=horzcat('fragility',num2str(type),'_',num2str(code),'_',num2str(s),'.fig');
% saveas(gcf,[fpat,filesep,fnam],'fig')
% fnam=horzcat('fragility',num2str(type),'_',num2str(code),'_',num2str(s),'.bmp');	 
% saveas(gcf,[fpat,filesep,fnam],'bmp')

