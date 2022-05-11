% Create matrix for random order of painconditions and each exercise block
clear all
clc

elements_heat = ["3_2","5_2","7_2"];
elements_pressure = ["3_1","5_1","7_1"];
selected_pressures = {};
selected_heat = {};

% Create Matrix with alternating 0 and 1
sequence_pressure_first                       = rem(1:18,2);
sequence_heat_first                           = rem(0:17,2);
mat = [sequence_heat_first;sequence_heat_first;sequence_pressure_first;sequence_pressure_first];
%painconditions = [];

% Loop through possible pressures and heats and create new pain conditions
% matrix with alternating heat (9) and pressure pain (9) of 4 blocks with
% random start of heat(2)  or pressure (2) for 100 participants

for n = 1:100

    shuffled_mat = mat(randperm(size(mat,1)),:);

    for i = 1:4

        for m = 1:18


            if shuffled_mat(i,m) == 1

                randomIndex = randi(length(elements_pressure), 1);
                selected_pressure_value = elements_pressure(randomIndex);
                selected_pressures{m} = selected_pressure_value;


              
                if sum(strcmp([selected_pressures{:}],selected_pressure_value)) == 3


                    break;

                else

                    painconditions(i,m) = selected_pressure_value;

                end

            elseif shuffled_mat(i,m) == 0

                randomIndex = randi(length(elements_heat), 1);
                selected_heat_value = elements_heat(randomIndex);
                selected_heat{m} = selected_heat_value;

                if sum(strcmp([selected_heat{:}],selected_heat_value)) == 3


                    break;

                else

                    painconditions(i,m) = selected_heat_value;

                end

            end

        end

    end

    painconditions_all_subjects_cpar_thermode(:,:,n) = painconditions(:,:);


end



