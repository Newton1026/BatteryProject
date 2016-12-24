%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% T-KiBaM Function.                                                   %%%
%%% Created by Leonardo Martins Rodrigues on 08/12/2016.                %%%
%%% Last important update on 08/12/2016.                                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Parameters:
%%% - task: array with a discharge current (I) and its execution time (t).
%%% - bCap: battery CAPacity (mAh).
%%% - tempFile: temperatures used in the simulations (Degree Celsius).
function elt = mDTkibam (task,bCap,tempFile)
    %% Output Files
    graphic = 0;   % 0 (only text) or 1 (text + file).
    
    if(graphic == 1)
        % Cleaning any existent files.
        if (exist('kibam-output.txt','file'))
            delete('kibam-output.txt');
        end
    
        % Creating files (one to each node).
        filename = 'kibam-output.txt';
        outid = fopen (filename, 'a');
    end
    
    %% Definitions
    TINF = -5;               % Upper bound Temperature (degree Celsius).
    TSUP = 40;               % Lower bound Temperature (degree Celsius).
    
    %% Collect File Information
    %fprintf('   Hello %s!\n', tempFile);
    
    % Checking if file exists.
    if (~exist(tempFile,'file'))
        error('File does not exist!');
    end

    % Reading file.
    delimiter = ',';
    startRow = 2;
    formatSpec = ...
      '%*s%*s%f%f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';
    fid = fopen (tempFile, 'r');
    dataArray = textscan(fid, formatSpec, 'Delimiter', delimiter,...
      'HeaderLines' ,startRow-1, 'ReturnOnError', false);
    fclose(fid);
    
    % Importing relevant data.
    hora = dataArray{:, 1};
    temp = dataArray{:, 2};

    time_interval = hora(2) - hora(1);
    
    % Cleaning vars.
    clearvars tempFile delimiter startRow formatSpec fid dataArray ans;
    
    %% Curve Fitting
    % Piecewise Polynomial function: f(T) = a*x^3 + b*x^2 + c*x^1 + d*x^0;
    % vX: coefficients of part X.
    % CF: Correction Factor returned by the function.
    function y = CF(T)
        if(T >= -5 && T < 10)
            v1 = [-0.000000511703942                   0
                   0.001007597134289   0.998002046815767]; % 30.242 mA
            y = v1(1)*(T+5).^3 + v1(2)*(T+5).^2 + v1(3)*(T+5).^1 + v1(4);
        end
        if(T >= 10 && T < 25)
            v2 = [ 0.000002237539379  -0.000023026677378
                   0.000662196973612   1.011389003026715]; % 30.242 mA
            y = v2(1)*(T-10).^3 + v2(2)*(T-10).^2 + v2(3)*(T-10).^1 + v2(4);
        end
        if(T >= 25 && T < 32.5)
            v3 = [-0.000020925117234   0.000077662594698
                   0.001481735733400   1.023692650626454]; % 30.242 mA
            y = v3(1)*(T-25).^3 + v3(2)*(T-25).^2 + v3(3)*(T-25).^1 + v3(4);
        end
        if(T >= 32.5 && T <= 40)
            v4 = [ 0.000017473446358  -0.000393152543066
                  -0.000884438879363   1.030346405745630]; % 30.242 mA
            y = v4(1)*(T-32.5).^3 + v4(2)*(T-32.5).^2 + v4(3)*(T-32.5).^1 + v4(4);
        end
    end

    %% Arrhenius Equation
    arrhenius = @(A,Ea,R,T) A * exp(-Ea/(R*T));
    
    %% T-KiBaM Parameters
    Ea = 1.194932474687872;  % Activation Energy (KJ/mol).
    A = 0.963968672200049;   % Exponential factor (1/s).
    R = 8.314e-3;            % Gas constant (KJ/mol.K).

    y0_mAh = bCap;
    c = 0.5641805;           % Charge in the Available Charge tank (%).
    
    t0 = 0.0;                % Estimated battery lifetime (in sec).
    run = true;              % Loop control variable.
    itCount = 0;             % Iterations counter.
    [tasks,~] = size(task);  % Task set.
    it = 0;                  % TVM parameter: discharge current x time.

    %% Run the Model
    % Compute the average discharge current.
    task_avg = sum(task(:,1) .* task(:,2)) / sum(task(:,2));
    
    % Walk through the temperature array.
    for z = 1:length(temp)

        % Check the temperature range.
        if(temp(z) < TINF || temp(z) > TSUP)
            % If the temperature is out of range, print error message.
            fprintf('\n\n   Temperature out of range!\n');
            fprintf('   Please use %d %cC <= T <= %d %cC\n',TINF, char(176), TSUP, char(176));
            error('Incorrect temperature value.');
        end
        
        % Compute the estimated lifetime according to the task array.
        lt = ( y0_mAh * CF(temp(z)) ) / (task_avg * 1000);
        
        % Add charge capacity in each hour.
        y0_mAh = y0_mAh + (y0_mAh * (CF(temp(z)) - 1.0) / lt);
        
        % Update the battery capacity (in As).
        y0_As = 3.6 * y0_mAh;   % Conversion from 'mAh' to 'As'.
        i0 = ( c )*y0_As;       % The Available Charge tank capacity.
        j0 = (1-c)*y0_As;       % The Bound Charge tank capacity.
        
        % Update parameters according to temperature.
        T = temp(z) + 273.15;        % Conversion from Celsius to Kelvin.
        k = arrhenius(A,Ea,R,T);     % The new rate constant.
        
        %% Temperature-Dependent Voltage Model (TVM)
        % This model is based on the following paper:
        %    Experimental Validation of a Battery Dynamic Model for EV
        %    Applications - Oliver Tremblay and Louis-A. Dessaint
        if(t0 == 0)
            % prExp is necessary only in the first iteration.
            prExp = arrhenius(0.082728471292994,-2.718140875366010,R,T);
        end
        Av = 0.4831;
        Eo = arrhenius(2.884194576613940,0.257138414788235,R,T);
        Rv = arrhenius(0.000071344680888,-15.357723400214100,R,T);
        Kv = arrhenius(0.000234004626789,-11.318113750679100,R,T);
        B  = arrhenius(0.584664335270996,-7.640349444750650,R,T);
        alpha  = arrhenius(1.126795666175170,0.369782934961201,R,T);

        start_time = t0;             % Save the start time (in sec).
        
        % Run the model during 1 hour.
        while(run)
            for x = 1:tasks
                old_i0 = i0;   % Saving the Available Charge tank capacity.
                old_j0 = j0;   % Saving the Bound Charge tank capacity.
                old_t0 = t0;   % Saving the total simulation time.

                % KiBaM function call.
                [i0, j0, t0] = kibamT(c, k, i0, j0, t0, task(x,1), task(x,2));
                
                % Iterations counter.
                itCount = itCount + 1;

                % TVM computation.
                y = bCap / 1000 ;     % Battery Capacity (As to Ah conversion).
                i = task(x,1);        % Discharge currentin (in A).
                Ts = task(x,2)/3600;  % Simulation time step.
                it = it + (i * Ts);   % in Ah.

                % Battery voltage for Li-ion technology:
                % Vbatt = (Eo - ((Kv*(y/(y-it)))*(it)) - (R*i) + A*exp(-B*it)) - ((Kv*(y/(y-it)))*(i));

                % Battery voltage for Ni-MH technology:
                Exp = (1/(1+(B*i*Ts*alpha))) * prExp;  % Compute Exp(t);
                prExp = Exp;                           % Update Exp(t-1);
                Vbatt = Eo - (Rv*i) - (Kv*(y/(y-(it*alpha)))*((it*alpha)+i)) + Exp;

                % Print information in a TXT file.
                % TIME, VOLTAGE.
                if(graphic == 1)
                    if(Vbatt > 0 && Vbatt < 3.0)
                        fprintf(outid, '%.10f,%.10f\n', t0/3600, Vbatt);
                    end
                end
                
                % Test if the time interval ended.
                if( ((t0-start_time)/3600) >= time_interval )
                    run = false;
                    y0_As = i0 + j0;
                    y0_mAh = y0_As / 3.6;
                    break;
                end

                % Test if it is possible to remove charge.
                if (old_i0 < (old_i0 - i0))
                    run = false;
                    i0 = old_i0;
                    j0 = old_j0;
                    t0 = old_t0;
                    y0_As = i0 + j0;
                    y0_mAh = y0_As / 3.6;
                    break;
                end
            end
        end
        run = true;
        fprintf('   T = %.2f \t C = %.4f mAh \t V = %.4f V\n',temp(z),y0_mAh,Vbatt);
    end
    
    elt = t0;

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