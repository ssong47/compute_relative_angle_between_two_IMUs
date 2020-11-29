/* This README contains information regarding the microcontroller code (Teensy & Arduino) for IMU study. For more information, please e-mail ssong47@illinois.edu
/* Created by Seung Yun Song. January 25th 2020


==================================== LIBRARIES ====================================
<I2Cdev.zip>
Purpose: Necessary library file for communicating from Teensy 3.6 to MPU-6050 via I2C. 




<MPU6050.zip>
Purpose: Necessary library file for running the MPU-6050 IMUs based on InvenSense MPU-6050 register map document. 



==================================== TEENSY 3.6 PJRC ====================================
<Calibration.ino>*
Purpose: To calibrate the accelerometer and gyroscope of MPU-6050 by removing the offsets of the raw readings.
Flashed on: Teensy 3.6 PJRC


<Teensy_Code.ino>**
Purpose: To setup, collect data  from IMU 1, IMU 2, and encoder. To send 
Flashed on: Teensy 3.6 PJRC




==================================== ARDUINO UNO ====================================
<Arduino_Code.ino>
Purpose: To control the stepper motor at proper speeds (microseconds between each step), range of motion (step limit), and direction.
Flashed on: Arduino Uno




==================================== INSTRUCTIONS ====================================
1) Ensure all the electronic components are properly wired
2) Download the Arduino IDE from https://www.arduino.cc/en/main/software
3) Download Coolterm.exe from https://freeware.the-meiers.org/
4) Add the library files to the Arduino IDE
5) Follow the instructions at PJRC to flash arduino code files to Teensy 3.6 https://www.pjrc.com/teensy/loader.html
6) Flash the <Calibration.ino> into the Teensy 3.6
7) Calibrate the accelerometer and gyroscopes the IMUs by following the instructions in <Calibrate.ino>
8) Flash the <Teensy_Code.ino> with the proper offsets of IMU 1 and IMU 2 obtained from the calibrations
9) Flash the <Arduino_Code.ino> into the Arduino Uno with the desired motor driver setting
10) Set the motor driver to proper pulse/rev. 
11) Run the <Teensy_Code.ino> by connecting PC to the Teensy microcontroller via Coolterm.exe. The coolterm can send commands to the Teensy 3.6, collect and record data. 
12) Press 'c' to calibrate the two IMUs
13) Press 'q' to start collecting data and moving the stepper motor. Press any key to stop running the test. 

