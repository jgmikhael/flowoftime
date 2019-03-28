% This code simulates the results of Toda et al. (2017), who observed that
% optogenetic stimulation of basal ganglia output could lead to either
% earlier or later timing on the next trial, depending on when the
% stimulation occurred.
% Written 24Jan19 by JGM.

clear; close all; clc
set(0,'DefaultFigureWindowStyle','docked')
set(groot,'defaultLineLineWidth',2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = 80;             % number of states (features)
T = 10;             % objective time of reward
sigma = 10;         % width of features against subjective time
power = .7;         % compression factor: y = eta*t^power
gamma = .9;         % discount factor
alphaE = 7;         % learning rate for eta
%                     note: does not have to be less than 1
%                     (only requirement is: 0 < alphaE*y*Vdot/eta < 1)

% find baseline eta so y maps to the range t=(0,tmax)
tmax = 20;                  % max objective time
eta = n/tmax^power;         % scaling factor y = eta*t^power

yi = 1:n;                   % subjective time
Y = floor(eta*T^power);     % subjective reward time
ti = (yi/eta).^(1/power);   % objective time

% derive estimated value Vh
Vh = TD(n,Y,sigma,gamma);

% define domains; approximate 1-s interval by evaluating at its midpoint
stim = [T; T-1; T-2]+.5;        % stimulation domains, in objective time
stimY = floor(eta*stim.^power); % stimulation domains, in subjective time

% approximate magnitude of change in eta in each of the 3 domains
Vdot = [diff(Vh); 0];                       % dV/dy
deltaEta=(alphaE/eta)*stimY.*Vdot(stimY);   % update rule

% compute new eta (set delta = +1)
etaP = eta+deltaEta;

% given new eta and y, compute corresponding t
Tnew = (Y./etaP).^(1/power);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)

labelFont = 14;                                     % define font size

subplot(5,3,1:9)
image(imread('placeholder.png'));
set(gca,'xtick',[])
set(gca,'ytick',[])

cols = [132 132 132; 146 146 146; 219 219 219]/255; % color scheme
for e = 1:3
    subplot(5,3,[e+9 e+12])  
    b = bar([1 2], [T,Tnew(e)],.7);
    b.EdgeColor = [1 1 1];
    b.FaceColor = 'flat';
    b.CData(1,:) = (65/255)*[1 1 1];                % color scheme
    b.CData(2,:) = cols(e,:);
    xticks([1 2])
    xticklabels({'No Stim', 'Stim'})
    yticks([9 10 11])
    ylabel('Peak time (s)','FontSize',labelFont)
    xlim([0.3 2.7])
    ylim([9 11])
end
