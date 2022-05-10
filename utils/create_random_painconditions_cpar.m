% Create matrix for random order of painconditions and each exercise block
clear all
clc

for n = 1:100
    
    for i = 1:4

        painconditions                       = repelem([3,5,7],3); % Different intensitiy conditions 1 = low (10 VAS), 3 = low-mid (30 VAS), 5 = high mid (50 VAS), 7 = high (70 VAS). Repeat each condition 12 times per block
        painconditions_ordering              = painconditions (randperm(length(painconditions)));
        painconditions_mat(i,:)              = painconditions_ordering;
       
    end

    painconditions_all_subjects_cpar(:,:,n) = painconditions_mat(:,:);
   

end


save('C:\Users\user\Desktop\PEEP\fMRI\Code\utils\pain_conditions_cpar_Pilot-01','painconditions_all_subjects_cpar');
