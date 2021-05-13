function r=compute_single_data_rmse(reference,computed)
% Function to calculate root mean square error from a data vector or matrix 
% and the corresponding estimates.
% Usage: r=rmse(reference,estimate)
% Note: data and estimates have to be of same size
% Example: r=rmse(randn(100,100),randn(100,100));

% delete records with NaNs in both datasets first
I = ~isnan(reference) & ~isnan(computed); 
reference = reference(I); computed = computed(I);

r=sqrt(sum((reference(:)-computed(:)).^2)/numel(reference));