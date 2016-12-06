%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% T-KiBaM Function.                                                   %%%
%%% Created by Leonardo Martins Rodrigues on 28/01/2016.                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Parameters:
%%% - task: array with a discharge current (I) and its execution time (t).
%%% - bCap: battery CAPacity (mAh).
%%% - temp: temperature of the simulation (Degree Celsius).
function elt = mTkibam (task,bCap,temp)
    %% Definitions
    TINF = -5;               % Upper bound Temperature (degree Celsius).
    TSUP = 40;               % Lower bound Temperature (degree Celsius).

    %% Checking Temperature Range.
    if(temp < TINF && temp > TSUP)
        % If the temperature is out of range, print error message.
        fprintf('   Temperature out of range!\n');
        fprintf('   Please use %d %cC <= T <= %d %cC\n',TINF, char(176), TSUP, char(176));
        error('Incorrect temperature value.');
    end
    
    %% Output Files
    graphic = 0;   % 0 (only text) or 1 (text + file).
    if(graphic == 1)
        % Cleaning any existent files.
        if (exist('kibam-output.txt','file'))
            delete('kibam-output.txt');
        end
    
        % Creating files (one to each node).
        filename = 'kibam-output.txt';
        fid = fopen (filename, 'a');
    end
    
    %% Arrhenius Equation
    arrhenius = @(A,Ea,R,T) A * exp(-Ea/(R*T));    
    
    %% Curve Fitting
    % Piecewise Polynomial function: f(T) = a*x^3 + b*x^2 + c*x^1 + d*x^0;
    % vX: coefficients of part X.
    % CF: Correction Factor returned by the function.
    if(temp >= -5 && temp < 10)
        v1 = [-0.000000511703942                   0   0.001007597134289   0.998002046815767]; % 30.242 mA
        CF = @(T) v1(1)*(T+5).^3 + v1(2)*(T+5).^2 + v1(3)*(T+5).^1 + v1(4);
    end
    if(temp >= 10 && temp < 25)
        v2 = [ 0.000002237539379  -0.000023026677378   0.000662196973612   1.011389003026715]; % 30.242 mA
        CF = @(T) v2(1)*(T-10).^3 + v2(2)*(T-10).^2 + v2(3)*(T-10).^1 + v2(4);
    end
    if(temp >= 25 && temp < 32.5)
        v3 = [-0.000020925117234   0.000077662594698   0.001481735733400   1.023692650626454]; % 30.242 mA
        CF = @(T) v3(1)*(T-25).^3 + v3(2)*(T-25).^2 + v3(3)*(T-25).^1 + v3(4);
    end
    if(temp >= 32.5 && temp <= 40)
        v4 = [ 0.000017473446358  -0.000393152543066  -0.000884438879363   1.030346405745630]; % 30.242 mA
        CF = @(T) v4(1)*(T-32.5).^3 + v4(2)*(T-32.5).^2 + v4(3)*(T-32.5).^1 + v4(4);
    end
    
    %% T-KiBaM Parameters
    Ea = 1.194932474687872;  % Activation Energy (KJ/mol).
    A = 0.963968672200049;   % Exponential factor (1/s).
    R = 8.314e-3;            % Gas constant (KJ/mol.K).
    T = temp + 273.15;       % Conversion from Celsius to Kelvin.
    
    c = 0.5641805;           % Charge in the Available Charge tank (%).
    k = arrhenius(A,Ea,R,T); % The new rate constant.
    
    y0 = bCap * CF(temp);    % Battery Capacity (mAh) x Correction Factor. 
    y0 = (3600*y0)/1000;     % Conversion from 'mAh' to 'As'.
    
    %% Temperature-Dependent Voltage Model (TVM)
    % This model is based on the following paper:
    %    Experimental Validation of a Battery Dynamic Model for EV
    %    Applications - Oliver Tremblay and Louis-A. Dessaint
    Av = 0.4831;
    Eo = arrhenius(2.884194576613940,0.257138414788235,R,T);
    Rv = arrhenius(0.000071344680888,-15.357723400214100,R,T);
    Kv = arrhenius(0.000234004626789,-11.318113750679100,R,T);
    B  = arrhenius(0.584664335270996,-7.640349444750650,R,T);
    prExp = arrhenius(0.082728471292994,-2.718140875366010,R,T);
    alpha  = arrhenius(1.126795666175170,0.369782934961201,R,T);

    %% Initializing T-KiBaM Parameters
    i0 = ( c )*y0;          % The Available Charge tank capacity.
    j0 = (1-c)*y0;          % The Bound Charge tank capacity.
    t0 = 0.0;               % Initializing the estimated lifetime counter.
    run = true;             % Loop control variable.
    itCount = 0;            % Iterations counter.
    [tasks,~] = size(task); % Task set.
    it = 0;                 % TVM parameter: discharge current x time.

    
    %% Run the model
    while(run)
        for x = 1:tasks
            old_i0 = i0;    % Saving the Available Charge tank capacity.
            old_j0 = j0;    % Saving the Bound Charge tank capacity.
            old_t0= t0;     % Saving the total simulation time.

            [i0, j0, t0] = kibamT(c, k, i0, j0, t0, task(x,1), task(x,2));
            itCount = itCount + 1;
            
            % TVM computation.
            y = y0 * 5/18 * 0.001; % Battery Capacity (As to Ah conversion).
            i = task(x,1);         % Discharge currentin (in A).
            Ts = task(x,2)/3600;   % Simulation time step.
            it = it + (i * Ts);    % in Ah.            
            
            % Battery voltage for Li-ion technology:
            % Vbatt = (Eo - ((Kv*(y/(y-it)))*(it)) - (R*i) + A*exp(-B*it)) - ((Kv*(y/(y-it)))*(i));
            
            % Battery voltage for Ni-MH technology:
            Exp = (1/(1+(B*i*Ts*alpha))) * prExp;   % Compute Exp(t);
            prExp = Exp;                            % Update Exp(t-1);
            Vbatt = Eo - (Rv*i) - (Kv*(y/(y-(it*alpha)))*((it*alpha)+i)) + Exp;
            
            % Print information in a TXT file.
            % TIME, VOLTAGE.
            if(graphic == 1)
                if(Vbatt > 0 && Vbatt < 3.0)
                    fprintf(fid, '%.10f,%.10f\n', t0/3600, Vbatt);
                end
            end
            
            % Test if it is possible to remove charge.
            if (old_i0 < (old_i0 - i0))
                run = false;
                i0 = old_i0;
                j0 = old_j0;
                t0 = old_t0;
                break;
            end
        end
    end
    elt = t0;               % Setting up the returned value.
    
    %% Displaying data from simulations
