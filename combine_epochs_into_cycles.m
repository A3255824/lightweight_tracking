function combinedCycles = combine_epochs_into_cycles(epochData, videoTime)
% This function, combine_epochs_into_cycles, processes gait analysis data by pairing consecutive epochs to 
% form complete gait cycles. It computes cycle times for both left and right sides, evaluates the asymmetry 
% between these cycles, and visualizes the combined cycles for each pair. Additionally, it calculates and 
% stores statistics such as average and standard deviation for cycle times and asymmetries, aiding in the 
% analysis of gait dynamics and symmetry.
%% Number of complete cycles is half the number of epochs (since 2 epochs form 1 complete cycle)
% Assume videoFrameRate is defined and holds the frame rate of the video
numCompleteCycles = floor(length(epochData) / 2);
% Initialize arrays for combined cycles
combinedLeftCycles = cell(numCompleteCycles, 1);
combinedRightCycles = cell(numCompleteCycles, 1);
cycleDurations = zeros(numCompleteCycles, 1);
% Combine epochs into gait cycles and calculate cycle times
for i = 1:numCompleteCycles
    combinedIndex = i;
    epochIndex = (i-1)*2 + 1; % Calculate the index of the first epoch in the pair
    % Combine the current and next epochs for left and right cycles
    combinedLeftCycles{combinedIndex} = [epochData(epochIndex).left_X; epochData(epochIndex+1).left_X];
    combinedRightCycles{combinedIndex} = [epochData(epochIndex).right_X; epochData(epochIndex+1).right_X];
    % Calculate the duration of the current gait cycle
    startTime = videoTime(epochData(epochIndex).startFrame);
    endTime = videoTime(epochData(epochIndex+1).endFrame);
    cycleDurations(combinedIndex) = endTime - startTime;
end
% Determine the layout of subplots based on the number of cycles
numRows = ceil(sqrt(numCompleteCycles));
numCols = ceil(numCompleteCycles / numRows);
% Create a figure to plot the cycles
MakeFigure;
for i = 1:numCompleteCycles
    % Create a subplot for each cycle
    subplot(numRows, numCols, i);
    plot(videoTime(1:length(combinedLeftCycles{i})), combinedLeftCycles{i}, 'b-', 'DisplayName', 'Left X');
    hold on;
    plot(videoTime(1:length(combinedRightCycles{i})), combinedRightCycles{i}, 'r-', 'DisplayName', 'Right X');
    hold off;
    title(sprintf('Cycle %d', i));
    if i == numCompleteCycles
        legend('show');
    end
    xlabel('Time (s)');
    ylabel('X Coordinate (pixels)');
end
sgtitle('Combined Gait Cycles');
%% Save output variables
% Calculate statistics and store them in the output structure
combinedCycles.gait_cycle_times.all = cycleDurations;
% Calculate averages and standard deviations
combinedCycles.gait_cycle_stats.mean = mean(cycleDurations);
combinedCycles.gait_cycle_stats.std = std(cycleDurations);
end