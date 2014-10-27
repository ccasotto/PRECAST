function stats=leastSquares(iml, cumDamageStates, type)

    stats = zeros(2,4);
    options = optimset('TolFun',1e-20);
	LB = [0.0 0.0];
	UB = [10 10];
	if type == 1 %PGA in g
    solution = [0.13 0.06; 0.35 0.132];
	elseif type == 2 %Sa in cm/s/s
	solution = [2.5 0.3;3.0 0.1];
	else %Sd in cm
	solution = [0.04 0.017; 0.11 0.063];
	end
    for LS = 1:2;
		%lsqcurvefit(fun,x0,xdata,ydata)
        [x,resnorm] = lsqcurvefit(@lognormal,solution(LS,:),iml,cumDamageStates(:,LS+1),LB,UB,options);
        stats(LS,1:2) = x;
        stats(LS,3) = corr(cumDamageStates(:,LS+1),logncdf(iml,stats(LS,1),stats(LS,2))).^2;
		stats(LS,4) = resnorm;
	end
	
end

