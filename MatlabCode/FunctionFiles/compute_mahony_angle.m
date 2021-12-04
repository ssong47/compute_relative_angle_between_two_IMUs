function mahony_angle = compute_mahony_angle(gyroscope_in, accelerometer_in, rot_type, dt, kp, ki)
%{
    PURPOSE: Computes Mahnoy Angle from given IMU data 

    WHAT IT DOES: Compute angle using Mahony Filter, a PI controller based
    sensor fusion algorithm. 

    See paper below for more details:
    R. Mahony, T. Hamel and J. Pflimlin, "Nonlinear Complementary Filters on the Special Orthogonal Group," 
    in IEEE Transactions on Automatic Control, vol. 53, no. 5, pp. 1203-1218, June 2008, 
    doi: 10.1109/TAC.2008.923738.

    WRITTEN ON: 27th November 2021 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.

%}    


%{
    LICENSE
     This code "compute_mahony_angle.m" is placed under the University of Illinois at Urbana-Champaign license
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

% Intialize quaternions for Mahony filter. Mahony Filter outputs a
% quaternion 
mahony_q = zeros(length(gyroscope_in), 4);

% Initialize class for Mahony Filter given the dt(time-interval), Kp, Ki
% (PI gains)
mahony = MahonyAHRS('SamplePeriod', dt, 'Kp', kp, 'Ki', ki);

% Compute quaternions using Mahony filter for all data points
for t = 1:length(gyroscope_in)
    mahony.UpdateIMU(gyroscope_in(t,:) * (pi/180), accelerometer_in(t,:));
    mahony_q(t, :) = mahony.Quaternion;
end

% Convert quaternion to euler angles
mahony_euler = quatern2euler(quaternConj(mahony_q)) * (180/pi);	% use conjugate for sensor frame relative to Earth and convert to degrees.

% Obtain Euler Angle of interest for a given rotation axis.
if strcmp(rot_type,'roll') == 1 
    mahony_angle = wrapTo360(mahony_euler(:,1));
elseif strcmp(rot_type, 'pitch') == 1
    mahony_angle = mahony_euler(:,2);
elseif strcmp(rot_type, 'yaw') == 1
    mahony_angle = mahony_euler(:,3);
end

end