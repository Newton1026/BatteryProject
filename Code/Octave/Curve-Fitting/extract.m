% Author: Leonardo Martins Rodrigues.
% Date: 28-01-2015.

% Function to extract the Voltage x Charge Removed from a Voltage x Time data file.
%	In this case, the file is organized as follows:
%		TimeNow | Timer  | Text |  V  | Text
%		17:54:01,00:10:00,Sample,1.506,VDC
% 		18:04:01,00:20:00,Sample,1.510,VDC
% 		18:14:01,00:30:00,Sample,1.513,VDC

% extract (fileName, resistor)
%	fileName: a string with the name of the file to 'read'. Ex.: "data.csv".
%	resistor: the resistor used in the experience (in Ohms). Ex.: 15

function extract(fileName, resistor)
	
	% Compute the current.
	V = 1.5;		% AA battery (in Volts).
	R = resistor;	% in Ohms.
	I = V/R;		% Compute the current.
	
	% Convert from A to mA.
	I = I * 1000;
	
	% Cleaning any existent files.
	if (exist([fileName "_out.csv"]))
		[err, msg] = unlink([fileName "_out.csv"]);
	end
	
	% Create an auxiliary data file to store the Voltage x Charge Removed.
	aux_filename = [fileName "_out.csv"];
	aux_fid = fopen (aux_filename, "a");
	
	% Open main data file to extract information.
	fid = fopen (fileName, "r");
	
	% Read data from each line and store in the variables above.
	[log_time, log_counter, sample, voltage, vdc] = textread(fileName, '%s %s %s %f %s', 'delimiter', ',');
	
	% Compute data: Voltage x I to obtain the Charge Removed from battery.
	hours_now = 0;
	
	for i = 1:length(log_counter)
		% Compute the hour from file.
		v = datevec (log_counter{i,1}, 13);
		hours_before = time2hour(v);
		
		% Compute the time (in hours) correctly.
		if(voltage(i) >= 0.8)					% Cutoff = 0.8 V in AA batteries.
			if(hours_now < 23.833)
				hours_now = hours_before;
			else
				hours_now = hours_now + 0.167;	% hour_now + 10 minutes;
			end
		end
		
		% Store the answer at charge_removed.
		charge_removed{i,1} = hours_now * I;
		
		% Store data in the auxiliary file.
		fprintf(aux_fid, "%s,%s,%f,%f\n", log_time{i,1}, log_counter{i,1}, voltage(i), charge_removed{i,1});
	end
	
	% Closing files.
	fclose(fid);
	fclose(aux_fid);
end