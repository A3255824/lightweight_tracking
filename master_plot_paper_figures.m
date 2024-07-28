function master_plot_paper_figures(structure)
%% Stride Characteristics
strideFlag = 1; 
% Get all MRN fields from the structure
mrn_list = fieldnames(structure);
% Preallocate cell arrays to store combined data for each MRN
combined_stride_time = cell(length(mrn_list), 2); % 2 for 'off' and 'on'
combined_stride_length = cell(length(mrn_list), 2);
combined_stride_velocity = cell(length(mrn_list), 2);
for i = 1:length(mrn_list)
    mrn = mrn_list{i};    
    for j = 1:2 % 1 for 'off', 2 for 'on'
        condition = 'off';
        if j == 2
            condition = 'on';
        end        
        % Access the stride characteristics for the current MRN and condition
        stride_data = structure.(mrn).(condition).stride_characteristics;        
        % Combine leading and trailing data for stride time, length, and velocity
        combined_stride_time{i, j} = vertcat(stride_data.stride_time_leading.all{:}, stride_data.stride_time_trailing.all{:});
        combined_stride_length{i, j} = vertcat(stride_data.stride_length_leading.all{:}, stride_data.stride_length_trailing.all{:});
        combined_stride_velocity{i, j} = vertcat(stride_data.stride_velocity_leading.all{:}, stride_data.stride_velocity_trailing.all{:});
    end
end

% Preallocate cell arrays to store aggregated means and standard deviations
aggregated_means_stride_time = cell(length(mrn_list), 2); % 2 for 'off' and 'on'
aggregated_stds_stride_time = cell(length(mrn_list), 2);
aggregated_means_stride_length = cell(length(mrn_list), 2);
aggregated_stds_stride_length = cell(length(mrn_list), 2);
aggregated_means_stride_velocity = cell(length(mrn_list), 2);
aggregated_stds_stride_velocity = cell(length(mrn_list), 2);

for i = 1:length(mrn_list)
    for j = 1:2 % 1 for 'off', 2 for 'on'
        [aggregated_means_stride_time{i, j}, aggregated_stds_stride_time{i, j}] = aggregate_means_stds({combined_stride_time{i, j}});      
        [aggregated_means_stride_length{i, j}, aggregated_stds_stride_length{i, j}] = aggregate_means_stds({combined_stride_length{i, j}});
        [aggregated_means_stride_velocity{i, j}, aggregated_stds_stride_velocity{i, j}] = aggregate_means_stds({combined_stride_velocity{i, j}});
    end
end

[p_stride_time, ~, ~] = signrank(cell2mat(aggregated_means_stride_time(:,1)),cell2mat(aggregated_means_stride_time(:,2))); 
[p_stride_length, ~, ~] = signrank(cell2mat(aggregated_means_stride_length(:,1)),cell2mat(aggregated_means_stride_length(:,2))); 
[p_stride_vel, ~, ~] = signrank(cell2mat(aggregated_means_stride_velocity(:,1)),cell2mat(aggregated_means_stride_velocity(:,2))); 

[~,p_var_stride_time,ci_stride_time,fstats_stride_time] = vartest2(cell2mat(aggregated_means_stride_time(:,1)),cell2mat(aggregated_means_stride_time(:,2)));
[~,p_var_stride_length,ci_stride_length,fstats_stride_length] = vartest2(cell2mat(aggregated_means_stride_length(:,1)),cell2mat(aggregated_means_stride_length(:,2)));
[~,p_var_stride_vel,ci_stride_vel,fstats_stride_vel] = vartest2(cell2mat(aggregated_means_stride_velocity(:,1)),cell2mat(aggregated_means_stride_velocity(:,2)));

plot_patient_combined_data(cell2mat(aggregated_means_stride_time), cell2mat(aggregated_stds_stride_time),...
    p_stride_time, p_var_stride_time, ci_stride_time, fstats_stride_time, 'Stride Time', 'Stride Time', 's');
plot_patient_combined_data(cell2mat(aggregated_means_stride_length), cell2mat(aggregated_stds_stride_length),...
    p_stride_length, p_var_stride_length, ci_stride_length, fstats_stride_length, 'Stride Length', 'Stride Length', 'cm');
plot_patient_combined_data(cell2mat(aggregated_means_stride_velocity), cell2mat(aggregated_stds_stride_velocity),...
    p_stride_vel, p_var_stride_vel, ci_stride_vel, fstats_stride_vel, 'Stride Velocity', 'Stride Velocity', 'm/s');

% Trailing versus leading Foot
simple_extract_statistics(strideFlag,structure,'stride_time_leading','Stride Time - Leading', 'Stride Time', 's');
simple_extract_statistics(strideFlag,structure,'stride_time_trailing','Stride Time - Trailing', 'Stride Time', 's');
simple_extract_statistics(strideFlag,structure,'stride_length_leading','Stride Length - Leading', 'Stride Length', 'in.');
simple_extract_statistics(strideFlag,structure,'stride_length_trailing','Stride Length - Trailing', 'Stride Length', 'in.');
simple_extract_statistics(strideFlag,structure,'stride_velocity_leading','Stride Velocity - Leading', 'Stride Velocity', 'in/s');
simple_extract_statistics(strideFlag,structure,'stride_velocity_trailing','Stride Velocity - Trailing', 'Stride Velocity', 'in/s');

% All other metrics
simple_extract_statistics(strideFlag,structure,'epoch_times','Epoch Times', 'Epoch Duration', 's');
simple_extract_statistics(strideFlag,structure,'turnaround_times','Turnaround Times Between Epochs', 'Turnaround Time', 's');
simple_extract_statistics(strideFlag,structure,'asymmetry_between_feet','Stride Asymmetry', 'Stride Length Asymmetry', 'in.');
simple_extract_statistics(strideFlag,structure,'normalized_asymmetry','Stride Asymmetry Normalized', 'Stride Length Asymmetry Normalized', 'in.');
simple_extract_statistics(strideFlag,structure,'directional_asymmetry','Stride Directional Asymmetry', 'Stride Length Directional Asymmetry', 'in');

%% Gait Cycle Characteristics
strideFlag = 0; 
simple_extract_statistics(strideFlag,structure,'', 'Roundtrip Gait Cycle Times', 'Gait Cycle Time', 's');
%% Variance Assesment
levene_test_summary(structure, 'epoch_times');
levene_test_summary(structure, 'turnaround_times');
end 