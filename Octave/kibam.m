%{
    This source code implements the functions for Kinetic Battery Model (KiBaM), as
    described in [Battery Modeling - M. R. Jongerden and B. R. Haverkort].

    Author: Leonardo Martins Rodrigues.
    Date of creation: 15-03-2014 - Version: 1.0

	KiBaM has the bound charge well and the available charge well.
	Note:	'c', 'k', 'y0', 'i0, 'j0', 'current', 't0', 'timePeriod', 'showPlot' and 'fid' are the function parameters.
			'y0', 'i0' and 'j0' are the function return values.
			'c' and 'k' are related to the KiBaM.
%}

function [y0, i0, j0] = kibam (c, k, y0, i0, j0, current, t0, timePeriod, showPlot, fid)

	% Defining constants.
	t_min = 60;
	
	% Defining variables.
	I = current;
	y0 = i0 + j0;
	
	% Calculating k' (k_ in this case) as described in [Jongerden - Battery Model].
	k_ = k / (c * (1-c));
	
	% Calculating the available charge on the wells.
	for(t = t0/t_min : 0.01 : timePeriod/t_min)
		i = (i0 * exp(- k_ * t)) + ((((y0 * k_ * c) - I)*(1 - exp(- k_ * t))) / k_) - (I * c * ((k_ * t) - 1 + exp(- k_ * t)) / k_);
		fprintf(fid, "%f %f\n", t, i);	% This line only writes the Available Charge Well state.
		j = (j0 * exp(- k_ * t)) + (y0 * (1 - c) * (1 - exp(- k_ * t))) - ((I * (1 - c) * ((k_ * t) - 1 + exp(- k_ * t))) / k_);
		% fprintf(fid, "%f %f %f\n", t, i, j);	% This line writes the Available and Bound Charge Well state. If used, please comment the previous fprintf line.
	endfor

	% Updating the content of the two wells.
	i0 = i;
	j0 = j;
		
endfunction