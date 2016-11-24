% Author: Leonardo Martins Rodrigues.
% Date: 28-01-2015.

% Install Packages to run this file (Octave Command Line).
% pkg install package_name

% If problems occur (MacOS X), the line above should work (Terminal):
% touch /usr/local/Cellar/octave/3.8.1_1/share/octave/3.8.1/etc/macros.texi

% Installed packages in this Mac (to be abble to use 'leasqr' function).
% Package Name   | Version | Installation directory
% ---------------+---------+-----------------------
%       general *|   1.3.4 | /Users/Leomr85/octave/general-1.3.4
% miscellaneous *|   1.2.1 | /Users/Leomr85/octave/miscellaneous-1.2.1
%         optim *|   1.4.0 | /Users/Leomr85/octave/optim-1.4.0
%        struct *|  1.0.10 | /Users/Leomr85/octave/struct-1.0.10

% Load Packages before run this file (Octave Command Line).
% octave:1> pkg load all

% kibamFit (fileName)
%	fileName: the name of the output file from 'extract' function.

function kibamFit(fileName)
	% Clear the octave environment.
	% clear all; clf;
	
	% (Re)Load the packages (necessary to use 'leasqr' from optim package).
	pkg load all;

	% Read lines from fileName (Ex.: "energizer_ultimate_lithium_AA_15ohm.csv_out.csv").
	[log_time, log_counter, voltage, chrgR] = textread(fileName, '%s %s %f %f', 'delimiter', ',');

	% Create adequate matrices to handle the values from file.
	I = zeros(length(chrgR), 1);
	V = zeros(length(voltage), 1);
	
	% Store the values from file in the new matrices.
	for i = 1:length(chrgR)
		I(i,:) = [chrgR(i)];     % in mAh.
		V(i,:) = [voltage(i)];   % in V.
		if(voltage(i) < 0.8)
			qmax = chrgR(i);     % in mAh.
		end
	end

	% Give the start value to the variables that will be fit.
	%	Remember: "k" -> p(1), "c" -> p(2), "qmax" -> p(3).
	c = 0.625;				% The content of Available Charge.
	k = 0.00001/(c*(1-c));	% k = k'/c(1-c);
	% qmax = 33358.33;			% The maximum possible capacity at I = 0.

	% Set the time vector that matches with the log time.
	t = [0:0.167:(size(I)(1)*0.167)-0.167]';	% in Hours (10 to 10 minutes log).
	
	% Perform the fit.
	pin = [ k c qmax ];
	[f,p,cvg,iter,corp,covp,covr,stdresid,z,r2] = leasqr(t,I',pin,"kibam_func");

	% Print out the results
	printf("\n   >>> c = %.6f | k = %.9f | qmax = %f\n\n",p(2)*10^(-2), p(1)*10^(-2), qmax);
	% p*10^(-2)				% Answer needs to be multiplied for 10^(-2). I do not know why!?
	% iter
	% covp

	% Plot the results.
	plot(I',V,"+ ; Voltage Curve from Data;", "markersize", 2.5);
	hold on;
	plot(kibam_func(t,p),V,"r ;Least Square Curve Fitting;");

	% Add some descriptions to the plot.
	grid on;
	ylabel("Voltage (V)");
	xlabel("Charge Removed (mAh)");
	title("Voltage x Charge Removed");
endfunction

% References to leasqr function:
%	https://www.packtpub.com/books/content/gnu-octave-data-analysis-examples
%	http://www.krizka.net/2010/11/01/non-linear-fitting-using-gnuoctave-and-leasqr/