
plot(DispPo,VbPo);
xlabel('Top Drift [%]')
ylabel('Base Shear [kN]')
hold on
plot(limit.LS1,limit.Vb1,'ro');
plot(limit.LS2,limit.Vb2,'ro');