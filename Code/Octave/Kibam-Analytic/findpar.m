%{
    This source code implements the functions for finding parameters in KiBaM, as
    described in [Lead Acid Battery Storage Model For Hybrid Energy Systems - J. F.
	Manwell and J. G McGowan].

    Author: Leonardo Martins Rodrigues.
    Date of creation: 17-06-2015 - Version: 1.0

	KiBaM has the bound charge well and the available charge well.
	Note: 'c' and 'k' are constants related to the KiBaM.
%}

function [c] = findpar (k, Ft, t1, t2)
	
	% Calculating the value of the 'c' parameter.
	c = ( (Ft*(1-exp(-k*t1))*t2) - ((1-exp(-k*t2))*t1) )/( (Ft*(1-exp(-k*t1))*t2) - ((1-exp(-k*t2))*t1) - (k*Ft*t1*t2) + (k*t1*t2) );

end