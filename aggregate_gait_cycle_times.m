function [off_table, on_table] = aggregate_gait_cycle_times(structure)
% Get all the MRN field names
mrn_fieldnames = fieldnames(structure);
% Initialize empty matrices for the means and stds for 'off' and 'on' conditions
off_table = zeros(2, length(mrn_fieldnames)); % First row for mean, second row for std
on_table = zeros(2, length(mrn_fieldnames));  % Same structure as off_table
% Loop through each MRN
for i = 1:length(mrn_fieldnames)
    mrn = mrn_fieldnames{i};
    % Process both 'off' and 'on' conditions
    for condition = ["off", "on"]
        % Directly access gait cycle times for the current condition of the current MRN
        gait_cycle_times = structure.(mrn).(condition).gait_cycle_times;
        % Extract the mean and std for gait cycle times
        metric_mean = gait_cycle_times.mean;
        metric_std = gait_cycle_times.std;
        % Add the mean and std to the appropriate table
        if condition == "off"
            off_table(1, i) = metric_mean;
            off_table(2, i) = metric_std;
        else % condition == "on"
            on_table(1, i) = metric_mean;
            on_table(2, i) = metric_std;
        end
    end
end
end