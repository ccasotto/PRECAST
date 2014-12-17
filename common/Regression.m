clc
clear all
close all
a = pwd;

% Initial options
noLSs=3; %n. of limit states
type = 1; %typology
code = 1; %precode-lowcode
s = [4]; %seismic design lateral load
c=02; %friction coefficient
correlation = 1;
threed = 1;
plotflag = 0;

addpath('../common/');
IMLsX = dlmread('IMLsX.tcl');
IMLsY = dlmread('IMLsY.tcl');
if threed; IMLs = (IMLsX.*IMLsY).^0.5; frame = '3D'; else IMLs = IMLsX; frame = '2D'; end
T = 0.5:0.1:4;
Ts = [];

for i=1:length(s)
    
    pdm = dlmread(horzcat('./../Results/',frame,'/pdm',num2str(type),'_',num2str(s(i)),'_0.',num2str(c),'.tcl'));
    
    if correlation
        [ LS1, LS2, LSmean, T1, T2, Tm, m_s_r ] = Correlation( pdm, IMLs,T);
        Ts(i) = T(Tm);
        pdm(:,4)=IMLs(:,Tm);
        [DPM] = DamageProbabilityMatrix (pdm, noLSs);
        cumDamageStates = fragility(DPM, noLSs);
    else
        Tm = find(T>=Ts(i),1);
        pdm(:,4)=IMLs(:,Tm);
        [DPM] = DamageProbabilityMatrix (pdm, noLSs);
        cumDamageStates = fragility(DPM, noLSs);
        for j=1:2
            [m_s_r(j,1), m_s_r(j,2)] = fn_mle_pc_probit(DPM(:,noLSs+1), 100, cumDamageStates(:,j+1)*100);
            m_s_r(j,3) = corr(cumDamageStates(:,j+1),logncdf(DPM(:,noLSs+1),log(m_s_r(j,1)),(m_s_r(j,2)))).^2;
        end
    end
    MLE = m_s_r;
    iml=1:DPM(length(DPM),4)/length(DPM):DPM(length(DPM),4);

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

    if plotflag
        fpat='../Results/plots';
        fnam=horzcat('T',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'.fig');
        saveas(gcf,[fpat,filesep,fnam],'fig')
        fnam=horzcat('T',num2str(type),'_',num2str(code),'_',num2str(s),'_',num2str(c),'.bmp');	 
        saveas(gcf,[fpat,filesep,fnam],'bmp')
    end

    figure
    hold on
    plot1 = plot(DPM(:,4),cumDamageStates(:,2),'LineStyle','none');
    plot2 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
    plot3 = plot(iml,logncdf(iml,log(m_s_r(1,1)),m_s_r(1,2)));
    plot4 = plot(iml,logncdf(iml,log(m_s_r(2,1)),m_s_r(2,2)));
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

    if plotflag
        fpat=horzcat(a,'/Results/plots');
        fnam=horzcat(num2str(type),'_',num2str(s),'_',num2str(c),'.fig');
        saveas(gcf,[fpat,filesep,fnam],'fig')
        fnam=horzcat(num2str(type),'_',num2str(s),'_',num2str(c),'.bmp');	 
        saveas(gcf,[fpat,filesep,fnam],'eps')
    end

    figure %Comparison
    hold on
    plot1 = plot(iml,logncdf(iml,log(MLE(2,1)),MLE(2,2)));
    plot2 = plot(DPM(:,4),cumDamageStates(:,3),'LineStyle','none');
    pdm = dlmread(horzcat('./../Results/',frame,'/pdm',num2str(type),'_',num2str(s(i)),'_0.3.tcl'));
    pdm(:,4)=IMLs(:,Tm);
    [DPM] = DamageProbabilityMatrix (pdm, noLSs);
    cumDamageStates = fragility(DPM, noLSs);
    for j=1:2
        [m_s_r(j,1), m_s_r(j,2)] = fn_mle_pc_probit(DPM(:,noLSs+1), 100, cumDamageStates(:,j+1)*100);
        m_s_r(j,3) = corr(cumDamageStates(:,j+1),logncdf(DPM(:,noLSs+1),log(m_s_r(j,1)),(m_s_r(j,2)))).^2;
    end
    plot5 = plot(iml,logncdf(iml,log(m_s_r(2,1)),m_s_r(2,2)));
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

    if plotflag
        fpat=horzcat(a,'/results/collapse');
        fnam=horzcat('CMP',num2str(type),'_',num2str(s),'_',num2str(c),'.fig');
        saveas(gcf,[fpat,filesep,fnam],'fig')
        fnam=horzcat('CMP',num2str(type),'_',num2str(s),'_',num2str(c),'.bmp');	 
        saveas(gcf,[fpat,filesep,fnam],'bmp')
    end
    
    
    
end
dlmwrite(horzcat('stats',num2str(type),'_',num2str(code),'_',num2str(s),'.tcl'),MLE,'delimiter','	');
