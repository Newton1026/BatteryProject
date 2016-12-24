%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% KiBaM Auxiliar Function.                                            %%%
%%% Created by Leonardo Martins Rodrigues on 29/03/2016.                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Parameters:
%%% - tempArray: array of temperatures to simulate.
%%% - taskArray: cell array of tasks to simulate.
%%% The information to run the KiBaM is created in this function.

%%% Example of use:
%%% >> mIkibam([25],{[0.030242 1]});
%%% >> mIkibam([25],{[0.030242 1];[0.020303 1]});
%%% >> mIkibam([25],{[0.030242 1];[0.020303 1];[0.030242 1; 0 1]});
%%% >> mIkibam([25,32.5],{[0.030242 1]});
%%% >> mIkibam([25,32.5],{[0.030242 1];[0.020303 1; 0 1]});

function mIkibam (tempArray,taskArray)
    %% Second to Hour conversion
    secondToHour = @(value) value/3600;

    %% Initial Parameters
    Y0 = 750;                     % Battery capacity (in mAh).
    N = taskArray;

    [r, ~] = size(N);

    %% Main Function Call
    fprintf('  --------------------\n');
    if(ischar(tempArray) == 0)
        final = zeros(1,r);
        for j=1:length(tempArray)
            fprintf('   T = %.1f\n',tempArray(j));
            fprintf('  --------------------\n');
            for i = 1:r
                %%final(i) = mInterface(N{i},Y0);             % KiBaM.
                final(i) = mTkibam(N{i},Y0,tempArray(j));   % T-KiBaM.
                disp(['   Time (s): ' num2str(final(i))]);
                disp(['   Time (h): ' num2str(secondToHour(final(i)))]);
                fprintf('  --------------------\n');
            end
            fprintf('\n');
        end
    else
        fprintf('   File input\n');
        fprintf('  --------------------\n');
        final = zeros(1,1);
        for i = 1:r
            final = mDTkibam(N{i},Y0,tempArray);   % D-T-KiBaM.
            disp(['   Time (s): ' num2str(final)]);
            disp(['   Time (h): ' num2str(secondToHour(final))]);
            fprintf('  --------------------\n');
        end
    end
end


%% To perform the code more than one time.
% f = @() mIkibam;
% timeit(f);

%% Main
% Special task sequences: LOAD + SLEEP.
%    load = 0.030242;   % Discharge Current in active period (in A).
%    sleep = 0.000019;   % Discharge Current in sleep period (in A).
%    timePeriod = 1;     % The granularity of the simulation (in sec).
%    len1 = 10;           % Active part length, units.
%    len2 = 10;           % Inactive part length, units.
%    cycle = [ones(1,len1)  ones(1,len2)]' * timePeriod;
%    loads = [(ones(1,len1)*load)  (ones(1,len2)*sleep)]';

% Special task sequences: LOAD1 + LOAD2 + LOAD3 + SLEEP.
% The order can be changed. E.g.: LOAD1 + SLEEP + LOAD2 + LOAD3
%     load1 = 0.0254;       % 1st Discharge Current (in A).
%     load2 = 0.0151;       % 2nd Discharge Current (in A).
%     load3 = 0.0080;       % 3rd Discharge Current (in A).
%     sleep = 0.000019;     % Discharge Current in sleep period (in A).
%     len1 = 240;           % Active part length of LOAD1, units.
%     len2 = 600;           % Active part length of LOAD2, units.
%     len3 = 360;           % Active part length of LOAD3, units.
%     len4 = 600;           % Active part length of SLEEP, units.
%     T1=ones(1,len1);   T2=ones(1,len2);
%     T3=ones(1,len3);   T4=ones(1,len4);
%     I1=(ones(1,len1)*load1);   I2=(ones(1,len2)*load2);
%     I3=(ones(1,len3)*load3);   I4=(ones(1,len4)*sleep);
%     cycle = [T1 T2 T3 T4]';
%     loads = [I1 I2 I3 I4]';

% Building the task vector.
% Uncomment if using some of the Special task sequences.
%    conc = horzcat(loads,cycle);
%    N = {conc};

%% Normal Duty Cycle tasks: from 3.125% to 100%.
% N = {[0.010424 1]};
% N = {[0.020303 1]};
% N = {[0.030242 1]};

% N = {[0.030242 0.960; 0 0.960]};  % 50.0% DC
% N = {[0.030242 0.480; 0 1.440]};  % 25.0% DC
% N = {[0.030242 0.240; 0 1.680]};  % 12.5% DC
% N = {[0.030242 0.120; 0 1.800]};  % 6.25% DC
% N = {[0.030242 0.060; 0 1.860]};  % 3.125% DC
% N = {[0.030242 0.030; 0 1.890]};  % 1.5625% DC
% N = {[0.030242 0.015; 0 1.905]};  % 0.78125% DC


%% Batch tasks
% N = {[0.005498 1]; [0.010384 1]; [0.019852 1]};
% N = {[0.005498 1]; [0.010384 1]; [0.019852 1]; [0.030237 1]; [0.030237 0.960; 0 0.960]; [0.030237 0.480; 0 1.440]; [0.030237 0.240; 0 1.680]; [0.030237 0.120; 0 1.800]};
% N = {[0.005498 1]; [0.019852 1]; [0.030237 1]; [0.030237 0.960; 0 0.960]; [0.030237 0.480; 0 1.440]; [0.030237 0.240; 0 1.680]; [0.030237 0.120; 0 1.800]};
% N = {[6.000 0.1]; [3.000 0.11]; [1.500 0.1]; [0.750 0.1]; [0.375 0.1]; [0.1875 0.1]; [0.09375 0.1]; [0.046875 0.1]; [0.0234375 0.1]};