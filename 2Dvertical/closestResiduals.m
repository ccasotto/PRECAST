function y = closestResiduals(x,xdata,ydata)

    ycurve=logncdf(xdata,x(1),x(2));
    xcurve=xdata;
    y=0;
    
    for i=1:length(ydata)
        y=y+min(sqrt((xcurve-xdata(i)).^2 + (ycurve-ydata(i)).^2))^2;
    end

end