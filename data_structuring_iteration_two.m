function [filteredData,videoTime,videoObj] = data_structuring_iteration_two(data, videoFileName)
% Reading the video properties to compute the frame rate of the
% acquisition
videoObj = VideoReader(videoFileName);
frameRate = videoObj.FrameRate;
% Extract the timestamp from the video file name
% Assuming videoFileName is the name of your video file
videoFileName = videoObj.name; 
% Define the regular expression pattern to match the timestamp
% The pattern will match any characters after 'Video-' and before 'AM' or 'PM'
timeStampPattern_firstOP = 'Video\D+(\d+\D\d+\D\d+\D\d+\D\d+\D\d+)\D(AM|PM)';
timeStampPattern_secondOP = 'Video\s+(\d+-\d+-\d+),\s+(\d+\.\d+\.\d+)\s+(AM|PM)';
% Extract the timestamp from the video file name
if ~isempty(regexp(videoFileName, timeStampPattern_firstOP, 'tokens'))
    timeStampMatch = regexp(videoFileName, timeStampPattern_firstOP, 'tokens');
    % Extract the timestamp and replace non-digit characters with a dash
    timeStamp = timeStampMatch{1}{1};
    timeStamp = regexprep(timeStamp, '\D', '-');
elseif ~isempty(regexp(videoFileName, timeStampPattern_secondOP, 'tokens'))
    timeStampMatch = regexp(videoFileName, timeStampPattern_secondOP, 'tokens');
    % Extract the timestamp and replace non-digit characters with a dash
    timeStamp = timeStampMatch{1}{1};
    timeStamp = regexprep(timeStamp, '\D', '-');
end

if isempty(timeStampMatch)
    error('Timestamp could not be extracted from the video file name.');
end
% Remove all non-numeric characters from the timeStamp
numericTimeStamp = regexprep(timeStamp, '\D', '');
% Assuming 'data' is a table and the first column contains the video file names
% Convert the first column to string if it's not already
dataFirstCol = string(data.(1));
% Remove all non-numeric characters from each entry in dataFirstCol
numericDataFirstCol = regexprep(dataFirstCol, '\D', '');
% Find all rows where the numeric part of the timestamp in dataFirstCol matches numericTimeStamp
rowsWithTimeStamp = contains(numericDataFirstCol, numericTimeStamp);
% Filter the data for those rows
filteredData = data(rowsWithTimeStamp, :);
% Calculate time corresponding to each frame number and turn the time into
% minutes and seconds.
timePerFrame = 1 / frameRate; % Time per frame in seconds
videoTime = filteredData.FrameNumber * timePerFrame;
end