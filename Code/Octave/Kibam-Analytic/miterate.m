% Adjustable parameters.
error = 0.0001;    % Permissible error.
lowerV = 1e-7;    % Lower value to use as parameter in 'for' statement.
step_V = 1e-6;    % Step value to use as parameter in 'for' statement.
upperV = 9.99e-1; % Upper value to use as parameter in 'for' statement.

t1a = 37.827778;   % In Hours.
t2a = 138.545833;   % In Hours.
Fta = (750.95704/761.72499);   % Ft = q_t1 / q_t2

t1b = 23.677778;       % In Hours.
t2b = 138.545833;         % In Hours.
Ftb = (715.94497/761.72499);   % Ft = q_t1 / q_t2


% Program parameters (non-adjustable).
flag = false;    % Control to print the result.
c1 = 0.0;        % Variable to receive the 1st result.
c2 = 0.0;        % Variable to receive the 2nd result.


% Main program.
for k = lowerV:step_V:upperV
	c1 = findpar(k,Fta,t1a,t2a);
	c2 = findpar(k,Ftb,t1b,t2b);
	if(abs(c1-c2) < error)
        fprintf('\n   c1 = %f | c2 = %f\n   k'' = %f\n\n', c1, c2, k);
		flag = true;
		break;
    end
end

if(~flag)
    fprintf('\n   c1 = %f | c2 = %f', c1, c2);
	fprintf('\n   k'' not found!\n\n');
end

% Baixa Temperatura (5,19,30 mA) T=2.86V;
%    c1 = 0.718191 | c2 = 0.718191
%    k = 0.105941

% Temperatura ambiente (5,19,30 mA) T=2.8V;
%    c1 = 0.828164 | c2 = 0.828164
%    k = 0.021139

