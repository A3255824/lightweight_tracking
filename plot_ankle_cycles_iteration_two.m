function plot_ankle_cycles_iteration_two(filteredData,videoTime,videoObj,conf_threshold)
%% This function analyzes the fluctuations/cycles of the gait in x and y space
% Identify the confidence interval value cutoff and extract the
% ankle-specific data 
joint = 'ankle';
ankleData = helper_extract_filter_interpolate_feature_data(filteredData, joint, videoTime,...
    conf_threshold,videoObj);
%% Plot all epochs for a single gait type
% MakeFigure; 
% plot(ankleData.videoTime,ankleData.left_Y,'LineWidth', 4); hold on; 
% plot(ankleData.videoTime,ankleData.right_Y, 'LineWidth', 4);
% ylabel('Y Axis Coordinate'); 
% xlabel('Time (seconds)');
% leg = legend('Left Y Ankle','Right Y Ankle');
% set(leg, 'Box', 'off');
% set(gca, 'FontSize', 25, 'LineWidth', 5);
% box 'off'
% 
% MakeFigure; 
% plot(ankleData.videoTime,ankleData.left_X,'LineWidth', 4); hold on; 
% plot(ankleData.videoTime,ankleData.right_X, 'LineWidth', 4);
% ylabel('X Axis Coordinate'); 
% xlabel('Time (seconds)');
% leg = legend('Left Y Ankle','Right Y Ankle');
% set(leg, 'Box', 'off');
% set(gca, 'FontSize', 25, 'LineWidth', 5);
% box 'off'
end