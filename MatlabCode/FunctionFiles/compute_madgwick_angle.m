function madgwick_angle = compute_madgwick_angle(gyroscope_in, accelerometer_in, rot_type, dt, beta)
%{
    PURPOSE: To compute angle using Madgwick Filter

    WHHAT IT DOES: Computes angle using Madgwick Filter, a sensor fusion
    algorithm using gradient descent algorithm for better estimating the IMU 
    angles, for a given rotation type.

    See the paper below for more details: 
    
    S. O. H. Madgwick, A. J. L. Harrison and R. Vaidyanathan, 
    "Estimation of IMU and MARG orientation using a gradient descent algorithm," 
    2011 IEEE International Conference on Rehabilitation Robotics, 2011, pp. 1-7, 
    doi: 10.1109/ICORR.2011.5975346.

    WRITTEN ON: 27th November 2021

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.
%}    


%{
    LICENSE
     This code "compute_madgwick_angle.m" is placed under the University of Illinois at Urbana-Champaign license
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



% Initialize the output quaternion array for Madgwick Filter. The Madgwick
% Filter outputs the quaternion first. We later have to convert it to Euler
% angles 
madgwick_q = zeros(length(gyroscope_in), 4);

% Define Madgwick Class
Madgwick = MadgwickAHRS('SamplePeriod', dt, 'Beta', beta);

% For all the IMU data, apply Madgwick Filter to obtain quaternion 
for t = 1:length(gyroscope_in)
    Madgwick.UpdateIMU(gyroscope_in(t,:) * (pi/180), accelerometer_in(t,:));
    madgwick_q(t, :) = Madgwick.Quaternion;
end

% Convert the quaternion to euler angles (deg)
madgwick_euler = quatern2euler(quaternConj(madgwick_q)) * (180/pi);	% use conjugate for sensor frame relative to Earth and convert to degrees.

% For given rotation type, find the angle of interest from the Euler Angles
if strcmp(rot_type,'roll') == 1 
    madgwick_angle = wrapTo360(madgwick_euler(:,1));  
elseif strcmp(rot_type, 'pitch') == 1
    madgwick_angle = madgwick_euler(:,2);  
elseif strcmp(rot_type, 'yaw') == 1
    madgwick_angle = madgwick_euler(:,3);  
end  

end