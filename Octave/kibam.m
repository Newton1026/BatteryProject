% This model uses KiBaM Battery Model with the bound charge well and the available charge well.
% Note: 'y0', 'current', 't0', 'timePeriod' and 'showPlot' are the function parameters.
%		'y0' is the function return value.

function [y0, i0, j0] = kibam (y0, i0, j0, current, t0, timePeriod, showPlot, fid)

	% Defining constants.
	c = 0.625;		% Original Value: 0.625
	k = 0.00001;	% in min^(-1).
	t_min = 60;
	
	% Defining variables.
	I = current;
	y0 = i0 + j0;
	
	% Calculating k' (k_ in this case) as described in [Jongerden - Battery Model].
	k_ = k / (c * (1-c));
	
	for(t = t0/t_min: 0.01: timePeriod/t_min)
		i = (i0 * exp(- k_ * t)) + ((((y0 * k_ * c) - I)*(1 - exp(- k_ * t))) / k_) - (I * c * ((k_ * t) - 1 + exp(- k_ * t)) / k_);
		fprintf(fid, "%f %f\n", t, i);	
		j = (j0 * exp(- k_ * t)) + (y0 * (1 - c) * (1 - exp(- k_ * t))) - ((I * (1 - c) * ((k_ * t) - 1 + exp(- k_ * t))) / k_);
	endfor
	
	i0 = i;
	j0 = j;
		
endfunction