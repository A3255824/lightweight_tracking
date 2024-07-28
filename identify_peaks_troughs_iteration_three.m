function [epochData,epochDataPruned] = identify_peaks_troughs_iteration_three(filteredData,videoTime,videoObj,conf_threshold)
% This function analyzes motion data by extracting, filtering, and interpolating feature data for specified body joints,
% identifying epochs of motion based on peaks and troughs in the mean X coordinates, and visualizing the segmented motion data.
% It processes data for shoulders, hips, eyes, and ankles to compute the mean X coordinates, identifies epochs based on peaks 
% and troughs, extracts the corresponding left and right X and Y coordinates for each epoch, and visualizes the epochs and 
% coordinates for detailed analysis.
%% Varargins specified (WARNING: THESE ARE HARDCODED VALUES/ACCESS POINTS)
bufferSize = 2; 
%% Extract, filter, and interpolate feature data for different body parts and calculate the mean of the X coordinates.
part1Data = helper_extract_filter_interpolate_feature_data(filteredData, 'ankle', videoTime,conf_threshold,videoObj);
all_means_matrix = mean([part1Data.left_X, part1Data.right_X], 2);
% Calculate the mean across columns for each row to get the overall mean
overall_mean_x = mean(all_means_matrix, 2);
%% Identify the peaks and troughs of the dataset and plot the result
% Plot the overall_mean_x data, the peaks, the troughts, label the axes, add legend 
% Define the path where the excel file might be located
videoPath = videoObj.Path;
videoName = videoObj.Name;

% Define the full path to the excel file
excelFileName = fullfile(videoPath, strcat('epoch_selection_', videoName, '.xlsx'));
% Check if the file exists
if isfile(excelFileName)
    % Load the excel file
    peaksData = readtable(excelFileName, 'Sheet', 'Peaks');
    troughsData = readtable(excelFileName, 'Sheet', 'Troughs');
    % Extract peak and trough information
    peakLocations = peaksData.peakLocations;
    peakValues = peaksData.peakValues;
    troughLocations = troughsData.troughLocations;
    troughValues = troughsData.troughValues;
else
    % File does not exist, prompt for manual extraction
    disp('No existing data file found. Please manually select peaks and troughs.');
    MakeFigure;
    plot(overall_mean_x, 'b');
    title('Click to select peaks, then press "Enter"');
    xlabel('Frame');
    ylabel('Mean X Coordinate');
    % Use ginput to manually select peaks
    [peakX, peakY] = ginput();
    peakLocations = round(peakX);
    peakValues = peakY;    
    % Now select troughs
    title('Click to select troughs, then press "Enter"');
    [troughX, troughY] = ginput();
    troughLocations = round(troughX);
    troughValues = -troughY; % Invert the values because ginput will give positive values    
    % Plot the selected peaks and troughs on the graph
    hold on;
    plot(peakLocations, peakValues, 'rv', 'MarkerFaceColor', 'r', 'DisplayName', 'Peaks');
    plot(troughLocations, -troughValues, 'gs', 'MarkerFaceColor', 'g', 'DisplayName', 'Troughs');
    legend('show');
    hold off;    
    % Save the data to an Excel file
    T_peak = table(peakLocations, peakValues);
    T_troughs = table(troughLocations, troughValues);
    % Write the tables to separate sheets
    writetable(T_peak, excelFileName, 'Sheet', 'Peaks');
    writetable(T_troughs, excelFileName, 'Sheet', 'Troughs');
    disp(['Data saved to ', excelFileName]);
end
%% This loop creates epochs in a sliding window fashion. For the first peak, it checks for a following trough to define the 
% first epoch. For subsequent peaks, it creates two epochs: one from the peak to the next trough, and another from the previous 
% trough to the current peak. For the final peak, it creates an epoch that extends from the last trough to the peak itself. 
% This approach ensures that every point is considered as part of an epoch, capturing the complete motion between peaks and troughs.

