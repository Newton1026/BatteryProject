% Author: Leonardo Martins Rodrigues.
% Date: 28-01-2015.

% Function to convert the time stored in a vector to hours.
% time2hour (timeVector)
%	timeVector: a vector with time in the follow format > '2015 1 1 10 15 47'.

function [hours] = time2hour (timeVector)
	hours = timeVector(4) + (timeVector(5)/60) + (timeVector(6)/3600);
end