function filter_raw_data(extracted_raw_file_names, read_directory, save_status, save_directory, sampling_freq)

%{
    PURPOSE: To remove noise from raw data 

    WHHAT IT DOES: Applies a Butterworth lowpass filter on the raw data 

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
 


for i_file = 1:length(extracted_raw_file_names)

    disp('Filtering Raw Data from .mat File...');

    extracted_filename_decomposition = regexp(extracted_raw_file_names(i_file), '_', 'split');
    speed_type = regexprep(extracted_filename_decomposition{1}(3), '.mat', '');
    rotation_type = extracted_filename_decomposition{1}(2);
    
    save_filtered_file_name = strcat(strcat(strcat('filtered_',rotation_type), '_'), speed_type);

    
    
    %% Load Raw Data
    raw_extracted_file_name = strcat(read_directory, char(extracted_raw_file_names(i_file)));
    load(raw_extracted_file_name);


    %% Filtering Accelerometer and Gyro Data 
    cutoff_freq = 4;                      
    filter_order = 4; 

    [bLP, aLP] = butter(filter_order,cutoff_freq/(sampling_freq/2));
    
    all_time = all_time - all_time(1); % Ensure the time starts from zero 
    
    imu1_q1_filt = filtfilt(bLP, aLP, all_imu1_q1);
    imu1_q2_filt = filtfilt(bLP, aLP, all_imu1_q2);
    imu1_q3_filt = filtfilt(bLP, aLP, all_imu1_q3);
    imu1_q4_filt = filtfilt(bLP, aLP, all_imu1_q4);

    imu2_q1_filt = filtfilt(bLP, aLP, all_imu2_q1);
    imu2_q2_filt = filtfilt(bLP, aLP, all_imu2_q2);
    imu2_q3_filt = filtfilt(bLP, aLP, all_imu2_q3);
    imu2_q4_filt = filtfilt(bLP, aLP, all_imu2_q4);


    accel_1_x_filt = filtfilt(bLP, aLP, all_accel_1_x);
    accel_1_y_filt = filtfilt(bLP, aLP, all_accel_1_y);
    accel_1_z_filt = filtfilt(bLP, aLP, all_accel_1_z);

    accel_2_x_filt = filtfilt(bLP, aLP, all_accel_2_x);
    accel_2_y_filt = filtfilt(bLP, aLP, all_accel_2_y);
    accel_2_z_filt = filtfilt(bLP, aLP, all_accel_2_z);

    gyro_1_x_filt = filtfilt(bLP, aLP, all_gyro_1_x);
    gyro_1_y_filt = filtfilt(bLP, aLP, all_gyro_1_y);
    gyro_1_z_filt = filtfilt(bLP, aLP, all_gyro_1_z);

    gyro_2_x_filt = filtfilt(bLP, aLP, all_gyro_2_x);
    gyro_2_y_filt = filtfilt(bLP, aLP, all_gyro_2_y);
    gyro_2_z_filt = filtfilt(bLP, aLP, all_gyro_2_z);

    encoder_filt = all_encoder;

    %% Save Filtered Data 
   
    if strcmp(save_status, 'yes') == 1
        save(char(strcat(save_directory,save_filtered_file_name)), 'all_time','encoder_filt',...
            'imu1_q1_filt','imu1_q2_filt', 'imu1_q3_filt', 'imu1_q4_filt',...
            'imu2_q1_filt','imu2_q2_filt', 'imu2_q3_filt', 'imu2_q4_filt',...
            'gyro_1_x_filt', 'gyro_1_y_filt','gyro_1_z_filt',...
            'gyro_2_x_filt', 'gyro_2_y_filt', 'gyro_2_z_filt',...
            'accel_1_x_filt', 'accel_1_y_filt','accel_1_z_filt',...
            'accel_2_x_filt', 'accel_2_y_filt', 'accel_2_z_filt', 'calibration_line', 'data_line');


    end
    
    
end
end