% Initialize epochs cell array
epochs = {};
% Loop through the peak and trough locations to identify epochs
for i = 1:length(peakLocations)    
    % For the first peak, create an epoch only if there's a trough after it
    if i == 1 && ~isempty(find(troughLocations > peakLocations(i), 1))
        epochEnd = troughLocations(find(troughLocations > peakLocations(i), 1));
        epochs{end+1} = [peakLocations(i), epochEnd];
    elseif i < length(peakLocations)
        % For middle peaks, create an epoch from the peak to the next trough
        nextTroughIndex = find(troughLocations > peakLocations(i), 1);
        if ~isempty(nextTroughIndex)
            epochs{end+1} = [peakLocations(i), troughLocations(nextTroughIndex)];
        end        
        % Also create an epoch from the previous trough to this peak
        prevTroughIndex = find(troughLocations < peakLocations(i), 1, 'last');
        if ~isempty(prevTroughIndex)
            epochs{end+1} = [troughLocations(prevTroughIndex), peakLocations(i)];
        end
    else
        % For the last peak, create an epoch from the last trough to this peak
        lastTroughIndex = find(troughLocations < peakLocations(i), 1, 'last');
        if ~isempty(lastTroughIndex)
            epochs{end+1} = [troughLocations(lastTroughIndex), peakLocations(i)];
        end
    end
