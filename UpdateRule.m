% This code illustrates the bidirectional update rule for eta.
% Written 8Nov18 by JGM.

clear; close all; clc
set(0,'DefaultFigureWindowStyle','docked')
set(groot,'defaultLineLineWidth',2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = 100;                % number of states (and thus max subjective time)
y = 1:n;                % subjective time
Y = 60;                 % (subjective) time of reward delivery
power = .7;             % compression factor: y = eta*t^power
eta = 1;                % pacemaker rate
t = (y/eta).^(1/power); % objective time
T = (Y/eta)^(1/power);  % objective time of reward delivery
gamma = .9;             % discount factor
sigma = 5;              % width of features against subjective time
alphaE = .1;            % learning rate for eta
r = 1;                  % magnitude of reward (note: TD.m assumes r = 1)

% learn value estimate Vh, against subjective time y
Vh = TD(n,Y+1,sigma,gamma); % Vh response occurs in the next step

% derive RPE
delta = r+gamma*Vh(2:end)-Vh(1:end-1);

% compute update rule for eta
Vdiffy = [0; (diff(Vh(1:end-1))+diff(Vh(2:end)))/2]; % dV/dy
dEta = (alphaE/eta)*y(1:end-1)'.*delta.*Vdiffy;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)

labelFont = 15;
set(1,'defaultAxesColorOrder',[0 0 0]+[0; .5]);
set(groot,'defaultLineLineWidth',3)

plot(t,Vh,'k')
hold on
plot(T*[1 1],[-2.5 1.5],'--','Color',.3+[0 0 0],'LineWidth',2)

yyaxis left
ylabel('Estimated Value','FontSize',labelFont)
ylim(1.2*[min([Vh; dEta]) max([Vh; dEta])])

yyaxis right
ylabel('Change in Pacemaker Rate (\Delta\eta)','FontSize',labelFont')
ylim(1.4*[min([Vh; dEta]) max([Vh; dEta])])

plot(t(1:end-1),dEta,'Color',.5+[0 0 0])
hold on
plot([t(1) t(end)],[0 0],'Color',.3+[0 0 0],'LineWidth',2)

xlabel('Objective Time','FontSize',labelFont)
xlim([0 2*T])
