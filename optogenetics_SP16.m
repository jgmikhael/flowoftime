% This code simulates the results of Soares et al. (2016), who observed
% that optogenetic activation and inhibition of DA neurons resulted in
% behaviors consistent with a slower and faster internal clock,
% respectively.
% Written 14Nov18 by JGM.

clear; close all; clc
set(0,'DefaultFigureWindowStyle','docked')
set(groot,'defaultLineLineWidth',2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = 80;             % number of states (features)
T = 1.5;            % objective midpoint between short and long durations
sigma = 10;         % width of features against subjective time
power = .7;         % compression factor: y = eta*t^power
gamma = .9;         % discount factor
alphaE = 10;        % learning rate for eta
%                     note: does not have to be less than 1
%                     (only requirement is: 0 < alphaE*y*Vdot/eta < 1)

% find baseline eta so y maps to the range t=(0,tmax)
tmax = 3;                   % max objective time
eta = n/tmax^power;         % scaling factor y = eta*t^power

yi = 1:n;                   % subjective time
Y = floor(eta*T^power);     % subjective midpoint, corresponds to T = 1.5
ti = (yi/eta).^(1/power);   % objective time

% derive estimated value Vh
Vh = TD(n,Y,sigma,gamma);

% approximate magnitude of change in eta over the course of an entire trial
Vdot = [diff(Vh); 0];              % dV/dy
deltaEta = (alphaE/eta)*yi*Vdot;   % sum over entire trial

% compute new eta for activation/inhibition (set delta = +1 or -1)
etaP = eta+deltaEta;    % new eta with activation
etaN = eta-deltaEta;    % new eta with inhibition

% given new eta and y, compute corresponding t
tP = (yi/etaP).^(1/power);
tN = (yi/etaN).^(1/power);

% assign p(Long) ~ softmax
p = 1./(1+exp(5*(T-ti)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)

labelFont = 13; titleFont = 13;     % font sizes

subplot(2,2,1)
image(imread('placeholder.png'));
set(gca,'xtick',[]); set(gca,'ytick',[])
subplot(2,2,2)
image(imread('placeholder.png'));
set(gca,'xtick',[]); set(gca,'ytick',[])

subplot(2,2,3)
plot(ti,p,'k')
hold on
plot(tP,p,'Color',.5+[0 0 0])
title('Activation','FontSize',titleFont)
subplot(2,2,4)
plot(ti,p,'k')
hold on
plot(tN,p,'Color',.8+[0 0 0])
title('Inhibition','FontSize',titleFont)

for e = 3:4
    subplot(2,2,e)
    xlabel('Time Interval','FontSize',labelFont)
    ylabel('p(Long Choice)','FontSize',labelFont)
    xlim([.6 2.4])
    ylim([-.15 1.15])
    yticks([0 1])
    xticks([.6 1.5 2.4])
end
