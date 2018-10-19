clear all
close all
clc

G = 6.67408*10^-11; %m3/(kg.s2), gravitational constant
goEarth = 9.81; %m/s2
timeSteps = 1000;
beta = 200; %kg/m2
Ld = 0; %lift to drag ratio
dragOn = 0;

%% Martian parameters
rMars = 3393000; %m 
muMars = 42970*1000^3; %m3/s2
goMars = muMars/rMars^2; %m/s2
oneSol = (24*3600)+(39*60)+35.244;  % seconds (1 day 39 minutes 35.244 seconds)

thetaMars = 0:.01:2*pi;
thetaMars = thetaMars';
rMarsx = rMars*cos(thetaMars);
rMarsy = rMars*sin(thetaMars);

%% Phobos parameters
rPBody = 11267; %m
massP = 1.0659*10^16; %kg
muP = G*massP; %m3/s2
goP = muP/rPBody^2; %m/s2

periapsisP = 9234420; %m
apoapsisP = 9517580; %m

aP = 9376000; %m, semi major axis
eP = .0151; %eccentricity
PP = 7*3600+39.2*60; %s, orbital period
iP = 1.093 *pi/180; %rad, inclination to Martian equator (26.04 deg to ecliptic)
pP = aP*(1-eP^2); %m, semi latus rectum (parameter)
% rP0 = aP; %m, where Phobos starts on its orbit
rP0 = aP; %m, where Phobos starts on its orbit

thetaP0 = acos((pP/aP-1)/eP); %rad, true anomaly
gammaP0 = atan((eP*sin(thetaP0))/(1+eP*cos(thetaP0)));
vP0 = sqrt(muMars/aP^3)*rP0; %m/s, mean motion, average velocity

%% Phobos orbit calculations
betaP = 1;
LdP = 0;
% thetaP0 = 0;
% gammaP0 = 0;

tfP = 8*3600;
tspanP = linspace(0,tfP,timeSteps);
ICP = [gammaP0 vP0 rP0 thetaP0];
orb_opt = odeset('RelTol', 1e-11, 'AbsTol', [1e-11*ones(1,length(ICP))]); %tolerances
[timeP, xdotP] = ode45(@(t,x) orbitProject( x,muMars,goMars, rMars, betaP,LdP,dragOn), tspanP, ICP, orb_opt);

gammaP = xdotP(:,1);
vP = xdotP(:,2);
rP = xdotP(:,3);
thetaP = xdotP(:,4);
accP = diff(vP)./diff(timeP);

rPx = rP.*cos(thetaP);
rPy = rP.*sin(thetaP);

%% Rocket circular orbit parameters
PcR = 5*oneSol; %s, period
rcR = (((PcR/(2*pi))^2)*muMars)^(1/3); %m, radius
vcR = sqrt(muMars/rcR); %m/s, circular orbit
rR0 = rcR;

[timeRc, gammaR, vR,rR,thetaR,accR, dataR ] = HohmannTransfer(rR0, rR0,beta,timeSteps,dragOn, 0,0 );

rRx = rcR.*cos(thetaR);
rRy = rcR.*sin(thetaR);

%% Rocket Hohmann transfers and entry
% All dv's are assumed to happen instantaneously

%5 sol to Phobos circular
[time1, gamma1, v1,r1,theta1,acc1, data1 ] = HohmannTransfer(rR0, rP0,beta,timeSteps,dragOn, thetaR(end),gammaR(end) ); 
hEntry = 125000; %m
rEntry = hEntry+rMars; %m

% circular Phobos to elliptical Phobos
dragOn = 0;
tspan = [0 3600*8];
IC = ICP;
[timece, xdotce] = ode45(@(t,x) orbitProject( x,muMars,goMars, rMars, beta,Ld,dragOn), tspan, IC, orb_opt);
gammace = xdotce(:,1);
vce = xdotce(:,2);
rce = xdotce(:,3);
thetace = xdotce(:,4);

[timeE, gammaE, vE,rE,thetaE,accE, dataE ] = HohmannTransfer( apoapsisP,periapsisP,beta,timeSteps,dragOn, thetaP0,gammaP0 ); 


