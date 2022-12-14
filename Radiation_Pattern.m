clear all, close all, clc
%% Import the data

addpath('Data','Functions','Images')

T_A = readtable('Radiation_Pattern.xlsx','Range','A1:G74','Sheet',1);
T_B = readtable('Radiation_Pattern.xlsx','Range','A1:G74','Sheet',2);

%% Format the Data

phi = T_A.Azimuth; phi(isnan(phi)) = [];
theta = T_A.Elevation; theta(isnan(theta)) = [];

%% Theoretical

antenna = monopoleRadial();
antenna.Height = 16.9*10^-2; % [m]
antenna.Width = 1.5*10^-2; % [m]
antenna.NumRadials = 4;
antenna.RadialWidth = 3*10^-3; % [m]
antenna.RadialLength = 17*10^-2; % [m]
antenna.RadialTilt = 45; % [°]
antenna.Conductor = metal('PEC');

figure();
show(antenna)
exportgraphics(gcf,'./Images/Antenna_Model.png')

p = patternElevation(antenna, 1.16*10^9);
p = [p(end-90:end); p(1:91)];
figure();
polarplot(deg2rad(linspace(-90,90,length(p))), p );
thetaticks(theta(1):15:theta(end)); thetalim([theta(1) theta(end)]);
rlim([-40 10]) 
title('Simulated radiation pattern in Elevation')

ax = gca;
ax.ThetaDir = 'clockwise';
ax.ThetaZeroLocation = 'top';
ax.RAxisLocation = 0;

exportgraphics(gcf,'./Images/Antenna_Model_Elevation.png')

%% Polar plot Azimuth

figure()
polarplot(deg2rad(phi),T_A.Amplitude);
hold on
polarplot(deg2rad(phi),T_B.Amplitude)
thetaticks(phi(1):15:phi(end));
rlim([-65 -35]); rticks(-60:5:-40); rticklabels({'-60','','-50','','-40'})
title('Radiation Pattern in Azimuth (zero elevation)')
legend('Antenna A','Antenna B','Location','SouthOutside')

ax = gca;
ax.ThetaDir = 'clockwise';
ax.ThetaZeroLocation = 'top';
ax.RAxisLocation = 0;
      
exportgraphics(gcf,'./Images/Radiation_Pattern_Azimuth.png')

%% Polar plot Elevation

figure()
polarplot(deg2rad(theta),T_A.Amplitude_1(1:length(theta)) );
hold on
polarplot(deg2rad(theta),T_B.Amplitude_1(1:length(theta)) )
thetaticks(theta(1):15:theta(end)); thetalim([theta(1) theta(end)])
rticks(-60:5:-40); rticklabels({'-70','','-60','','-50','','-40','','-30'}); rlim([-70 -30])
title('Radiation Pattern in Elevation (zero azimuth)')
legend('Antenna A','Antenna B','Location','SouthOutside')

ax = gca;
ax.ThetaDir = 'clockwise';
ax.ThetaZeroLocation = 'top';
ax.RAxisLocation = 0;
        
exportgraphics(gcf,'./Images/Radiation_Pattern_Elevation.png')

%% Gain

load('./Data/Center_Frequency.mat')

lambda = 3*10^8/freq_center; % [m]

Att_cable = 15 - 13.38; % [dB]
P_Rx_A = -32.2; % [dBm]
P_Rx_B = -30.3; % [dBm]
E = 370*10^-3; % [V/m]

syms G
eqn_A = E == sqrt( 10^(P_Rx_A/10) * 10^-3 * (480*pi)/lambda^2 * 1/(10^(G/10)) * 1/(10^(Att_cable/10)) );
eqn_B = E == sqrt( 10^(P_Rx_B/10) * 10^-3 * (480*pi)/lambda^2 * 1/(10^(G/10)) * 1/(10^(Att_cable/10)) );

eq_A = 20*log10(E*10^3) == 47.8 + 10*log10(G) + 10*log10( 10^(P_Rx_A/10)*10^-6 ) - 20*log10(3*10^-3);

gain_A = double( solve(eqn_A,G) );
gain_B = double( solve(eqn_B,G) );

g = double( solve(eq_A,G) );