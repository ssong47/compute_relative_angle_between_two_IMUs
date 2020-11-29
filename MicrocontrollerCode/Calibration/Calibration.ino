/*  Purpose: To obtain calibration settings of MPU-6050 for accurate raw gyroscopic and accelerometer readings.
 *  What it does: Teensy sketch that returns calibrate gyroscopic and acceleroemter offsets for MPU-6050
 *  Written on: 31th January 2014
 *  Done by: Luis Ródenas <luisrodenaslorda@gmail.com>
 *  Based on: the library and previous work by Jeff Rowberg <jeff@rowberg.net>
 *  Updates (of the library) should (hopefully) always be available at https://github.com/jrowberg/i2cdevlib
*/ 

/* NOTE
 *  These offsets were meant to calibrate MPU6050's internal DMP, but can be also useful for reading sensors. 
 *  The effect of temperature has not been taken into account so I can't promise that it will work if you 
 *  calibrate indoors and then use it outdoors. Best is to calibrate and use at the same room temperature.
*/ 

/* ==========  LICENSE  ==================================
 I2Cdev device library code is placed under the MIT license
 Copyright (c) 2011 Jeff Rowberg
 
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
 =========================================================
 */

// I2Cdev and MPU6050 must be installed as libraries
#include "I2Cdev.h"
#include "MPU6050.h"
#include "Wire.h"

//Change this 3 variables if you want to fine tune the skecth to your needs.
int buffersize = 1000;     //Amount of readings used to average, make it higher to get more precision but sketch will be slower  (default:1000)
int accelTolerance = 7;     //Acelerometer error allowed, make it lower to get more precision, but sketch may not converge  (default:8)
int gyroTolerance = 1;     //gyro error allowed, make it lower to get more precision, but sketch may not converge  (default:1)

//MPU6050 AccelGyro(0x68); // <-- for AD0 (pin that specifies I2C address. default is 0x68) low, use this and comment line below
MPU6050 AccelGyro(0x69); //<-- for AD0 high, use this and comment line below

int16_t ax, ay, az,gx, gy, gz; // raw values of accelerometer and gyroscope in x,y,z
int meanAx,meanAy,meanAz,meanGx,meanGy,meanGz,state = 0;
int axOffset,ayOffset,azOffset,gxOffset,gyOffset,gzOffset; 

void setup() {
  // join I2C bus (I2Cdev library doesn't do this automatically)
  Wire.begin();
  // COMMENT NEXT LINE IF YOU ARE USING ARDUINO DUE
  TWBR = 24; // 400kHz I2C clock (200kHz if CPU is 8MHz). Leonardo measured 250kHz.

  // initialize serial communication
  Serial.begin(115200);

  // initialize device
  AccelGyro.initialize();

  // wait for ready
  while (Serial.available() && Serial.read()); // empty buffer
  while (!Serial.available()){
    Serial.println(F("Send any character to start sketch.\n"));
    delay(1500);
  }                
  while (Serial.available() && Serial.read()); // empty buffer again

  // start message
  Serial.println("\nMPU6050 calibrate Sketch");
  delay(2000);
  Serial.println("\nYour MPU6050 should be placed in horizontal position, with package letters facing up. \nDon't touch it until you see a finish message.\n");
  delay(3000);
  
  // verify connection
  Serial.println(AccelGyro.testConnection() ? "MPU6050 connection successful" : "MPU6050 connection failed");
  delay(1000);
  
  // reset offsets of accelerometer and gyroscopes to zero. 
  AccelGyro.setXAccelOffset(0);
  AccelGyro.setYAccelOffset(0);
  AccelGyro.setZAccelOffset(0);
  AccelGyro.setXGyroOffset(0);
  AccelGyro.setYGyroOffset(0);
  AccelGyro.setZGyroOffset(0);

  
}


void loop() {
  // State 0 - State of finding the mean values of the accelerometer and gyroscope for the data points equal to buffer size.   
    if (state==0){ 
    Serial.println("\nReading sensors for first time...");
    meanSensors();
    state++;
    delay(1000);
  }



  // State 1 - State of finding appropriate offset values of the accelerometer and gyroscope to make the mean values from above all equal to zero, except for a_z (= 16384)
  //           These offset values will be used to configure the accelerometer and gyroscopes in the Teensy_code.ino
  if (state==1) {
    Serial.println("\nCalculating offsets...");
    calibrate_sensors();
    state++;
    delay(1000);
  }


  // State 2 - State of reporting the offset values. 
  if (state==2) {
    meanSensors();
    Serial.println("\nFINISHED!");
    Serial.print("\nSensor readings with offsets: ");
    Serial.print(meanAx); 
    Serial.print(", ");
    Serial.print(meanAy); 
    Serial.print(", ");
    Serial.print(meanAz); 
    Serial.print(", ");
    Serial.print(meanGx); 
    Serial.print(", ");
    Serial.print(meanGy); 
    Serial.print(", ");
    Serial.println(meanGz);
    Serial.print("Your offsets: ");
    Serial.print(axOffset); 
    Serial.print(", ");
    Serial.print(ayOffset); 
    Serial.print(", ");
    Serial.print(azOffset); 
    Serial.print(", ");
    Serial.print(gxOffset); 
    Serial.print(", ");
    Serial.print(gyOffset); 
    Serial.print(", ");
    Serial.println(gzOffset); 
    Serial.println("\nData is printed as: acelX acelY acelZ gyroX gyroY gyroZ");
    Serial.println("Check that your sensor readings are close to 0 0 16384 0 0 0");
    Serial.println("If calibrate was succesful write down your offsets so you can set them in your projects using something similar to mpu.setXAccelOffset(youroffset)");
    while (1);
  }
}






