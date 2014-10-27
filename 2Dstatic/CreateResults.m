clc
clear all
close all
a = pwd;
noLSs=3;
T=0.5:0.1:4;
IMLs=dlmread('IMLsX.tcl');
s = [4 6 9 12];
c = 2;
iml = 0.01:0.01:0.5;
i = 1;
for p = 1:2 %p = 1 SA(Topt) p = 2 IMpw
	for type = 1:2
	counter = 1;
	while counter <length(s)+1
	pdmTOT = dlmread(horzcat(a,'\results\',num2str(type),'_',num2str(s(counter)),'\pdm',num2str(c),'1.tcl'));
 	pdmCnn = dlmread(horzcat(a,'\results\',num2str(type),'_',num2str(s(counter)),'\pdmOC',num2str(c),'1.tcl'));
 	pdm = dlmread(horzcat(a,'\results\',num2str(type),'_',num2str(s(counter)),'\pdmWO1.tcl'));
	if p == 2
		[Periods, text] = xlsread('results/Periods.xlsx','YieldingPeriods');
		Tel = Periods(4*(type-1)+counter);
		t1 = find(T>Tel);
		T1 = t1(1)-1;
		t2=find(T>T(T1)*1.5);
		T2=t2(1)-1;
		t3=find(T>T(T1)*2);
		T3 = t3(1)-1;
		pdm(:,4)=IMLs(:,T1).*(IMLs(:,T2)./IMLs(:,T1)).^(1/3).*(IMLs(:,T3)./IMLs(:,T1)).^(1/3);
        pdmTOT(:,4)=IMLs(:,T1).*(IMLs(:,T2)./IMLs(:,T1)).^(1/3).*(IMLs(:,T3)./IMLs(:,T1)).^(1/3);
		pdmCnn(:,4) =IMLs(:,T1).*(IMLs(:,T2)./IMLs(:,T1)).^(1/3).*(IMLs(:,T3)./IMLs(:,T1)).^(1/3);
		
	else
		[Periods, text] = xlsread('results/Periods.xlsx','OptimalPeriods');
		Tm = find(T>=Periods(i),1);
		pdm(:,4)=IMLs(:,Tm);
		pdmTOT(:,4)=IMLs(:,Tm);
		pdmCnn(:,4) = IMLs(:,Tm);
	
	end
		[DPM] = DamageProbabilityMatrix (pdm, noLSs);
		[DPMCnn] = DamageProbabilityMatrix (pdmCnn, noLSs);
		[DPMTOT] = DamageProbabilityMatrix (pdmTOT, noLSs);
		cumDamageStates = fragility(DPM, noLSs);
		for j=1:2
			[mle(j,1), mle(j,2)] = fn_mle_pc_probit(DPM(:,noLSs+1), 100, cumDamageStates(:,j+1)*100);
			mle(j,3) = corr(cumDamageStates(:,j+1),logncdf(DPM(:,noLSs+1),log(mle(j,1)),(mle(j,2)))).^2;
			mle(j,1) = log(mle(j,1));
			mean(j) = exp(mle(j,1)+mle(j,2)^2); %This are the mean and the st. dev. of the lognotmal distribution
			st(j) = (exp(2*mle(j,1)+2*mle(j,2)^2)-exp(2*mle(j,1)+mle(j,2)^2))^0.5;
			R2(j) = mle(j,3);
		end
		
		cumDamageStatesTOT = fragility(DPMTOT, noLSs);
		cumDamageStatesCnn = fragility(DPMCnn, noLSs);
		cumDamageStatesCnn(:,4) = DPM(:,4);
		[fitCnn, probCnn] = CnnStatistics( cumDamageStatesCnn,noLSs );
% This is if you want mean and st.dev. of the corresponding normal distribution   
		fit(4*(type-1)+counter,1:3) = mle(1,1:3);
		fit(4*(type-1)+counter,4:6) = mle(2,1:3);
		fit(4*(type-1)+counter,7:9) = fitCnn(2,1:3);
		fit(4*(type-1)+counter,10) = probCnn;
% This is if you want mean and st.dev. of the lognormal distribution
% 		fit(4*(type-1)+counter,1:3) = [mean(1) st(1) R2(1)];
% 		fit(4*(type-1)+counter,4:6) = [mean(2) st(2) R2(2)];

	counter = counter +1;
	i=i+1;
	end
	end
	type = [s s];
	legenda = ['m' 's' 'R' 'm' 's' 'R' 'm' 's' 'R' 'p'];
	xlswrite('ResultsStatic.xlsx',fit,horzcat('p',num2str(p),'_',num2str(c)),'B3:K10')
	xlswrite('ResultsStatic.xlsx',legenda,horzcat('p',num2str(p),'_',num2str(c)),'B2:K2')
	xlswrite('ResultsStatic.xlsx',type',horzcat('p',num2str(p),'_',num2str(c)),'A3:A10')
	
end



% y = [y1 y2];
% figure(1)
% plot1 = plot(iml, y1(:,1:4));
% set(plot1(1),'LineWidth',1,'Color',[1 0 0],'DisplayName','PC-Type1-4');
% set(plot1(2),'LineWidth',1,'Color',[0 1 0],'DisplayName','LC-Type1-6');
% set(plot1(3),'LineWidth',1,'Color',[1 0 1],'DisplayName','LC-Type1-9');
% set(plot1(4),'LineWidth',1,'Color',[0 0 1],'DisplayName','LC-Type1-12');
% legend('show','location','southeast')
% legend boxoff
% 
% figure(2)
% plot2 = plot(iml, y1(:,5:8));
% 
% figure(3)
% plot3 = plot(iml, y2(:,1:4));
% set(plot3(1),'LineWidth',1,'Color',[1 0 0],'DisplayName','PC-Type1-4');
% set(plot3(2),'LineWidth',1,'Color',[0 1 0],'DisplayName','LC-Type1-6');
% set(plot3(3),'LineWidth',1,'Color',[1 0 1],'DisplayName','LC-Type1-9');
% set(plot3(4),'LineWidth',1,'Color',[0 0 1],'DisplayName','LC-Type1-12');
% legend('show','location','southeast')
% legend boxoff
% 
% figure(4)
% plot4 = plot(iml, y2(:,5:8));
% set(plot4(1),'LineWidth',1,'Color',[1 0 0],'DisplayName','PC-Type2-4');
% set(plot4(2),'LineWidth',1,'Color',[0 1 0],'DisplayName','LC-Type2-6');
% set(plot4(3),'LineWidth',1,'Color',[1 0 1],'DisplayName','LC-Type2-9');
% set(plot4(4),'LineWidth',1,'Color',[0 0 1],'DisplayName','LC-Type2-12');
% legend('show','location','southeast')
% legend boxoff


