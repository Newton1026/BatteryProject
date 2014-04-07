%{
    This source code defines the main informations for Duty Cycle analisys.

    Author: Leonardo Martins Rodrigues.
    Date of creation: 04-04-2014 - Version: 1.0

	Execution instructions (terminal/console):
	1) Access the folder where the files are located. For example:
		$ cd /Users/YourUser/Desktop/Simulation
	2) Call 'octave'.
		$ octave
	3) Call the name of this script.
		octave:1> modelDutyCycle
	4) To log out, just type 'quit'.
		octave:2> quit

	Notes:
		1)	1 A = 1 C/s (Coulomb/second) .:. 1 As = 1 C
			3600 As = 1 Ah = 1000 mAh .:. 7200 As = 2 Ah = 2000 mAh
%}

	% Setting the initial KiBaM Parameters (all nodes with the same values).
	y0 = 3600;				% Initial charge in the battery (Available + Bound Charge Wells) (in As.).
	c = 0.625;				% The constant that defines the fraction in Available Charge Well.
	k = 0.00001;			% in min^(-1).
	acwMinLevel = 100;		% This value defines when the battery will stop to work.

	% Setting the nodes in the simulation and their fields.
	nodes = 1;
	for z = 1:nodes
		n(z).id = z;		% Node Id.
		n(z).t0 = 0.0;		% Initial Time.
		n(z).y0 = y0;		% Initial Battery Capacity.
		n(z).i0 = (c)*y0;	% Initial Capacity at Available Well.
		n(z).j0 = (1-c)*y0;	% Initial Capacity at Bound Well.
		n(z).i = 0.0;		% Actual Capacity at Available Well.
		n(z).j = 0.0;		% Actual Capacity at Bound Well.
		n(z).fid = 0;		% Node File Descriptor.
	endfor
	
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

	% Setting simulation variables.
	p = 0.0;		% Period.
	
	% Duty Cycle specifications.
	Bi = [0.01536, 0.03072, 0.06144, 0.12288, 0.24576, 0.49152, 0.98304, 1.96608, 3.93216, 7.86432, 15.72864, 31.45728, 62.91456, 125.82912, 251.65824];
	t_Bi = Bi(15)			% Beacon Interval (in seconds). Choose one of the fifteen indexes.
	t_op = t_Bi * (1/4);	% Time in operation (in seconds).
	t_sl = t_Bi * (3/4);	% Time in Sleep Mode (in seconds).
	
	% Main loop (Switching nodes).
	while (n(z).i0 > acwMinLevel)
		for z = 1:nodes
			
			% Executing the main charge.
			I = 0.040;			% in Ampere
			p = n(z).t0 + t_op;	% in seconds
			[n(z).y0, n(z).i0, n(z).j0] = kibam (c, k, n(z).y0, n(z).i0, n(z).j0, I, n(z).t0, p, n(z).id, n(z).fid);
			n(z).t0 = p;
			
			% Let the battery to rest.
			I = 0.005;			% in Ampere
			p = n(z).t0 + t_sl;	% in seconds
			[n(z).y0, n(z).i0, n(z).j0] = kibam (c, k, n(z).y0, n(z).i0, n(z).j0, I, n(z).t0, p, n(z).id, n(z).fid);
			n(z).t0 = p;
		
		endfor
	endwhile

	% Closing all opened files.
	for z = 1:nodes
		fclose(n(z).fid);
	endfor

	% Showing some informations on the terminal.
	printf("\n");
	for z = 1:nodes
		printf("Node: %d .:. Work time: %f (min) | %f (horas)\n", n(z).id, n(z).t0/60, n(z).t0/3600);
	endfor
	printf("\n");

	% ############################################################################################
	% Plotting information from files.
	hold off;
	
	for z = 1:nodes
		a = load([int2str(n(z).id) ".txt"]);
		if (z == 1)
			plot(a(:,1), a(:,2), "b--");
		else
			plot(a(:,1), a(:,2), "g-.");
		endif
		hold on;
	endfor
	
	grid on;
	axis([0 3000 0 2300], "manual");
	
	title ("Descarga no tubo Carga Disponível");
	hx = get (gca, 'title');
	set (hx, 'color', [1 0 0], 'fontsize', 16, 'fontname', 'Helvetica'); 
	
	xlabel ("Tempo (min)");
	hx = get (gca, 'xlabel');
	set (hx, 'color', [1 0 0], 'fontsize', 14, 'fontname', 'Helvetica'); 
	
	fixAxes;
	% ############################################################################################
