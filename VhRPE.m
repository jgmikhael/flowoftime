% This code illustrates the effect of state uncertainty on estimated value
% and hence the RPE.
% Written 9Nov18 by JGM.

clear; close all; clc
set(0,'DefaultFigureWindowStyle','docked')
set(groot,'defaultLineLineWidth',2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = 40;                    	% number of states (features)
power = .8;                	% compression factor: y = eta*t^power
y = 1:n;                   	% subjective time
t = y.^(1/power);          	% objective time
CS = floor(.3*n);           % subjective time of conditioned stimulus 
CSt = CS^(1/power);         % objective time of conditioned stimulus
Y = floor(.8*n);            % subjective reward time   
T = Y^(1/power);            % objective reward time
gamma = .9;                	% discount factor
r = zeros(n-1,1); r(Y) = 1; % reward schedule

% compute estimated value Vh and its RPE
Vh = TD(n,Y,4,gamma);
Vh(1:CS-1) = 0;
dh = r+gamma*Vh(2:end)-Vh(1:end-1); dh(Y+1:end) = 0;

% define true value V and its RPE
V = gamma.^(Y-y); V = V'; V([1:CS-1 Y+1:end]) = 0;
d = r+gamma*V(2:end)-V(1:end-1); d(Y+1:end) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1) 
labelFont = 15; LgdFont = 12;           % define font sizes

subplot(2,1,1)
plot(t,Vh,'k')
hold on
plot(t,V,'Color',.7+[0 0 0],'Linestyle','--')
ylabel('Estimated Value','FontSize',labelFont)
lgd = legend('With State Uncertainty','Without State Uncertainty',...
    'Location','Northwest');
lgd.FontSize = LgdFont;
ylim(1.2*[min(Vh) max(Vh)])

subplot(2,1,2)
plot(t(1:end-1),dh,'k')
hold on
plot(t(1:end-1),d,'Color',.7+[0 0 0],'LineStyle','--')
ylim(1.2*[min(dh) max(dh)])
ylabel('RPE','FontSize',labelFont)

for e = 1:2
    subplot(2,1,e)
    xlim([0 1.2*T])
    xlabel('Objective Time','FontSize',labelFont)
end
