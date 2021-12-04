/*   Purpose: To reliably calibrate, and collect data from MPU-6050 and encoder. 
 *   What it does: A Teensy sketch that setups and reads data from MPU-6050 and encoder. 
 *             Also, this sketch signals a separate microcontroller (Arduino Uno) that controls the stepper motor 
 *   Written on: 25th January 2020
 *   Done by: Seung Yun Song <ssong47@illinois.edu>
 *   Refer the paper: ""
*/

/* ==========  LICENSE  ==================================
 This code "Teensy_code.ino" is placed under the University of Illinois at Urbana-Champaign license
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
 =========================================================
 */

#include <I2Cdev.h>
#include <MPU6050_6Axis_MotionApps20.h>
#include <math.h>
#if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
#include "Wire.h"
#endif
#include "Arduino.h"

# define imu1 0x69 //IMU with AD0 to HIGH
# define imu2 0x68 //IMU with AD0 to LOW


// IMU 1 Variables 
MPU6050 mpu(0x69);
uint8_t mpu1Address;      // I2c address of IMU 1
Quaternion q;             // quaternion vector containing a,b,c,d. q = a + bi + cj + dk, where i,j,k are reference axes of IMU.  
float q0a, q1a, q2a, q3a; // individual components of quaternion vector 
int16_t ax1, ay1, az1;  // raw accelerometer values in x,y,z
int16_t gx1, gy1, gz1;  // raw gyroscopic values in x,y,z 
bool dmpReady = false;  // set true if Digital Motion Processing (DMP) initialization was successful
uint8_t mpuIntStatus;   // holds actual interrupt status byte from IMU
uint8_t devStatus;      // return status after each device operation (0 = success, !0 = error)
uint16_t packetSize;    // expected DMP packet size (default is 42 bytes)
uint16_t fifoCount;     // count of all bytes currently in First-In-First-Out (FIFO)
uint8_t fifoBuffer[64]; // FIFO storage buffer
int imu1CalibrationOffset[6] = {-1750, -99, 2020, 131, -64, -131};  // Calibration offset values (ax,ay,az,gx,gy,gz) obtained from calibration.ino
volatile bool mpuInterrupt1= false;     // indicates whether MPU interrupt pin has gone high


// IMU 2 Variables 
MPU6050 mpu2(0x68);
uint8_t mpu2Address;
Quaternion q2;      
float q0b, q1b, q2b, q3b;    
int16_t ax2, ay2, az2;
int16_t gx2, gy2, gz2;
bool dmpReady2 = false;  
uint8_t mpuIntStatus2;   
uint8_t devStatus2;      
uint16_t packetSize2;    
uint16_t fifoCount2;     
uint8_t fifoBuffer2[64]; 
int imu2CalibrationOffset[6] = {-3424, -1040, 1670, -36, 81, 48}; // {-3707, -341, 1621, -474, 41, -39};
volatile bool mpuInterrupt2 = false;     // indicates whether MPU interrupt pin has gone high


String rawDataString; // String containing all raw data that is transmitted to PC 

// IMU time sampling variables 
unsigned long imuCurMillis;     // most current time stamp in ms 
unsigned long imuPrevMillis = 0;// previous time stamp in ms
unsigned long imuInterval = 10; // time between two sample points in ms. For example, imuInterval = 10 -> 100 Hz
                                // Smallest imuInterval is 10. Any value below 10 is not possible due to DMP computation time.

// Stepper Motor Pin
const int enPin2 = 11  ; // stepper motor enable pin # on Teensy

// Encoder Pins
int encoderPin1 = 3; // Green line of Encoder (double check)
int encoderPin2 = 2; // White line of Encoder (double check)

// Encoder Variables for Computation
volatile int lastEncoded = 0;
long lastencoderValue = 0;
int lastMSB = 0;
int lastLSB = 0;
volatile long encoderValue = 0; // Raw encoder output data in digital units
float encoderAngle = 0 ;        // Encoder angle in degrees 
float countPerRev = 4000.0000;  // Counter per Rev
float fullRot = 351.0000;       // not 360.000 deg due to slight offset of the optical encoder alignment with motor shaft.  


