/* This README contains information regarding the data proessing of raw text file data. If you have any questions, e-mail to ssong47@illinois.edu
/* Created by Seung Yun Song, November 27th 2021


==================================== How to Run MATLAB files ===========================
1) Make sure the "Main.m" file is in the same directory as the "Data", "Figure", "FunctionFiles" folder
2) Run the "Main.m" file 

==================================== Notes ====================================
* = rot_type is a string that can be one of the following = 'pitch', 'roll', 'yaw' for all MATLAB files.
** = Sampling rate is 100 Hz for all MATLAB files
*** = imu_type is a string tht can be one of the following = 'moving', 'stationary' for all MATLAB files.
**** = the raw data includes the following:  'all_time','all_encoder','all_imu1_q1','all_imu1_q2', 'all_imu1_q3', 'all_imu1_q4',...
            'all_imu2_q1','all_imu2_q2', 'all_imu2_q3', 'all_imu2_q4', 'all_gyro_1_x', 'all_gyro_1_y','all_gyro_1_z',...
            'all_accel_1_x', 'all_accel_1_y', 'all_accel_1_z','all_gyro_2_x', 'all_gyro_2_y','all_gyro_2_z','all_accel_2_x', 'all_accel_2_y', 'all_accel_2_z'