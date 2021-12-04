function theta_gi = compute_gyro_integration_angle(gyro_x, gyro_y, gyro_z, dt, rotation_type)
%{
    PURPOSE: To compute angle using gyro integration from gyro data 

    WHHAT IT DOES: Computes angle by integrating gyrscopic data given the
    rotation type (yaw/pitch/roll) and sampling frequency (100Hz). 

    WRITTEN ON: 27th November 2021

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.
%}    


%{
    LICENSE
     This code "compute_gyro_integration_angle.m" is placed under the University of Illinois at Urbana-Champaign license
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
    % For a given rotation type
    if strcmp(rotation_type, 'pitch') == 1
        % integrate the relevant gyro data using cumtrapz and dt(=0.01)
        theta_gi = dt * cumtrapz(gyro_y);
        
    elseif strcmp(rotation_type, 'roll') == 1
        theta_gi = dt * cumtrapz(gyro_x);

    elseif strcmp(rotation_type, 'yaw') == 1
        theta_gi = dt * cumtrapz(-gyro_z); 
    end
    % Note that the negative sign was added since the encoder was flipped
    % for yaw trials. Thus, we matched the signs of the gyro and encoder
    % by adding negative sign to the appropriate places. However, this does
    % not alter the results or our claims.
    

end