// This function computes the digital encoder value by updating the raw digital encoder values read from encoder pin 1 (MSB) and 2 (LSB)
void updateEncoder() {
  int MSB = digitalRead(encoderPin1); //MSB = most significant bit
  int LSB = digitalRead(encoderPin2); //LSB = least significant bit

  int encoded = (MSB << 1) | LSB; //converting the 2 pin value to single number
  int sum  = (lastEncoded << 2) | encoded; //adding it to the previous encoded value

  if (sum == 0b1101 || sum == 0b0100 || sum == 0b0010 || sum == 0b1011) encoderValue ++;
  if (sum == 0b1110 || sum == 0b0111 || sum == 0b0001 || sum == 0b1000) encoderValue --;

  lastEncoded = encoded; //store this value for next time
}


// Define time and sample number
unsigned long sampleTime;
unsigned long sampleTimeOld;
int samplingSpeed;  
unsigned long sampleNumber = 1;
signed long totalTestTime;
boolean dataEntryDone = 0;


// IMU calibration information (accel range, accel sensitivity, gyro range, gyro sensitivity)
String imuInfo;
String imu1Info;
String imu2Info;
uint8_t gyroRange;
uint8_t accelRange;
float gyroSensitivity;
float accelSensitivity;


void imuSetupCalibration(int offset1[], int offset2[], int (& sensorRange) [2]) {
  // Setup and Calibration of IMU 1
  Wire.beginTransmission(imu1);
  Serial.print(" Found I2C address:"); Serial.println(imu1, HEX);
  Serial.println(F("Initializing I2C devices..."));
  mpu.initialize();
  Serial.println(F("Testing device connections..."));
  Serial.println(mpu.testConnection() ? F("MPU6050 connection successful") : F("MPU6050 connection failed"));
  Serial.println(F("Initializing DMP..."));
  devStatus = mpu.dmpInitialize();

  // Applying accelerometer and gyroscopic offsets obtained from Calibration.ino sketch for accurate raw sensor readings
  mpu.setXAccelOffset(offset1[0]);
  mpu.setYAccelOffset(offset1[1]);
  mpu.setZAccelOffset(offset1[2]);
  mpu.setXGyroOffset(offset1[3]);
  mpu.setYGyroOffset(offset1[4]);
  mpu.setZGyroOffset(offset1[5]);


  // Get gyroscope and accelerometer range 
  gyroRange = mpu.getFullScaleGyroRange();
  accelRange = mpu.getFullScaleAccelRange();
  sensorRange[0] = gyroRange; 
  sensorRange[1] = accelRange;
 
  // If IMU are properly running, enable DMP and start reading data from IMU
  if (devStatus == 0) {
    Serial.println(F("Enabling DMP..."));
    mpu.setDMPEnabled(true);
    Serial.println(F("Enabling interrupt detection (Arduino external interrupt 0)..."));
    mpuIntStatus = mpu.getIntStatus();
    Serial.println(F("DMP ready! Waiting for first interrupt..."));
    dmpReady = true;
    packetSize = mpu.dmpGetFIFOPacketSize();

  } else {
    // ERROR!
    // 1 = initial memory load failed (most common mode of failure. Reboot if necessary)
    // 2 = DMP configuration updates failed
    Serial.print(F("DMP Initialization failed (code "));
    Serial.print(devStatus);
    Serial.println(F(")"));
  }
  Wire.endTransmission(imu1);



  // Setup and Calibration of IMU 2
  Wire.beginTransmission(imu2);
  Serial.print(" Found I2C address:"); Serial.println(imu2, HEX);
  Serial.println(F("Initializing I2C devices..."));
  mpu2.initialize();
  Serial.println(F("Testing device connections..."));
  Serial.println(mpu2.testConnection() ? F("MPU6050 connection successful") : F("MPU6050 connection failed"));
  Serial.println(F("Initializing DMP..."));
  devStatus2 = mpu2.dmpInitialize();

  mpu2.setXAccelOffset(offset2[0]);
  mpu2.setYAccelOffset(offset2[1]);
  mpu2.setZAccelOffset(offset2[2]);
  mpu2.setXGyroOffset(offset2[3]);
  mpu2.setYGyroOffset(offset2[4]);
  mpu2.setZGyroOffset(offset2[5]);
  

  if (devStatus2 == 0) {
    Serial.println(F("Enabling DMP..."));
    mpu2.setDMPEnabled(true);
    Serial.println(F("Enabling interrupt detection (Arduino external interrupt 0)..."));
    Serial.println(F("DMP ready! Waiting for first interrupt..."));
    dmpReady2 = true;
    packetSize2 = mpu2.dmpGetFIFOPacketSize();

  } else {
    Serial.print(F("DMP Initialization failed (code "));
    Serial.print(devStatus2);
    Serial.println(F(")"));
  }
  Wire.endTransmission(imu2);
}



