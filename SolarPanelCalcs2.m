clear all
close all
clc

%% Assumptions
% The losses between the panels and battery and rest of the system are the
% same for both photovoltaic and thermal
% Thermal experiences all of the same losses that photovoltaic does except
% for the temperature losses
% Thermal efficiency typically ranges from 70-90%. I assumed 90% because
% NASA should be able to get 90%. 
% All degradation values were gathered from ENAE 691 Satellite Design
% "Electrical Power" by Roberto Arocho on 4/7/17
% Tmax is 30C. If it is above 33C then it goes negative. 30C seems like a
% reasonable option. 

% Avionics gets 112.5 kW

earth = 1;
betaEarth = 90;
betaMars = 90;
years = 15; %mission length
concentration = 3;


if earth == 1
    beta = betaEarth;
    sunEnergy = 1367; %w/m^2
else
    beta = betaMars;
    sunEnergy = 588; %w/m^2
end

%% Inputs
Tmax = 147; %Celsius, maximum temperature that the solar cells will reach
voltage = 32; %battery voltage
dod = .25; %depth of discharge
batteryNum = 1; %number of batteries

%% from RASCAL limits
MaxOutput = 650000; %W

%% Losses within system
% values from slide 56
% PPT
Nsabatp = .86; %solar array to battery
Nbatldp = .84; %battery to load
Nsaldp = .9; %solar array to load

% DET
Nsabatd = .79; %solar array to battery
Nbatldd = .84; %battery to load
Nsaldd = .83; %solar array to load

%% Other losses
% values from slide 58
maxTempLoss = .0019*(Tmax-28); %Tmax = max operational temperature in C
tempL = 1-maxTempLoss; %temp factor
sunAngle = 1-cosd(beta); 
sunIntensity = .9675;
timeDegradation = 1-.03*years;
packing = .85;
uncertainty = .95;
shadowing = .99;

PHlosses = tempL*sunAngle*sunIntensity*timeDegradation*packing*uncertainty*shadowing*Nsaldp
Tlosses = packing*uncertainty*shadowing*sunIntensity*sunAngle*timeDegradation*Nsaldp

%% Solar array output before losses at BOL
sunAngle = 1-cosd(betaEarth); 
timeDegradation = 1-.03*0;

PHpBOL = MaxOutput/(tempL*Nsaldp*sunAngle*sunIntensity*timeDegradation*packing*uncertainty*shadowing)
TpBOL  = MaxOutput/(      Nsaldp*sunAngle*sunIntensity*timeDegradation*packing*uncertainty*shadowing)

%% Power available at EOL
% from slide 58
PHpEOL = PHpBOL*PHlosses
TpEOL  = TpBOL*Tlosses

%% Photovoltaic parameters
% GaAs panels from slide 58
PHsaEfficiency = .295; %triple junction GaAs efficiency
PHsaEffArea = sunEnergy*concentration*PHsaEfficiency*PHlosses; %W/m^2
PHsaSpecificMass = .8; %kg/m^2
PHarea = PHpBOL/PHsaEffArea %m^2
PHmass = PHsaSpecificMass*PHarea %kg

%% %%% SOLAR THERMAL %%% %%
% mass from http://www.greener-way.com/solar-thermal.htm
Tefficiency = .9; %90% for solar thermal
TenergyPerArea = sunEnergy*concentration*Tefficiency*Tlosses; %w/m^2
TmaxSize = TpBOL/TenergyPerArea %m^2 total area needed for max energy
% space scale assumes same ratio of space system to earth system for
% thermal panels as for PV panels, 14.6 kg/m2 comes from
% https://news.energysage.com/average-solar-panel-size-weight/ where it has
% 3 lb/ft2
spaceScale = .8/14.6; %weight of space PV panels/weight of earth PV panels
TspecificMass = 18*spaceScale; %kg/m^2
TmassPanels = TmaxSize*TspecificMass
TconcentratorMass = .2; %https://www.grc.nasa.gov/www/tmsb/dynamicpower/doc/adv_sd_tech.html
TmassConcentrator = TmaxSize*(concentration-1)*TconcentratorMass
TmassTotal = TmassPanels + TmassConcentrator
TareaTotal = TmaxSize*(concentration)
''

TmassPanels
TmassConcentrator
TmassTotal
TareaPanels = TmaxSize/concentration
TareaConcentrator = TmaxSize*(concentration-1)/concentration
TareaTotal = TareaPanels + TareaConcentrator

PHmassPanels = PHmass/concentration
PHmassConcentrator = PHarea*(concentration-1)/concentration*TconcentratorMass
PHmassTotal = PHmassPanels + PHmassConcentrator
PHareaPanels = PHarea/concentration
PHareaConcentrator = PHarea*(concentration-1)/concentration
PHareaTotal = PHarea

% %% Photovoltaic battery requirements
% % PPT
% PHeStoragep = PHavgLoadp*eclTimeMax/60/Nbatldp; %WHr
% PHaHrReqp = PHeStoragep/voltage; %AHr
% PHaHrReqAdjustedp = PHaHrReqp/(dod*batteryNum); %AHr
% 
% % DET
% PHeStoraged = PHavgLoadd*eclTimeMax/60/Nbatldd; %WHr
% PHaHrReqd = PHeStoraged/voltage; %AHr
% PHaHrReqAdjustedd = PHaHrReqd/(dod*batteryNum); %AHr
% 
% %% Thermal battery requirements
% % PPT
% TeStoragep = TavgLoadp*eclTimeMax/60/Nbatldp; %WHr
% TaHrReqp = TeStoragep/voltage; %AHr
% TaHrReqAdjustedp = TaHrReqp/(dod*batteryNum); %AHr
% 
% % DET
% TeStoraged = TavgLoadd*eclTimeMax/60/Nbatldd; %WHr
% TaHrReqd = TeStoraged/voltage; %AHr
% TaHrReqAdjustedd = TaHrReqd/(dod*batteryNum); %AHr

%% Battery calcs
load = 10000; %W, spacecraft needs during launch
launchTime = 1; %hr, time between launch and solar panels finished deploying
batteryLoss = .85; %average value of Nbatldd, Nbatldp, etc. 
energyNeeded = load*launchTime/batteryLoss %WHr
ampsNeeded = energyNeeded/voltage; %AHr
ampsNeededAdjusted = ampsNeeded/(dod*batteryNum) %AHr





