function plot_patient_data(off_table, on_table, p_wilcoxon, p_f_test, ci_f_test, fstat_f_test, metricName, yLabel, yUnit)
    MakeFigure; % Create a new figure window
    % Get a matrix of colors, one for each patient
    colors = lines(size(off_table, 2));
    % Initialize an array to hold scatter plot handles for the legend
    scatterHandles = gobjects(size(off_table, 2), 1);
    % Plot individual patient means as points and connect them with lines
    for i = 1:size(off_table, 2)
        % Define the color for the current patient
        currentColor = colors(i, :);
        % Plot 'Off' scatter
        scatterHandles(i) = scatter(1, off_table(1, i), 'o', ...
            'MarkerEdgeColor', currentColor, 'MarkerFaceColor', currentColor, ...
            'SizeData', 100);
        hold on;
        % Plot error bar for 'Off' scatter
        errorbar(1, off_table(1, i), off_table(2, i), 'Color', currentColor, ...
            'LineWidth', 2, 'CapSize', 10);
        % Plot 'On' scatter
        scatter(2, on_table(1, i), 'o', 'MarkerEdgeColor', currentColor, ...
            'MarkerFaceColor', currentColor, 'SizeData', 100);
        % Plot error bar for 'On' scatter
        errorbar(2, on_table(1, i), on_table(2, i), 'Color', currentColor, ...
            'LineWidth', 2, 'CapSize', 10);
        % Connect 'Off' and 'On' points with a line
        plot([1, 2], [off_table(1, i), on_table(1, i)], 'Color', currentColor, ...
            'LineWidth', 2);
    end
    % Create legend entries
    legendEntries = arrayfun(@(x) sprintf('Patient #%d', x), 1:size(off_table, 2), 'UniformOutput', false);
    legend(scatterHandles, legendEntries, 'Location', 'bestoutside');
    % Customize the plot
    xlim([0.5 2.5]); % Set X-axis limits
    set(gca, 'XTick', [1, 2], 'XTickLabel', {'OFF Dopaminergic State', 'ON Dopaminergic State'});
    ylabel([yLabel ' (' yUnit ')']);
    % Update title to include F-test results
    title(sprintf('%s - %d Patients - Wilcoxon p-value: %g, F-test p-value: %g, CI: [%g, %g], F-stat: %g', ...
        metricName, size(off_table, 2), p_wilcoxon, p_f_test, ci_f_test(1), ci_f_test(2), fstat_f_test));
    set(gca, 'LineWidth', 2, 'FontSize', 14);
    grid on;
    hold off;
end