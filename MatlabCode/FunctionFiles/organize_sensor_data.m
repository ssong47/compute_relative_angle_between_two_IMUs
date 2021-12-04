function [gyroscope, gyroscope_raw, accelerometer] = organize_sensor_data(gyroscope_in, gyroscope_raw_in, accelerometer_in, rot_type)
%{
    PURPOSE: To organize IMU data to run the Madgwick and Mahohny Filters

    WHHAT IT DOES: Organizes the IMU data in the appropriate format to run
    the Madgwick and Mahony Filters

    WRITTEN ON: 27th November 2021

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.
%}    


%{
    LICENSE
     This code "organize_sensor_data.m" is placed under the University of Illinois at Urbana-Champaign license
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



% Get total length of data
N = length(gyroscope_in);

% Organize Accelerometer Data [accelX, accelY, accelZ]
accelerometer = [accelerometer_in(:,1), accelerometer_in(:,2), accelerometer_in(:,3)];


% For Roll, 
if strcmp(rot_type,'roll') == 1 
    % Put gyro data as [gyroX, 0, 0] format
    gyroscope = [gyroscope_in(:,1), zeros(N,1), zeros(N,1)];
    gyroscope_raw = [gyroscope_raw_in(:,1), zeros(N,1), zeros(N,1)];  
    
% For Pitch,
elseif strcmp(rot_type, 'pitch') == 1
    % Put gyro data as [0, gyroY, 0] format
    gyroscope = [zeros(N,1), gyroscope_in(:,2), zeros(N,1)];
    gyroscope_raw = [zeros(N,1), gyroscope_raw_in(:,2), zeros(N,1)];
    
% For Yaw,
elseif strcmp(rot_type, 'yaw') == 1
    % Put gyro data as [0, 0, gyroZ] format
    gyroscope = [zeros(N,1), zeros(N,1), gyroscope_in(:,3)];
    gyroscope_raw = [zeros(N,1), zeros(N,1), gyroscope_raw_in(:,3)];
end


end