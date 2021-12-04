function [rmse_array, rmse_avg, rmse_std] = compute_rmse_array(reference, computed, window_size)
%{
    PURPOSE: Compare the accuracy of the seven algorithms (GI, AC, KF, CF, DMP, MW, MH)

    WHAT IT DOES: computes the RMSE array of the computed values with 
                  respect to reference values given the window size, 
                  average of the RMSE array
                  standard deviation of the RMSE array


    WRITTEN ON: 27th November 2021 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.

%}    


%{
    LICENSE
     This code "compute_rmse_array.m" is placed under the University of Illinois at Urbana-Champaign license
     Copyright (c) 2021 Seung Yun Song

     Permission is hereby granted, free of charge, to any person obtaining a copyblu
     of this software and associated documentation files (the "Software"), to deal
     in the Software without restriction, including without limitation the rights
     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
     copies of the Software, and to permit persons to whom the Software is
     furnished to do so, subject to the following conditions:

     The above copyright notice and this permission notice shall be included in
     all copies or substantial portions of the Software.

     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
     THE SOFTWARE.

%} 


% Initialize RMSE array 
rmse_array = zeros(length(reference),1);

% Initialize start and end indexes
i_start = 1;
i_end = i_start + window_size - 1; 

% For all data points
while i_end <= length(reference)
    for i = i_start:i_end
        if i == i_end
            % Compute RMSE between reference and computed data for the
            % given window
            rmse_array(i) = real(compute_single_data_rmse(reference(i_start:i_end),computed(i_start:i_end)));
            
            % Move to next window by updating start and end indexes
            % Note that the window moves by one data point
            i_start = i_start + 1;
            i_end = i_start + window_size - 1;
        end
    end
end

% Compute mean and std of RMSE
rmse_avg = mean(rmse_array);
rmse_std = std(rmse_array);




end