function [rmse_array, rmse_avg, rmse_std] = compute_rmse_array(reference, computed, window_size)
% WHAT IT DOES: computes the RMSE array of the computed values with 
% respect to reference values given the window size, 
% average of the RMSE array
% standard deviation of the RMSE array

rmse_array = zeros(length(reference),1);

i_start = 1;
i_end = i_start + window_size - 1; 

while i_end <= length(reference)
    for i = i_start:i_end
        if i == i_end
            rmse_array(i) = real(compute_single_data_rmse(reference(i_start:i_end),computed(i_start:i_end)));
            
            i_start = i_start + 1;
            i_end = i_start + window_size - 1;
        end
    end
end

rmse_avg = mean(rmse_array);
rmse_std = std(rmse_array);




end