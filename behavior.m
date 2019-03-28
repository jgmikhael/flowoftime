% This code simulates the results of behavioral experiments examining the
% effects of external reward rate on the internal clock (Killeen &
% Fetterman, 1988; Morgan et al., 1993).
% Written 14Nov18 by JGM.

clear; close all; clc
set(0,'DefaultFigureWindowStyle','docked')
set(groot,'defaultLineLineWidth',2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = 80;             % number of states (also max subjective time)
y = 1:n;            % subjective time
sigma = 10;         % width of features against subjective time
power = .7;         % compression factor: y = eta*t^power
gamma = .9;         % discount factor
r0 = 1;             % reward size

% x(i,j) = (time i, feature j)
x = normpdf(y,y',sigma); x = x/max(x(:));

% define baseline Yb, Tb, eta
Yb = 40;                 % baseline reward time (subjective)
Tb = 30;                 % baseline reward time (objective)
etab = Yb/Tb^power;      % baseline eta: Y = eta*T^power

Vh = TD(n,Yb,sigma,gamma);

tL = [25:35, Tb, Tb]; % list of probe reward times
%                               1:n-2 are for Killeen & Fetterman (1988)
%                               n-1:n are for Morgan et al. (1993)
l = length(tL);

% for Morgan et al. (1993), define fast (T-comp), slow (T+comp) conditions
comp = 3;  % initialize T+/-comp, and learn to converge to T

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eta0 = etab*ones(1,l);     % initial eta in each task; 
                                % ... last two will be updated below
etaL = zeros(1,l);         % final eta in each task

for e = 1:l % for each reward time (i.e., for each task)

    % identify T and initial eta
    T = tL(e);
    eta = eta0(e);
    
    % compute evolution of eta under reward at T
    et = TDeta(n,T,eta,power,Vh,1,gamma);
   
    % store evolution of eta's in master matrix
    etaEvol(:,e) = et; % etaEvol(i,j) = (eta at timestep i, task j)
    
    % final eta is the stochastic fixed point
    et(et==0)=[];                       
    eta = mode(round(et*100))/100;
    etaL(e) = eta;
  
    % for Morgan et al. (1993), use data from Killeen & Fetterman (1988) to
    % determine what the initial eta should be for each of slow and fast
    % condition
   if T == tL(end-1)-comp && e < length(tL)-1
        eta0(end-1) = eta;
    elseif T == tL(end-1)+comp && e < length(tL)-1
        eta0(end) = eta;
   end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)

labelFont = 13; lgdFont = 11;       % define font sizes

subplot(2,2,1)
image(imread('placeholder.png'));

subplot(2,2,2)
image(imread('placeholder.png'));

for e = 1:2
    subplot(2,2,e)
    set(gca,'xtick',[])
    set(gca,'ytick',[])
end

subplot(2,2,3)
rd = 1./tL(1:end-2); % reward density
scatter(rd, etaL(1:end-2),'k')
ylabel('Pacemaker Rate (\eta)','FontSize',labelFont)
xlabel('Reinforcement Density','FontSize',labelFont)
xlim([min(rd) max(rd)])

subplot(2,2,4)
eSparse = etaEvol(1:35:180,end-1:end); % sparsify for Morgan et al. (1993)
scatter(0:length(eSparse)-1,eSparse(:,1),'k','filled')
hold on
scatter(0:length(eSparse)-1,eSparse(:,2),'k')
lgd = legend('Fast Bias','Slow Bias');
lgd.FontSize = lgdFont;
xlabel('Time','FontSize',labelFont)
ylabel('Pacemaker Rate (\eta)','FontSize',labelFont)
