
	% Note: 1 A = 1 C/s (Coulomb/second) .:. 1 As = 1 C
	% Note: 3600 As = 1 Ah = 1000 mAh .:. 7200 As = 2 Ah = 2000 mAh

	% Setting the initial KiBaM Parameters (all nodes with the same values).
	y0 = 3600;
	c = 0.625;

	% Setting the nodes in the simulation.
	nodes = 2;
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
	
	% Creating files (equivalent to each node).
	for z = 1:nodes
		filename = [int2str(z) ".txt"];
		n(z).fid = fopen (filename, "a");		
	endfor

	% Setting simulation variables.
	p = 0.0;		% Period
	t_op = 600;		% Time of operation
	
	% Main loop.
	while (n(z).i0 > 100)
		for z = 1:nodes
			
	 		I = 0.040;			% in Ampere
	 		p = n(z).t0 + t_op;	% in seconds
	 		[n(z).y0, n(z).i0, n(z).j0] = kibam (n(z).y0, n(z).i0, n(z).j0, I, n(z).t0, p, n(z).id, n(z).fid);
			n(z).t0 = p + 1.00;
		
			for x = 1:nodes
				if (x != z)
					I = 0.005;			% in Ampere
					p = n(x).t0 + t_op;	% in seconds
					[n(x).y0, n(x).i0, n(x).j0] = kibam (n(x).y0, n(x).i0, n(x).j0, I, n(x).t0, p, n(z).id, n(x).fid);
					n(x).t0 = p + 1.00;
				endif
			endfor
		
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

	% Plotting information from files.
	% hold off;
	
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