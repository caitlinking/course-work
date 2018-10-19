function [  ] = PlotsProject( acc, acc1, acc2, acc3, accDrag, accDrag1, accDrag2, accDrag3, accP, accR, data1, data2, gamma, gamma1, gamma2, gamma3, gammaP, gammaR, ...
    lift, lift1, lift2, lift3, oneSol, pres, pres1, pres2, pres3, r, r1, r2, r3, rcR, rho, rho1, rho2, rho3, rMars, rMarsx, rMarsy, rP, rPx, rPy, rRx, rRy, rx, ry, theta, theta1,...
    theta2, theta3, thetaMars, thetaP, time, time1, time2, time3, timeP, timeRc, v, v1, v2, v3, vcR, vP, goEarth,vEscape,...
     temp1, temp2, temp3, temp, h, h1, h2, h3,downrange3,rce,timece,vce)
dc = distinguishable_colors(5); %matlab program for nice graph colors


figure('units', 'normalized', 'outerposition', [0     0 .9 .8 ] )
figure('units', 'normalized', 'outerposition', [.05     .05 .9 .8 ] )
figure('units', 'normalized', 'outerposition', [.1     .1 .9 .8 ] )
figure('units', 'normalized', 'outerposition', [.15     .15 .9 .8 ] )

dUnits = 1000;
tUnits = 1;
pauseLength = .005;
animatedGraph = 0;

if dUnits == 1
    dd = 'distance (m)';
    vv = 'velocity (m/s)';
    hh = 'altitude (m)';
elseif dUnits == 1000;
     dd = 'distance (km)';
     vv = 'velocity (km/s)';
     hh = 'altitude (km)';
end

if tUnits == 1
    tt = 'time (s)';
elseif tUnits == 60
    tt = 'time (min)';
elseif tUnits == 3600
    tt = 'time (hrs)';
elseif tUnits == oneSol
    tt = 'time (sol)';
end

aa = 'acceleration (earth g)';
pp = 'pressure (kpa)';
rr = 'rho (kg/m3)';
cc = 'temp (C)';

%% Figure 1
figure(1)
subplot(2,3,1)
hold on
plot(rPx/dUnits, rPy/dUnits,'g', 'linewidth', 2)
plot(rMarsx/dUnits, rMarsy/dUnits,'r', 'linewidth', 2)
plot(rRx/dUnits, rRy/dUnits, 'b')
legend('Phobos', 'Mars','Rocket')
title('Orbit Paths Around Mars')
xlabel(dd)
ylabel(dd)
legend('location', 'east')

subplot(2,3,2)
plot(v/dUnits, h/dUnits)
title('velocity vs. altitude')
xlabel(vv)
ylabel(hh)

subplot(2,3,3)
plot(v3/dUnits, h3/dUnits)
title('Entry velocity vs. altitude')
xlabel(vv)
ylabel(hh)

subplot(2,3,4)
plot(time/tUnits, h/dUnits)
title('Rocket altitude vs. time')
xlabel(tt)
ylabel(hh)

subplot(2,3,5)
plot(time/tUnits, v/dUnits)
title('Rocket velocity vs. time')
xlabel(tt)
ylabel(vv)

subplot(2,3,6)
plot(acc/goEarth, h/dUnits)
title('Acceleration vs. altitude')
xlabel('acceleration (earth g)')
ylabel(hh)



%% Figure 2
figure(2)

subplot(2,3,1)
hold on
plot(temp3, h3/dUnits)
xlabel(cc)
ylabel(hh)
title('entry: altitude vs. temp')

rRx = r.*cos(theta);
rRy = r.*sin(theta);


% subplot(2,3,2)
% hold on
% plot(rMarsx/dUnits, rMarsy/dUnits ,'r', 'linewidth', 2)
% axis([min(rPx) max(rPx) min(rPy) max(rPy)]*1.15/dUnits)
% for ii = 1:length(rPx)    
%     q = scatter(rPx(ii)/dUnits, rPy(ii)/dUnits, 'filled');
%     q.MarkerFaceColor =  [0 1-ii/length(rRx) 0];
%     q.SizeData = 10;
%     plot(rRx(1:ii)/dUnits, rRy(1:ii)/dUnits, 'b--')
%     pause(pauseLength/10)
% end
% xlabel(dd)
% ylabel(dd)
% title('Orbit Path')

subplot(2,3,3)
hold on
plot(rMarsx/dUnits, rMarsy/dUnits,'r', 'linewidth', 2)
plot(rPx/dUnits, rPy/dUnits, 'g', 'linewidth', 2)
plot(rx/dUnits, ry/dUnits,'b')
axis([min(rPx) max(rPx) min(rPy) max(rPy)]*1.15/dUnits)
title('Orbit Paths around Mars (zoomed to Phobos)')
xlabel(dd)
ylabel(dd)

