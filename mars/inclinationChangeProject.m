function [ time, gamma, v,r,theta,acc, data ] = inclinationChangeProject( rad1, rad2,beta,timeSteps,dragOn,theta0, gamma0, i1, i2  )

rMars = 3393000; %m %Or whatever altitude we're landing at
muMars = 42970*1000^3; %m3/s2
goMars = muMars/rMars^2; %m/s2

%% First Maneuver 
vc1 = sqrt(muMars/rad1);
vp1 = sqrt(muMars/rad1)*sqrt(2*rad2/(rad1+rad2));
Ld = 0;

dv1 = abs(sqrt(vc1^2+vp1^2-2*vc1*vp1*cosd(i1))) ; %delta v for first maneuver

tf = pi*sqrt((.5*(rad1+rad2))^3/muMars);
tspan = linspace(0,tf,timeSteps);

v0 = vc1-dv1;
r0 = rad1;

IC = [gamma0 v0 r0 theta0];
orb_opt = odeset('RelTol', 1e-11, 'AbsTol', [1e-11*ones(1,length(IC))]); %tolerances
[time1, xdot1] = ode45(@(t,x) orbitProject( x,muMars,goMars, rMars, beta,Ld,dragOn), tspan, IC, orb_opt);

gamma1 = xdot1(:,1);
v1 = xdot1(:,2);
r1 = xdot1(:,3);
theta1 = xdot1(:,4);
acc1 = diff(v1)./diff(time1);

rRx1 = r1.*cos(theta1);
rRy1 = r1.*sin(theta1);

%% Second Maneuver
va = sqrt(muMars/rad2)*sqrt(2*rad1/(rad1+rad2));
v2 = sqrt(muMars/rad2);

dv2 = abs(sqrt(v2^2 + va^2 - 2*v2*va*cosd(i2)))  ;
dvTotal = dv1+dv2;
gamma0 = gamma1(end);
gamma0 = 0;
v0 = v1(end)-dv2;
r0 = r1(end);
theta0 = theta1(end);

IC = [gamma0 v0 r0 theta0];
orb_opt = odeset('RelTol', 1e-11, 'AbsTol', [1e-11*ones(1,length(IC))]); %tolerances
[time2, xdot2] = ode45(@(t,x) orbitProject( x,muMars,goMars, rMars, beta,Ld,dragOn), tspan, IC, orb_opt);

gamma2 = xdot2(:,1);
v2 = xdot2(:,2);
r2 = xdot2(:,3);
theta2 = xdot2(:,4);
acc2 = diff(v2)./diff(time2);

rRx2 = r2.*cos(theta2);
rRy2 = r2.*sin(theta2);

%% Combining variables
time = [time1; time1(end)+time2];
gamma = [gamma1; gamma2];
v = [v1; v2];
r = [r1; r2];
theta = [theta1; theta2];
acc = [acc1; acc1(end); acc2; acc2(end)];

data.ti1 = time1;
data.ti2 = time2;
data.g1 = gamma1;
data.g2 = gamma2;
data.v1 = v1;
data.v2 = v2;
data.r1 = r1;
data.r2 = r2;
data.th1 = theta1;
data.th2 = theta2;
data.a1 = [acc1; acc1(end)];
data.a2 = [acc2; acc2(end)];
dv1
dv2
dvTotal
end


