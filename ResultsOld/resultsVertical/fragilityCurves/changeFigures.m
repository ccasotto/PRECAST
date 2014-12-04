
set(gca,'FontSize',7,'FontName','Times New Roman');

% Create xlabel
xlabel('Sa(T=1.5 sec) [cm/s^2]','FontSize',9,'FontName','Times New Roman');

% Create ylabel
ylabel('Number of records','FontSize',9,'FontName','Times New Roman');
legend1 = legend(gca,'show');
set(legend1,'Location','SouthEast','FontSize',7,'FontName','Times New Roman');
legend boxoff

xSize = 8.5; ySize = 6.5;
xLeft = (21-xSize)/2; yTop = (30-ySize)/2;
set(gcf, 'Windowstyle', 'normal')
set(gcf,'PaperPosition',[xLeft yTop xSize ySize])
set(gcf,'Position',[5 5 xSize*10 ySize*10])
print -depsc2 SAxy.eps;
close