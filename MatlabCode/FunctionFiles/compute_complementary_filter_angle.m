function theta_cf = compute_complementary_filter_angle(gamma, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z, dt, rot_type, imu_type, ac_offset)
    %{
    PURPOSE: To compute angle using Complementary Filter from accelerometer and Gyro data 

    WHHAT IT DOES: Computes angle by using Complementary Filter which fuses accelerometer and gyro data given the
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
     This code "compute_complementary_filter_angle.m" is placed under the University of Illinois at Urbana-Champaign license
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
    

    
    inverse_gamma = 1 - gamma; % inverse complementary term 

    % Intialize CF angle
    theta_cf = zeros(size(accel_x));
    
    % Compute accelerometer inclination angle so that we can fuse it w/ 
    % with gyro data later in this function
    theta_accel = compute_accel_inclination_angle(accel_x, accel_y, accel_z, rot_type, imu_type, ac_offset);
    
    % Obtain relevant Gyro data for the associated rotation axis
    if strcmp(rot_type, 'pitch') == 1
        gyro = gyro_y;
        
    elseif strcmp(rot_type, 'roll') == 1
        gyro = gyro_x;
    
    elseif strcmp(rot_type, 'yaw') == 1
        % Negative sign is added to make sure theta_gi has same sign as
        % theta_encoder
        gyro = -gyro_z;
        
    end
    
    % Compute CF angle using complementary filter 
    for idx = 1:length(theta_cf)
        if idx == 1 % for the first data sample, only use the current data sample point
            theta_cf(idx) = inverse_gamma * gyro(idx) * dt + gamma * theta_accel(idx); 
        else % for the data sample greater than 1, use the previous and current data sample. 
             % This naturally smoothens the CF angle. 
            theta_cf(idx) = inverse_gamma * (theta_cf(idx - 1) + gyro(idx) * dt) + gamma * theta_accel(idx);         
        end
    end
    
    

end