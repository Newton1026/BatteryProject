%{
    Function A (L, tk, tk_1, B) as described in "An Analitical
    High-Level Battery Model for Use in Energy Management of
    Portable Eletronic Systems" by Rakhmatov and Vrudhula.
    
    Author: Leonardo Martins Rodrigues.
    Date: 27/10/2014.
    
    Notes:
    1) Original constants values (Li-ion Battery):
        alpha = 271.47
        beta = 10.39
%}

function [ans] = f_A (L, tk, tk_1, B)
    sum1 = 0.0;
    sum2 = 0.0;
    
    % Test to avoid division by zero.
    if(L - tk_1 != 0)
        for m = 1:10
            sum1 = sum1 + ( exp(-((B^2)*(m^2))/(L - tk_1)) - ((pi * exp(-((B^2)*(m^2))/(L - tk_1)))/(pi - 1 + sqrt(1 + (pi * ((L - tk_1)/((B^2)*(m^2))))))) );
        endfor
    endif
    
    % Test to avoid division by zero.
    if(L - tk != 0)
        for m = 1:10
            sum2 = sum2 + ( exp(-((B^2)*(m^2))/(L - tk  )) - ((pi * exp(-((B^2)*(m^2))/(L - tk  )))/(pi - 1 + sqrt(1 + (pi * ((L - tk  )/((B^2)*(m^2))))))) );
        endfor
    endif
    
    % Return the answer.
    ans = (sqrt(L - tk_1) * (1 + (2 * sum1))) - (sqrt(L - tk) * (1 + (2 * sum2)));
    
endfunction