%{
    This source code defines the main informations for Markov Chain KiBaM analysis.

    Author: Leonardo Martins Rodrigues.
    Date of creation: 20-08-2014 - Version: 1.0
	Last modification: 20-08-2014

	Execution instructions (terminal/console):
	1) Access the folder where the files are located. For example:
		$ cd /Users/YourUser/Desktop/Simulation
	2) Call 'octave'.
		$ octave
	3) Call the name of this script.
		octave:1> kibamMarkov
	4) To log out, just type 'quit'.
		octave:2> quit

	Notes:
		1)	1 A = 1 C/s (Coulomb/second) .:. 1 As = 1 C
			3600 As = 1 Ah = 1000 mAh .:. 7200 As = 2 Ah = 2000 mAh
%}

hold off; % setenv("GNUTERM","x11");
grid on;

printf("\nDefining KiBaM variables...");
t = 0;					% The simulation time (in s).
window = 10;			% The discrete time interval.
cutoff = 10;			% The minimum level of charge in the battery.
y0 = 3600; 				% The total battery capacity (in As).
c = 0.625;				% The fraction available in the Available Charge Well.
k = 0.0001;				% The constant used to control de flux between the two wells.
kl = k / (c * (1-c));
acw_i = y0 * (c);		% The Available Charge Well.
bcw_j = y0 * (1-c);		% The Bounded Charge Well.
h_1 = acw_i;			% The height of the charge on Available Charge Well.
h_2 = bcw_j;			% The height of the charge on Bounded Charge Well.
q_I = 0.950;			% The probability that in one time unit, I charge units are demanded.
q_0 = 1 - q_I;			% The probability that an idle slot occurs.
p_t = 0.80;				% The probability to recover with time during an idle slot.
disp("Done!")



printf("\nDefining Markov variables...");
state = [acw_i, bcw_j, t];
plot(state(3),state(1),".");
hold on;
disp("Done!")



printf("\nStarting simulation...");				

while(state(1) >= cutoff)
	% Set the current I of the model.
	if(state(3) > 1200 && state(3) < 2400)
		c_I = 0.0005;
	else
		c_I = 0.5;
	endif
	
	% The quanta of charge the battery can recover.
	Q = (1.05-c_I)^2;
	
	% Stabilize the charge over the two wells.
	r_J = kl * h_2 * (h_2 - h_1);
	
	% Sort some random number between 0 and 1.
	shouldApply_I = rand(1);

	% Run the discharge current...
	if(shouldApply_I <= q_I)
		acw_i = acw_i - c_I + r_J;
		bcw_j = bcw_j - r_J;
		t = t + 1;
	% Run an idle slot...
	else
		shouldRecover = rand(1)*0.25;
		% With recover? Yes...
		if(shouldRecover <= q_0*p_t)
			acw_i = acw_i + Q;
			bcw_j = bcw_j - Q;
			t = t + 1;
		% With recover? No...
		% else
		% 	t = t + 1;
		endif
	endif

	h_1 = acw_i;
	h_2 = bcw_j;
	
	state = [acw_i, bcw_j, t];
	if(mod(state(3),window)==0)
		plot(state(3)/60,state(1),".");
		hold on;
	endif

endwhile
disp("Done!\n")

printf("Tempo: %f seg | %f min | %f h\n",state(3),state(3)/60,state(3)/3600);