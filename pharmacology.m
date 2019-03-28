% This code simulates the pharmacological effects of DA agonists and
% antagonists on timekeeping in a reproduction task in humans (Lake & Meck,
% 2013).
% Written 12Nov18 by JGM.

clear; close all; clc
set(0,'DefaultFigureWindowStyle','docked')
set(groot,'defaultLineLineWidth',2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = 80;             	% number of states (also max subjective time)
power = .7;           	% compression factor: y = eta*t^power
y = (1:n)';          	% subjective time, which represents the states
t = y.^(1/power);     	% objective time
sigma = 5;           	% width of features against subjective time
alphaE = 20;          	% learning rate for eta (does not have to be 
%                         	<1; only full term multiplying delta does)
gamma = .9;         	% discount factor
tTot = 35;            	% total objective duration length for placebo

% x(i,j) = (time i, feature j)
x = normpdf(y,y',sigma); x = x./max(x);

% find baseline eta so y=1:n maps to the range t=(0,40)
eta = n/tTot^power;

% define gain modulation of positive RPEs for [high, low, baseline] tonic
% DA, and let (gain for negative RPEs) = 1/(gain for positive RPEs)
gainList = [5 .2 1];
l = length(gainList);

Tl = [7 17];
eta_end = zeros(2,l);
for e = 1:2

    T = Tl(e);                  % objective duration of timed interval
    Y = floor(eta*T^power);     % subjective duration of timed interval
    
    % Vh against subjective time y
    Vh = TD(n,Y,sigma,gamma);
    delta = gamma*Vh(2:end)-Vh(1:end-1);
    
    % produced duration ends after peak of Vh is reached,
    % so set delta to 0 after the peak
    [~, peak] = max(Vh);
    delta(peak+1:end) = 0;
    
    % define effective RPEs (i.e., delta after gain modulation)
    mod = ((delta>0)*gainList+(delta<0)*(1./gainList));
    dList = mod.*(delta*ones(1,3));
    
    % compute total change in eta, according to the approximation
    Vdot = Vh(2:end)-Vh(1:end-1);   % dV/dy
    dEta = alphaE*sum(dList.*((y(1:end-1).*Vdot)*ones(1,3)))./eta;
    eta_end(e,:) = eta + dEta;
    
end

% define baseline y_7 & y_17 corresponding to t = 7 & t = 17; note that
% these are distinct from the original Y, as non-zero RPEs leading up to Y
% will create a bias that has to be corrected by the agent
y7 = floor(eta_end(1,3)*7^power);
y17 = floor(eta_end(2,3)*17^power);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)

labelFont = 13; lgdSize = 10;       % define font sizes
col = [.7 .7 .7; .3 .3 .3; 0 0 0];  % define color scheme

subplot(2,1,1)
image(imread('placeholder.png'));
set(gca,'xtick',[])
set(gca,'ytick',[])

subplot(2,1,2)

for g = 1:l
    t1 = (y./eta_end(1,g)).^(1/power);
    plot(t1,x(:,y7),'Color',col(g,:),'LineStyle','--')
    hold on
end

for g = 1:l
    t1 = (y./eta_end(2,g)).^(1/power);
    if g == 3
       plot([t1; 40],[x(:,y17); 0],'Color',col(g,:))
       % (this extrapolates for untested domain of placebo, i.e., 40)
    else
        plot(t1,x(:,y17),'Color',col(g,:))
    end
    hold on
end

xlim([0 40])
xticks(5*(0:8))
xlabel('Time (s)','FontSize',labelFont)
ylabel('Temporal Estimate','FontSize',labelFont)
lgd = legend('7-s, high DA', '7-s, low DA', '7-s, placebo',...
    '17-s, high DA', '17-s, low DA','17-s, placebo');
lgd.FontSize = lgdSize;
