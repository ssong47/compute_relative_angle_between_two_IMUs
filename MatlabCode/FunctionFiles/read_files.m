function [time, encoder,...
          accel_1_x, accel_1_y, accel_1_z,...
          gyro_1_x_raw, gyro_1_y_raw, gyro_1_z_raw,...
          gyro_1_x, gyro_1_y, gyro_1_z,...
          accel_2_x, accel_2_y, accel_2_z,...
          gyro_2_x_raw, gyro_2_y_raw, gyro_2_z_raw,...
          gyro_2_x, gyro_2_y, gyro_2_z,...
          imu1_q1, imu1_q2, imu1_q3, imu1_q4,...
          imu2_q1, imu2_q2, imu2_q3, imu2_q4] = read_files(read_directory, file_name)
%{
    PURPOSE: To read data from filtered .mat file

    WHHAT IT DOES: Reads and loads IMU and Encoder data from filtered .mat
    file during the testing period. 

    WRITTEN ON: 27th November 2021

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.
%}    


%{
    LICENSE
     This code "read_files.m" is placed under the University of Illinois at Urbana-Champaign license
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


    filename = strcat(read_directory, file_name);
    load(filename);
   

    %% Extract test data 
    i_start = data_line + 1; % use data only after the trial has started (i.e., the motor begun moving)
    time = all_time(i_start:end) - all_time(i_start);
    encoder = encoder(i_start:end);

    accel_1_x = accel_1_x_filt(i_start:end);
    accel_1_y = accel_1_y_filt(i_start:end);
    accel_1_z = accel_1_z_filt(i_start:end);

    accel_2_x = accel_2_x_filt(i_start:end);
    accel_2_y = accel_2_y_filt(i_start:end);
    accel_2_z = accel_2_z_filt(i_start:end);

    gyro_1_x = gyro_1_x_filt(i_start:end);
    gyro_1_y = gyro_1_y_filt(i_start:end);
    gyro_1_z = gyro_1_z_filt(i_start:end);
    
    gyro_1_x_raw = gyro_1_x_raw(i_start:end);
    gyro_1_y_raw = gyro_1_y_raw(i_start:end);
    gyro_1_z_raw = gyro_1_z_raw(i_start:end);

    gyro_2_x = gyro_2_x_filt(i_start:end);
    gyro_2_y = gyro_2_y_filt(i_start:end);
    gyro_2_z = gyro_2_z_filt(i_start:end);
    
    gyro_2_x_raw = gyro_2_x_raw(i_start:end);
    gyro_2_y_raw = gyro_2_y_raw(i_start:end);
    gyro_2_z_raw = gyro_2_z_raw(i_start:end);
    
    imu1_q1 = imu1_q1_filt(i_start:end);
    imu1_q2 = imu1_q2_filt(i_start:end);
    imu1_q3 = imu1_q3_filt(i_start:end);
    imu1_q4 = imu1_q4_filt(i_start:end);

    imu2_q1 = imu2_q1_filt(i_start:end);
    imu2_q2 = imu2_q2_filt(i_start:end);
    imu2_q3 = imu2_q3_filt(i_start:end);
    imu2_q4 = imu2_q4_filt(i_start:end);


end