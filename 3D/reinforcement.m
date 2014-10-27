function [ As,d ] = reinforcement( M,b,dlt,fsk,Rck,co,k,rt )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    sa=fsk;
    sc=6+((Rck-15)/4);
    f=find(rt(1,:)==fsk);
    r1=rt(find(rt(:,f)==Rck),f+1);
    t1=rt(find(rt(:,f)==Rck),f+2);
    mu=1;
    r=r1*sqrt(1/(sc*k/2*(1-k/3+((1-dlt)/(1/mu*((1-k)/(k-dlt)-1))))));
    t=((k^2)*r)/(2*co*t1*(1-k-mu*(k-dlt)));                                 
    As=t*(sqrt(M*10^6*b*10^3))/10^6;
    d=r*(sqrt(M*10^6/(b*10^3)))/10^3;

end