%circular Phobos to entry
[time2, gamma2, v2,r2,theta2,acc2, data2 ] = HohmannTransfer(rP0, rEntry,beta,timeSteps,dragOn, theta1(end),gamma1(end) ); 
vEscape = sqrt(2*muMars./r2);
vEscape = vEscape';

i = 1.08+13.9; %deg, Phobos to equatorial plane
dvInclination = 2*v2(end)*sind(i/2);
[ timei, gammai, vi,ri,thetai,acci, datai ] = inclinationChangeProject( rP0, rEntry,beta,timeSteps,dragOn,0, 0, i/2, i/2  );

%entry to surface
[time3, gamma3, v3,r3,theta3,acc3] = EntryProject( r2(end), theta2(end), muMars,timeSteps,goMars,rMars,beta ); 

%% Compiling variables
time = [time1; time1(end)+time2; time1(end)+time2(end)+time3];
gamma = [gamma1; gamma2;gamma3];
v = [v1; v2; v3];
r = [r1; r2; r3];
theta = [theta1; theta2; theta3];
acc = [acc1; acc2; acc3];

rx = r.*cos(theta);
ry = r.*sin(theta);

%% Getting other variables out of orbitProject
%5 sol to Phobos
for ii = 1:length(time1)
    dragOn = 0;
    x = [ gamma1(ii); v1(ii); r1(ii); theta1(ii)];
    [ ~,  pres1(ii), temp1(ii),rho1(ii), accDrag1(ii), lift1(ii) ] = orbitProject( x,muMars,goMars, rMars ,beta,Ld,dragOn);
end

%Phobos to entry
for ii = 1:length(time2)
    dragOn = 0;
    x = [ gamma2(ii); v2(ii); r2(ii); theta2(ii)];
    [ ~,  pres2(ii),temp2(ii), rho2(ii), accDrag2(ii), lift2(ii) ] = orbitProject( x,muMars,goMars, rMars ,beta,Ld,dragOn);
end

% entry to surface
for ii = 1:length(time3)
    dragOn = 1;
    x = [ gamma3(ii); v3(ii); r3(ii); theta3(ii)];
    [ ~,  pres3(ii),temp3(ii), rho3(ii), accDrag3(ii), lift3(ii) ] = orbitProject( x,muMars,goMars, rMars ,beta,Ld,dragOn);
end

pres1 = pres1';
pres2 = pres2';
pres3 = pres3';
rho1 = rho1';
rho2 = rho2';
rho3 = rho3';
accDrag1 = accDrag1';
accDrag2 = accDrag2';
accDrag3 = accDrag3';
lift1 = lift1';
lift2 = lift2';
lift3 = lift3';
temp1 = temp1';
temp2 = temp2';
temp3 = temp3';

pres = [pres1; pres2; pres3];
rho = [rho1; rho2; rho3];
accDrag = [accDrag1; accDrag2; accDrag3];
lift = [lift1; lift2; lift3];
temp = [temp1; temp2; temp3];

h = r - rMars;
h1 = r1 - rMars;
h2 = r2 - rMars;
h3 = r3 - rMars;
hfinal = h(end)/1000 %km, final altitude (should be 0)

downrange3 = (theta3-theta3(1))*rMars;

%% Plots 
PlotsProject( acc, acc1, acc2, acc3, accDrag, accDrag1, accDrag2, accDrag3, accP, accR, data1, data2, gamma, gamma1, gamma2, gamma3, gammaP, gammaR, ...
    lift, lift1, lift2, lift3, oneSol, pres, pres1, pres2, pres3, r, r1, r2, r3, rcR, rho, rho1, rho2, rho3, rMars, rMarsx, rMarsy, rP, rPx, rPy, rRx, rRy, rx, ry, theta, theta1,...
    theta2, theta3, thetaMars, thetaP, time, time1, time2, time3, timeP, timeRc, v, v1, v2, v3, vcR, vP, goEarth,vEscape,...
    temp1, temp2, temp3, temp, h, h1, h2, h3, downrange3,rce,timece, vce)

