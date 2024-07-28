function [aggregated_means, aggregated_stds] = aggregate_means_stds(data)
    aggregated_means = cellfun(@mean, data, 'UniformOutput', true);
    aggregated_stds = cellfun(@std, data, 'UniformOutput', true);
end