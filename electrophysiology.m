% This code simulates the results of Mello et al. (2015), who observed
% flexible rescaling of time cells with trial length.
% Written 10Nov18 by JGM.

clear; close all; clc
set(0,'DefaultFigureWindowStyle','docked')
set(groot,'defaultLineLineWidth',2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = 80;                 % number of states (also max subjective time)
y = 1:n;                % subjective time
sigma = 30;             % width of features against subjective time
power = .6;             % compression factor: y = eta*t^power
FI0 = 12;               % smallest fixed interval (FI)
gamma = .9;             % discount factor
r0 = 1;                 % reward magnitude

% define features against objective time
x = normpdf(y,y',sigma); x = x/max(x(:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)

labelFont = 14;         % define font size

subplot(2,5,1:5)
image(imread('placeholder.png'));
set(gca,'xtick',[])
set(gca,'ytick',[])

for e = 1:5
    
    eta = y(end)./(FI0*e)^power;
    t = (y/eta).^(1/power); 
    
    subplot(2,5,e+5)
    h = pcolor([t-max(t) t],y,[x x]);
    h.EdgeColor = 'none';
    ax = gca;
    FI = FI0*e;
    ax.XLim = [-FI FI];
    ax.XTick = [-FI 0 FI];
    yticks([20 40 60])
    yticklabels({'60','40','20'})
    title(['FI = ' num2str(12*e)])
    caxis([.6 1.4]);
    colormap('gray')
    
end

subplot(2,5,8)
xlabel('time relative to reward','FontSize',labelFont)

subplot(2,5,6)
ylabel('cell #','FontSize',labelFont)
