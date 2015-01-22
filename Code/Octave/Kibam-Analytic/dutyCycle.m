%{
    This source code defines the main informations for Duty Cycle analysis.

    Author: Leonardo Martins Rodrigues.
    Date of creation: 04-04-2014 - Version: 1.0
	Last modification: 22-04-2014

	Execution instructions (terminal/console):
	1) Access the folder where the files are located. For example:
		$ cd /Users/YourUser/Desktop/Simulation
	2) Call 'octave'.
		$ octave
	3) Call the name of this script.
		octave:1> dutyCycle
	4) To log out, just type 'quit'.
		octave:2> quit

	Notes:
		1)	1 A = 1 C/s (Coulomb/second) .:. 1 As = 1 C
			3600 As = 1 Ah = 1000 mAh .:. 7200 As = 2 Ah = 2000 mAh
%}

	% Discovering the simulation time. Getting the time at the beggining of the simulation.
	time_before = time();	% in seconds.

	% ############################################################################################
	% Setting the initial KiBaM Parameters (all nodes with the same values).
	y0 = 1800;				% Initial charge in the battery (Available+Bound Charge Wells), in As.
	c = 0.625;				% The constant that defines the fraction in Available Charge Well.
	k = 0.00001;			% in min^(-1).
	acwMinLevel = 5;		% This value defines when the battery will stop to work ...
							% ... (acw -> Available Charge Well).

	% ############################################################################################
	% Setting the nodes in the simulation and their fields.
	nodes = 1;
	for z = 1:nodes
		n(z).id = z;		% Node Id.
		n(z).t0 = 0.0;		% Initial Time (in seconds).
		n(z).y0 = y0;		% Initial Battery Capacity.
		n(z).i0 = (c)*y0;	% Initial Capacity at Available Well. Constant value.
		n(z).j0 = (1-c)*y0;	% Initial Capacity at Bound Well. Constant value.
		n(z).i = n(z).i0;	% Actual Capacity at Available Well.
		n(z).j = n(z).j0;	% Actual Capacity at Bound Well.
		n(z).soc = 100.0;	% Initial State of Charge (SoC).
		n(z).fid = 0;		% Node File Descriptor.
	endfor
	
	% ############################################################################################
	% Cleaning any existent files.
	for z = 1:nodes
		if (exist([int2str(z) ".txt"]))
			[err, msg] = unlink([int2str(z) ".txt"]);
		endif
	endfor
	
	% Creating files (one to each node).
	for z = 1:nodes
		filename = [int2str(z) ".txt"];
		n(z).fid = fopen (filename, "a");
	endfor

	% ############################################################################################
	% Duty Cycle specifications.
	aBaseSuperframeDuration = 0.01536;			% in seconds.
	Bo = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14];	% Beacon Order.
	So = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14];	% Superframe Order.
	
	% 01: 0.01536 -> exp: 0
	% 02: 0.03072 -> exp: 1
	% 03: 0.06144 -> exp: 2
	% 04: 0.12288 -> exp: 3
	% 05: 0.24576 -> exp: 4
	% 06: 0.49152 -> exp: 5
	% 07: 0.98304 -> exp: 6
	% 08: 1.96608 -> exp: 7
	% 09: 3.93216 -> exp: 8
	% 10: 7.86432 -> exp: 9
	% 11: 15.72864 -> exp: 10
	% 12: 31.45728 -> exp: 11
	% 13: 62.91456 -> exp: 12
	% 14: 125.82912 -> exp: 13
	% 15: 251.65824 -> exp: 14

	% 0 <= SO <= BO <= 14.
	Bi = aBaseSuperframeDuration * 2^(Bo(15));
	Sd = aBaseSuperframeDuration * 2^(So(10));
	
	t_opr = Sd;			% Time in operation (in seconds).
	t_slp = Bi - Sd;	% Time in Sleep Mode (in seconds).
	% printf("\n	Beacon Interval: %f | Superframe Duration: %f", Bi, Sd);
	
	% ############################################################################################
	% Defining Charges and its times.
	A = [0.040, 10.00];	% [current, time_of_operation]. Relative to a Tx Task.
	B = [0.020, 2.00];	% [current, time_of_operation]. Relative to a Rx Task.
	C = [0.0005, 10.00];	% [current, time_of_sleep]. Relative to Sleep Mode.
	
	% Defining the tasks array. One for charge and other for time.
	% task_i = [A(1), C(1)];	% [A(1), B(1), C(1)];
	% task_t = [A(2), C(2)];	% [A(2), B(2), C(2)];
	
	% Special run.
	task_i_array1 = [A(1), A(1), C(1), C(1), C(1), C(1), C(1), C(1), C(1), C(1)];
	task_t_array1 = [A(2), A(2), C(2), C(2), C(2), C(2), C(2), C(2), C(2), C(2)];
	
	task_i_array2 = [A(1), C(1), C(1), C(1), C(1), A(1), C(1), C(1), C(1), C(1)];
	task_t_array2 = [A(2), C(2), C(2), C(2), C(2), A(2), C(2), C(2), C(2), C(2)];
	
	
	printf("\n	Charges: ");
	for y = 1:length(task_i)
		printf("%f ", task_i(y));
	endfor
	printf("\n");
	
	% ############################################################################################
	% Main loop #1 (Execute until the battery reaches 'acwMinLevel').
	while (n(z).i > acwMinLevel)
		for z = 1:nodes

			% for y = 1:length(task_i)
			% 	[n(z).y0, n(z).i, n(z).j, n(z).t0] = kibam (c, k, n(z).y0, n(z).i, n(z).j, n(z).t0, task_i(y), task_t(y), n(z).fid);
			%
			% 	% Updating the SoC value.
			% 	n(z).soc = 100.0 * (n(z).i / n(z).i0);
			%
			% 	fprintf(n(z).fid, "%f %f %f %f\n", n(z).t0/60, n(z).i, n(z).soc, task_i(y));
			% endfor
			
			
			% Special Run.
			choice = 1;
			color = "b";
			if(choice == 1)
				hold off;
				for y = 1:length(task_i_array1)
					[n(z).y0, n(z).i, n(z).j, n(z).t0] = kibam (c, k, n(z).y0, n(z).i, n(z).j, n(z).t0, task_i_array1(y), task_t_array1(y), n(z).fid);

					% Updating the SoC value.
					n(z).soc = 100.0 * (n(z).i / n(z).i0);

					fprintf(n(z).fid, "%f %f %f %f\n", n(z).t0/60, n(z).i, n(z).soc, task_i_array1(y));
				endfor
			else
				color = "m";
				for y = 1:length(task_i_array2)
					[n(z).y0, n(z).i, n(z).j, n(z).t0] = kibam (c, k, n(z).y0, n(z).i, n(z).j, n(z).t0, task_i_array2(y), task_t_array2(y), n(z).fid);

					% Updating the SoC value.
					n(z).soc = 100.0 * (n(z).i / n(z).i0);

					fprintf(n(z).fid, "%f %f %f %f\n", n(z).t0/60, n(z).i, n(z).soc, task_i_array2(y));
				endfor
			endif


			% % Scenario #1.
			% % Executing the charges.
			% if((n(z).t0 >= 1200 && n(z).t0 < 2400))
			% 	[n(z).y0, n(z).i, n(z).j, n(z).t0] = kibam (c, k, n(z).y0, n(z).i, n(z).j, n(z).t0, task_i(1), task_t(1), n(z).fid);
			% else
			% 	[n(z).y0, n(z).i, n(z).j, n(z).t0] = kibam (c, k, n(z).y0, n(z).i, n(z).j, n(z).t0, task_i(2), task_t(2), n(z).fid);
			% endif
			%
			% % Updating the SoC value.
			% n(z).soc = 100.0 * (n(z).i / n(z).i0);
			%
			% fprintf(n(z).fid, "%f %f %f\n", n(z).t0/60, n(z).i, n(z).soc);

			% % Scenario #5.
			% % Executing the charges.
			% if((n(z).t0 >= 0 && n(z).t0 < 36000))
			% 	[n(z).y0, n(z).i, n(z).j, n(z).t0] = kibam (c, k, n(z).y0, n(z).i, n(z).j, n(z).t0, task_i(2), task_t(2), n(z).fid);
			% else
			% 	if((n(z).t0 >= 36000 && n(z).t0 < (36000 + 18000)))
			% 		[n(z).y0, n(z).i, n(z).j, n(z).t0] = kibam (c, k, n(z).y0, n(z).i, n(z).j, n(z).t0, task_i(3), task_t(3), n(z).fid);
			% 	else
			% 		[n(z).y0, n(z).i, n(z).j, n(z).t0] = kibam (c, k, n(z).y0, n(z).i, n(z).j, n(z).t0, task_i(1), task_t(1), n(z).fid);
			% 	endif
			% endif
			%
			% % Updating the SoC value.
			% n(z).soc = 100.0 * (n(z).i / n(z).i0);
			%
			% fprintf(n(z).fid, "%f %f %f\n", n(z).t0/60, n(z).i, n(z).soc);

		endfor
	endwhile
	
	% % Main loop #2 (Perform the tasks only once).
	% % Scenario #4.
	% for z = 1:nodes
	% 	fprintf(n(z).fid, "%f %f %f\n", n(z).t0/60, n(z).i, n(z).soc);
	%
	% 	for y = 1:length(task_i)
	% 		[n(z).y0, n(z).i, n(z).j, n(z).t0] = kibam (c, k, n(z).y0, n(z).i, n(z).j, n(z).t0, task_i(y), task_t(y), n(z).fid);
	%
	% 		% Updating the SoC value.
	% 		n(z).soc = 100.0 * (n(z).i / n(z).i0);
	%
	% 		fprintf(n(z).fid, "%f %f %f\n", n(z).t0/60, n(z).i, n(z).soc);
	% 	endfor
	% endfor
	
	
	
	% Closing all opened files.
	for z = 1:nodes
		fclose(n(z).fid);
	endfor

	% ############################################################################################
	% Plotting information from files.
	% hold off;
	
	for z = 1:nodes
		a = load([int2str(n(z).id) ".txt"]);
		if (z == 1)
			plot(a(:,1), a(:,2), color, 'linestyle', "-", 'linewidth', 0.4);
		else
			plot(a(:,1), a(:,2), "g", 'linestyle', "-", 'linewidth', 0.4);
		endif
		hold on;
	endfor
	
	grid on;
	axis([0 7000 0 2500], "manual");
	
	title ("Descarga no tanque Carga Disponivel");
	hx = get (gca, 'title');
	set (hx, 'color', [1 0 0], 'fontsize', 16, 'fontname', 'Helvetica'); 
	
	xlabel ("Tempo (min)");
	hx = get (gca, 'xlabel');
	set (hx, 'color', [1 0 0], 'fontsize', 14, 'fontname', 'Helvetica'); 
	
	fixAxes;
	
	% ############################################################################################
	% Getting the time at the ending of the simulation.
	time_after = time();
	time_sim = time_after - time_before;
	
	% Showing statistics.
	printf("\n	ID | Lifetime (min)	  (horas) | Execution Time (seg)     (min)\n");
	% Showing some informations on the terminal.
	for z = 1:nodes
		printf("	%d	%f 	%f		%f  %f\n", n(z).id, n(z).t0/60, n(z).t0/3600, time_sim, time_sim/60);
	endfor
	printf("\n");
	
	% Showing statistics (SoC).
	printf("\n	ID |	SoC (%%)\n");
	for z = 1:nodes
		printf("	%d	%f\n", n(z).id, n(z).soc);
	endfor
	printf("\n");
	% ############################################################################################