void imuRead(uint8_t addr, char outputType) {

  //Enter here whenever time interval exceeds imuInterval 
  if (imuCurMillis - imuPrevMillis >= imuInterval) { 
    imuPrevMillis = imuCurMillis;
    imuCurMillis = millis();

    // Record Time Stamps and speed
    sampleTime = millis();
    samplingSpeed = 1000 / (sampleTime - sampleTimeOld);


    // Start reading data from IMU 1 
    Wire.beginTransmission(imu1);
    if (!dmpReady) return;        // if DMP failed, don't try to do anything
    mpu1Address = mpu.getDeviceID();
    mpuInterrupt1 = false;        // reset interrupt flag and get INT_STATUS byte 
    mpuIntStatus = mpu.getIntStatus();
    fifoCount = mpu.getFIFOCount();

    if (fifoCount == 1024) { // check for overflow (this should never happen unless our code is too inefficient)
      mpu.resetFIFO();       // reset so we can continue cleanly      
    } else if (mpuIntStatus & 0x02) {   // otherwise, check for DMP data ready interrupt (this should happen frequently)
     
      fifoCount = mpu.getFIFOCount();   // wait for correct available data length, should be a VERY short wait
      while (fifoCount < packetSize) fifoCount = mpu.getFIFOCount();
      mpu.getFIFOBytes(fifoBuffer, packetSize); // read a packet from FIFO
      
      // track FIFO count here in case there is > 1 packet available
      // (this lets us immediately read more without waiting for an interrupt)
      fifoCount = 0;
      switch (outputType) {
        case 'r':
          // display quaternion values in easy matrix form: w x y z
          mpu.dmpGetQuaternion(&q, fifoBuffer);
          q0a = q.w; q1a = q.x; q2a = q.y; q3a = q.z;
          mpu.getMotion6(&ax1, &ay1, &az1, &gx1, &gy1, &gz1);
          break;

      }

    }
    mpu.resetFIFO();
    Wire.endTransmission(imu1);



    // Start reading data from IMU 2 
    Wire.beginTransmission(imu2);
    if (!dmpReady2) return;
    mpu2Address = mpu2.getDeviceID();
    mpuInterrupt2 = false;
    mpuIntStatus2 = mpu2.getIntStatus();
    fifoCount2 = mpu2.getFIFOCount();
    if (fifoCount2 == 1024) {
      mpu2.resetFIFO();
    } else if (mpuIntStatus2 & 0x02) {
      fifoCount2 = mpu2.getFIFOCount();
      while (fifoCount2 < packetSize) fifoCount2 = mpu2.getFIFOCount();
      mpu2.getFIFOBytes(fifoBuffer2, packetSize);
      fifoCount2 = 0;

      switch (outputType) {
        case 'r':
          mpu2.dmpGetQuaternion(&q2, fifoBuffer2);
          mpu2.getMotion6(&ax2, &ay2, &az2, &gx2, &gy2, &gz2);

          q0b = q2.w; q1b = q2.x; q2b = q2.y; q3b = q2.z;

          encoderAngle = encoderValue / countPerRev * fullRot; //Processed encoder output data in angular units (degrees)

          // Gather all raw data that you wish to transmit to PC
          rawDataString = String(millis()) + "," + String(-encoderAngle) + "," + String(q0b) + "," + String(q1b) + "," + String(q2b) + "," + String(q3b) + "," +  String(q0a) + "," + String(q1a) + "," + String(q2a) + "," + String(q3a) + "," +String((gx2) / (gyroSensitivity))+ "," + String((gy2) / (gyroSensitivity)) + "," + String((gz2) / (gyroSensitivity))+ "," + String((ax2) / (accelSensitivity)) + "," + String(ay2/accelSensitivity) + "," + String((az2)/(accelSensitivity)) + "," + String((gx1) / (gyroSensitivity))+ "," + String((gy1) / (gyroSensitivity)) + "," + String((gz1) / (gyroSensitivity))+ "," + String((ax1) / (accelSensitivity)) + "," + String(ay1/accelSensitivity) + "," + String((az1)/(accelSensitivity));
          Serial.println(rawDataString);
          sampleNumber++;
          delay(2);
          break;
      }

    }
    mpu2.resetFIFO();
    Wire.endTransmission(imu2);

  }
  
}



