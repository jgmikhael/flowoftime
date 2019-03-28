% This code updates the pacemaker rate eta based on the bidirectional
% learning rule.
% Written 6Nov18 by JGM.

function et = TDeta(n,T,eta,power,Vh,r0,gamma)

% inputs
%   n: number of states                                 (1x1)
%   T: (objective) time of reward delivery              (1x1)
%   eta: initial eta                                    (1x1)
%   power: compression factor (y = eta*t^power)         (1x1)
%   Vh: estimated value function                        (nx1)
%   r0: reward magnitude                                (1x1)
%   gamma: discount factor                              (1x1)

% output
%   eta: evolution of eta during learning               (nx1)

numIter = 300;              % number of trials
absT = numIter*n;           % housekeeping variable
r = zeros(1,n);             % housekeeping for reward schedule
alphaE = 1;                 % learning rate for eta (need not be < 1)
Y = floor(eta*T.^power);    % subjective reward time

% update eta
et = zeros(absT,1);
abs = 0;
for iter = 1:numIter        % for each trial
    for yi = 1:n-1          % for each timepoint within that trial
        if yi<Y+1           % only if haven't gotten reward yet
            abs = abs+1;
            
            % update eta
            delta = r(yi)+gamma*Vh(yi+1)-Vh(yi);
            
            Vdiffy=[(diff(Vh(1:end-1))+diff(Vh(2:end)))/2;0;0]; % dV/dy
            eta = max(0,eta+alphaE*yi*Vdiffy(yi)*delta/eta);

            % update Y and reward schedule
            Y = floor(eta*T.^power);
            r = zeros(1,n); r(Y) = r0;
            
            % store new eta
            et(abs) = eta;     
        end
    end
end

end