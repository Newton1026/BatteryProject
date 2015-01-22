%{
    Script to run lifetime estimation of a Li-ion Battery.
    "An Analitical High-Level Battery Model for Use in
    Energy Management of Portable Eletronic Systems" by
    by Rakhmatov and Vrudhula
    
    Author: Leonardo Martins Rodrigues.
    Date: 27/10/2014.
    
    Notes:
    1) Original constants values (Li-ion Battery):
        alpha (or 'a') = 271.47
        beta (or 'B')= 10.39

    2) Parameters:
        Si = Current Profile
        St = Times of Currents
        alpha
        beta
%}


% Defining the constants.
a = 271.47;
B = 10.39;

% Defining the current profile.
Si = [20 15 10 5 9.6];   % The currents (in A/m^2).
St = [0  1  2  3 4];   % The time (in minutes) grows (See Fig. 2 of the original paper).

% for i = 1:length(Si)
	f_LE (Si, St, a, B);
	% if(length(Si) > 2)
		% Si(1) = [];
		% St(1) = [];
	% endif
% endfor