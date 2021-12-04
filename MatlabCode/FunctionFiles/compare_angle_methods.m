function compare_angle_methods(angle_file_names, read_directory, save_status, save_directory, fs, filter_type)
%{
    PURPOSE: Compare the accuracy of the seven algorithms (GI, AC, KF, CF, DMP, MW, MH)

    WHAT IT DOES: Compute the root-mean-squared errors (RMSE) between the seven methods 
    (GI, AC, KF, CF, DMP, MW, MH) and the ground truth(encoder).

    WRITTEN ON: 27th November 2021 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.

%}    


%{
    LICENSE
     This code "compare_angle_methods.m" is placed under the University of Illinois at Urbana-Champaign license
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

 



% For all files
for i_file = 1:length(angle_file_names)
    % Obtain the speed and the rotation type 
    angle_name_decomposition = regexp(angle_file_names{i_file}, '_', 'split');
    speed_type = angle_name_decomposition{1}{4};
    rotation_type = angle_name_decomposition{1}{3};
    fprintf('Comparing Different Angle Methods for %s %s...\n', rotation_type, speed_type)

    % Define file name for saving 
    save_metric_file_name = strcat('rmse_', filter_type, '_metric_',rotation_type,'_', speed_type);
    
    % Load Angle Data (just to get time data)
    angle_filename = strcat(read_directory, char(angle_file_names{i_file}));
    load(angle_filename);
    
    % Define window size 
    window_size = 1 * 60 * fs ; % 1 minute = 60 sec = 6000 data points
    
     % Compute RMSE for Gyroscopic Integration
    [rmse_gi, rmse_avg_gi, rmse_std_gi] = compute_rmse_array(encoder, gi_angle, window_size);

    % Compute RMSE for Accelerometer Inclination
    if (strcmp(rotation_type, 'roll') == 1) || (strcmp(rotation_type, 'pitch') ==1)
        [rmse_ac, rmse_avg_ac, rmse_std_ac] = compute_rmse_array(encoder, ac_angle, window_size);
    elseif (strcmp(rotation_type, 'yaw') == 1)
        % RMSE for AC are not available for Yaw rotations
        rmse_ac = zeros(length(rmse_gi),1);
    end
    
    % Compute RMSE for Complementary Filter
    [rmse_cf, rmse_avg_cf, rmse_std_cf] = compute_rmse_array(encoder, cf_angle, window_size);

    % Compute RMSE for Kalman Filter
    [rmse_kf, rmse_avg_kf, rmse_std_kf] = compute_rmse_array(encoder, kf_angle, window_size);    

    % Compute RMSE for DMP 
    [rmse_dmp, rmse_avg_dmp, rmse_std_dmp] = compute_rmse_array(encoder, dmp_angle, window_size);

    % Compute RMSE for Madgwick Filter
    [rmse_mw, rmse_avg_mw, rmse_std_mw] = compute_rmse_array(encoder, mw_angle, window_size);

    % Compute RMSE for Mahony Filter
    [rmse_mh, rmse_avg_mh, rmse_std_mh] = compute_rmse_array(encoder, mh_angle, window_size);


    % Compile all the RMSE data into a master array
    master_rmse = [rmse_gi, rmse_ac, rmse_cf, rmse_kf, rmse_dmp, rmse_mw, rmse_mh];

    %% Save Metric Data
    if strcmp(save_status, 'yes') == 1
                save(char(strcat(save_directory,save_metric_file_name)), ...
                    'master_rmse', 'window_size');
    end

end
end