// "meanSensors" is a function that computes the mean raw readings of accelerometer and gyroscope data points equal to the (buffer size + 100)
// Ideally, these raw readings should equal to zero except for az = 16384 (equivalent to 1.0 gravitational constant) 
void meanSensors(){
  
  // buff_ax,ay,az,gx,gy,gz are summation of raw readings from IMU for "buffersize" data points.
  long i=0,buff_ax=0,buff_ay=0,buff_az=0,buff_gx=0,buff_gy=0,buff_gz=0; 



  while (i < (buffersize + 101)){ //while counter is less than the buffer size + 101, 
    
    // read raw accel/gyro measurements from device
    AccelGyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);
    
    if (i > 100 && i <=(buffersize + 100)){ // Discard the first 100 measurements to ensure the calibrate data does not include any transient behavior in the beginning.
      buff_ax = buff_ax + ax;
      buff_ay = buff_ay + ay;
      buff_az = buff_az + az;
      buff_gx = buff_gx + gx;
      buff_gy = buff_gy + gy;
      buff_gz = buff_gz + gz;
    }
    
    if (i == (buffersize + 100)){ // If the counter has reached the buffersize + 100, find the mean values of the raw IMU readings. 
      meanAx = buff_ax / buffersize;
      meanAy = buff_ay / buffersize;
      meanAz = buff_az / buffersize;
      meanGx = buff_gx / buffersize;
      meanGy = buff_gy / buffersize;
      meanGz = buff_gz / buffersize;
    }
    i++; 
    delay(2); //Needed so we don't get repeated measures
  }
}


// "calibrate_sensors" function finds the appropriate offset values of accelerometer and gyroscope to make the (meanAx,ay,az,gx,gy,gz) to be close to (0,0,16384,0,0,0). 
// These offset values will be used to configure the accelerometer and gyroscopes in the Teensy_code.ino
void calibrate_sensors(){
   
  axOffset = -meanAx / 8; 
  ayOffset = -meanAy / 8;
  azOffset = (16384 - meanAz) / 8; // az is parallel to gravity, so the reading of az should be near 16384 (= 1g)

  gxOffset = -meanGx / 4;
  gyOffset = -meanGy / 4;
  gzOffset = -meanGz / 4;
  
  while (1){
    int ready=0; // state variable (ranging from 0 - 6) representing whether the offset values are within the tolerance defined above (accel,gyroTolerance). 

    // Apply the newly computed offset values to the IMU's register, just like how Teensy_code.ino would in the setup code. 
    AccelGyro.setXAccelOffset(axOffset);
    AccelGyro.setYAccelOffset(ayOffset);
    AccelGyro.setZAccelOffset(azOffset);

    AccelGyro.setXGyroOffset(gxOffset);
    AccelGyro.setYGyroOffset(gyOffset);
    AccelGyro.setZGyroOffset(gzOffset);

    // After the configuration with new offsets, Find and print the mean values of accelerometer and gyroscope
    // If the offset values are set properly, the mean values should be equal to (0,0,16384,0,0,0). 
    meanSensors();
    Serial.println("...");


    Serial.print("meanAx = ");
    Serial.print(meanAx);
    Serial.print(", meanAy = ");
    Serial.print(meanAy);
    Serial.print(", meanAz = ");
    Serial.print(meanAz);
    Serial.print(", meanGx = ");
    Serial.print(meanGx);
    Serial.print(", meanGy = ");
    Serial.print(meanGy);
    Serial.print(", meanGz = ");
    Serial.print(meanGz);
    


    if (abs(meanAx) <= accelTolerance) ready++; 
    else axOffset = axOffset - meanAx / accelTolerance; 

                                                        
    if (abs(meanAy) <= accelTolerance) ready++;
    else ayOffset = ayOffset - meanAy / accelTolerance;

    if (abs(16384-meanAz) <= accelTolerance) ready++; //16384 is the digitized value of 1 gravitational constant
    else azOffset = azOffset + (16384 - meanAz) / accelTolerance;

    if (abs(meanGx)<=gyroTolerance) ready++;
    else gxOffset = gxOffset - meanGx / (gyroTolerance + 1);

    if (abs(meanGy)<=gyroTolerance) ready++;
    else gyOffset = gyOffset - meanGy / (gyroTolerance + 1);

    if (abs(meanGz)<=gyroTolerance) ready++;
    else gzOffset = gzOffset - meanGz / (gyroTolerance + 1);

    if (ready==6) break; // If all 6-axes (accelerometer x,y,z and gyroscope x,y,z) are calibrated, then exit the function
  }
}
