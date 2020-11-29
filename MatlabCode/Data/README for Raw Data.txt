/* This README contains information regarding the organization of the raw text file data. For more information, please e-mail ssong47@illinois.edu
/* Created by Seung Yun Song. January 25th 2020
 
The raw text files contain two main sets of data = 1) calibration, 2) testing data 




Each column of data contains the following = 

1) Sampled Time (ms)

2) Encoder (deg)

3,4,5,6) IMU 2 quaternion from DMP (4 values = a,b,c,d)

7,8,9,10) IMU 1 quaternion from DMP (4 values = a,b,c,d)

11,12,13) Raw Gyroscope Readings (deg/s) of IMU 2 about x,y,z (3 values) 

14,15,16) Raw Accelerometer Readings (g - gravitational constant) of IMU 2 about x,y,z (3 values)

17,18,19) Raw Gyroscope Readings (deg/s) of IMU 1 about x,y,z (3 values) 

20,21,22) Raw Accelerometer Readings (g - gravitational constant) of IMU 1 about x,y,z (3 values)