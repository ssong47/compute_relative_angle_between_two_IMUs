/* This README contains information regarding the data proessing of raw text file data. If you have any questions, e-mail to ssong47@illinois.edu
/* Created by Seung Yun Song, January 25th 2020


==================================== Function Files ====================================
<accel_inclination.m> 
INPUT = accel_x, accel_y, accel_z, rotation_axis (rot_type*)
OUTPUT = Angle from accel (theta_ai)
Description = Computes the angle from accelerometer inclination angle (theta_ai) using raw accelerometer values from x,y,z (accel_x, accel_y, accel_z) about the desired rotation axis (rot_type). 


<calib_matrix.m>
INPUT = Quaternion values for IMU 1 and IMU 2 during calibration (c_imu1_q1, c_imu1_q2, c_imu1_q3, c_imu1_q4, c_imu2_q1, c_imu2_q2, c_imu2_q3, c_imu2_q4)
OUTPUT = Calibration Matrix for IMU 1 and IMU 2(R), Calibration Matrix for IMU 1 (R_1_calib)**
Description = Computes the calibration matrix using the quaternion values of IMU 1 and IMU 2 during calibration. 



<compute_rmse.m>
INPUT = array of encoder reference angles (reference), array of computed angles (computed), size of window (window_size)
OUTPUT = Data array of root-mean-squared-error values (rmse_array), average RMSE error (rmse_avg), (rmse_std)
Description = Computes the RMSE array, RMSE avg, RMSE std between the encoder angles (reference) and the computed angles (computed) using a <rmse.m> given the window size (window_size).  



<rmse.m>
INPUT = array of reference signal (reference), array of computed signal (computed)
OUTPUT = RMSE array (r)
Description = Computes the array of RMSE between reference and computed signal



<complementary_filter.m>
INPUT = parameter for adjusting the cut-off frequency of the complementary filter (alpha), filtered accelerometer value in x,y,z (accel_x, accel_y, accel_z), filtered gyrsoscopic value (gyro_x, gyro_y, gyro_z), sampling rate*** (fs), rotation axis (rot_type)
OUTPUT = Angle computed from complementary filter (theta_cf)
Description = Computes the angle from complementary filter using filtered acceleroemter and gyroscopes about x,y,z for the given rotation axis 



<dmp.m>
INPUT = Calibration Matrix for IMU 1 and IMU 2 (R), Calibration Matrix for IMU 1(R_2_cali), filtered IMU quaternion values of IMU 1 and IMU 2 (imu1_q1, imu1_q2, imu1_q3, imu1_q4, imu2_q1, imu2_q2, imu2_q3, imu2_q4), type of IMU**** (imu_type), rotation axis (rot_type)
OUTPUT = Angle computed using digital motion processing - dmp (theta_dmp)
Description = Computes the angle from dmp using filtered quaternion values from IMU 1, IMU 2, calibration matrices, and about given rotation axis



<gyro_integration.m>
INPUT = filtered gyroscope values about x,y,z (gyro_x, gyro_y, gyro_z), sampling rate in Hz (fs), rotation axis (rot_type)
OUTPUT = Angle computed using gyroscopic integration (theta_gi)
Description = Computes the angle from gyroscopic integration (theta_gi) using filtered gyroscopic values about the given rotation axis. 



<kalman_filter.m>
INPUT = Process noise matrix (Q), Measurement Noise Matrix (R), filtered accelerometer value in x,y,z (accel_x, accel_y, accel_z), filtered gyrsoscopic value (gyro_x, gyro_y, gyro_z), sampling rate (fs), rotation axis (rot_type)
OUTPUT = Angle computed using kalman filter (theta_kf)
Description = Computes angle from kalman filter (theta_kf) using filtered accelerometer (accel_x, accel_y, accel_z) and gyroscope values in x,y,z (gyro_x, gyro_y, gyro_z) about given rotation axis. 




==================================== Main Files ==================================== 
<imu_study_extract_raw_data.m> 
INPUT = raw .txt file data (e.g., raw_pitch_fast.mat)
OUTPUT = pre-processed .mat file data (e.g., preprocessed_pitch_fast.mat)
Description = Extracts the raw text data*****, checks for and removes corrupted raw data, and saves the data in .mat file  



<imu_study_process_raw_data.m>
INPUT = pre-processed .mat file data (e.g., preprocessed_pitch_fast.mat)
OUTPUT = filtered .mat file data (e.g., filtered_pitch_fast.mat) + line of calibration 
Description = Filters pre-processed data using a 4th order Low-pass Butterworth filter at cut-off frequency of 20 Hz



<imu_study_compute_angle.m>
INPUT = filtered .mat file data (e.g., filtered_pitch_fast.mat)
OUTPUT = angles computed in .mat file data (e.g., angle_pitch_fast.mat) + filter parameters (alpha, Q,R, fs, R, R_1_calib)
Description = Computes angles from filtered .mat data using gyroscopic integration (GI), accelerometer inclincation (AI), complementary filter (CF), Kalman filter (KF), Digital Motion Processing (DMP)



<imu_study_compare_angle_methods.m>
INPUT = angles computed in .mat file data (e.g., angle_pitch_fast.mat)
OUTPUT = RMSE data + time delay data (e.g., metric_pitch_fast.mat), RMSE parameters (window_size), Delay parameters (maximum time lag), time intervals (index)******
Description = Compares the different computed angles (theta_gi, theta_ai, theta_cf, theta_kf, theta_dmp) to gold standard (encoder) by computing RMSE, time-delay for four different time intervals



<imu_study_plot_tabulate.m>
INPUT = angles computed in .mat file data (e.g., angle_pitch_fast.mat), RMSE data + time delay data (e.g., metric_pitch_fast.mat) 
OUTPUT = 
Description = Plots computed angles (gi, ai, cf, kf, dmp, encoder) vs time for different time intervals, Plots RMSE of gi,ai,cf,kf,dmp vs time, Tabulates RMSE and time delay data 

 




==================================== Notes ====================================
* = rot_type is a string that can be one of the following = 'pitch', 'roll', 'yaw' for all MATLAB files.
** = Calib
*** = Sampling rate is 100 Hz for all MATLAB files
**** = imu_type is a string tht can be one of the following = 'moving', 'stationary', 'both' for all MATLAB files.
***** = the raw data includes the following:  'all_time','all_encoder','all_imu1_q1','all_imu1_q2', 'all_imu1_q3', 'all_imu1_q4',...
            'all_imu2_q1','all_imu2_q2', 'all_imu2_q3', 'all_imu2_q4', 'all_gyro_1_x', 'all_gyro_1_y','all_gyro_1_z',...
            'all_accel_1_x', 'all_accel_1_y', 'all_accel_1_z','all_gyro_2_x', 'all_gyro_2_y','all_gyro_2_z','all_accel_2_x', 'all_accel_2_y', 'all_accel_2_z'


****** = indices of the start and end of four time intervals
        1) 0 - 5 min
        2) 5 - 15 min
        3) 15 - 25 min
        4) 0 - 25 min