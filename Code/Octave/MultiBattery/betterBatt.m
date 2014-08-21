%{
    This source code implements the function to discover which battery has higher capacity given an array of batteries.

    Author: Leonardo Martins Rodrigues.
    Date of creation: 29-04-2014 - Version: 1.0

	Note:	'battArray' is the function parameter. An array tha contains the batteries used by the node.
			'out' is the function return values.
%}

function out = betterBatt (battArray)
	
	out = 0;
	capacity = 0.0;
	for w = 1:length(battArray)
		if(battArray(w) > capacity)
			capacity = battArray(w);
			out = w;
		endif
	endfor
	
endfunction