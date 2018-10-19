function [ xdot, pres, temp, rho, accDrag, lift ] = orbitProject( x,muMars,goMars, rMars ,beta,Ld,dragOn)
gamma = x(1);
v = x(2);
r = x(3);
h = r - rMars;
g = goMars*(rMars/r)^2; % gravity
vc = sqrt(muMars/r);

%% Drag acceleration
% from https://www.grc.nasa.gov/www/k-12/airplane/atmosmrm.html
if dragOn == 1
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
else
    accDrag = 0;
    temp = 0;
    pres = 0;
    rho = 0;
end
%% Lift acceleration
lift = rho*v^2*Ld/(2*beta);
% lift = 0;

%% orbit calcs
xdot(1,1) = 1/v*(lift-(1-(v^2)/(vc^2))*g*cos(gamma)); %gammadot
xdot(2,1) = -g*sin(gamma) - accDrag ; %vdot
xdot(3,1) = v*sin(gamma); % rdot
xdot(4,1) = v/r*cos(gamma); % thetadot

% if xdot(3,1) < rMars
%     xdot(3,1) = rMars;
% end

end

