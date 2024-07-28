function leveneTestResults = compare_variances_structure(structure, variableName)
    % Initialize a structure to hold the Levene's test results
    leveneTestResults = struct();        
    % Get a list of all patient MRNs in the structure
    patient_mrn_fields = fieldnames(structure);    
    % Iterate over each patient MRN
    for i = 1:length(patient_mrn_fields)
        patient_mrn = patient_mrn_fields{i};        
        
        % Dynamically access the patient's off and on data based on the variableName
        off_data = structure.(patient_mrn).off.stride_characteristics.(variableName).all;
        on_data = structure.(patient_mrn).on.stride_characteristics.(variableName).all;        
        
        % Conduct Levene's Test
        [h, p, ci, stats] = levenesTest(off_data, on_data);
        
        % Store the results in the output structure
        leveneTestResults.(patient_mrn) = struct('h', h, 'p', p, 'ci', ci, 'stats', stats);
    end
end

function [h, p, ci, stats] = levenesTest(off_data, on_data)
    % Compute the median of each group
    medianOff = median(off_data);
    medianOn = median(on_data);
    % Calculate the absolute deviations from the median
    absDevOff = abs(off_data - medianOff);
    absDevOn = abs(on_data - medianOn);
    % Perform Welch’s t-test on the absolute deviations
    [h, p, ci, stats] = ttest2(absDevOff, absDevOn, 'Vartype', 'unequal');
end