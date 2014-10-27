function [ chord ] = Chord( asset )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
	Lv = asset.ColH_ground;
	h = asset.ColW;
	db = asset.barA;
	g = 1;
	chord.PyX = 2.14*asset.esy/h;
	chord.PuX = (asset.esu+asset.ecu)/h;%actually concrete and steel don't reach their maximum together, concrete is close to zero instead
	chord.LplX = 0.1*Lv+0.17*h+0.24*db*asset.Fy/sqrt(asset.Fc); %not sure there must be a term for the strain penetration that should not be included
	chord.zyX = (chord.PyX*Lv/3)+0.0013*(1+1.5*h/Lv)+0.13*chord.PyX*db*asset.Fy/sqrt(asset.Fc);
	chord.zX = 1/g*(chord.zyX+(chord.PuX-chord.PyX)*chord.LplX*(1-0.5*chord.LplX/Lv));

	h = asset.ColD;
	db = (0.02^2)/4*pi;
	chord.PyY = 2.14*asset.esy/h;
	chord.PuY = (asset.esu+asset.ecu)/h;%actually concrete and steel don't reach their maximum together, concrete is close to zero instead
	chord.LplY = 0.1*Lv+0.17*h+0.24*db*asset.Fy/sqrt(asset.Fc); %not sure there must be a term for the strain penetration that should not be included
	chord.zyY = (chord.PyY*Lv/3)+0.0013*(1+1.5*h/Lv)+0.13*chord.PyY*db*asset.Fy/sqrt(asset.Fc);
	chord.zY = 1/g*(chord.zyY+(chord.PuY-chord.PyY)*chord.LplY*(1-0.5*chord.LplY/Lv));
	
	chord.zy = sqrt((chord.zyX)^2+(chord.zyY)^2);
	chord.z = sqrt((chord.zX)^2+(chord.zY)^2);
end

