function [ scu,ssd,hu ] = stress(M,N,As,b,h,d1,co)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    ro=As/(b*h);
    Ai=b*h+2*co*As;
    J=(b*h^3)/12+2*co*As*(h/2-d1)^2;
    W=J/(b/2);
    G=W/Ai;
    ec=M/N;
    if ec<G;
        scu=(N/Ai+N*ec/W)/1000;
        scd=(N/Ai-N*ec/W)/1000;
        y=scd*h/(scu-scd);
        if scd<0
            hu=h-d1;
        else hu=h-y/2;
        end
        ssu=co*scu*(1-d1*(h+y));
        ssd=co*scu*(y+d1)/(h+y);
    else c2=(h/2-d1);
        ea=(ec+c2);
        a1=abs(ec-c2);
        X=[b/6 b/2*(ec-h/2) co*As*(ea+a1) -co*As*((h-d1)*ea+d1*a1)];
        c=roots(X);
        x=max(real(c));
        scu=N/((x*b/2)+co/x*As*(x-d1)-co/x*As*(h-d1-x));
        ssd=co/x*(h-d1-x)*scu;
        hu=h-x/2;
    end

end

