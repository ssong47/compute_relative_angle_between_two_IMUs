/*  Purpose: To reliably control the stepper motor using Arduino Uno with various speed and range of motion.
    What it does: Given the rotational Speed, range of motion, the motor will repeatedly rotate once a digital signal is received by Teensy.
    Written on: 25th January 2020
    Done by: Seung Yun Song <ssong47@illinois.edu>
    Refer the paper: ""
*/

/* ==========  LICENSE  ==================================
  This code "Arduino_code.ino" is placed under the University of Illinois at Urbana-Champaign license
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
const int STEPS_PER_REV = 200;

const int stepPin = 10;  //OUTPUT Arduino pin # controlling the pulsing of stepper motor. HIGH - step, LOW - do not step
const int dirPin = 9; //OUTPUT Arduino pin # controlling rotation direction of stepper motor. HIGH - clockwise, LOW - counter-clockwise
const int enPinOut = 11;  //OUTPUT Arduino pin # enable/disabling the stepper motor. HIGH - off, LOW - on
const int enPinIn = 6; //INPUT Arduino pin # receiving on/off signal from Teensy 3.6
int enable; // enable - logic of enPinIn

int stepperInterval = 80; //Determines the speed. Specifically, it is the interval between steps in micro-seconds. See note below.
// sixteenth micro step is used for all speed settings
// (protocol speed): stepperInterval: mean speed (deg/s)
// (fast): 80: 200 

// (medium): 160: 97.38
 
// (slow): 600: 26.5 

int stepLimit = STEPS_PER_REV * 16; // Determines the stepper motor's range of motion (= 200 step/rev * 1/2 rev * 16 microsteps/step)


  
void setup() {
  Serial.begin(230400); // Setting baud-rate to 230400. Must be same as Teensy 3.6 and coolterm.exe baudrate.
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(enPinOut, OUTPUT);
  pinMode(enPinIn, INPUT);
  digitalWrite(enPinIn, LOW);
  digitalWrite(enPinOut, HIGH); // Pull up enPIN, so that the motor is not spinning by default.
}

void loop() {
  enable = digitalRead(enPinIn); // Read signal from Teensy 3.6
  

  // If Teensy 3.6 sends a HIGH signal to enPinIn,
  if (enable == HIGH) {
    digitalWrite(enPinOut, LOW); // Rotate the stepper motor by one step
    digitalWrite(dirPin, HIGH); // at the given direction

    for (int x = 0; x < stepLimit; x++) { // until the range of motion is reached
      digitalWrite(stepPin, HIGH); // by moving the stepper motor by one increment
      delayMicroseconds(stepperInterval);
      digitalWrite(stepPin, LOW); // and then pausing
      delayMicroseconds(stepperInterval); // with intervals in between defined by stepperInterval.
    }

    digitalWrite(dirPin, LOW); // Once range of motion is reached, switch directions

    for (int x = 0; x < stepLimit; x++) { // Perform same rotation sequence as above, except with opposite direction
      digitalWrite(stepPin, HIGH);
      delayMicroseconds(stepperInterval);
      digitalWrite(stepPin, LOW);
      delayMicroseconds(stepperInterval);
    }
  }
  else if (enPinIn == LOW) { // If Teensy 3.6 sends a LOW signal to enPinIn
    digitalWrite(enPinOut, HIGH); // Do not rotate the stepper motor.
  }
}
