% This code computes the learned weights and estimated value under the TD
% model, using a temporal basis set specified by the input sigma.
% Written 6Nov18 by JGM. 

function [Vh, w] = TD(n,Y,sigma,gamma)

% inputs
%   n: number of states                                 (1x1)
%   Y: (subjective) time of reward delivery             (1x1)
%   sigma: width of features against subjective time    (1x1)
%   gamma: discount factor                              (1x1)

% outputs
%   Vh: estimated value ("V_hat")                       (nx1)
%   w: learned weights                                  (nx1)

% Note: Assumes reward of magnitude 1

y = (1:n)';                 % subjective time, also the means of states
alpha = .1;                 % learning rate of w
numIter = 1000;             % number of trials
absT = n*numIter;           % housekeeping variable

% define reward schedule
r = zeros(n,1); r(Y) = 1;   % rewards received in each state

% create x:                 x(i,j) = (subjective time i, feature j)
x = normpdf(y,y',sigma);

% initialize w, Vh, delta
w = zeros(absT,n);           
Vh = zeros(n,numIter);
delta = zeros(absT,1);

% learning w
abs = 1;
for iter = 2:numIter
    for yi = 1:n-1  
        abs=abs+1;            
        Vh(yi,iter) = w(abs-1,:)*x(yi,:)';  
        delta(abs) = r(yi) + gamma*Vh(yi+1,iter-1) - Vh(yi,iter);
        w(abs,:) = max(w(abs-1,:) + alpha*delta(abs)*x(yi,:),0);
    end   
end

% record outputs
w = w(.9*end,:); 
Vh = Vh(:,end-1);

end