%     disp(iterationsCount);
%     fprintf('Estimated Life Time: %.3f seconds (%.5f min or %.5f h or %.5f days)', t0, t0/60, t0/3600, (t0/3600)/24);
%     fprintf('\nFinal State of Charge: %f', soc);
%     fprintf('\nTubo J: %f - Tubo I: %f\n', j,i);
end

% 1 - Discharging at High and Low Temperatures:
% http://batteryuniversity.com/learn/article/discharging_at_high_and_low_temperatures

% 2 - TVM parameters for each temperature:
%     % -5 oC:
%     Eo = 2.57;           % Battery nominal voltage value (in V).
%     Rb = 0.070;          % Internal Resistence (in Ohm).
%     Kb = 0.0375;         % Polarisation Resistence (Ohm).
%     A = 0.4831;          % Exponential Zone Amplitude (V).
%     B = 18.00;           % Exponential Zone Time Constant Inverse (1/Ah).
%     prExp = 0.280;       % Exp(t), used for Ni-MH battery type.
%     tau_b = 0.954;       % Adjusts the simulation time step.

%     % 10 oC:
%     Eo = 2.585;          % Battery nominal voltage value (in V).
%     Rb = 0.048;          % Internal Resistence (in Ohm).
%     Kb = 0.0286;         % Polarisation Resistence (Ohm).
%     A = 0.4831;          % Exponential Zone Amplitude (V).
%     B = 15.01;           % Exponential Zone Time Constant Inverse (1/Ah).
%     prExp = 0.262;       % Exp(t), used for Ni-MH battery type.
%     tau_b = 0.9630;      % Adjusts the simulation time step.
    
%     % 25 oC:   
%     Eo = 2.60;           % Battery nominal voltage value (in V).
%     Rb = 0.035;          % Internal Resistence (in Ohm).
%     Kb = 0.0225;         % Polarisation Resistence (Ohm).
%     A= 0.4831;           % Exponential Zone Amplitude (V).
%     B = 12.750;          % Exponential Zone Time Constant Inverse (1/Ah).
%     prExp = 0.247;       % Exp(t), used for Ni-MH battery type.
%     tau_b = 0.9706;      % Adjusts the simulation time step.

%     % 32 oC:   
%     Eo = 2.606;          % Battery nominal voltage value (in V).
%     Rb = 0.030;          % Internal Resistence (in Ohm).
%     Kb = 0.0201;         % Polarisation Resistence (Ohm).
%     A = 0.4831;          % Exponential Zone Amplitude (V).
%     B = 11.82;           % Exponential Zone Time Constant Inverse (1/Ah).
%     prExp = 0.241;       % Exp(t), used for Ni-MH battery type.
%     tau_B = 0.9742;      % Adjusts the simulation time step.
    
%     % 40 oC:   
%     Eo = 2.612;          % Battery nominal voltage value (in V).
%     Rb = 0.026;          % Internal Resistence (in Ohm).
%     Kb = 0.0180;         % Polarisation Resistence (Ohm).
%     A = 0.4831;          % Exponential Zone Amplitude (V).
%     B = 11.00;           % Exponential Zone Time Constant Inverse (1/Ah).
%     prExp = 0.235;       % Exp(t), used for Ni-MH battery type.
%     tau_b = 0.9776;      % Adjusts the simulation time step.