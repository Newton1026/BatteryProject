%{
    This source code implements the functions for Kinetic Battery Model (KiBaM), as
    described in [Battery Modeling - M. R. Jongerden and B. R. Haverkort].

    Author: Leonardo Martins Rodrigues.
    Date of creation: 09-04-2014 - Version: 1.0

	KiBaM has the bound charge well and the available charge well.
	Note:	'c', 'k', 'i0, 'j0', 't0', 'task_i' and 'task_t' are the function parameters.
			'i0', 'j0' and 't0' are the function returned values.
			'c' and 'k' are constants related to the KiBaM.
%}
    
function [i0, j0, t0] = kibamT (c, k, i0, j0, t0, task_i, task_t)
	
	% Defining variables.
	I = task_i;   % Discharge current.
	t = task_t;   % Execution time of I.
	y0 = i0 + j0; % The initial battery capacity.
    
	t0 = t0 + (task_t);   % Total lifetime.
	
	% Calculating the available charge on the wells.
	i = (i0 * exp(- k * t)) + ((((y0 * k * c) - I)*(1 - exp(- k * t))) / k) - (I * c * ((k * t) - 1 + exp(- k * t)) / k);
	j = (j0 * exp(- k * t)) + (y0 * (1 - c) * (1 - exp(- k * t))) - ((I * (1 - c) * ((k * t) - 1 + exp(- k * t))) / k);

	% Updating the content of the two wells.
	i0 = i;
	j0 = j;
		
end