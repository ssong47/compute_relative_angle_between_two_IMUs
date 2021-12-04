function compute_angle(filtered_file_names, read_directory, save_status, save_directory, sampling_freq, filter_type, plot_status)
%{
    PURPOSE: To compute angles using seven methods from filtered data 

    WHAT IT DOES: Computes angle using seven computational methods
    (Gyroscopic Integration, Accelerometer inclincation, Complementary
    Filter, Kalman Filter, Digital Motion Processing, Madgwick Filter, and Mahony Filter)

    WRITTEN ON: 27th November 2021

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.
%}    


%{
    LICENSE
     This code "compute_angle.m" is placed under the University of Illinois at Urbana-Champaign license
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
 

for i_file = 1:length(filtered_file_names)   
    % Obtain speed(slow,med,fast) and rotation type (yaw,pitch,roll) info
    filtered_filename_decomposition = regexp(filtered_file_names{i_file}, '_', 'split');
    speed_type = regexprep(filtered_filename_decomposition{1}(3), '.mat', '');
    rotation_type = filtered_filename_decomposition{1}(2);
    fprintf('Computing Angles using GI,AC,CF,KF,DMP,MW,MH methods for %s %s ...\n', rotation_type{1}, speed_type{1})

    % Define file name for saving the compiled angle data
    save_angle_file_name = strcat(filter_type,'_angle_', rotation_type, '_', speed_type);

    % Load Data from filtered file 
    [ time, encoder,...
      accel_1_x, accel_1_y, accel_1_z,...
      gyro_1_x_raw, gyro_1_y_raw, gyro_1_z_raw,...
      gyro_1_x, gyro_1_y, gyro_1_z,...
      accel_2_x, accel_2_y, accel_2_z,...
      gyro_2_x_raw, gyro_2_y_raw, gyro_2_z_raw,...
      gyro_2_x, gyro_2_y, gyro_2_z,...
      imu1_q1, imu1_q2, imu1_q3, imu1_q4,...
      imu2_q1, imu2_q2, imu2_q3, imu2_q4] = read_files(read_directory, char(filtered_file_names{i_file}));
    

    dt = 1/sampling_freq; % time interval (s) between each data point


    %% [Gyroscope Integration] Compute Angle  
    % offset needed since the encoder started 90deg from IMU 
    gi_offset = 90; 
    if strcmp(rotation_type, 'pitch') == 1 || strcmp(rotation_type, 'roll') == 1 
        % GI angle of IMU 1 
        gi_angle_1 = compute_gyro_integration_angle(gyro_1_x, gyro_1_y, gyro_1_z, dt, rotation_type);
        % GI angle of IMU 2 
        gi_angle_2 = compute_gyro_integration_angle(gyro_2_x, gyro_2_y, gyro_2_z, dt, rotation_type);

    elseif strcmp(rotation_type, 'yaw') == 1       
         if strcmp(filter_type, 'filtered') == 1 
            gi_angle_1 = compute_gyro_integration_angle(gyro_1_x, gyro_1_y, gyro_1_z, dt, rotation_type);
            gi_angle_2 = compute_gyro_integration_angle(gyro_2_x, gyro_2_y, gyro_2_z, dt, rotation_type);
         else
             % below is just for reference to demonstrate that if gyro data is not high-pass filtered, the GI angle drifts significantly
            gi_angle_1 = compute_gyro_integration_angle(gyro_1_x_raw, gyro_1_y_raw, gyro_1_z_raw, dt, rotation_type);
            gi_angle_2 = compute_gyro_integration_angle(gyro_2_x_raw, gyro_2_y_raw, gyro_2_z_raw, dt, rotation_type);
        end
    end
   
    
    % GI angle of IMU 2 - IMU 1
    gi_angle = gi_angle_2 - gi_angle_1 + gi_offset;
    
    
    %% [Accelerometer Inclincation] Compute Angle
    % Note that for yaw, the AC angles are zeros since it cannot be
    % computed for yaw. 
    
    % offset needed since the encoder started 90deg from IMU 
    ac_offset = 90; 
    
    % AC angle of IMU 1 
    ac_angle_1 = compute_accel_inclination_angle(accel_1_x, accel_1_y, accel_1_z, rotation_type, 'stationary', ac_offset);    

    % AC angle of IMU 2 
    ac_angle_2 = compute_accel_inclination_angle(accel_2_x, accel_2_y, accel_2_z, rotation_type, 'moving', ac_offset);

    % AC angle of IMU 2 - IMU 1
    ac_angle = ac_angle_2 - ac_angle_1;
  
    
    
    %% [Complementary Filter] Compute Angle 
    if strcmp(rotation_type, 'pitch') == 1 || strcmp(rotation_type, 'roll') == 1 
        cf_offset = 0;
        gamma = 0.11; % tuning parameter for CF.  
         
         % CF angle of IMU 1
        cf_angle_1 = compute_complementary_filter_angle(gamma, accel_1_x, accel_1_y, accel_1_z, gyro_1_x_raw, gyro_1_y_raw, gyro_1_z_raw, dt, rotation_type, 'stationary', ac_offset);

        % CF angle of IMU 2 
        cf_angle_2 = compute_complementary_filter_angle(gamma, accel_2_x, accel_2_y, accel_2_z, gyro_2_x_raw, gyro_2_y_raw, gyro_2_z_raw, dt, rotation_type, 'moving', ac_offset);

    elseif strcmp(rotation_type, 'yaw') == 1 
         gamma = 0.0000001; % set to small value to rely mostly on gyroscopic data for yaw rotations
         cf_offset = 90;
         
         % CF angle of IMU 1
         cf_angle_1 = compute_complementary_filter_angle(gamma, accel_1_x, accel_1_y, accel_1_z, gyro_1_x, gyro_1_y, gyro_1_z, dt, rotation_type, 'stationary', ac_offset);

         % CF angle of IMU 2 
         cf_angle_2 = compute_complementary_filter_angle(gamma, accel_2_x, accel_2_y, accel_2_z, gyro_2_x, gyro_2_y, gyro_2_z, dt, rotation_type, 'moving', ac_offset);
    end
    
    
    % CF angle of IMU 2 - IMU 1
    cf_angle = cf_angle_2 - cf_angle_1 + cf_offset;
    
    
    %% [Kalman Filter] Compute Angle 
    % Process Noise. Lower = more trust on the model dynamics 
    Q = [1e-3, 0; 0, 2.5e-3]; 
    
    if strcmp(rotation_type, 'pitch') == 1 || strcmp(rotation_type, 'roll') == 1 
         kf_offset = 0;
         % Sensor Noise. Lower = More trust on the sensor measurements. 
         % For pitch and roll, Set low since gyro and accelerometer sensor data are meaningful
         R = eye(2) * 3.7552; 
         
         % KF angle of IMU 1 
         kf_angle_1 = compute_kalman_filter_angle(Q, R, accel_1_x, accel_1_y, accel_1_z, gyro_1_x_raw, gyro_1_y_raw, gyro_1_z_raw, dt, rotation_type, 'stationary', ac_offset);

         % KF angle of IMU 2 
         kf_angle_2 = compute_kalman_filter_angle(Q, R, accel_2_x, accel_2_y, accel_2_z, gyro_2_x_raw, gyro_2_y_raw, gyro_2_z_raw, dt, rotation_type, 'moving', ac_offset);
    elseif strcmp(rotation_type, 'yaw') == 1 
         kf_offset = 90;
         % Sensor Noise. Higher = less trust on the sensor measurements. 
         % For yaw, Set high since accelerometer sensor data are not reliable
         R = eye(2) * 10^8;  
         
         % KF angle of IMU 1 
         kf_angle_1 = compute_kalman_filter_angle(Q, R, accel_1_x, accel_1_y, accel_1_z, gyro_1_x, gyro_1_y, gyro_1_z, dt, rotation_type, 'stationary', ac_offset);

         % KF angle of IMU 2 
         kf_angle_2 = compute_kalman_filter_angle(Q, R, accel_2_x, accel_2_y, accel_2_z, gyro_2_x, gyro_2_y, gyro_2_z, dt, rotation_type, 'moving', ac_offset);
   
    end
    
    % KF angle of IMU 2 - IMU 1
    kf_angle = kf_angle_2 - kf_angle_1 + kf_offset;
    
    
    
    %% [DMP] Compute Angle     
    [dmp_angle_1, dmp_angle_2, dmp_angle] = compute_dmp_angle_q2e(rotation_type, speed_type, imu1_q1, imu1_q2, imu1_q3, imu1_q4, imu2_q1, imu2_q2, imu2_q3, imu2_q4);
    
    
    
    %% Organize IMU readings appropriately to use the Madgwick and Mahony Filters
    [gyroscope_1, gyroscope_1_raw, accelerometer_1] = organize_sensor_data([gyro_1_x, gyro_1_y, gyro_1_z],...
                                                                           [gyro_1_x_raw, gyro_1_y_raw, gyro_1_z_raw],...
                                                                           [accel_1_x, accel_1_y, accel_1_z], rotation_type);
    [gyroscope_2, gyroscope_2_raw, accelerometer_2] = organize_sensor_data([gyro_2_x, gyro_2_y, gyro_2_z],...
                                                                           [gyro_2_x_raw, gyro_2_y_raw, gyro_2_z_raw],...
                                                                           [accel_2_x, accel_2_y, accel_2_z], rotation_type);
    
    
    %% [Madgwick] Compute Angle
    if strcmp(rotation_type, 'pitch') == 1 || strcmp(rotation_type, 'roll') == 1 
        mw_offset = 0;
        beta = 0.043; % Tuning parameter for Madgewick Filter. 
        mw_angle_1 = compute_madgwick_angle(gyroscope_1_raw, accelerometer_1, rotation_type, dt, beta);
        mw_angle_2 = compute_madgwick_angle(gyroscope_2_raw, accelerometer_2, rotation_type, dt, beta);  
        
    elseif strcmp(rotation_type, 'yaw') == 1 
        beta = 0.0; % Set to zero to rely only on gyroscopic data. 
        mw_offset = 90;
        if strcmp(filter_type, 'filtered') == 1
            mw_angle_1 = compute_madgwick_angle(gyroscope_1, accelerometer_1, rotation_type, dt, beta);
            mw_angle_2 = compute_madgwick_angle(gyroscope_2, accelerometer_2, rotation_type, dt, beta);  
        else
            mw_angle_1 = compute_madgwick_angle(gyroscope_1_raw, accelerometer_1, rotation_type, dt, beta);
            mw_angle_2 = compute_madgwick_angle(gyroscope_2_raw, accelerometer_2, rotation_type, dt, beta);  
        end
    end
        
    % Determine appropriate sign for Madgwick (and Mahony) angles to match the encoder
    % angles 
    asign = determine_asign(rotation_type);
    
    % Compute relative Madgwick Angle between IMU 1 and 2
    mw_angle = asign * (mw_angle_1 - mw_angle_2) + mw_offset; 
    
    

    %% [Mahony] Compute Angle
    if strcmp(rotation_type, 'pitch') == 1 || strcmp(rotation_type, 'roll') == 1 
        mh_offset = 0;
       
        kp = 5;   % Kp tuning parameter term for Mahony Filter
        ki = 0.1; % KI tuning parameter term for Mahony Filter
        
        mh_angle_1 = compute_mahony_angle(gyroscope_1_raw, accelerometer_1, rotation_type, dt, kp, ki);
        mh_angle_2 = compute_mahony_angle(gyroscope_2_raw, accelerometer_2, rotation_type, dt, kp, ki);
        
    elseif strcmp(rotation_type, 'yaw') == 1 
        mh_offset = 90;
        kp = 0.00; % Kp set to zero to rely only on gyro data for yaw 
        ki = 0.00; % Ki set to zero to rely only on gyro data for yaw 
        if strcmp(filter_type, 'filtered') == 1
            mh_angle_1 = compute_mahony_angle(gyroscope_1, accelerometer_1, rotation_type, dt, kp, ki);
            mh_angle_2 = compute_mahony_angle(gyroscope_2, accelerometer_2, rotation_type, dt, kp, ki);
        else
            mh_angle_1 = compute_mahony_angle(gyroscope_1_raw, accelerometer_1, rotation_type, dt, kp, ki);
            mh_angle_2 = compute_mahony_angle(gyroscope_2_raw, accelerometer_2, rotation_type, dt, kp, ki);
        end
    end
    
    % Compute relative mahony angle between IMU 1 and 2
    mh_angle = asign * (mh_angle_1 - mh_angle_2) + mh_offset; 
    
    
    % Ensure all angles start from zero in the beginning 
    % And Truncate data the very beginning and end parts of the data to remove any
    % artifacts from the preprocessing. 
    i_start = 7250; 
    i_end = length(time) - 2000;
    time = time(i_start:i_end) - time(i_start);
    encoder = encoder(i_start:i_end) - encoder(i_start);
    gi_angle = gi_angle(i_start:i_end) - gi_angle(i_start);
    ac_angle = ac_angle(i_start:i_end) - ac_angle(i_start);
    cf_angle = cf_angle(i_start:i_end) - cf_angle(i_start);
    kf_angle = kf_angle(i_start:i_end) - kf_angle(i_start);
    dmp_angle = dmp_angle(i_start:i_end) - dmp_angle(i_start);
    mw_angle = mw_angle(i_start:i_end) - mw_angle(i_start);
    mh_angle = mh_angle(i_start:i_end) - mh_angle(i_start);
    
    % Compute mean absolute error (MAE). Just for reference. 
    % Note MAE is not the same as RMSE but represent similar concept (error
    % between estimated and ground  truth)
    mae_gi = mean(abs(encoder - gi_angle));
    mae_ac = mean(abs(encoder - ac_angle));
    mae_cf = mean(abs(encoder - cf_angle));
    mae_kf = mean(abs(encoder - kf_angle));
    mae_dmp= mean(abs(encoder - dmp_angle));
    mae_mw = mean(abs(encoder - mw_angle));
    mae_mh = mean(abs(encoder - mh_angle));

    fprintf('MAE of GI: %f\t AC:%f\t CF:%f\t KF:%f\t DMP:%f\t MW:%f\t MH:%f\t \n',...
            mae_gi, mae_ac, mae_cf, mae_kf, mae_dmp, mae_mw, mae_mh);

    % Plot angle data if necessary 
    if strcmp(plot_status, 'plot') == 1
        figure('Name', 'GI')
        plot(time/60, encoder)
        hold on 
        plot(time(1:length(gi_angle))/60, gi_angle)
        ylabel('Angle (deg)')
        xlabel('Time (min)')
        xlim([0 25])
        ylim([-150 300])
        legend('encoder', 'GI + HPF')
        
        figure('Name', 'AC')
        plot(time/60, encoder)
        hold on 
        plot(time(1:length(ac_angle))/60, ac_angle)
        ylabel('Angle (deg)')
        xlabel('Time (min)')
        xlim([0 25])
        ylim([-150 300])
        legend('encoder', 'AC')
        
        figure('Name','CF')
        plot(time/60, encoder)
        hold on
        plot(time/60, cf_angle)
        legend('encoder','CF')
        xlabel('Time (min)')
        ylabel('Angle (deg)')
        xlim([0 25])
        ylim([-150 300])
        
        figure('Name','KF')
        plot(time/60, encoder)
        hold on 
        plot(time/60, kf_angle)
        legend('encoder','KF')
        xlabel('Time (min)')
        ylabel('Angle (deg)')
        xlim([0 25])
        ylim([-150 300])
        
        figure('Name','DMP')
        plot(time/60, encoder)
        hold on 
        plot(time/60, dmp_angle)
        legend('encoder','DMP')
        xlim([0 25])
        ylim([-150 300])
        xlabel('Time (min)')
        ylabel('Angle (deg)')
        
        figure('Name','MW')
        plot(time/60, encoder)
        hold on 
        plot(time/60, mw_angle)
        legend('encoder','MW')
        xlim([0 25])
        ylim([-150 300])
        xlabel('Time (min)')
        ylabel('Angle (deg)')
        
        figure('Name','MH')
        plot(time/60, encoder)
        hold on 
        plot(time/60, mh_angle)
        legend('encoder','MH')
        xlim([0 25])
        ylim([-150 300])
        xlabel('Time (min)')
        ylabel('Angle (deg)')
    end
        
        
    % Save Angle Data 
    if strcmp(save_status, 'yes') == 1
            save(char(strcat(save_directory,save_angle_file_name)), 'time','encoder',...
                'ac_angle_1','ac_angle_2', 'ac_angle',...
                'gi_angle_1','gi_angle_2', 'gi_angle',...
                'cf_angle_1', 'cf_angle_2','cf_angle',...
                'kf_angle_1', 'kf_angle_2', 'kf_angle',...
                'dmp_angle_1', 'dmp_angle_2', 'dmp_angle', ...
                'mw_angle_1', 'mw_angle_2', 'mw_angle',...
                'mh_angle_1', 'mh_angle_2', 'mh_angle',...
                'gamma','Q','R','sampling_freq');

    end
end

end