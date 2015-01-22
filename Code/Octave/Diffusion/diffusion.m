% Discovering the simulation time. Getting the time at the beggining of the simulation.
time_before = time();   % in seconds.

% ############################################################################################
% Setting the initial Diffusion Model parameters (all nodes with the same values).
batCapMax = 60;         % in Ampere.min (A.min); Ex.: 60 Amin = 1000 mAh;
sigma_diffM = 0.0;      % Apparent Charge Lost initial value;
beta_diffM = 0.11825;   % Model constant (Original Value: 0.273);


% ############################################################################################
% Setting the nodes in the simulation and their fields.
nodes = 1;
for z = 1:nodes
	n(z).id = z;          % Node Id.
	n(z).t0 = 0.0;        % Initial Time (in minutes).
	n(z).y0 = batCapMax;  % Actual Battery Capacity.
	n(z).fid = 0;         % Node File Descriptor.
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
aBaseSuperframeDuration = 0.01536;          % in seconds.
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

t_opr = Sd;			        % Time in operation (in seconds).
t_slp = Bi - Sd;        % Time in Sleep Mode (in seconds).
printf("\n	Beacon Interval: %f | Superframe Duration: %f", Bi, Sd);

% ############################################################################################
% Defining Charges and its times.
A = [0.0400, 10];	      % [current, time_of_operation (min)]. Relative to a Tx Task.
B = [0.0200, t_opr/60];	% [current, time_of_operation (min)]. Relative to a Rx Task.
C = [0.0005, 5];	      % [current, time_of_sleep (min)]. Relative to Sleep Mode.

% Defining the task's array. One for charge and other for time.
task_i = [A(1)];	      % [A(1), B(1), C(1)];
task_t = [A(2)];	      % [A(2), B(2), C(2)];

%
% Adicionar outra carga e corrigir problema de reposição sigma_diffM...
%

printf("\n	Charges: ");
for y = 1:length(task_i)
	printf("%f ", task_i(y));
endfor
printf("\n");

while (sigma_diffM < batCapMax)
	
	for z = 1:nodes
		for y = 1:length(task_i)
			fprintf(n(z).fid, "%f %f %f\n", n(z).t0, n(z).y0, sigma_diffM);
			[sigma_diffM, n(z).t0] = diffM(task_i(y), task_t(y), beta_diffM, C(2),n(z).t0);
			n(z).y0 = batCapMax - sigma_diffM;
			
			fprintf(n(z).fid, "%f %f %f\n", n(z).t0, n(z).y0, sigma_diffM);
			[sigma_diffM, n(z).t0] = diffM(task_i(y), task_t(y), beta_diffM, 0, n(z).t0);
			n(z).y0 = batCapMax - sigma_diffM;
		endfor
	endfor

endwhile

% Closing all opened files.
for z = 1:nodes
	fclose(n(z).fid);
endfor

% ############################################################################################
% Plotting information from files.
hold off;

for z = 1:nodes
	a = load([int2str(n(z).id) ".txt"]);
	if (z == 1)
		plot(a(:,1), a(:,2), "b", 'linestyle', "-", 'linewidth', 0.4);
	else
		plot(a(:,1), a(:,2), "g", 'linestyle', "-", 'linewidth', 0.4);
	endif
	hold on;
endfor

grid on;
axis([0 1500 0 65], "manual");

title ("Descarga no tubo Carga Disponível");
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
printf("	%d	%f 	%f 		%f  %f\n", 1, n(z).t0, n(z).t0/60, time_sim, time_sim/60);