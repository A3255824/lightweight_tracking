function levene_test_summary(structure, variableName)
    % Call the function to perform Levene's test for all patients
    leveneTestResults = compare_variances_structure(structure, variableName);    
    % Extract patient MRNs and initialize arrays for summary
    patientNumbers = 1:length(fieldnames(leveneTestResults));
    pValues = zeros(length(patientNumbers), 1);
    ciLowerBounds = zeros(length(patientNumbers), 1);
    ciUpperBounds = zeros(length(patientNumbers), 1);
    tStatistics = zeros(length(patientNumbers), 1); % For storing F statistic or equivalent 
    dfStatistics = zeros(length(patientNumbers), 1); % For storing F statistic or equivalent    
    % Populate the arrays with results from each patient
    patientMRNs = fieldnames(leveneTestResults); % Keep track of original MRN order
    for i = 1:length(patientMRNs)
        result = leveneTestResults.(patientMRNs{i});
        pValues(i) = result.p;
        ciLowerBounds(i) = result.ci(1);
        ciUpperBounds(i) = result.ci(2);
        tStatistics(i) = result.stats.tstat;
        dfStatistics(i) = result.stats.df;
    end   
    % Create a table with the summary data
    summaryTable = table((1:length(patientMRNs))', pValues, ciLowerBounds, ciUpperBounds, tStatistics, dfStatistics, ...
                         'VariableNames', {'PatientNumber', 'PValue', 'CI Lower', 'CI Upper', 'tStat', 'df'});    
    % Optionally, rename patient numbers to sequential numbers
    summaryTable.PatientNumber = (1:length(patientMRNs))';    
    % Display the table in the Matlab command window
    disp(summaryTable);   
    % Optionally, write the table to a CSV file
    writetable(summaryTable, 'LeveneTestSummary.csv');
end