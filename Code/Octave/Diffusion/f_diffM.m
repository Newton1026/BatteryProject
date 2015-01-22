%{
    This source code implements the functions for Diffusion Model, as
    described in [Which Battery Model to Use - M. R. Jongerden and B. R. Haverkort].

    Author: Leonardo Martins Rodrigues.
    Date of creation: 13-08-2014 - Version: 1.0

	Diffusion Model (Apparent Charge Lost = sigma).
	sigma = charge lost to the load (l) + unavailable charge (u);

	OBS.:
		% KiBaM (Apparent Charge Lost = sigma).
		% sigma = charge lost to the load (l) + unavailable charge (u)
		c = 0.166;
		k = 0.0167;

		l_KiBaM = I*tl;
		u_KiBaM = ((1-c)*I/c)*((1-exp(- kl * tl))/kl);
		sigma_KiBaM = l_KiBaM + u_KiBaM;

%}

function [sigma_diffM, t0] = diffM (task_i, task_t, beta_diffM, idle_t, t0)
	
	% Defining variables.
	B = beta_diffM;
	I = task_i;
	
	% Normal task.
	if(idle_t == 0)
		t = (t0 + task_t);
		sum = 0.0;
	
		for m = 1:10
			sum = sum + ((1 - exp(- B^2 * m^2 * t))/(B^2 * m^2));
		endfor
		t0 = t0 + task_t;
		l_diffM = I*t;
	
	% Sleep task.
	else
		tl = task_t;
		ti = t0 + idle_t;
		sum = 0.0;
	
		for m = 1:10
			sum = sum + (((exp(- B^2 * m^2 * ti))*(1 - exp(- B^2 * m^2 * tl)))/(B^2 * m^2));
		endfor
		t0 = t0 + idle_t;
		l_diffM = I*ti;
	endif
	
	u_diffM = 2*I*sum;
	
	% Returning values;
	sigma_diffM = (l_diffM + u_diffM);
		
endfunction