function outputTable = helper_extract_filter_interpolate_feature_data(filteredData, joint,...
    videoTime, conf_threshold,videoObj)
% This function processes the filtered data to extract feature data for a specified joint (shoulder, hip, eye, or ankle).
% It accounts for the maximum video height to correct the y-axis orientation, filters out data below a confidence threshold,
% and linearly interpolates missing data points. The output is a table with interpolated values for video time, frame number,
% x and y coordinates, and confidence levels for the specified joint.

% This is the maximum height of the video as defined by videoObj
% This is used to transpose the y coordinates such that going up increases in Y axis
maxVideoHeight = videoObj.Height;

% Create variable names for x, y, and confidence columns
right_x_col = ['right_' joint 'X'];
left_x_col = ['left_' joint 'X'];
right_y_col = ['right_' joint 'Y'];
left_y_col = ['left_' joint 'Y'];
right_conf_col = ['right_' joint 'Conf'];
left_conf_col = ['left_' joint 'Conf'];

% Get the column indices for x, y, and confidence for both sides
right_x_col_idx = find(strcmp(filteredData.Properties.VariableNames, right_x_col));
left_x_col_idx = find(strcmp(filteredData.Properties.VariableNames, left_x_col));
right_y_col_idx = find(strcmp(filteredData.Properties.VariableNames, right_y_col));
left_y_col_idx = find(strcmp(filteredData.Properties.VariableNames, left_y_col));
right_conf_col_idx = find(strcmp(filteredData.Properties.VariableNames, right_conf_col));
left_conf_col_idx = find(strcmp(filteredData.Properties.VariableNames, left_conf_col));

% Extract the data for x, y, and confidence for both sides
right_x = filteredData{:, right_x_col_idx};
left_x = filteredData{:, left_x_col_idx};
right_y = filteredData{:, right_y_col_idx};
left_y = filteredData{:, left_y_col_idx};
right_conf = filteredData{:, right_conf_col_idx};
left_conf = filteredData{:, left_conf_col_idx};

% Create logical indices for confidence above the threshold for both sides
valid_indices = (right_conf >= conf_threshold) & (left_conf >= conf_threshold);

% Linearly interpolate missing values based on valid indices
all_indices = (1:length(right_x))';
right_x_interp = interp1(all_indices(valid_indices), right_x(valid_indices), all_indices, 'linear', 'extrap');
right_y_interp = interp1(all_indices(valid_indices), right_y(valid_indices), all_indices, 'linear', 'extrap');
left_x_interp = interp1(all_indices(valid_indices), left_x(valid_indices), all_indices, 'linear', 'extrap');
left_y_interp = interp1(all_indices(valid_indices), left_y(valid_indices), all_indices, 'linear', 'extrap');
% Linearly interpolate missing values based on valid indices for the time
% and frame numbers in the video
videoTime_interp = interp1(all_indices(valid_indices), videoTime(valid_indices), all_indices, 'linear', 'extrap');
frameNumber_interp = interp1(all_indices(valid_indices), filteredData.FrameNumber(valid_indices), all_indices, 'linear', 'extrap');

% This changes the direction of top/bottom in the y coordinate
right_y_interp = abs(right_y_interp - maxVideoHeight);
left_y_interp = abs(left_y_interp - maxVideoHeight);

% Construct the output table with interpolated values
outputTable = table(videoTime_interp, frameNumber_interp,... 
    right_x_interp, right_y_interp, right_conf, left_x_interp, left_y_interp, ...
    left_conf, 'VariableNames', {'videoTime', 'frameNumber','right_X', 'right_Y',...
    'right_Conf', 'left_X', 'left_Y', 'left_Conf'});
end