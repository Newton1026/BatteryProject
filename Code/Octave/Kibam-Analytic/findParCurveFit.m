% fun = @(x,xdata) (xdata(:,1)./xdata(:,2)) .* ( ((1-exp(-x(2).*xdata(:,2))).*(1-x(1))+(x(2).*x(1).*xdata(:,2))) ./ ((1-exp(-x(2).*xdata(:,1))).*(1-x(1))+(x(2).*x(1).*xdata(:,1))));

temperature = 25;

if(temperature == -5)
    % -5?C
    t1 = [72.31	753];  % slow discharge curve.
    t2 = [36.54	741];  % middle discharge curve.
    t3 = [23.99	725];  % fast discharge curve.
end

if(temperature == 25)
    % 25?C
    t1 = [73.88	770];  % slow discharge curve.
    t2 = [37.36	758];  % middle discharge curve.
    t3 = [24.63	744];  % fast discharge curve.
end

xdata = [t2(1) t1(1); t3(1) t1(1)];
ydata = [t2(2)/t1(2); t3(2)/t1(2)];
x0 = [0.98 0.0001];         % Initial guess for 'c' and 'k' parameters.

% Used only with 'trust-region-reflective' algorithm.
lb = [0.01, 0.00000000001]; % Lower bounds.
ub = [0.99, 0.99];         % Upper bounds.

x = otimizar(x0,xdata,ydata,lb,ub);
format long;
fprintf('\n  |           Temperature = %d          |\n', temperature);
disp('  |        c         |         k        |');
fprintf('  |%.15f | %.15f|\n\n', x(1),x(2));