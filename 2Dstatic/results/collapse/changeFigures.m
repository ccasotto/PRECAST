
set(gca,'FontSize',7,'FontName','Times New Roman');

% Create xlabel
xlabel('Sa(Topt) [cm/s^2]','FontSize',9,'FontName','Times New Roman');
xlabel('IMpw [cm/s^2]','FontSize',9,'FontName','Times New Roman');

% Create ylabel
ylabel('Probability of Exceedance','FontSize',9,'FontName','Times New Roman');
legend1 = legend(gca,'show');
set(legend1,'Location','SouthEast','FontSize',7,'FontName','Times New Roman');
legend boxoff

set(gcf, 'Windowstyle', 'normal')
xSize = 8.5; ySize = 6.5;
xLeft = (21-xSize)/2; yTop = (30-ySize)/2;
set(gcf,'PaperPosition',[xLeft yTop xSize ySize])
set(gcf,'Position',[5 5 xSize*10 ySize*10])
print -depsc2 fragility1_4_0.eps;
close