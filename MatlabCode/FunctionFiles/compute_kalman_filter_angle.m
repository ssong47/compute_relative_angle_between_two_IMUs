function theta_kf = compute_kalman_filter_angle(Q, R, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z, dt, rotation_type, imu_type, ac_offset)
    %{
    PURPOSE: To compute angle using Kalman Filter from accelerometer and Gyro data 

    WHHAT IT DOES: Computes angle by using Kalman Filter which fuses accelerometer and gyro data given the
    rotation type (yaw/pitch/roll) and sampling frequency (100Hz). 
    
    See below paper for more details: 
    P. Gui, L. Tang, and S. Mukhopadhyay, “MEMS based IMU for tilting 
    measurement: Comparison of complementary and kalman filter based data
    fusion,” in 2015 IEEE 10th Conference on Industrial Electronics 
    and Applications (ICIEA), 2015, pp. 2004–2009,
    doi: 10.1109/ICIEA.2015.7334442.

    WRITTEN ON: 27th November 2021

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.
%}    


%{
    LICENSE
     This code "compute_kalman_filter_angle.m" is placed under the University of Illinois at Urbana-Champaign license
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


    % Array of measurement updates using accelerometer measurements
    theta_hat_accel = compute_accel_inclination_angle(accel_x, accel_y, accel_z, rotation_type, imu_type, ac_offset);

    % Obtain relevant gyro data for a given rotation type
    if strcmp(rotation_type, 'pitch') == 1
        gyro = gyro_y;
    elseif strcmp(rotation_type, 'roll') == 1
        gyro = gyro_x;
    elseif strcmp(rotation_type, 'yaw') == 1
        % Negative sign is added to make sure theta_gi has same sign as
        % theta_encoder
        gyro = -gyro_z;
    end

    % State Space Model
    A = [1 -dt; 0 1];
    B = [dt; 0];
    C = [1 0; 0 0];
    P = eye(2) * 10^6; %6


    state_estimate = [0 0]'; % initial condition of state estimate
    
    theta_hat_kalman    = zeros(1, length(accel_x)); % estimate of angle
    bias_theta_kalman   = zeros(1, length(accel_x)); % estimate of bias of gyro

    % Compute Kalman filter angle
    for i = 2:length(accel_x)
  
        % Update the input (u_k)
        theta_dot = gyro(i);

        % Predict the state (x_k)
        state_estimate = A * state_estimate + B * [theta_dot];

        % Predict the error covariance matrix 
        P = A * P * A' + Q;

        % Update the measurement 
        measurement = [theta_hat_accel(i) 0]'; 

        % Update the new output measurement using measurement and state
        % estimate
        y_tilde = measurement - C * state_estimate;

        % Obtain Kalman Gain
        S = R + C * P * C';
        K = P * C' * (S^-1);

        % Update new state estimate combining prediction and update terms 
        state_estimate = state_estimate + K * y_tilde;

        % Update new error covariance matrix using Kalman Gain
        P = (eye(2) - K * C) * P;

        theta_hat_kalman(i)    = state_estimate(1);
        bias_theta_kalman(i)   = state_estimate(2);
    end
    
    theta_kf = theta_hat_kalman.'; % Change from row to column vector. 

end