void setup() {


#if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE // join I2C bus (I2Cdev library doesn't do this automatically)
  Wire.begin();
  Wire.setClock(400000); // 400kHz I2C clock. Comment this line if having compilation difficulties
#elif I2CDEV_IMPLEMENTATION == I2CDEV_BUILTIN_FASTWIRE
  Fastwire::setup(400, true);
#endif

  Serial.begin(230400); // initialize serial communication and set baud rate (230400). Recommend not going below this to ensure proper data sampling
                        // Ensure baudrate of Arduino_code.ino and coolterm.exe baudrate are the same as this value 
  delay(500); 

  //Setup for Stepper Motor 
  pinMode(enPin2, OUTPUT);
  digitalWrite(enPin2, LOW);
  delay(100);


  // Setup for Encoder Reading 
  // Encoder Pin Setup to Input mode and pull up mode.
  pinMode(encoderPin1, INPUT_PULLUP);
  pinMode(encoderPin2, INPUT_PULLUP);


  // Encoder pin setup to high
  digitalWrite(encoderPin1, HIGH); //turn pullup resistor on
  digitalWrite(encoderPin2, HIGH); //turn pullup resistor on


  //Call updateEncoder() when any high/low changed seen
  //on interrupt 0 (pin 2), or interrupt 1 (pin 3)
  attachInterrupt(encoderPin1, updateEncoder, CHANGE);
  attachInterrupt(encoderPin2, updateEncoder, CHANGE);


  // IMU Setup and Calibration
  Serial.println("================== Beginning IMU Calibration ==================");

  int sensorRange[2] = {0,0};
  imuSetupCalibration(imu1CalibrationOffset, imu2CalibrationOffset, sensorRange);


  
  // Set appropriate gyro and accel sensitivity given the range. 
  gyroRange = sensorRange[0];
  accelRange = sensorRange[1];

  
  Serial.print("Reported Gyroscope range:");
  Serial.println(gyroRange);
  Serial.print("Reported Accelerometer range:");
  Serial.println(accelRange);
  
  switch (gyroRange) {
    case 0:
      gyroSensitivity = 131;
      break;
    case 1:
      gyroSensitivity = 65.5;
      break;
    case 2:
      gyroSensitivity = 32.8;
      break;
    case 3:
      gyroSensitivity = 16.4;
      break;
  }

  switch (accelRange) {
    case 0:
      accelSensitivity = 16384;
      break;
    case 1:
      accelSensitivity = 8192;
      break;
    case 2:
      accelSensitivity = 4096;
      break;
    case 3:
      accelSensitivity = 2048;
      break;
  }





  delay(1000);
}




