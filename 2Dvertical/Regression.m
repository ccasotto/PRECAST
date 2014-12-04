clc
clear all
close all
a = pwd;
noLSs=3;
type = 1;
code = 1;
s = 4;
c=02;
IMLs=dlmread('IMLsX.tcl');
pdm = dlmread(horzcat(a,'./../Results/pdm1.tcl'));
T=0.1:0.1:4;
Tm = find(T>=1.7,1);
pdm(:,4)=IMLs(:,Tm);

% Dimitrios Vamvatsikos Intensity Measure
% Tel = 1.45;
% t1 = find(T>Tel);
% T1 = t1(1)-1;
% t2=find(T>T(T1)*1.5);
% T2=t2(1)-1;
% t3=find(T>T(T1)*2);
% T3 = t3(1)-1;
% pdm(:,4)=IMLs(:,T1).*(IMLs(:,T2)./IMLs(:,T1)).^(1/3).*(IMLs(:,T3)./IMLs(:,T1)).^(1/3);

[DPM] = DamageProbabilityMatrix (pdm, noLSs);
cumDamageStates = fragility(DPM, noLSs);
%iml=1:DPM(length(DPM),4)/length(DPM):DPM(length(DPM),4);
iml=0.01:DPM(length(DPM),4)/length(DPM):DPM(length(DPM),4);
	for j=1:2
		[mle(j,1), mle(j,2), mle(j,4)] = fn_mle_pc_probit(DPM(:,noLSs+1), 100, cumDamageStates(:,j+1)*100);
		mle(j,3) = corr(cumDamageStates(:,j+1),logncdf(DPM(:,noLSs+1),log(mle(j,1)),(mle(j,2)))).^2;
	end
 	fit.MLE = mle;
	fit.MLE(:,1) = log(fit.MLE(:,1));
	fit.MLE(:,4) = fit.MLE(:,4)/100;

%% Plots Comparisons
figure (1)
hold on
plot1 = plot(DPM(:,4),cumDamageStates(:,2),'LineStyle','none');
plot2 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
plot3 = plot(iml,logncdf(iml,fit.MLE(1,1),fit.MLE(1,2)));
plot4 = plot(iml,logncdf(iml,fit.MLE(2,1),fit.MLE(2,2)));
set(plot1,'Marker','*','Color',[0 0 1],'DisplayName','LS1');
set(plot2,'Marker','+','Color',[1 0 0],'DisplayName','LS2');
set(plot3,'LineWidth',2,'Color',[0 0 1],'LineStyle','-','DisplayName','yielding');
set(plot4,'LineWidth',2,'Color',[1 0 0],'LineStyle','-','DisplayName','collape');
xlabel('IMpw [cm/s^2]','Fontsize',14);
ylabel('Probability of Exceedance','Fontsize',14);
legend('show');
box off
legend boxoff

% dlmwrite(horzcat('stats',num2str(type),'_',num2str(code),'_',num2str(s),'.tcl'),fit.MLE,'delimiter','	');
% fpat=horzcat(a,'\results\fragilityCurves');
% fnam=horzcat('fragilityRandFrict',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'.fig');
% saveas(gcf,[fpat,filesep,fnam],'fig')
% fnam=horzcat('fragilityRandFrict',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'.bmp');	 
% saveas(gcf,[fpat,filesep,fnam],'bmp')

pdm = dlmread(horzcat(a,'/../Results/pdmWO1.tcl'));
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

figure
hold on
plot1 = plot(DPM(:,4),cumDamageStates(:,2),'LineStyle','none');
plot2 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
plot3 = plot(iml,logncdf(iml,fit.MLE(1,1),fit.MLE(1,2)));
plot4 = plot(iml,logncdf(iml,fit.MLE(2,1),fit.MLE(2,2)));
set(plot1,'Marker','*','Color',[0 0 1],'DisplayName','LS1');
set(plot2,'Marker','+','Color',[1 0 0],'DisplayName','LS2');
set(plot3,'LineWidth',2,'Color',[0 0 1],'LineStyle','-','DisplayName','yielding');
set(plot4,'LineWidth',2,'Color',[1 0 0],'LineStyle','-','DisplayName','collape');
xlabel('IMpw [cm/s^2]','Fontsize',14);
ylabel('Probability of Exceedance','Fontsize',14);
legend('show');
box off
legend boxoff

% fpat=horzcat(a,'\results\collapse');
% fnam=horzcat('Comparison03-randFrict',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'.fig');
% saveas(gcf,[fpat,filesep,fnam],'fig')
% fnam=horzcat('Comparison03-randFrict',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'.bmp');	 
% saveas(gcf,[fpat,filesep,fnam],'bmp')

dlmwrite(horzcat('stats',num2str(type),'_',num2str(code),'_',num2str(s),'IMpw.tcl'),fit.MLE,'delimiter','	');
