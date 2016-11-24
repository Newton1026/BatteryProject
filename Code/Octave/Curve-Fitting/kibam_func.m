% Function used least square curve fitting.
function [I] = kibam_func(t,par)
	par(1) = par(1)/(par(2)*(1-par(2)));		% k = k'/c(1-c);
	I = (par(1)*par(2)*par(3)) / (1-exp(-par(1)*t)+(par(2)*(par(1)*t - 1 + exp(-par(1)*t))));
end