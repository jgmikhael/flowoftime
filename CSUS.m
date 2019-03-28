% This code illustrates the effect of density of states on the shape of V
% and delta. Here, with more states within the same CS-US interval, the
% value function will appear to have a steeper slope when plotted against
% objective time.
% Written 6Nov18 by JGM.

clear; close all; clc
set(0,'DefaultFigureWindowStyle','docked')
set(groot,'defaultLineLineWidth',2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parameters
nL = [40 60 80];        % number of states
a = .8;                 % (time of reward delivery)/(total duration)
cs = .2;                % (time of conditioned stimulus)/(total duration)
sigma = .3;             % stdev of features against subjective time
gamma = .95;            % discount factor
numIter = 1000;         % number of trials
power = .7;             % defines objective time:   y = eta*t^power
%                                           i.e.,   t = (y/eta)^(1/power)

labelFont = 14; lgdFont = 12;   % define font sizes
col = [.6 .3 0]'*[1 1 1];       % define color scheme

figure(1)

for e = 1:2
    subplot(2,1,e)
    plot(10*[1 1], [0,2],'k--')
    hold on
    plot(80*[1 1], [0,2],'k--')
    hold on
end
for nInd = 1:3
    
    n = nL(nInd);               % number of states
    y = (1:n)';                 % subjective time, representing the states
    t = y.^(1/power);           % objective time
    absT = n*numIter;           % housekeeping variable
     
    % define reward schedule
    r0 = 1;                     % magnitude of reward
    T = floor(a*t(end));        % time of reward delivery (objective time)
    Y = floor(T^power);         % time of reward delivery (subjective time) 
    r = zeros(n,1); r(Y) = r0;  % rewards received in each state
 
    % create x                  x(i,j) = (subjective time i, feature j)
    x = normpdf(y, y', sigma);
    
    % learn the weights w and estimated value Vh
    w = zeros(absT,n);          % initialize w
    Vh = zeros(n,numIter);      % initialize Vh
    alpha = .1;                 % learning rate
    abs = 1;                    % housekeeping variable
    delta = zeros(absT,1);      % initialize RPE
    for iter = 2:numIter
        for yi = 1:n-1
            abs=abs+1;
            Vh(yi,iter) = w(abs-1,:)*x(yi,:)';
            delta(abs)=r(yi)+gamma*Vh(yi+1,iter-1)-Vh(yi,iter);
            w(abs,:) = max(w(abs-1,:)+alpha*delta(abs)*x(yi,:),0);
        end
    end
    w = w(.9*end,:);           	% w on convergence
    Vh = w*x'; Vh(1:cs*n) = 0;	% Vh based on converged w
    d = r(1:end-1)'+gamma*Vh(2:end)-Vh(1:end-1);
 
    t = 100*t/max(t);           % align all three curves by the CS
    
    subplot(2,1,1)
    h(nInd) = plot(t,Vh,'Color',col(nInd,:));
    hold on
    scatter(t,Vh,'MarkerEdgeColor',col(nInd,:))
    hold on
    if nInd == 1; ylim([-.01,1.2*max(Vh)]); end
    
    subplot(2,1,2)
    plot(t(1:end-1),d,'Color',col(nInd,:))
    hold on
    scatter(t(1:end-1),d,'MarkerEdgeColor',col(nInd,:))
    hold on
    if nInd == 1; ylim([-.005,1.2*max(d)]); end
    
end

subplot(2,1,1)
ylabel('Value','FontSize',labelFont)
lgd=legend(h,{'Low DA','Baseline DA','High DA'}, 'Location', 'Northwest');
lgd.FontSize = lgdFont;

subplot(2,1,2)
ylabel('RPE','FontSize',labelFont)
yticks([0 .1 .2 .3])

for e = 1:2
    subplot(2,1,e)
    xlim([0 max(t)])
    xlabel('Objective Time','FontSize',labelFont)
end
