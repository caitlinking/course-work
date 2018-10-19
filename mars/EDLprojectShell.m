clear all
close all
clc

rMars = 3393000; %m
muMars = 42970*1000^3; %m3/s2
goMars = muMars/rMars^2; %m/s2
beta = 400;
LtoD = .24;
hland = 4;

tspan = [0 415]; %s
tspan = [0:.5:615];
gamma0 = -5*pi/180; %rad, flight path angle
hEntry = 125000;
r0 = hEntry+rMars; %km
v0 = sqrt(muMars/r0); %m/s, initial (circular velocity)
theta0 = pi/2; %rad, orbit position
IC = [gamma0 v0 r0 theta0];
[time, xdot] = ode45(@(t,x) EDLproject( x,hland*1000), tspan, IC,[]);

gamma = xdot(:,1);
v = xdot(:,2);
r = xdot(:,3);
theta = xdot(:,4);
acc = diff(v)./diff(time)/9.81;
acc = [acc; acc(end)];
h = r - rMars;


flag = 0;
for ii = 1:length(r)
    if h(ii) == min(h) || flag == 1
        if flag == 0
            flag = 1;
            num = ii;
        end
        h(ii) = h(num);
        r(ii) = r(num);
        v(ii) = v(num);
        acc(ii) = acc(num);
        theta(ii) = theta(num);
        gamma(ii) = gamma(num);
    end
end


for ii = 1:length(r)
x = [gamma(ii) v(ii) r(ii) theta(ii)];
[ ~, pres(ii), temp(ii), rho(ii), accDrag(ii), lift(ii), prop(ii), parachute(ii), epd(ii) ] = EDLproject( x,hland*1000);
end

figure('units', 'normalized', 'outerposition', [0   .05 .9 .8 ] )
figure('units', 'normalized', 'outerposition', [.05 .1  .9 .8 ] )
figure('units', 'normalized', 'outerposition', [.1  .15 .9 .8 ] )

r = r/1000;
v = v/1000;
accDrag = accDrag/9.81;
lift = lift/9.81;
prop = prop/9.81;
parachute = parachute/9.81;
epd = epd/9.81;

h = r - rMars/1000;
downrange = h.*(gamma-gamma(1));
hy = h.*sin(theta);
t = time;

aa = 'acceleration (earth g)';
pp = 'pressure (kpa)';
rr = 'rho (kg/m3)';
cc = 'temp (C)';
tt = 'time (s)';
dd = 'distance (km)';
hh = 'altitude (km)';
vv = 'velocity (km/s)';
gg = 'gamma (rad)';
th = 'theta (rad)';
ad = 'Drag acc (earth g)';
ll = 'lift (earth g)';
pa = 'parachute (earth g)';
pr = 'propulsive (earth g)';

figure(1)

subplot(2,3,1)
hold on
plot(v,h)
xlabel(vv)
ylabel(hh)
title('alt vs vel')

subplot(2,3,2)
hold on
plot(t,h)
xlabel(tt)
ylabel(hh)
title('alt vs time')

subplot(2,3,3)
hold on
plot(t,v)
xlabel(tt)
ylabel(vv)
title('vel vs time')

subplot(2,3,4)
hold on
plot(downrange, hy)
xlabel(dd)
ylabel(dd)
title('flight path')

subplot(2,3,5)
hold on
plot(acc,h)
xlabel(aa)
ylabel(hh)
title('acc vs alt')

subplot(2,3,6)
hold on
plot(t,acc)
xlabel(tt)
ylabel(tt)
title('time vs acceleration')


figure(2)
subplot(2,3,1)
plot(parachute,h)
xlabel(pa)
ylabel(hh)

subplot(2,3,2)
plot(prop, h)
xlabel(pr)
ylabel(hh)

subplot(2,3,3)
plot(rho,h)
xlabel(rr)
ylabel(hh)

subplot(2,3,4)
plot(accDrag, h)
xlabel(ad)
ylabel(hh)

subplot(2,3,5)
plot(lift, h)
xlabel(ll)
ylabel(hh)

figure(3)
subplot(2,1,1)
hold on
plot(t, h)
plot(t, t*0+hland, 'k--')
xlabel(tt)

ylabel(hh)
yyaxis right
axis([0 900 -1 4])
plot(t, v)
% plot(t,t*0, 'k--')
ylabel(vv)
legend('altitude', 'ground', 'velocity')
title('EDL Altitude and Velocity')


prop(min(find(h==min(h))):end) = 0;
accTot = parachute+prop+accDrag+lift+epd;


subplot(2,1,2)
hold on
plot(t, parachute)
plot(t, prop)
plot(t, accDrag)
plot(t, accTot, '--')
plot(t, 0*t+3, 'k--')
xlabel(tt)
ylabel(aa)
axis([0 900 0 hland])
title('Deceleration Sources')
legend('parachute', 'propulsive', 'drag',  'total', 'human tolerance')

hland
he = min(h)
ve = v(find(h==min(h)));
ve = ve(1)




