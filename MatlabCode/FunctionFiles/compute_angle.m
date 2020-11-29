function compute_angle(filtered_file_names, read_directory, save_status, save_directory, sampling_freq )
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
     This code "filter_raw_data.m" is placed under the University of Illinois at Urbana-Champaign license
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
 


for i_file = 1:length(filtered_file_names)
    disp('Computing Angles using GI,AI,CF,KF,DMP methods...');
    
    filtered_filename_decomposition = regexp(filtered_file_names{i_file}, '_', 'split');
    speed_type = regexprep(filtered_filename_decomposition{1}(3), '.mat', '');
    rotation_type = filtered_filename_decomposition{1}(2);

    save_angle_file_name = strcat(strcat(strcat('angle_',rotation_type), '_'), speed_type);

    

    %% Load Filtered Data
    filtered_filename = strcat(read_directory, char(filtered_file_names{i_file}));
    load(filtered_filename);

    %% Extract only the calibration data 
    c_imu1_q1 = imu1_q1_filt(1:data_line);
    c_imu1_q2 = imu1_q2_filt(1:data_line);
    c_imu1_q3 = imu1_q3_filt(1:data_line);
    c_imu1_q4 = imu1_q4_filt(1:data_line);

    c_imu2_q1 = imu2_q1_filt(1:data_line);
    c_imu2_q2 = imu2_q2_filt(1:data_line);
    c_imu2_q3 = imu2_q3_filt(1:data_line);
    c_imu2_q4 = imu2_q4_filt(1:data_line);
    
    %% Extract test data 
    i_start = calibration_line + 1;
    time = all_time(i_start:end) - all_time(i_start);
    encoder = min(180, max(0, encoder_filt(i_start:end)));

    accel_1_x = accel_1_x_filt(i_start:end);
    accel_1_y = accel_1_y_filt(i_start:end);
    accel_1_z = accel_1_z_filt(i_start:end);

    accel_2_x = accel_2_x_filt(i_start:end);
    accel_2_y = accel_2_y_filt(i_start:end);
    accel_2_z = accel_2_z_filt(i_start:end);

    gyro_1_x = gyro_1_x_filt(i_start:end);
    gyro_1_y = gyro_1_y_filt(i_start:end);
    gyro_1_z = gyro_1_z_filt(i_start:end);

    gyro_2_x = gyro_2_x_filt(i_start:end);
    gyro_2_y = gyro_2_y_filt(i_start:end);
    gyro_2_z = gyro_2_z_filt(i_start:end);

    imu1_q1 = imu1_q1_filt(i_start:end);
    imu1_q2 = imu1_q2_filt(i_start:end);
    imu1_q3 = imu1_q3_filt(i_start:end);
    imu1_q4 = imu1_q4_filt(i_start:end);

    imu2_q1 = imu2_q1_filt(i_start:end);
    imu2_q2 = imu2_q2_filt(i_start:end);
    imu2_q3 = imu2_q3_filt(i_start:end);
    imu2_q4 = imu2_q4_filt(i_start:end);

    


    %% [Accelerometer Inclincation] Compute Angle
    % AI angle of IMU 1 
    ai_angle_1 = compute_accel_inclination_angle(accel_1_x, accel_1_y, accel_1_z, rotation_type, 'stationary');    
    
    % AI angle of IMU 2 
    ai_angle_2 = compute_accel_inclination_angle(accel_2_x, accel_2_y, accel_2_z, rotation_type, 'moving');
    
    % AI angle of IMU 2 - IMU 1
    ai_angle = ai_angle_2 - ai_angle_1;
    

     
    %% [Gyroscope Integration] Compute Angle  
    % GI angle of IMU 1 
    gi_angle_1 = compute_gyro_integration_angle(gyro_1_x,gyro_1_y,gyro_1_z, sampling_freq, rotation_type);
    
    % GI angle of IMU 2 
    gi_angle_2 = compute_gyro_integration_angle(gyro_2_x,gyro_2_y,gyro_2_z, sampling_freq, rotation_type);
    
    % GI angle of IMU 2 - IMU 1
    gi_angle = gi_angle_2 - gi_angle_1;

    
    

    %% [Complementary Filter] Compute Angle 
    alpha = 0.01;    % coefficient determining cut-off frequency of low and high pass filter 
                    % 0.01 is chosen heuristically.    
    % CF angle of IMU 1 
    cf_angle_1 = compute_complementary_filter_angle(alpha, accel_1_x, accel_1_y, accel_1_z, gyro_1_x, gyro_1_y, gyro_1_z, sampling_freq, rotation_type, 'stationary');
    
    % CF angle of IMU 2 
    cf_angle_2 = compute_complementary_filter_angle(alpha, accel_2_x, accel_2_y, accel_2_z, gyro_2_x, gyro_2_y, gyro_2_z, sampling_freq, rotation_type, 'moving');
    
    % CF angle of IMU 2 - IMU 1
    cf_angle = cf_angle_2 - cf_angle_1;



    %% [Kalman Filter] Compute Angle 
    Q = eye(2) * 0.00001; % Process Noise. Higher = I don't trust the model dynamics
    R = eye(2) * 100; % Sensor Noise. Higher = I don't trust the sensor

    % KF angle of IMU 1 
    kf_angle_1 = compute_kalman_filter_angle(Q, R, accel_1_x, accel_1_y, accel_1_z, gyro_1_x, gyro_1_y, gyro_1_z, sampling_freq, rotation_type, 'stationary');
    
    % KF angle of IMU 2 
    kf_angle_2 = compute_kalman_filter_angle(Q, R, accel_2_x, accel_2_y, accel_2_z, gyro_2_x, gyro_2_y, gyro_2_z, sampling_freq, rotation_type, 'moving');
    
    % KF angle of IMU 2 - IMU 1
    kf_angle = kf_angle_2 - kf_angle_1;
     
    

    
    %% [DMP] Compute Angle     
    % R_1 is rotation matrix for IMU 1 (Stationary)
    % R_2 is rotation matrix for IMU 2 (Moving)    
    [R_calibration, R_1_calibration] = compute_calib_matrix(c_imu1_q1, c_imu1_q2, c_imu1_q3, c_imu1_q4, c_imu2_q1, c_imu2_q2, c_imu2_q3, c_imu2_q4);
    
    % DMP angle of IMU 1 
    imu_type = 'stationary';
    dmp_angle_1 = compute_dmp_angle(R_calibration, R_1_calibration, imu1_q1, imu1_q2, imu1_q3, imu1_q4, imu2_q1, imu2_q2, imu2_q3, imu2_q4,rotation_type, imu_type);

    % DMP angle of IMU 2 
    imu_type = 'moving';
    dmp_angle_2 = compute_dmp_angle(R_calibration, R_1_calibration, imu1_q1, imu1_q2, imu1_q3, imu1_q4, imu2_q1, imu2_q2, imu2_q3, imu2_q4,rotation_type, imu_type);

    % DMP angle of IMU 2 - IMU 1 
    dmp_angle = dmp_angle_2 - dmp_angle_1;
    
    
    %% Save Angle Data 
    if strcmp(save_status, 'yes') == 1

            save(char(strcat(save_directory,save_angle_file_name)), 'time','encoder',...
                'ai_angle_1','ai_angle_2', 'ai_angle',...
                'gi_angle_1','gi_angle_2', 'gi_angle',...
                'cf_angle_1', 'cf_angle_2','cf_angle',...
                'kf_angle_1', 'kf_angle_2', 'kf_angle',...
                'dmp_angle_1', 'dmp_angle_2', 'dmp_angle', ...
                'alpha','Q','R','sampling_freq','R_1_calibration');

    end
end


end