% This code illustrates the effect of the parameter eta on time cell
% response profiles, when plotted against objective time.
% Written 2Nov18 by JGM.

clear; close all; clc
set(0,'DefaultFigureWindowStyle','docked')
set(groot,'defaultLineLineWidth',2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parameters
n = 10;         % number of features
mu = 1:n;       % means of features, plotted against subjective time
sigma = .7;     % width of features, plotted against subjective time
power = .7;     % compression: (subjective time)=eta*(objective time)^power
eta = [1,1.5];  % two example eta's

% define objective time (t) and subjective time (y) for eta = 1
y = (0:.01:n)';
t = y.^(1/power);

% create basis functions x(i,j) = (subjective time i, feature j)
x = normpdf(eta(1)*y, mu, sigma);
x1 = normpdf(eta(2)*y, mu, sigma);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)

labelFont = 15; etaFontSize = 15;           % define font sizes
C = linspace(0,.8,n)'*[1 1 1];              % define color scheme
set(groot,'defaultLineLineWidth',3)

subplot(2,1,1)
h = plot(t,x);
set(h, {'color'}, num2cell(C,2));
title(strcat({'\eta = 1'},...
{'                                                                  '}),...
'FontSize',etaFontSize)

subplot(2,1,2)
h = plot(t,x1);
set(h, {'color'}, num2cell(C,2));
title(strcat({'\eta = 1.5'},...
{'                                                                '}),...
'FontSize',etaFontSize)

for e = 1:2
    subplot(2,1,e)
    ylabel('Time Cell Activation','FontSize',labelFont)
    set(gca,'ytick',[])
    xlim([0 n^(1/power)])
    ylim([0, max(x(:))])
    xlabel('Objective Time','FontSize',labelFont)
end