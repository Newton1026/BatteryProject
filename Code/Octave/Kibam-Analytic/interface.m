 % Begin Simulator
	printf("\n .............::::::::::::: KiBaM Simulator :::::::::::::.............\n\n");
	printf("Created by Leonardo Martins Rodrigues on 16/01/2015.\n");
	
% Change Standard Parameters?
	printf("The following table shows the 'standard parameters' used in this tool.\n\n");
 	printf("Parameter | Value\n    c     | 0.625\n    k     | 0.00001\n Battery  | 500 mAh\n cutoff   | 5 mAh.\n\n");

	printf("You can change those parameters on the next instructions.\n");
	input("Press 'enter' to continue!\n");
	
	choice = yes_or_no("Would you like to change the standard parameters? ");
 	if(choice == true)
 		c = input("Type the value of the parameter 'c' (Ex.: 0.625): ");
 		k = input("Type the value of the parameter 'k' (Ex.: 0.00001): ");
 		y0 = input("Type the new battery capacity 'y0' (Ex.: 500): ");
 		cutoff = input("Type the value of the 'cutoff' (Ex.: 5): ");
 		printf("Parameters are set ... Ok!\n\n");
 	else
 		c = 0.625;
 		k = 0.00001;
 		y0 = 500; % in mAh.
 		cutoff = 5;
 		printf("\n");
 	end
	
	y0 = (3600*y0)/1000; % Conversion from 'mAh' to 'As'.
	
% Choose the quantity of tasks in the simulation...
	tasks = input("How many tasks do you want in the simulation?\n(Ex.: 0 = standard example, 1, 2 ...) = ");
	if(tasks > 0)
		% task = zeros (tasks, 2);
		for x = 1:tasks
			task(x,1) = input("Enter the load current in A (Ex.: 0.040): ");
			task(x,2) = input("Enter the load period in seconds (Ex.: 2): ");
		end
		task
	else
		task = [0.0400 2; 0.00015 6]
		tasks = length(task);
	end
	
	printf("       ^            ^\n       |            |\n      Load         time\n\n");

% Choose the results style: "only text" or "text + Graphics".
	graphic = input("Would you like to generate graphic output? (0 = No, 1 = Yes) ");
	if(graphic == 1)
		% Cleaning any existent files.
		if (exist("kibam-output.txt"))
				[err, msg] = unlink("kibam-output.txt");
		end
	
		% Creating files (one to each node).
		filename = ["kibam-output.txt"];
		fid = fopen (filename, "a");
	end
	printf("\n");

% Call the KiBam Function
	input("The simulation will start now. It may take a while.\nPress Control+C to abort. Press 'enter' to continue!\n");
	
	i0 = ( c )*y0;
	j0 = (1-c)*y0;
	i = i0;
	j = j0;
	t0 = 0.0;
	soc= 100.0;
	
	totalCharge = i;
	
	while(i > cutoff)
		for x = 1:tasks
			[y0, i, j, t0] = kibam2(c, k, y0, i, j, t0, task(x,1), task(x,2));
			
			% Updating the SoC value.
			soc = 100.0 * (i / i0);
			
			% If graphic output is enable, then save the data in a TXT file.
			if(graphic == 1)
				fprintf(fid, "%f %f %f\n", t0/60, i, soc);
			end
		end
	end
	
	printf("\nEstimated Life Time: %.3f seconds (%.3f min or %.3f h)", t0, t0/60, t0/3600);
	printf("\nFinal State of Charge: %f\n", soc);
	
 	% Generate graphic output
 	if(graphic == 1)
 		% Closing opened files.
 		fclose(fid);
 		
 		% Graphic definitions.
		hold off;
		color = "b"; % b=blue, r=red, m=magenta, y=yellow, g=green.
	
		a = load("kibam-output.txt");
		plot(a(:,1), a(:,2), color, 'linestyle', "-", 'linewidth', 0.4);
	
		grid on;
		axis([0 ((t0/60)+100) 0 (totalCharge+100)], "manual");
	
		title ("Descarga no tanque Carga Disponível");
		hx = get (gca, 'title');
		set (hx, 'color', [1 0 0], 'fontsize', 16, 'fontname', 'Helvetica'); 
	
		xlabel ("Tempo (min)");
		hx = get (gca, 'xlabel');
		set (hx, 'color', [1 0 0], 'fontsize', 14, 'fontname', 'Helvetica'); 
	
		fixAxes;
 	end

 	printf("\n .............::::::::::::: Simulation done :::::::::::::.............\n\n");