subplot(2,3,4)
plot(rho3, h3/dUnits) 
title('entry: rho vs. altitude')
xlabel('rho (kg/m3)')
ylabel(hh)
% axis([min(rho), max(rho), -1000/dUnits, 120000/dUnits])

subplot(2,3,5)
plot(pres3, h3/dUnits)
title('entry: pressure')
xlabel('pressure (kpa)')
ylabel(hh)
% axis([min(pres), max(pres), -1000/dUnits, 120000/dUnits])


subplot(2,3,6)
hold on
plot(rMarsx/dUnits, rMarsy/dUnits,'r', 'linewidth', 2)
plot(rPx/dUnits, rPy/dUnits, 'g', 'linewidth', 2)
plot(rx/dUnits, ry/dUnits,'b')
title('Orbit Paths around Mars (zoomed to Phobos)')
xlabel(dd)
ylabel(dd)

if animatedGraph == 1
subplot(2,3,6)
hold on
plot(rMarsx/dUnits, rMarsy/dUnits ,'r', 'linewidth', 2)
plot(rPx/dUnits, rPy/dUnits,'g', 'linewidth', 2)
title('Orbit Paths Around Mars')
xlabel(dd)
ylabel(dd)
for ii = 1:length(r)
    plot(rx(1:ii)/dUnits, ry(1:ii)/dUnits, 'r--')
% for ii=1:length(rcR)
%     plot(rRx(1:ii)/dUnits,rRy(1:ii)/dUnits,'b')
%     plot(rPx(1:ii)/dUnits, rPy(1:ii)/dUnits,'g', 'linewidth', 2)
    axis([min(rRx) max(rRx) min(rRy) max(rRy)]*1.15/dUnits)
    pause(pauseLength/100)
end
end
% for ii=1:length(r1x)
%     plot(r1x(1:ii)/dUnits, r1y(1:ii)/dUnits,'b')
%     pause(pauseLength)
% end
% for ii=1:length(r2x)
%     plot(r2x(1:ii)/dUnits, r2y(1:ii)/dUnits,'b--', 'linewidth', 2)
%     pause(pauseLength)
% end
% for ii=1:length(r3x)
%     plot(r3x(1:ii)/dUnits, r3y(1:ii)/dUnits,'b')
%     pause(pauseLength)
% end
% for ii=1:length(r2x)
%     plot(r4x(1:ii)/dUnits, r4y(1:ii)/dUnits,'b--', 'linewidth', 2)
%     pause(pauseLength)
% end
% % plot(r4x/dUnits, r4y/dUnits, 'r--', 'linewidth', 2)
% % axis([min(rPx) max(rPx) min(rPy) max(rPy)]/dUnits)
% end


%% figure 3
figure(3)

subplot(2,3,1)
plot(v2/dUnits,h2/dUnits)
title('Phobos to entry: altitude vs. velocity')
ylabel(hh)
xlabel(vv)


subplot(2,3,4)
plot(time/tUnits, h/dUnits)
title('altitude vs. time')
xlabel(tt)
ylabel(hh)

subplot(2,3,5)
plot(time/tUnits, v/dUnits)
xlabel(tt)
ylabel(vv)
title('velocity vs. time')

subplot(2,3,6)
hold on
plot(vEscape/dUnits, h2/dUnits)
plot(v2/dUnits, h2/dUnits)
xlabel(vv)
ylabel(hh)
title('Phobos to entry: velocity vs. altitude')
legend('Escape', 'rocket')

%% Figure 4
figure(4)

subplot(2,3,1)
hold on
plot(timece/tUnits, rce/dUnits)
plot(timeP/tUnits, rP/dUnits,'r--')
xlabel(tt)
ylabel(dd)
title('Radius - Phobos and rocket')
legend('rocket', 'Phobos')

subplot(2,3,2)
hold on
plot(timece/tUnits, vce/dUnits)
xlabel(tt)
ylabel(vv)
title('rocket velocity in Phobos elliptical orbit')

subplot(2,3,3)
hold on
plot(time3, h3/dUnits)
xlabel(tt)
ylabel(hh)

subplot(2,3,4)
hold on
plot(acc3, h3/dUnits)
xlabel(aa)
ylabel(hh)

subplot(2,3,6)
hold on
plot(downrange3/dUnits, h3/dUnits)
xlabel(dd)
ylabel(hh)
title('entry to surface: downrange vs. altitude')

figure(5)
% subplot(2,3,3)
hold on
plot(rMarsx/dUnits, rMarsy/dUnits,'r', 'linewidth', 2)
plot(rPx/dUnits, rPy/dUnits, 'g', 'linewidth', 2)
plot(rx/dUnits, ry/dUnits,'b')
% axis([min(rPx) max(rPx) min(rPy) max(rPy)]*1.15/dUnits)
title('Orbit Paths around Mars')
xlabel(dd)
ylabel(dd)

end

