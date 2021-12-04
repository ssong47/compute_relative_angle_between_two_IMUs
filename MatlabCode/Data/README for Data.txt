/* This README contains information regarding the organization of the raw data (.txt) and processed matlab data (.mat). For more information, please e-mail ssong47@illinois.edu
/* Created by Seung Yun Song. November 25th 2021
 
<Raw Data Files (.txt)>
9 raw readings of the nine test trials (text files (.txt)) (e.g., raw_yaw_slow.txt)
Each trial contained 22 columns of data. Each column of data contains the following. 

1) Sampled Time (ms)

2) Encoder (deg)

3,4,5,6) IMU 2 quaternion from DMP (4 values = a,b,c,d)

7,8,9,10) IMU 1 quaternion from DMP (4 values = a,b,c,d)

11,12,13) Raw Gyroscope Readings (deg/s) of IMU 2 about x,y,z (3 values) 

14,15,16) Raw Accelerometer Readings (g - gravitational constant) of IMU 2 about x,y,z (3 values)

17,18,19) Raw Gyroscope Readings (deg/s) of IMU 1 about x,y,z (3 values) 

20,21,22) Raw Accelerometer Readings (g - gravitational constant) of IMU 1 about x,y,z (3 values)

 

 

 

<Processed Data Files (.mat)>
MATLAB scripts are used to process the raw text files. Additional 37 .mat files will be created. Description for these .mat files are given below. 

 
9 raw readings of the nine test trials in MATLAB data files (.mat)  (e.g., raw_yaw_slow.mat)
These files are similar to the previous raw text files but converted into MATLAB data space for easier processing in MATLAB.
These contain similar information as the previous raw text files as well as the line of when the calibration phase and data phase starts.   

 
 
9 filtered readings of the nine test trials in MATLAB data files (.mat) (e.g., filtered_yaw_slow.mat)
These files contain filtered readings of the previous raw MATLAB files. Any missing data strings are removed. The IMU data are preprocessed and filtered.

 

9 angle readings of the nine test trials in MATLAB data files (.mat)  (e.g., filtered_angle_yaw_slow.mat)
These files contain computed angles from the previous filtered MATLAB files. Seven  computational algorithms (Accelerometer Inclination, Gyroscopic Integration, Complementary Filter, Kalman Filter, Digital Motion Processing, Madgwick Filter, Mahony Filter) are used. 

 

9 RMSE readings of the nine test trials in MATLAB data files (.mat)  (e.g., rmse_filtered_metric_yaw_slow.mat)
These files contain computed metrics such as Root-Mean-Squared-Errors (RMSE) for each computed algorithm. The RMSE is a metric for how accurately each algorithm can estimate the true rotated angle. A RMSE below 6 degrees is acceptable for quantifying human joint angles in biomechanics. 


1 tabulated data that contains the average and std of the RMSE for the nine trials (i.e., rmse_table.mat)