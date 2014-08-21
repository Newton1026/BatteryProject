printf("\nCreating the Transition Matrix P(s,s',a)...");
P(:,:,1) = [0.00 1.00; 0.00 1.00];

P(:,:,2) = [1.00 0.00; 1.00 0.00];
disp("Done!");



printf("Creating the Reward Matrix R(s',a)...");
R(:,1) = [0 2]';
R(:,2) = [1 0]';
disp("Done!");



printf("Checking the validity of the description... ");
mdp_check(P, R)



printf("Defining the discount value... ");
discount = 0.95;
disp("Done!");



[V, policy] = mdp_policy_iteration(P, R, discount)
[policy] = mdp_value_iteration(P, R, discount)