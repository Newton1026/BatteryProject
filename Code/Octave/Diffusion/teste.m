	% Defining variables.
	B = 0.11825;					% Original Value: 0.273;
	I = 0.04; 		        % A
	t = 0.00;		          % min
	sum = 0.0;
	sigma_diffM = 0.0;
	
	hold off;
	for t = 0:99
	% while sigma_diffM < 60 % A.min

		sum = 0.0;
		for m = 1:10
			sum = sum + ((1 - exp(- B^2 * m^2 * t))/(B^2 * m^2));
			% sum = sum + (((exp(- B^2 * m^2 * ti))*(1 - exp(- B^2 * m^2 * tl)))/(B^2 * m^2));
		endfor

		l_diffM = I*t;
		u_diffM = 2*I*sum;

		% Returning values;
		sigma_diffM = (l_diffM + u_diffM);

		plot(t,sigma_diffM,".");
		hold on;

		% t+=1;
	% endwhile
	endfor

	tl = t + 1;
	
	for ti = 100:299
	% while sigma_diffM < 60 % A.min
		
		sum = 0.0;
		for m = 1:10
			% sum = sum + ((1 - exp(- B^2 * m^2 * t))/(B^2 * m^2));
			sum = sum + (((exp(- B^2 * m^2 * ti))*(1 - exp(- B^2 * m^2 * tl)))/(B^2 * m^2));
		endfor

		l_diffM = (I*ti);
		u_diffM = (2*I*sum);
	
		% Returning values;
		sigma_diffM = (l_diffM + u_diffM);
	
		plot(ti,sigma_diffM,".");
		hold on;
		
		% t+=1;
	% endwhile
	endfor
	
	ti