void loop() {
  digitalWrite(enPin2, LOW); //Disable Stepper motor when not in use

  while (Serial.read() >= 0) {} // wait for input to arrive
  Serial.println(); //Print new line for spacing
  Serial.println();
  
  //Display serial menu options. Send the character 'i','q','c' via serial monitor to perform the commands below.
  //Use serial monitor as command center to control the IMUs. For data logging, use Coolterm.exe. 
  Serial.println(F("type:"));
  Serial.println(F("i - input trial info"));  
  Serial.println(F("c - calibration"));       // Before test trial, run this code. Make sure the 2 IMUs axes are parallel during calibration. 
                                              // Ensure the IMUs are not disturbed. The stepper motors will not be running                                              
  Serial.println(F("r - record data"));       // Start collecting test data and rotate the stepper motor for 25 minutes. 

  sampleNumber = 1;

  while (!Serial.available()) {} // waiting for input to arrive
  char c = toLowerCase(Serial.read());
  
  // Discard extra Serial data.
  do {
    delay(10);
  } while (Serial.readString() == 'c' || Serial.readString() == 'r' || Serial.readString() == 'i' );
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------
  switch (c) {
    case 'i':
      delay(10);
      Serial.println();
      Serial.println(F("================== Recording Test Setup Information =================="));
      while (1) {
        Serial.print(F("Trial #: "));
        while (1) {
          if (Serial.available() > 0) {
            String trialNumber = Serial.readString();
            Serial.println(trialNumber);
            break;
          }
        }

        Serial.print(F("Rotation Axis (1 - Roll, 2 - Pitch, 3 - Yaw): "));
        while (1) {
          if (Serial.available() > 0) {
            String speedSetup = Serial.readString();
            Serial.println(speedSetup);
            break;
          }
        }

        Serial.print(F("Max Speed (1 - 25deg/s, 2 - 100deg/s, 3 - 200deg/s: "));
        while (1) {
          if (Serial.available() > 0) {
            String speedSetup = Serial.readString();
            Serial.println(speedSetup);
            break;
          }
        }


        Serial.print(F("IMU 1 (8 Pin) Calibration Offset (Accel X,Y,Z, Gyro X,Y,Z): "));
        imu1Info = String(imu1CalibrationOffset[0]) + ", " + String(imu1CalibrationOffset[1]) + ", " + String(imu1CalibrationOffset[2]) + ", " + String(imu1CalibrationOffset[3]) + ", " + String(imu1CalibrationOffset[4]) + ", " + String(imu1CalibrationOffset[5]);
        Serial.println(imu1Info);
        //
        Serial.print(F("IMU 2 (6 Pin) Calibration Offset (Accel X,Y,Z, Gyro X,Y,Z): "));
        imu2Info = String(imu2CalibrationOffset[0]) + ", " + String(imu2CalibrationOffset[1]) + ", " + String(imu2CalibrationOffset[2]) + ", " + String(imu2CalibrationOffset[3]) + ", " + String(imu2CalibrationOffset[4]) + ", " + String(imu2CalibrationOffset[5]);
        Serial.println(imu2Info);


        Serial.print(F("IMU Accel range, Accel sensitivity, Gyro range, Gyro sensitivity): "));
        imuInfo = String(accelRange) + ", " + String(accelSensitivity) + ", " + String(gyroRange) + ", " + String(gyroSensitivity);
        Serial.println(imuInfo);


        Serial.print(F("Data entry done? (If so, press enter)  "));
        while (1) {
          if (Serial.available() > 0) {
            dataEntryDone = 1;
            Serial.println("Done!");
            Serial.flush();
            break;
          }
        }
        if  (dataEntryDone == 1) {
          break;
        }
      }

    case 'c':
      Serial.flush();
      delay(10);
      Serial.println();
      Serial.println("================== Calibrating IMUs ==================");

      while (sampleNumber <= 500) {   // calibrate for 5 seconds approximately, or 500 data points.
        imuCurMillis = millis();
        imuRead(imu1, 'r');
        imuRead(imu2, 'r');
        sampleTimeOld = sampleTime;
        if (Serial.available()) {
          break;
        }

      }


      break;

    default:
      Serial.println();
      Serial.println(F("Invalid entry!!!"));
      break;

  
    case 'r':


      delay(10);
      Serial.println();
      Serial.println("================== Recording IMU + Encoder Data ==================");
      totalTestTime = millis();
      int motorDelayCounter = 0;
      while (1) {
        if (motorDelayCounter >= 10000){  // Do not start rotating motor right away for protection.
          digitalWrite(enPin2, HIGH);
        }
        imuCurMillis = millis();
        imuRead(imu1 , 'r');
        imuRead(imu2 , 'r');
        sampleTimeOld = sampleTime;
        motorDelayCounter = motorDelayCounter + 1;

   
        if (Serial.available() || ((millis() - totalTestTime) >= 1500000)) {      // If any command is sent to serial monitor, end test after approximately 25 minutes of running time.
          digitalWrite(enPin2, LOW);
          break;
        }

       
      }

      break;
  }
}
