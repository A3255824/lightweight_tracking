function [off_table, on_table] = aggregate_data_stride(structure, variable)
    % Get all the MRN field names
    mrn_fieldnames = fieldnames(structure);    
    % Initialize empty matrices for the means and stds for 'off' and 'on' conditions
    off_table = zeros(2, length(mrn_fieldnames));
    on_table = zeros(2, length(mrn_fieldnames));    
    % Loop through each MRN
    for i = 1:length(mrn_fieldnames)
        mrn = mrn_fieldnames{i};        
        % Process both 'off' and 'on' conditions
        for condition = ["off", "on"]
            % Access the stride characteristics for the current condition of the current MRN
            stride_characteristics = structure.(mrn).(condition).stride_characteristics;            
            % Extract the mean and std for the specified variable
            metric_mean = stride_characteristics.(variable).mean;
            metric_std = stride_characteristics.(variable).std;            
            % Add the mean and std to the appropriate table
            if condition == "off"
                off_table(1, i) = metric_mean;
                off_table(2, i) = metric_std;
            else
                on_table(1, i) = metric_mean;
                on_table(2, i) = metric_std;
            end
        end
    end
end