function [ xdot, pres, temp, rho, accDrag, lift, prop, parachute, epd ] = EDLproject( x,hland)
muMars = 42970*1000^3; %m3/s2
rMars = 3393000; %m
goMars = muMars/rMars^2; %m/s2
mpay = 25000;
minert = 10741;
Ve = 3488; %m/s

beta = 200;
LtoD = .24;
prop = 0;
parachute = 0;
epd = 0;

Cd = .6; 
radius = 20/2;%m
A = pi*radius^2;

gamma = x(1);
v = x(2);
r = x(3);
theta = x(4);
h = r - rMars;
if h <0
    h = 0;
end

mprop = (mpay + minert)/(exp(-(300-v)/Ve)) - mpay - minert;
mass = mpay+minert+mprop;
mass = 25000+692;

hepd = 50000;
hpara = 11000;
hprop = 2500+hland;

%% Drag acceleration
% from https://www.grc.nasa.gov/www/k-12/airplane/atmosmrm.html
    if h > 7000
        temp = -23.4-.00222*h; %C, temperature
    else
        temp = -31 - .000998*h; %C, temperature
    end
    pres = .669*exp(-.00009*h); %kPa, pressure
    if temp < -270
        temp = -270;
    end
    
    rho = pres/(.1921*(temp+273.1));
    
    accDrag = rho*v^2/(2*beta) ;%N, drag acceleration
% accDrag = 0;


%% EDL slow down methods
% early propulsive deceleration
% if h < hepd && h > hpara+1000
%     epd = 250000/mass;
% end
if h < hpara && h > hprop + 500 %if parachute is open
    %https://www.grc.nasa.gov/www/k-12/VirtualAero/BottleRocket/airplane/rktvrecv.html
    parachute = rho*v^2*Cd*A/2/mass;
%     parachute = 0;
end
% if h < hshield %parachute is still open
%     mass = mass0 - mpara - mshield;
%     parachute = rho*v^2*Cd*A/2/mass;
% %     parachute = 0;
% end
if h < hprop  %parachute gone, propulsion
    prop = 1.9*9.81*mass/mass;
%     prop = (goMars*(hprop)+1/2*v^2)/(hprop-hland);
end

g = goMars*(rMars/r)^2; % gravity
vc = sqrt(muMars/r);

%% Lift acceleration
lift = rho*v^2*LtoD/(2*beta);
% lift = 0;

%% orbit calcs
xdot(1,1) = 1/v*(lift-(1-(v^2)/(vc^2))*g*cos(gamma)); %gammadot
xdot(2,1) = -g*sin(gamma) - accDrag - prop - parachute - epd; %vdot
xdot(3,1) = v*sin(gamma); % rdot
xdot(4,1) = v/r*cos(gamma); % thetadot



end

