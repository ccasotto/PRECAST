clc
clear all
close all
a = pwd;
noLSs=3;
T=0.5:0.1:4;
IMLsX = dlmread('IMLsX.tcl');
IMLsY = dlmread('IMLsY.tcl');
s = [4 6 9 12];
c = 2;
iml = 0:1:600;
i = 1;
[Periods(:,1), text1] = xlsread('results/OptimalPeriods.xlsx');
[Periods(:,2), text2] = xlsread('results/YieldingPeriods.xlsx');

for p=1:2
for type = 1:2
	counter = 1;
	while counter <length(s)+1
	pdm = dlmread(horzcat(a,'/results/',num2str(type),'_',num2str(s(counter)),'/pdm',num2str(c),'1.tcl'));
	if p==1
		Tm = find(T>=Periods(i,p),1);
		IMLs = (IMLsX.*IMLsY).^0.5;
		pdm(:,4)=IMLs(:,Tm);                    % IM is expressed in cm/s^2
	else
		Ty = Periods(4*(type-1)+counter,p);
		t1 = find(T>Ty);
		T1 = t1(1)-1;
		t2=find(T>T(T1)*1.5);
		T2=t2(1)-1;
		t3=find(T>T(T1)*2);
		T3 = t3(1)-1;
		SaT1 = (IMLsX(:,T1).*IMLsY(:,T1)).^0.5;
		SaT2 = (IMLsX(:,T2).*IMLsY(:,T2)).^0.5;
		SaT3 = (IMLsX(:,T3).*IMLsY(:,T3)).^0.5;
		IMLs = SaT1.*(SaT2./SaT1).^(1/3).*(SaT3./SaT1).^(1/3);
		pdm(:,4)=IMLs;
	end
	[DPM] = DamageProbabilityMatrix (pdm, noLSs);
	cumDamageStates = fragility(DPM, noLSs);
    xlswrite(horzcat(a,'/results/cumDamage',num2str(type),'_',num2str(s(counter)),'_',num2str(c),'.csv'),[DPM(:,4) cumDamageStates(:,2:3)]);
	%iml=1:DPM(length(DPM),4)/length(DPM):DPM(length(DPM),4);
	for j=1:2
		[mle(j,1), mle(j,2)] = fn_mle_pc_probit(DPM(:,noLSs+1), 100, cumDamageStates(:,j+1)*100);
		mle(j,3) = corr(cumDamageStates(:,j+1),logncdf(DPM(:,noLSs+1),log(mle(j,1)),(mle(j,2)))).^2;
        mle(j,1) = log(mle(j,1));
        mean(j) = exp(mle(j,1)+mle(j,2)^2);                                %This are the mean and the st. dev. of the lognormal distribution
        st(j) = (exp(2*mle(j,1)+2*mle(j,2)^2)-exp(2*mle(j,1)+mle(j,2)^2))^0.5;
        R2(j) = mle(j,3);
	end
    
	param(4*(type-1)+counter,1:3) = [mle(1,1) mle(1,2) R2(1)];
	param(4*(type-1)+counter,4:6) = [mle(2,1) mle(2,2) R2(2)];
	
	logparam(4*(type-1)+counter,1:3) = [mean(1) st(1) R2(1)];
	logparam(4*(type-1)+counter,4:6) = [mean(2) st(2) R2(2)];
	y1(:,i) = [logncdf(iml, mle(1,1), mle(1,2))]';
	y2(:,i) = [logncdf(iml, mle(1,2), mle(2,2))]';
	counter = counter +1;
	i=i+1;
	end
end
	type = [s s];
	legenda = ['m' 's' 'R' 'm' 's' 'R'];
	xlswrite('Results3d.xlsx',param,horzcat('method',num2str(p)),'B2:G9')
	xlswrite('Results3d.xlsx',legenda,horzcat('method',num2str(p)),'B1:G1')
	xlswrite('Results3d.xlsx',type',horzcat('method',num2str(p)),'A2:A9')
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
% 
% 
