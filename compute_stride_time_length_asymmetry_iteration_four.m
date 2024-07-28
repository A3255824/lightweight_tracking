function stride_data = compute_stride_time_length_asymmetry_iteration_four(epochData, videoTime, sagittal_length)
    %% Function analyzes the gait characteristics of a subject by computing the stride length and asymmetry between the left and 
    % right foot during gait cycles. It first establishes a conversion factor to translate pixel measurements into inches 
    % based on the 'sagittal length'. Then, it iterates through the provided gait epochs to identify crossover points 
    % between the left and right foot x-coordinates, calculates the time intervals and distances at these points, and 
    % assesses the stride length asymmetry. The output is a structured record of the stride times, lengths, and asymmetry 
    % measures for each foot.    
    %% Calculate the conversion factor from pixels to inches using the maximum total x-coordinate range
    % across all epochs in pixels and the known sagittal length in inches.
    maxTotalXDistanceInPixels = 0;    
    % Loop through each epoch to find the maximum total distance in x-coordinates
    for epochIdx = 1:length(epochData)
        left_X = epochData(epochIdx).left_X;
        right_X = epochData(epochIdx).right_X;        
        % Check if left_X or right_X are empty
        if isempty(left_X) || isempty(right_X)
            disp(['Epoch ' num2str(epochIdx) ' has empty data.']);
            continue; % Skip this iteration
        end        
        % Update the maximum total distance if the current one is larger
        totalXDistanceInPixels = max([left_X; right_X]) - min([left_X; right_X]);
        maxTotalXDistanceInPixels = max(maxTotalXDistanceInPixels, totalXDistanceInPixels);
    end    
    % Calculate the conversion factor from pixels to inches
    pixelsToInches = sagittal_length / maxTotalXDistanceInPixels;    
    %% Identify crossover points and calculate stride characteristics for each epoch
    % Initialize vectors to store time intervals and distances between crossovers for all epochs
    all_epochs_stride_data = struct('stride_time_leading', {}, ...
                                    'stride_time_trailing', {}, ...
                                    'stride_length_leading', {}, ...
                                    'stride_length_trailing', {}, ...
                                    'asymmetry_between_feet', {}, ...
                                    'normalized_asymmetry', {}, ...
                                    'directional_asymmetry', {});
    % Loop through each epoch in epochData
    for epochIdx = 1:length(epochData)
        % Get left_X, right_X, and the epoch-specific videoTime for the current epoch
        left_X = epochData(epochIdx).left_X;
        right_X = epochData(epochIdx).right_X;
        % Initialize crossover points
        crossoverIdx = [];
        for i = 1:length(left_X)-1
            % Check if the lines are crossing
            if (left_X(i) - right_X(i)) * (left_X(i+1) - right_X(i+1)) < 0
                % The exact crossover point can be found by linear interpolation
                % Slopes of the lines between the points
                slope_left = left_X(i+1) - left_X(i);
                slope_right = right_X(i+1) - right_X(i);
                % Intersect point (where the difference is zero)
                intercept = (right_X(i) - left_X(i)) / (slope_left - slope_right);
                % Crossover index adjusted for interpolation
                crossover_point = i + intercept;
                crossoverIdx = [crossoverIdx; crossover_point];
            end
        end
        % Plot the left and right foot positions
        MakeFigure; hold on;
        plot(left_X, 'b-', 'DisplayName', 'Left Foot');
        hold on;
        plot(right_X, 'r-', 'DisplayName', 'Right Foot');
        % Plot vertical lines at the crossover points
        for i = 1:length(crossoverIdx)
            xline(crossoverIdx(i), 'g-', 'DisplayName', 'Crossover');
        end
        title('Gait Crossover Points for Epoch 1');
        xlabel('Sample Index');
        ylabel('Position (pixels)');
        hold off;        
        %% Calculate stride points for leading foot (first, third, fifth crossover points, etc.)
        leading_stride_points = crossoverIdx(1:2:end);
        % Calculate stride points for trailing foot (second, fourth, sixth crossover points, etc.)
        trailing_stride_points = crossoverIdx(2:2:end);
        % New figure for plotting the actual crossover points without connecting lines
        MakeFigure;
        plot(left_X, 'b-', 'DisplayName', 'Left Foot');
        hold on;
        plot(right_X, 'r-', 'DisplayName', 'Right Foot');
        % Plot the crossover points as dots for the leading foot strides
        for i = 1:length(leading_stride_points)-1
            % Plot start of stride (circle marker)
            plot(leading_stride_points(i), interp1(1:length(left_X), left_X, leading_stride_points(i), 'linear'), 'go', 'MarkerSize', 10, 'LineWidth', 2);
            % Plot end of stride (cross marker)
            plot(leading_stride_points(i+1), interp1(1:length(left_X), left_X, leading_stride_points(i+1), 'linear'), 'gx', 'MarkerSize', 10, 'LineWidth', 2);
        end
        % Plot the crossover points as dots for the trailing foot strides
        for i = 1:length(trailing_stride_points)-1
            % Plot start of stride (circle marker)
            plot(trailing_stride_points(i), interp1(1:length(right_X), right_X, trailing_stride_points(i), 'linear'), 'mo', 'MarkerSize', 10, 'LineWidth', 2);
            % Plot end of stride (cross marker)
            plot(trailing_stride_points(i+1), interp1(1:length(right_X), right_X, trailing_stride_points(i+1), 'linear'), 'mx', 'MarkerSize', 10, 'LineWidth', 2);
        end
        title('Stride Identification on Gait Plot');
        xlabel('Sample Index');
        ylabel('Position (pixels)');
        hold off;
        % Calculate the time and distance of each stride
        % Initialize arrays to store stride time and distance for each foot
        leading_stride_times = [];
        leading_stride_distances = [];
        % Calculate stride time and distance for the leading foot
        for i = 1:length(leading_stride_points)-1
            stride_start_idx = round(leading_stride_points(i));
            stride_end_idx = round(leading_stride_points(i+1));
            stride_time = abs(videoTime(stride_end_idx) - videoTime(stride_start_idx));
            stride_distance = abs(left_X(stride_end_idx) - left_X(stride_start_idx)) * pixelsToInches;
            % Store the calculated stride time and distance for the leading foot
            leading_stride_times = [leading_stride_times; stride_time];
            leading_stride_distances = [leading_stride_distances; stride_distance];
        end
        % Initialize arrays to store stride time and distance for the trailing foot
        trailing_stride_times = [];
        trailing_stride_distances = [];
        % Calculate stride time and distance for the trailing foot
        for i = 1:length(trailing_stride_points)-1
            stride_start_idx = round(trailing_stride_points(i));
            stride_end_idx = round(trailing_stride_points(i+1));
            stride_time = abs(videoTime(stride_end_idx) - videoTime(stride_start_idx));
            stride_distance = abs(right_X(stride_end_idx) - right_X(stride_start_idx)) * pixelsToInches;
            % Store the calculated stride time and distance for the trailing foot
            trailing_stride_times = [trailing_stride_times; stride_time];
            trailing_stride_distances = [trailing_stride_distances; stride_distance];
        end
        % Calculate stride velocity for the leading and trailing foot
        leading_stride_velocities = leading_stride_distances ./ leading_stride_times;
        trailing_stride_velocities = trailing_stride_distances ./ trailing_stride_times;
        % Store the calculated stride velocities in the structure for the current epoch
        all_epochs_stride_data(epochIdx).stride_velocity_leading.all = leading_stride_velocities;
        all_epochs_stride_data(epochIdx).stride_velocity_trailing.all = trailing_stride_velocities;
        % Calculate asymmetry as the absolute difference between left and right distances
        % Initialize arrays to store asymmetry information
        asymmetry = [];
        asymmetry_normalized = [];
        directional_asymmetry = [];
        % Calculate asymmetry between the corresponding strides of the leading and trailing foot
        for i = 1:min(length(leading_stride_distances), length(trailing_stride_distances))
            % Absolute difference between the strides of the leading and trailing foot
            stride_asymmetry = abs(leading_stride_distances(i) - trailing_stride_distances(i));
            asymmetry = [asymmetry; stride_asymmetry];
            % Average stride length for normalization
            average_stride_length = (leading_stride_distances(i) + trailing_stride_distances(i)) / 2;
            % Normalized asymmetry
            normalized_asymmetry = stride_asymmetry / average_stride_length;
            asymmetry_normalized = [asymmetry_normalized; normalized_asymmetry];
            % Directional asymmetry takes into account the direction of the difference
            directional_stride_asymmetry = leading_stride_distances(i) - trailing_stride_distances(i);
            directional_asymmetry = [directional_asymmetry; directional_stride_asymmetry];
        end
        % After calculating each metric for the current epoch, store them in the structure
        all_epochs_stride_data(epochIdx).stride_time_leading.all = leading_stride_times;
        all_epochs_stride_data(epochIdx).stride_time_trailing.all = trailing_stride_times;
        all_epochs_stride_data(epochIdx).stride_length_leading.all = leading_stride_distances;
        all_epochs_stride_data(epochIdx).stride_length_trailing.all = trailing_stride_distances;
        all_epochs_stride_data(epochIdx).asymmetry_between_feet.all = asymmetry;
        all_epochs_stride_data(epochIdx).normalized_asymmetry.all = asymmetry_normalized;
        all_epochs_stride_data(epochIdx).directional_asymmetry.all = directional_asymmetry;
        % Calculate mean and standard deviation for leading_stride_times
        all_epochs_stride_data(epochIdx).stride_time_leading.mean = nanmean(leading_stride_times);
        all_epochs_stride_data(epochIdx).stride_time_leading.std = nanstd(leading_stride_times);
        % Calculate mean and standard deviation for trailing_stride_times
        all_epochs_stride_data(epochIdx).stride_time_trailing.mean = nanmean(trailing_stride_times);
        all_epochs_stride_data(epochIdx).stride_time_trailing.std = nanstd(trailing_stride_times);
        % Calculate mean and standard deviation for leading_stride_distances
        all_epochs_stride_data(epochIdx).stride_length_leading.mean = nanmean(leading_stride_distances);
        all_epochs_stride_data(epochIdx).stride_length_leading.std = nanstd(leading_stride_distances);
        % Calculate mean and standard deviation for trailing_stride_distances
        all_epochs_stride_data(epochIdx).stride_length_trailing.mean = nanmean(trailing_stride_distances);
        all_epochs_stride_data(epochIdx).stride_length_trailing.std = nanstd(trailing_stride_distances);
        % Calculate mean and standard deviation for asymmetry
        all_epochs_stride_data(epochIdx).asymmetry_between_feet.mean = nanmean(asymmetry);
        all_epochs_stride_data(epochIdx).asymmetry_between_feet.std = nanstd(asymmetry);
        % Calculate mean and standard deviation for normalized_asymmetry
        all_epochs_stride_data(epochIdx).normalized_asymmetry.mean = nanmean(asymmetry_normalized);
        all_epochs_stride_data(epochIdx).normalized_asymmetry.std = nanstd(asymmetry_normalized);
        % Calculate mean and standard deviation for directional_asymmetry
        all_epochs_stride_data(epochIdx).directional_asymmetry.mean = nanmean(directional_asymmetry);
        all_epochs_stride_data(epochIdx).directional_asymmetry.std = nanstd(directional_asymmetry);
        % Calculate mean and standard deviation for leading_stride_velocities
        all_epochs_stride_data(epochIdx).stride_velocity_leading.mean = nanmean(leading_stride_velocities);
        all_epochs_stride_data(epochIdx).stride_velocity_leading.std = nanstd(leading_stride_velocities);
        % Calculate mean and standard deviation for trailing_stride_velocities
        all_epochs_stride_data(epochIdx).stride_velocity_trailing.mean = nanmean(trailing_stride_velocities);
        all_epochs_stride_data(epochIdx).stride_velocity_trailing.std = nanstd(trailing_stride_velocities);
    end
    first_crossovers = [epochData.firstCrossover];
    last_crossovers = [epochData.lastCrossover]; 
    % Compute the turnaround times between epochs
    epoch_times = videoTime(last_crossovers) - videoTime(first_crossovers);
    % Initialize a vector to hold the turnaround times
    turnaround_times = zeros(1, length(first_crossovers) - 1);
    % Calculate the turnaround times
    for idx = 1:length(turnaround_times)
        turnaround_times(idx) = videoTime(first_crossovers(idx + 1)) - videoTime(last_crossovers(idx));
    end
    %% Exported structures
    % Calculate mean and standard deviation for leading_stride_times
    stride_data.stride_time_leading.all = arrayfun(@(x)  x.stride_time_leading.all, all_epochs_stride_data, 'UniformOutput', false);
    stride_data.stride_time_leading.mean = nanmean(arrayfun(@(x) mean(x.stride_time_leading.all), all_epochs_stride_data));
    stride_data.stride_time_leading.std = nanstd(arrayfun(@(x) mean(x.stride_time_leading.all), all_epochs_stride_data));
    % Calculate mean and standard deviation for trailing_stride_times
    stride_data.stride_time_trailing.all = arrayfun(@(x)  x.stride_time_trailing.all, all_epochs_stride_data, 'UniformOutput', false);
    stride_data.stride_time_trailing.mean = nanmean(arrayfun(@(x) mean(x.stride_time_trailing.all), all_epochs_stride_data));
    stride_data.stride_time_trailing.std = nanstd(arrayfun(@(x) mean(x.stride_time_trailing.all), all_epochs_stride_data));
    % Calculate mean and standard deviation for leading_stride_distances
    stride_data.stride_length_leading.all = arrayfun(@(x)  x.stride_length_leading.all, all_epochs_stride_data, 'UniformOutput', false);
    stride_data.stride_length_leading.mean = nanmean(arrayfun(@(x) mean(x.stride_length_leading.all), all_epochs_stride_data));
    stride_data.stride_length_leading.std = nanstd(arrayfun(@(x) mean(x.stride_length_leading.all), all_epochs_stride_data));
    % Calculate mean and standard deviation for trailing_stride_distances
    stride_data.stride_length_trailing.all = arrayfun(@(x)  x.stride_length_trailing.all, all_epochs_stride_data, 'UniformOutput', false);
    stride_data.stride_length_trailing.mean = nanmean(arrayfun(@(x) mean(x.stride_length_trailing.all), all_epochs_stride_data));
    stride_data.stride_length_trailing.std = nanstd(arrayfun(@(x) mean(x.stride_length_trailing.all), all_epochs_stride_data));
    % Calculate mean and standard deviation for asymmetry
    stride_data.asymmetry_between_feet.mean = nanmean(arrayfun(@(x) mean(x.asymmetry_between_feet.all), all_epochs_stride_data));
    stride_data.asymmetry_between_feet.std = nanstd(arrayfun(@(x) mean(x.asymmetry_between_feet.all), all_epochs_stride_data));
    % Calculate mean and standard deviation for normalized_asymmetry
    stride_data.normalized_asymmetry.mean = nanmean(arrayfun(@(x) mean(x.normalized_asymmetry.all), all_epochs_stride_data));
    stride_data.normalized_asymmetry.std = nanstd(arrayfun(@(x) mean(x.normalized_asymmetry.all), all_epochs_stride_data));
    % Calculate mean and standard deviation for directional_asymmetry
    stride_data.directional_asymmetry.mean = nanmean(arrayfun(@(x) mean(x.directional_asymmetry.all), all_epochs_stride_data));
    stride_data.directional_asymmetry.std = nanstd(arrayfun(@(x) mean(x.directional_asymmetry.all), all_epochs_stride_data));
    % Calculate mean and std for leading stride velocities
    stride_data.stride_velocity_leading.all = arrayfun(@(x)  x.stride_velocity_leading.all, all_epochs_stride_data, 'UniformOutput', false);
    stride_data.stride_velocity_leading.mean = nanmean(arrayfun(@(x) mean(x.stride_velocity_leading.all), all_epochs_stride_data));
    stride_data.stride_velocity_leading.std = nanstd(arrayfun(@(x) mean(x.stride_velocity_leading.all), all_epochs_stride_data));
    % Calculate mean and std for trailing stride velocities:
    stride_data.stride_velocity_trailing.all = arrayfun(@(x)  x.stride_velocity_trailing.all, all_epochs_stride_data, 'UniformOutput', false);
    stride_data.stride_velocity_trailing.mean = nanmean(arrayfun(@(x) mean(x.stride_velocity_trailing.all), all_epochs_stride_data));
    stride_data.stride_velocity_trailing.std = nanstd(arrayfun(@(x) mean(x.stride_velocity_trailing.all), all_epochs_stride_data));
    % Calculate the overall mean and std for epoch times and distances
    stride_data.epoch_times.all = epoch_times;
    stride_data.epoch_times.mean = nanmean(epoch_times);
    stride_data.epoch_times.std = nanstd(epoch_times);
    stride_data.turnaround_times.all = turnaround_times;
    stride_data.turnaround_times.mean = nanmean(turnaround_times);
    stride_data.turnaround_times.std = nanstd(turnaround_times); 
end