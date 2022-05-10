%% Create matrix of randomised bike intensities
clear all
clc

% for n = 1:100
% 
%     conditions                              = [zeros(1,6/2) ones(1,6/2)]; % randomise exercise condidition (1 = high intensitiy, 0 = low intensitiy)
%     ordering                                = randperm(6);
%     conditions_rand                         = conditions(ordering);
%     exercise_conditions                      = conditions_rand;
%     exercise_conditions_all_subjects(:,:,n) = exercise_conditions(:,:);
% 
% end

goal_N = 99;
conditions                              = [zeros(1,4/2) ones(1,4/2)]; % randomise exercise condidition (1 = high intensitiy, 0 = low intensitiy)
unique_permutations = unique(perms(conditions),'rows');
numel_uperm = size(unique_permutations,1);
repetitions = ceil(goal_N/numel_uperm);
conditions_list = repmat(unique_permutations, [repetitions 1]);
exercise_conditions_all_subjects = conditions_list(randperm(goal_N),:);
save('C:\Users\user\Desktop\PEEP\fMRI\Code\utils\cycle_ints_Pilot-01','exercise_conditions_all_subjects');