function  combinedStructure = compute_stride_characteristic_iteration_three(epochData,...
    epochDataPruned,videoTime,sagittal_length)
%% This is a master function to analyze gait metrics of stride and gait cycles.
%% Function analyzes the gait characteristics of a subject by computing the stride length and 
% asymmetry between the left and right foot during gait cycles. It first establishes a conversion factor to
% translate pixel measurements into inches based on the 'sagittal length'. Then, it iterates through the
% provided gait epochs to identify crossover points between the left and right foot x-coordinates, calculates 
% the time intervals and distances at these points, and assesses the stride length asymmetry. The output is a 
% structured record of the stride times, lengths, and asymmetry measures for each foot.
structure_stride = compute_stride_time_length_asymmetry_iteration_four(epochDataPruned,videoTime,sagittal_length); 
%% Function processes gait analysis data by pairing consecutive epochs to form complete gait cycles. It 
% computes cycle times for both left and right sides, evaluates the asymmetry between these cycles, and 
% visualizes the combined cycles for each pair. Additionally, it calculates and stores statistics such as 
% average and standard deviation for cycle times and asymmetries, aiding in the analysis of gait dynamics 
% and symmetry.
structure_gait_cycle = combine_epochs_into_cycles(epochData, videoTime);
%% Create a new structure
combinedStructure = struct();
% Assign existing structures as fields in the new structure
combinedStructure.stride_characteristics = structure_stride;
combinedStructure.gait_cycle_times = structure_gait_cycle.gait_cycle_stats;
end