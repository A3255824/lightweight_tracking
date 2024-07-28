function simple_extract_statistics(strideFlag,structure,variable,title,yLabel,yUnits)
if strideFlag
    [off, on] = aggregate_data_stride(structure,variable);
    [p_wilcoxon, ~, ~] = signrank(off(1,:),on(1,:));
    [~,p_variance,ci,fstats] = vartest2(off(1,:),on(1,:));
    plot_patient_data(off, on, p_wilcoxon, p_variance,ci, fstats.fstat,title, yLabel, yUnits);
else
    [off, on] = aggregate_gait_cycle_times(structure);
    [p_wilcoxon, ~, ~] = signrank(off(1,:), on(1,:));
    [~,p_variance,ci,fstats] = vartest2(off(1,:),on(1,:));
    plot_patient_data(off, on, p_wilcoxon, p_variance,ci, fstats.fstat,title, yLabel, yUnits);
end
end