end
%% Convert cell array to a numeric matrix for easier manipulation
epochsMatrix = cell2mat(epochs');
% Sort the matrix based on the start points of each epoch
[~, order] = sort(epochsMatrix(:,1));
epochsMatrixSorted = epochsMatrix(order,:);
% Initialize the reordered epochs array
reorderedEpochs = [epochsMatrixSorted(1,:)];  % Start with the first epoch
% Loop through the sorted epochs to find the next continuous epoch
for i = 1:size(epochsMatrixSorted, 1)-1
    % Find the epoch that starts immediately after the end of the last added epoch
    [~, closestIndex] = min(abs(epochsMatrixSorted(:,1) - reorderedEpochs(end,2)));    
    % Check if the found epoch is continuous or the closest to being continuous
    if epochsMatrixSorted(closestIndex, 1) >= reorderedEpochs(end,2)
        % Add the next closest epoch to the reordered list
        reorderedEpochs = [reorderedEpochs; epochsMatrixSorted(closestIndex,:)];        
        % Mark the added epoch to avoid re-selection
        epochsMatrixSorted(closestIndex,1) = Inf;
    end
end
% Convert the numeric matrix back to a cell array
reorderedEpochsCell = mat2cell(reorderedEpochs, ones(1, size(reorderedEpochs, 1)), 2);
%% This section of the code visualizes the identified epochs overlaid on the plot of the overall mean X coordinate.
% Each epoch is then plotted on top of this, marked by black circles connected by lines, indicating the start and end points 
% of each epoch.
MakeFigure;
plot(overall_mean_x, 'b'); hold on;
for i = 1:length(reorderedEpochsCell)
    epoch = reorderedEpochsCell{i};
    plot(epoch, overall_mean_x(epoch), 'ko-', 'LineWidth', 2, 'MarkerFaceColor', 'k');
end
title('Overall Mean X Coordinate with Identified Epochs');
xlabel('Frame');
ylabel('Mean X Coordinate');
legend('Mean X Coordinate', 'Identified Epochs');
hold off;
%% This section initializes a structure array 'epochData' to store the segmented data corresponding to each epoch.
% It then iterates over the array of epochs; within each iteration, the code extracts segments of left and right X and Y 
% coordinates from the 'part4Data' dataset, corresponding to the ankle's position data, effectively splitting
% the continuous time series data into discrete chunks.
% Initialize a structure array to hold the epoch data
epochData = struct();
% Iterate through each defined epoch to extract and store the corresponding left and right X, Y coordinates.
for i = 1:length(reorderedEpochsCell)
    % Get the current epoch's start and end points
    epochStartPoint = reorderedEpochsCell{i}(1);
    epochEndPoint = reorderedEpochsCell{i}(2);    
    % Extract data for the current epoch
    epochData(i).left_X = part1Data.left_X(epochStartPoint:epochEndPoint);
    epochData(i).left_Y = part1Data.left_Y(epochStartPoint:epochEndPoint);
    epochData(i).right_X = part1Data.right_X(epochStartPoint:epochEndPoint);
    epochData(i).right_Y = part1Data.right_Y(epochStartPoint:epochEndPoint);    
    % Assign startFrame and endFrame for each epoch
    epochData(i).startFrame = epochStartPoint;
    epochData(i).endFrame = epochEndPoint;
    % Here, segment the videoTime array for the current epoch
    % Make sure that the videoTime array is long enough to accommodate the endFrame
    if epochEndPoint <= length(videoTime)
        epochData(i).videoTime = videoTime(epochStartPoint:epochEndPoint);
    else
        warning('videoTime does not extend to the end of the current epoch.');
        epochData(i).videoTime = videoTime(epochStartPoint:end);  % Use whatever is available
    end
end
%%
% Iterate through each epoch to find crossovers and prune the data
for i = 1:length(reorderedEpochsCell)
    % Extract the left and right X coordinates and the videoTime for the current epoch
    left_X = epochData(i).left_X;
    right_X = epochData(i).right_X;
    currentEpochVideoTime = epochData(i).videoTime;    
    % Find indices where left_X crosses over right_X
    crossoverIndices = find(diff(sign(left_X - right_X)) ~= 0);  
    % Check if there are at least two crossovers to define a range
    if length(crossoverIndices) >= 2
        % Define the start and end points for the active region
        activeStart = max(crossoverIndices(1) - bufferSize, 1);
        activeEnd = min(crossoverIndices(end) + bufferSize, length(left_X));
        % Update the epoch data to only include the active moving region
        epochDataPruned(i).left_X = left_X(activeStart:activeEnd);
        epochDataPruned(i).left_Y = epochData(i).left_Y(activeStart:activeEnd);
        epochDataPruned(i).right_X = right_X(activeStart:activeEnd);
        epochDataPruned(i).right_Y = epochData(i).right_Y(activeStart:activeEnd);
        % Prune the videoTime segment to match the pruned data range
        epochDataPruned(i).videoTime = currentEpochVideoTime(activeStart:activeEnd);
        % Store the indices of the first and last crossovers relative to the original data
        epochDataPruned(i).firstCrossover = epochData(i).startFrame + activeStart - 1;
        epochDataPruned(i).lastCrossover = epochData(i).startFrame + activeEnd - 1;
    else
        % If there are not enough crossovers, this might indicate an issue or non-moving epoch
        % Indicate that this epoch does not have an active moving region
        epochDataPruned(i).activeRegion = false;
    end
end
%% This section creates two figures with subplots for each epoch, one figure for the X coordinates and one for the Y coordinates.
% In each subplot of the X or Y coordinates figure, the left and right X coordinates are plotted for each epoch.
% The X and Y labels are set for the axes to indicate the frame number and the respective coordinate values.
% Store the total number of epochs which will be used for plotting and analysis.
numEpochs = length(reorderedEpochsCell);
% Define the number of columns for the subplot grid
numColumns = 2;
% Calculate the number of rows needed based on the number of epochs and the desired number of columns
numRows = ceil(numEpochs / numColumns);
% Create a figure for X coordinates
MakeFigure; hold on;
for i = 1:numEpochs
    subplot(numRows, numColumns, i);
    plot(epochDataPruned(i).left_X, 'b-'); hold on;
    plot(epochDataPruned(i).right_X, 'r-');
    title(['Epoch ' num2str(i) ' X Coordinates']);
    if i == numEpochs % Move legend to the last subplot for clarity
        legend('Left Ankle X', 'Right Ankle X');
    end
    hold off;
end
xlabel('Frame');
ylabel('X Coordinate');

% Create a figure for Y coordinates
MakeFigure; hold on;
for i = 1:numEpochs
    subplot(numRows, numColumns, i);
    plot(epochDataPruned(i).left_Y, 'b-'); hold on;
    plot(epochDataPruned(i).right_Y, 'r-');
    title(['Epoch ' num2str(i) ' Y Coordinates']);
    if i == numEpochs % Move legend to the last subplot for clarity
        legend('Left Ankle Y', 'Right Ankle Y');
    end
    hold off;
end
xlabel('Frame');
ylabel('Y Coordinate');
end