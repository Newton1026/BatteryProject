%{
    Lifetime estimation from Rakhmatov and Vrudhula:
    "An Analitical High-Level Battery Model for Use in
    Energy Management of Portable Eletronic Systems".
    
    Author: Leonardo Martins Rodrigues.
    Date: 27/10/2014.
    
    Notes:
    1) Original constants values (Li-ion Battery):
        alpha (or 'a') = 271.47
        beta (or 'B')= 10.39

    2) Parameters:
        Si = Current Profile
        St = Times of Currents
        alpha
        beta
    
    3) Indexes in Octave.
        Si =  [5   1   2]
        Si(1)
        ans =  5
%}

function f_LE (Si, St, a, B)
    
    % Do not forget: test the length of Si/St...

    % Find the smallest t E [0,t1] such that: a < 2*I0*A(t,t,0,B);
    if (a < (2 * Si(1) * f_A(St(2), St(2), 0, B)) )
        for t = 0:0.1:St(2)
            if(a < (2 * Si(1) * f_A(t, t, 0, B)) )
                % return {t,0};
                printf("[0, %.2f)\n", t);
                return;     % Finish the function.
            endif
        endfor
    endif
    
    % Find the smallest integer u E {2,3,...,n} such that: a < sum_k=1^u (2*Ik_1*A(tu,tk,tk_1,B))
    found_u = false;
    for u = 3:length(Si)
        sum = 0.0;
        for k = 2:u
            sum = sum + (2 * Si(k-1) * f_A(St(u), St(k), St(k-1), B));
        endfor
        if (a < sum)
            found_u = true;
            break;
        endif
    endfor
    
    if(found_u == false)
        % Calculating the return value;
        sum = 0.0;
        for k = 2:length(Si)
            sum = sum + (2 * Si(k-1) * f_A(St(length(St)), St(k), St(k-1), B));
        endfor
        printf("[%.2f, inf)\n", a - sum);
        return;
    endif
    
    % Find the smallest t E [tu_1,tu] such that: a < sum_k=1^u-1 2*Ik_1*A(t,tk,tk_1,B) + 2*Iu_1*A(t,t,tu_1,B)
    for t = St(u-1):0.1:St(u)
        sum = 0.0;
        for k = 2:(u-1)
            sum = sum + (2 * Si(k-1) * f_A(t, St(k), St(k-1), B)) + (2 * Si(u-1) * f_A(t, t, St(u-1), B));
        endfor
        if (a < sum)
            printf("[0, %.2f)\n", t);
            return;
        endif
    endfor

endfunction