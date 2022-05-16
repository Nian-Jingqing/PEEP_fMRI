% Create matrix for random order of painconditions and each exercise block
clear all
clc

elements_heat = repmat(["3_2","5_2","7_2"],1,3);
elements_pressure = repmat(["3_1","5_1","7_1"],1,3);


% Loop through possible pressures and heats and create new pain conditions
% matrix with alternating heat (9) and pressure pain (9) of 4 blocks with
% random start of heat(2)  or pressure (2) for 100 participants

painconditions_all_subjects_cpar_thermode = strings(4,18,100);

for n = 1:100

    shuffled_mat = Shuffle([0,0,1,1]);

    for i = 1:4

        first_mod = shuffled_mat(i);

        p = Shuffle(elements_pressure);
        h = Shuffle(elements_heat);

        painconditions = strings(1,18);


        if first_mod == 0

            painconditions(1:2:end) = h;
            painconditions(2:2:end) = p;

        else

            painconditions(1:2:end) = p;
            painconditions(2:2:end) = h;

        end

        painconditions_all_subjects_cpar_thermode(i,:,n) = painconditions;

    end

    

end


save('C:\Users\nold\PEEP\fMRI\Code\peep_functions_fMRI\utils\pain_conditions_cpar_thermode_Pilot-01_day2','painconditions_all_subjects_cpar_thermode');

