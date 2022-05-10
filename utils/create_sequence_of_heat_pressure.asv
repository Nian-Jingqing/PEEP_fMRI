% Create matrix for random order of painconditions and each exercise block
clear all
clc

heat = 0;
pressure = 1;

sequence_pressure_first                       = rem(1:18,2);
sequence_heat_first                           = rem(0:17,2);

randnumb = 0;
% for i = 1:4
%     if sum(randnumb) < 2
%         randnumb(i) = randi(2)-1;
% 
%     elseif sum(randnumb) == 2
%         randnumb(i) = 0;
%     end
% end


for n = 1:100

    for l = 1:4


        sequence                       = repelem([1,0],9); % Different intensitiy conditions 1 = low (10 VAS), 3 = low-mid (30 VAS), 5 = high mid (50 VAS), 7 = high (70 VAS). Repeat each condition 12 times per block
        sequence_ordering              = sequence (randperm(length(sequence)));
        sequence_mat(l,:)              = sequence_ordering;

    end

    sequence_mat_all_sub(:,:,n) = sequence_mat(:,:);
   


end