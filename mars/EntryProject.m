function [ time, gamma, v,r,theta,acc ] = EntryProject( rad, theta0, muMars,timeSteps,goMars,rMars,beta)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
dragOn = 1;
vc = sqrt(muMars/rad);

gamma0 = -5 *pi/180;
v0 = vc;
r0 = rad;
Ld = .24;
% tf = pi*sqrt((.5*(r0+rMars))^3/muMars)/2;

IC = [gamma0, v0, r0, theta0];
tspan = linspace(0,611, timeSteps);
% tspan = [0 299];

orb_opt = odeset('RelTol', 1e-11, 'AbsTol', [1e-11*ones(1,length(IC))]); %tolerances
[time, xdot] = ode45(@(t,x) orbitProject( x,muMars,goMars, rMars, beta,Ld,dragOn), tspan, IC, orb_opt);

gamma = xdot(:,1);
v = xdot(:,2);
r = xdot(:,3);
theta = xdot(:,4);
acc = diff(v)./diff(time);
acc = [acc; acc(end)];


end
