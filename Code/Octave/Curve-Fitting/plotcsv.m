% Author: Leonardo Martins Rodrigues.
% Date: 28-01-2015.

% Function to plot the data available in a csv file.
% plotcsv (fileName, override)
%	fileName: a string with the name of the file to 'read'. Ex.: "data.csv".
%	overlap: a boolean argument to determine if the plot is overlap or not. Ex.: true.

function plotcsv(fileName, override)
	% Close any plot window opened.
	close all;
	
	% Decide if the new plot overlaps the old plot.
	if(override == true)
		hold on;
	else
		hold off;
	end
 	
	% Read all file content and store in a variable (columns are separeted by a comma).
 	data = dlmread(fileName, ',');
	
	% Take what is important for the plot.
	volts = data(:,3);	% Column that represents the voltage reads.
	chrgR = data(:,4);	% Column that represents the Charge Removed computations.
	
	% Plot the Charge Removed (x axis) vs. Voltage (y axis).
	plot(chrgR, volts);
	
	% Add some descriptions to the plot.
	grid on;
	xlabel("Charge Removed (mAh)");
	ylabel("Voltage (V)");
	title("Voltage Discharge Data");
	
	% Create a PDF output. It did not work on my Mac!
	% print -dpdf -color out.pdf
end