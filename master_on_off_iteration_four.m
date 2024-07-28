function master_on_off_iteration_four
% This function processes video recordings from a specified directory,
% filtering for folders that match a given naming pattern.
% For each relevant folder, it analyzes 'off' and 'on' condition gait metrics
% using 'analyze_on_off_dopamine_iteration_two', based on CSV data and sagittal
% MP4 videos. Results are structured by patient MRN for further analysis.
% Warnings are issued for missing data or directories.
%% Varargins specified (WARNING: THESE ARE HARDCODED VALUES/ACCESS POINTS)
sagittal_length = 83; % This is the physical distance between the two cones along the sagittal view
conf_threshold = 0.85; % This value provides the confidence interval to threshold
directoryPath = '/Users/annie/Library/CloudStorage/Box-Box/PatientVideoRecordings/Manuscript Patients';
modelPath = '0_td-hm_ViTPose-large_8xb64-210e_coco-256x192-53609f55_20230314.pth';
namePathAnalyzedVideos = 'analyzed';
namePathCSV = 'combined.csv';
force_analysis = 0;
save_figures_flag = 0;
% Define the directory where analysis structures are saved
analysisStructuresDir = fullfile(directoryPath, 'analysisStructures');
%% Check the force_analysis flag
if force_analysis == 0
    % Get a list of '.mat' files in the analysis structures directory
    structFiles = dir(fullfile(analysisStructuresDir, '*.mat'));
    % Check if there are any '.mat' files (structures) in the directory
    if ~isempty(structFiles)
        % Find the most recent file
        [~, idx] = max([structFiles.datenum]);
        mostRecentFile = structFiles(idx).name;
        % Load the most recent structure
        load(fullfile(analysisStructuresDir, mostRecentFile), 'structure');
    else
        % No structure files found, set flag to run the analysis
        force_analysis = 1;
    end
end
%% Force analysis because no structures in file
if force_analysis == 1
    % List all subfolders in the directory, identify folders of interest
    % List the contents of the specified directory and return a struct array.
    % Each struct contains details about the items in the directory, including
    % names, whether it's a file or directory, size, modification dates, and more.
    subfolders = dir(directoryPath);
    % Create a logical array 'isub' where each element corresponds to an item in
    % 'subfolders'. The value is true if the item is a directory, and false otherwise.
    isub = [subfolders(:).isdir];
    % Extract the names of all subdirectories (excluding files) from 'subfolders'
    % and store them in a cell array 'nameFolds'.
    nameFolds = {subfolders(isub).name}';
    % Remove entries for the current ('.') and parent ('..') directories from
    % 'nameFolds' to avoid processing them.
    nameFolds(ismember(nameFolds,{'.','..'})) = [];
    % Define an expression pattern to match folder names in the format 'MM-DD-YYYY_MRN_Number'.
    % This pattern ensures that folder names adhere to a specific date and MRN format.
    pattern = '^\d{2}-\d{2}-\d{4}_MRN_\d+$';
    % Filter 'nameFolds' to include only those folder names that match the specified 'pattern'.
    % This is achieved by using 'regexp' to test each name against the pattern, 'isempty'
    % to check for non-matches, and logical indexing to select only the matching folder names.
    matchedFolders = nameFolds(~cellfun(@isempty, regexp(nameFolds, pattern)));
    % Loop over each matched folder
    for i = 1:length(matchedFolders)
        % Combine the base directory path with the current matched folder name to create its full path.
        matchedFolderPath = fullfile(directoryPath, matchedFolders{i});
        % Construct the path to the 'analyzed' subfolder within the current matched folder.
        analyzedFolderPath = fullfile(matchedFolderPath, namePathAnalyzedVideos);
        % Check if 'analyzed' folder exists
        if exist(analyzedFolderPath, 'dir')
            % Path to the specific subfolder within 'analyzed' of ML model
            specificFolderPath = fullfile(analyzedFolderPath, modelPath);
            % Check if the specific subfolder exists referring to the ML model
            if exist(specificFolderPath, 'dir')
                % Full path to the 'combined.csv' file
                csvFilePath = fullfile(specificFolderPath, namePathCSV);
                % Check if 'combined.csv' exists
                if exist(csvFilePath, 'file')
                    % Load the CSV file
                    % Perform operations with combinedData as needed
                    combinedData = readtable(csvFilePath);
                else
                    warning('combined.csv not found in %s', specificFolderPath);
                end
                % Find and load the analyzed MP4 files
                mp4Files = dir(fullfile(specificFolderPath, '*.mp4'));
                % If no MP4 files found, skip to the next iteration of the loop
                if isempty(mp4Files)
                    warning('No MP4 files found in %s', specificFolderPath);
                    continue; % Skip the rest of the loop iteration
                end
                % Checking and load individual .mp4 videos (sagittal only)
                for j = 1:length(mp4Files)
                    % Check and load 'sagital OFF' video
                    if contains(mp4Files(j).name, 'sagittal', 'IgnoreCase', true) && contains(mp4Files(j).name, 'OFF', 'IgnoreCase', true)
                        sagitalOFFVideoPath = fullfile(specificFolderPath, mp4Files(j).name);
                        % Perform operations with sagitalOFFVideoPath as needed
                    end
                    % Check and load 'sagital ON' video
                    if contains(mp4Files(j).name, 'sagittal', 'IgnoreCase', true) && contains(mp4Files(j).name, 'ON', 'IgnoreCase', true)
                        sagitalONVideoPath = fullfile(specificFolderPath, mp4Files(j).name);
                        % Perform operations with sagitalONVideoPath as needed
                    end
                end
                % Split the folder name to extract the MRN number and create a
                % unique field name for each patient's data.
                parts = strsplit(matchedFolders{i}, 'MRN_');
                fieldname = ['patient_mrn_' parts{2}]; % Concatenate 'patient' with the index 'i'
                % Analyze gait metrics and compute structure fields for 'off' and 'on'
                % states.'combinedData' is the CSV data, 'sagitalOFF/ONVideoPath' are the
                % paths to the corresponding videos.
                structure.(fieldname).off = analyze_on_off_dopamine_iteration_three(combinedData,...
                    sagitalOFFVideoPath,sagittal_length,conf_threshold);
                structure.(fieldname).on = analyze_on_off_dopamine_iteration_three(combinedData,...
                    sagitalONVideoPath,sagittal_length,conf_threshold);
            else
                warning('Specific folder not found in %s', analyzedFolderPath);
            end
        else
            warning('Analyzed folder not found in %s', matchedFolderPath);
        end
    end
    % Save structure
    % Get the current date and time as a string
    dateTimeNow = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    % Create the filename with the date and time stamp
    filename = sprintf('structure_%s.mat', dateTimeNow);
    % Create the full file path
    fullFilePath = fullfile(analysisStructuresDir, filename);
    % Save the structure to the file
    save(fullFilePath, 'structure');
    if save_figures_flag
        SaveFigs(analysisStructuresDir, filename);
    end
end
close all;
master_plot_paper_figures(structure); 
end