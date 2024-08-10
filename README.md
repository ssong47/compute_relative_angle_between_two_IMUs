# Sensor-fusion algorithms to compute 3D orientation of two 6-axis IMUs
This github repository contains code to compute relative joint angles of two 6-axis IMUs (MPU6050) using various sensor fusion algorithms.
![song1-3203346-large](https://github.com/user-attachments/assets/a2e656bc-1451-4b74-90f5-e151c0c9e783)


This repository contains data processing code from the paper below:
<br> **Corresponding paper**: [Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers](https://ieeexplore.ieee.org/abstract/document/9888780)


*Abstract* — Inertial measurement units (IMUs) are used in biomechanical and clinical applications for quantifying joint kinematics. This study aimed to assist researchers new to IMUs and wanting to develop an inexpensive IMU system to estimate the relative angle between IMUs, while understanding the different algorithms for estimating angular kinematics. Thus, there were three subgoals: 1) to present a low-cost and convenient IMU system utilizing two 6-axis IMUs for computing the relative angle between the IMUs; 2) to examine seven methods for estimating the angular kinematics of an IMU; and 3) to provide an open-source code and working principles of these methods. The raw gyroscopic and accelerometer data were preprocessed. The seven methods included gyroscopic integration (GI), accelerometer inclination (AC), basic complementary filter (BCF), Kalman filter (KF), digital motion processor (DMP, a proprietary algorithm), Madgwick filter (MW), and Mahony filter (MH). An apparatus was designed to test nine conditions that computed angles for rotation about three axes (roll, pitch, yaw) and three movement speeds (50°/s, 150°/s, 300°/s). Each trial lasted 25 min. The root-mean-squared error (RMSE) between the gold-standard value measured from the apparatus’ encoder and the value calculated from each of the seven methods was determined. For roll and pitch, all methods accurately quantified angles (RMSE < 6°) at all speeds. For yaw, all methods except AC and DMP displayed RMSE < 6° at all speeds. AC could not be used for yaw angle computation, and DMP displayed RMSE >6°. Researchers can utilize appropriate methods based on their study’s application.



## Table of Contents
1. [Introduction](#introduction)
2. [How to Use the Code](#how-to-use-the-code)
3. [Contact Information](#contact-information)
4. [License](#license)

## Introduction
The code files in this repository are used to process data was collected during our IMU study. The goal of this study was to provide a low-cost and accurate (RMSE < 6deg) IMU system to assist other researchers to compute relative joint angle (and any other applications). While there are expensive research grade IMUs in the commercial market, we encountered numerous scenarios in which a low-cost IMU system with slightly less accuracy was needed when running biomechanics and clinical studies. Thus, in this study, we used two low-cost 6-axis IMUs to compute relative angles by utilizing six different sensor fusion algorithms that range from simple gyroscopic integration to more sophisticated optimizer based sensor fusion algorithms. The level of accuracies for each algorithm was measured through a special test apparatus with programmable speeds up to 300 deg/s, three rotation axes, and relatively long test duration (~20 minutes). The apparatus contained a stepper motor and an encoder attached to the motor shaft. An IMU was attached to the motor shaft, while the other IMU was attached to stationary surface to serve as a reference. The encoder angle served as a gold standard to determine the root-mean squared error for each sensor fusion algorith. The inner workings, pros/cons, and tuning methods for each algorithm are discussed in the corresponding paper. 

The data from this study can be found in this [IEEE DataPort](https://ieee-dataport.org/open-access/estimating-relative-angle-between-two-6-axis-inertial-measurement-units-imus). You can use this data with the code in this repository as an example of how to process the validation study data.


## How to Use the Code
### Microcontroller Code
This C code is uploaded into the microcontrollers for controlling the stepper motor and reading the encoder + IMU data. In this study, we used two microcontroller codes were used since two different microcontrollers were used. First, the arduino code (ArduinoCode.ino) is used for controlling the stepper motor speed, direction, and duration. Second, the teensy code (TeensyCode.ino) is used for collecting IMU data from the two IMUs and the encoder angle data at a fixed sampling rate. When uploading the code to the microcontrollers, I recommend using the open source arduino software IDE (https://www.arduino.cc/en/software). Note that when uploading code to Teensy, you need follow some additional steps to enalbe the IDE interface with Teensy (https://www.pjrc.com/teensy/tutorial.html). Also, note that when uploading the teensy code, you need to include the library files (I2Cdev.zip and MPU6050.zip) into the arduino IDE. 

### Matlab Code (Data Processing Code)
This matlab code processes the collected IMU and motor encoder data to compare the accuracies. To run this code, simply git clone this repo (or download and unzip) and place the folder "MatlabCode" anywhere. Run the "Main.m" file to pre-process, compute using sensor fusion algorithms, plot, and save the IMU data.  

### Data files
The data files are saved in .mat file format to make it easier for MATLAB software to read/write/save data. See "MatlabCode/Data/README for Data.txt" for more information. 

## Contact Information
For any questions regarding the study or the data processing code, please contact:
- Seung Yun (Leo) Song: ssong47@illinois.edu
- Dr. Elizabeth Hsiao-Wecksler: ethw@illinois.edu

## License
MIT License

Copyright (c) 2021 ssong47

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
