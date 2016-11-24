%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% KiBaM Function.                                                     %%%
%%% Created by Leonardo Martins Rodrigues on 16/01/2015.                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Parameters:
%%% - task: array of current (I) and execution time (t).
%%% - Y0: battery capacity.
function elt = mInterface (task,Y0)
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
    
    %% Initial Parameters
    
    % KiBaM Parameters:
    c = 0.5641805;          % Charge in the Available Charge tank.
    k = 0.5952620;          % Rate constant.
    y0 = Y0;                % Battery Capacity in mAh.
    y0 = (3600*y0)/1000;    % Conversion from 'mAh' to 'As'.

    % Task set.
    [tasks, ~] = size(task);

    i0 = ( c )*y0;          % Initial capacity in Available Charge tank.
    j0 = (1-c)*y0;          % Initial capacity in Bound Charge tank.
    t0 = 0.0;               % Total simulation time.
    soc = 100.0;            % Battery State of Charge.   
    Ro = 2.8665;            % Internal Resistance of the battery.
    Emin = 2.0;             % Minimum internal discharge voltage ('empty').
    Eod = 2.84;             % Maximum internal discharge voltage ('full').
    run = true;             % Loop control variable.
    iterationsCount = 0;    % Iterations counter.

%     tic;
    while(run)
        for x = 1:tasks
            old_i0 = i0;    % Saving the Available Charge tank capacity.
            old_j0 = j0;    % Saving the Bound Charge tank capacity.
            old_t0= t0;     % Saving the total simulation time.

            % If graphic output is enable, then save the data in a TXT file.
            if(graphic == 1)
                E = Emin + ((Eod - Emin)*(i0/(c*y0)));
                V = E - (task(x,1) * Ro);
                % TIME,AVAILABLE_CHARGE,BOUND_CHARGE,UNAVAILABLE_CHARGE,SOC,VOLTAGE
                fprintf(fid, '%.10f,%.10f,%.10f,%.10f,%.10f,%.10f\n', t0/3600, i0, j0, (j0- (((1-c)/c)*i0)), soc , V);
            end
            
            % KiBaM Function call.
            [i0, j0, t0] = kibamT(c, k, i0, j0, t0, task(x,1), task(x,2));
            iterationsCount = iterationsCount + 1;
            
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
%     toc;
    elt = t0;               % Setting up the returned value.
    
    %% Displaying data from simulations
%     disp(iterationsCount);
%     fprintf('Estimated Lifetime: %.3f sec | %.5f min | %.5f h | %.5f days', t0, t0/60, t0/3600, (t0/3600)/24);
%     fprintf('\nFinal State of Charge: %f', soc);
%     fprintf('\nTubo J: %f | Tubo I: %f\n', j,available);
end