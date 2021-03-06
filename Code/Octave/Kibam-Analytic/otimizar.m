function [x,resnorm,residual,exitflag,output,lambda,jacobian] = otimizar(x0,xdata,ydata,lb,ub)
%% This is an auto generated MATLAB file from Optimization Tool.

%% Start with the default options
options = optimoptions('lsqcurvefit');

alg = 'levenberg-marquardt'; % 'trust-region-reflective' or 'levenberg-marquardt'.

if(strcmp(alg,'levenberg-marquardt'))
    % This is necessary since this algorithm does not handle bound
    % constraints.
    lb = [];
    ub = [];
end

%% Modify options setting
options = optimoptions(options,'Display', 'off');
options = optimoptions(options,'Algorithm', alg);
[x,resnorm,residual,exitflag,output,lambda,jacobian] = ...
lsqcurvefit(...
    @(x,xdata)(xdata(:,1)./xdata(:,2)).*(( ((1-exp(-x(2).*xdata(:,2))).*(1-x(1)))+(x(2).*x(1).*xdata(:,2)) )./( ((1-exp(-x(2).*xdata(:,1))).*(1-x(1)))+(x(2).*x(1).*xdata(:,1)) )),...
    x0,...
    xdata,...
    ydata,...
    lb,...
    ub,...
    options...
);
