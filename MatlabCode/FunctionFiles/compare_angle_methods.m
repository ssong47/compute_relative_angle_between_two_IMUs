function compare_angle_methods(angle_file_names, read_directory, save_status, save_directory, fs)
%{
    PURPOSE: To compute angle from filtered data 

    WHHAT IT DOES: Computes angle using five computational methods
    (gyroscopic integration, accelerometer inclincation, complementary
    filter, kalman filter, and digital motion processing)

    WRITTEN ON: 25th January 2020 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER: "Convenient and Low-Cost Methods of Calculating Human 
    Joint Angles using Inertial Measurement Units without Magnetometers" 
%}    


%{
    LICENSE
     This code "compare_angle_methods.m" is placed under the University of Illinois at Urbana-Champaign license
     Copyright (c) 2020 Seung Yun Song

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
 




for i_file = 1:length(angle_file_names)
    
    disp('Comparing Different Angle Methods...');

    angle_name_decomposition = regexp(angle_file_names{i_file}, '_', 'split');
    speed_type = regexprep(angle_name_decomposition{1}(3), '.mat', '');
    rotation_type = angle_name_decomposition{1}(2);

    save_metric_file_name = strcat(strcat(strcat('metric_',rotation_type), '_'), speed_type);

    dt = 1/fs;


    %% Load Angle Data
    angle_filename = strcat(read_directory, char(angle_file_names{i_file}));
    load(angle_filename);



    %% Divide into three time zones: 0-5min, 5-15min, 15-25min
    % Note that these three time zones are not used in the IMU study, but
    % can be useful for those interested in the the accuracy at various time zones
    t{1}(1) = 0;
    t{1}(2) = 5 * 60;

    t{2}(1) = 5 * 60;
    t{2}(2) = 15 * 60;

    t{3}(1) = 15 * 60;
    t{3}(2) = 25 * 60;


    %% Find closest index to these time zones
    index{1}(1) = 1;
    [a2, index{1}(2)] = min(abs(time - t{1}(2)));

    [b1, index{2}(1)] = min(abs(time - t{2}(1)));
    [b2, index{2}(2)] = min(abs(time - t{2}(2)));

    [c1, index{3}(1)] = min(abs(time - t{3}(1)));
    [c2, index{3}(2)] = min(abs(time - t{3}(2)));

    index{4}(1) = 1;
    index{4}(2) = length(time);



    %% Compute RMSE
    
    window_size = 6000; % 1 minute = 60 sec = 6000 data points
    
    reference_imu_1 = zeros(length(encoder),1); % reference for IMU 1 angles. Should be all zero.


    [rmse_ai_1, rmse_avg_ai_1, rmse_std_ai_1] = compute_rmse_array(encoder, ai_angle_1, window_size);
    [rmse_ai_2, rmse_avg_ai_2, rmse_std_ai_2] = compute_rmse_array(reference_imu_1, ai_angle_2, window_size);
    [rmse_ai, rmse_avg_ai, rmse_std_ai] = compute_rmse_array(encoder, ai_angle, window_size);


    [rmse_gi_1, rmse_avg_gi_1, rmse_std_gi_1] = compute_rmse_array(encoder, gi_angle_1, window_size);
    [rmse_gi_2, rmse_avg_gi_2, rmse_std_gi_2] = compute_rmse_array(reference_imu_1, gi_angle_2, window_size);
    [rmse_gi, rmse_avg_gi, rmse_std_gi] = compute_rmse_array(encoder, gi_angle, window_size);

    if (strcmp(rotation_type, 'roll') == 1) || (strcmp(rotation_type, 'pitch') ==1)

        [rmse_cf_1, rmse_avg_cf_1, rmse_std_cf_1] = compute_rmse_array(encoder, cf_angle_1, window_size);
        [rmse_cf_2, rmse_avg_cf_2, rmse_std_cf_2] = compute_rmse_array(reference_imu_1, cf_angle_2, window_size);
        [rmse_cf, rmse_avg_cf, rmse_std_cf] = compute_rmse_array(encoder, cf_angle, window_size);


        [rmse_kf_1, rmse_avg_kf_1, rmse_std_kf_1] = compute_rmse_array(encoder, kf_angle_1, window_size);
        [rmse_kf_2, rmse_avg_kf_2, rmse_std_kf_2] = compute_rmse_array(reference_imu_1, kf_angle_2, window_size);
        [rmse_kf, rmse_avg_kf, rmse_std_kf] = compute_rmse_array(encoder, kf_angle, window_size);
        
    elseif (strcmp(rotation_type, 'yaw') == 1)
        % RMSE for AI,CF,KF are not available for Yaw rotations
        rmse_cf_1 = zeros(length(rmse_ai_1),1);
        rmse_avg_cf_1 = 0;
        rmse_std_cf_1 = 0;
        
        rmse_cf_2 = zeros(length(rmse_ai_1),1);
        rmse_avg_cf_2 = 0;
        rmse_std_cf_2 = 0;
        
        rmse_cf = zeros(length(rmse_ai_1),1);
        rmse_avg_cf = 0;
        rmse_std_cf = 0;

        rmse_kf_1 = zeros(length(rmse_ai_1),1); 
        rmse_avg_kf_1 = 0;
        rmse_std_kf_1 = 0;
        
        rmse_kf_2 = zeros(length(rmse_ai_1),1);
        rmse_avg_kf_2 = 0;
        rmse_std_kf_2 = 0;
        
        rmse_kf = zeros(length(rmse_ai_1),1);
        rmse_avg_kf = 0;
        rmse_std_kf = 0;
    
    end

    [rmse_dmp_1, rmse_avg_dmp_1, rmse_std_dmp_1] = compute_rmse_array(encoder, dmp_angle_1, window_size);
    [rmse_dmp_2, rmse_avg_dmp_2, rmse_std_dmp_2] = compute_rmse_array(reference_imu_1, dmp_angle_2, window_size);
    [rmse_dmp, rmse_avg_dmp, rmse_std_dmp] = compute_rmse_array(encoder, dmp_angle, window_size);

    % compile all the RMSE data into a master array
    % the master_rmse_array is structured as the following:
    % master_rmse_array has 3 sets of data: rmse of IMU 1, rmse of IMU 2, rmse of IMU 2 - IMU 1
    
    % Each set of data has five rmse arrays (ai,gi,cf,kf,dmp) for roll &
    % pitch, and two rmse arrays (gi,dmp) for yaw.
    
    master_rmse_array{1} = [rmse_ai_1, rmse_gi_1, rmse_cf_1, rmse_kf_1, rmse_dmp_1];
    master_rmse_array{2} = [rmse_ai_2, rmse_gi_2 rmse_cf_2 rmse_kf_2 rmse_dmp_2];
    master_rmse_array{3} = [rmse_ai, rmse_gi rmse_cf rmse_kf rmse_dmp];

    master_temp = master_rmse_array;
    
    
    
    %% Compute RMSE for each zone
    % Using the master rmse array from above, the master rmse array is
    % divided into different time_zones to make "div_master_rmse". 
    
    % div_master_rmse has four time zones: 
    % i_zone = 1 -> 0-5 min
    % i_zone = 2 -> 5-15 min
    % i_zone = 3 -> 15-25 min
    % i_zone = 4 -> 0-25 min
    
    % Each time zone has three sets of data: rmse of IMU 1, rmse of IMU 2, rmse of IMU 2 - IMU 1
    
    % Each set of data has five rmse arrays (ai,gi,cf,kf,dmp) for roll &
    % pitch, and two rmse arrays (gi,dmp) for yaw.
    
    for i_imu = 1:3
        for i_zone = 1:4
            if master_temp{i_imu}(1,2) == 0
                master_temp{i_imu}(1:window_size-1,:) = [];
            end
            
            end_index = index{i_zone}(2) - window_size;
            
            div_master_rmse{i_zone}{i_imu}= master_temp{i_imu}(index{i_zone}(1):end_index,:);
            
        end
    end

    %% Compute Time Delay

    max_lag = 100; % max_lag is the maximum amount of time needed for searching for the time delay
    
    time_lag = {};
    
    % "div_master_delay" is a master array that has all the delay data
    % The structure is similar to "div_master_rmse"
    for i_zone = 1:4
        div_master_delay{i_zone}{1}(1) = finddelay(encoder(index{i_zone}(1):index{i_zone}(2)), gi_angle_1(index{i_zone}(1):index{i_zone}(2)) , max_lag);
        div_master_delay{i_zone}{2}(1) = finddelay(encoder(index{i_zone}(1):index{i_zone}(2)), gi_angle(index{i_zone}(1):index{i_zone}(2)) , max_lag);

        
        div_master_delay{i_zone}{1}(2) = finddelay(encoder(index{i_zone}(1):index{i_zone}(2)) , ai_angle_1(index{i_zone}(1):index{i_zone}(2)) , max_lag); 
        div_master_delay{i_zone}{2}(2) = finddelay(encoder(index{i_zone}(1):index{i_zone}(2)) , ai_angle(index{i_zone}(1):index{i_zone}(2)) , max_lag); 

        if (strcmp(rotation_type, 'roll') == 1) || (strcmp(rotation_type, 'pitch') ==1) 
            div_master_delay{i_zone}{1}(3) = finddelay(encoder(index{i_zone}(1):index{i_zone}(2)), cf_angle_1(index{i_zone}(1):index{i_zone}(2)) , max_lag);
            div_master_delay{i_zone}{1}(4)= finddelay(encoder(index{i_zone}(1):index{i_zone}(2)), kf_angle_1(index{i_zone}(1):index{i_zone}(2)) , max_lag);
            
            div_master_delay{i_zone}{2}(3) = finddelay(encoder(index{i_zone}(1):index{i_zone}(2)), cf_angle(index{i_zone}(1):index{i_zone}(2)) , max_lag);
            div_master_delay{i_zone}{2}(4)= finddelay(encoder(index{i_zone}(1):index{i_zone}(2)), kf_angle(index{i_zone}(1):index{i_zone}(2)) , max_lag);
            
        end
        div_master_delay{i_zone}{1}(5) = finddelay(encoder(index{i_zone}(1):index{i_zone}(2)), dmp_angle_1(index{i_zone}(1):index{i_zone}(2)) , max_lag);
        div_master_delay{i_zone}{2}(5) = finddelay(encoder(index{i_zone}(1):index{i_zone}(2)), dmp_angle(index{i_zone}(1):index{i_zone}(2)) , max_lag);
        
    end
 

    %% Save Metric Data
    if strcmp(save_status, 'yes') == 1

                save(char(strcat(save_directory,save_metric_file_name)), ...
                    'div_master_delay', 'div_master_rmse', 'window_size', 'max_lag', 'index');



    end

end
end