function [theta_ac] = compute_accel_inclination_angle(accel_x, accel_y, accel_z, rotation_type, imu_type, ac_offset)
    %{
    PURPOSE: To compute angle using accelerometer inclination from accelerometer data 

    WHHAT IT DOES: Computes angle by finding inclination of IMUs using accelerometer data given the
    rotation type (pitch/roll) and sampling frequency (100Hz). Note this
    cannot be used for yaw trials. 
    See https://www.analog.com/media/en/technical-documentation/application-notes/AN-1057.pdf 
    for more details.

    WRITTEN ON: 27th November 2021

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.
%}    


%{
    LICENSE
     This code "compute_accel_inclination_angle.m" is placed under the University of Illinois at Urbana-Champaign license
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
    
    % Initialize inclination angle array
    theta_ac = zeros(length(accel_x),1); 

    % Compute Inclination Angle 
    % Need to use different equations depending on rotation axis
    if strcmp(rotation_type, 'pitch') == 1
        flag = 0; % flag to keep the signs of pitch angle consistent
        for i = 2:length(accel_x)      
            
            % Compute inclination angle. 90 is added to ensure theta_ai starts from 0 deg
            theta_ac(i) = -(atand(accel_x(i)/sqrt(accel_y(i)^2 + accel_z(i)^2))+ ac_offset);

            % To prevent inversion of computed angle
            if (sign(accel_z(i)) < 0) && (strcmp(imu_type,'moving') == 1)  && (flag == 0)
                
                ref_angle = theta_ac(i-1);
                if (sign(accel_x(i)) < 0)
                    theta_ac(i) = abs(ref_angle - theta_ac(i)) + ref_angle;
                elseif (sign(accel_x(i)) > 0)
                    theta_ac(i) = ref_angle - abs(ref_angle - theta_ac(i));
                end
                flag = 1;
                
            elseif (sign(accel_z(i)) < 0) && (strcmp(imu_type,'moving') == 1)  && (flag == 1)
                
                if (sign(accel_x(i)) < 0)
                    theta_ac(i) = abs(ref_angle - theta_ac(i)) + ref_angle;
                elseif (sign(accel_x(i)) > 0)
                    theta_ac(i) = ref_angle - abs(ref_angle - theta_ac(i));
                end
                
            elseif (sign(accel_z(i)) > 0) 
                flag = 0;
            end
    
        end
                
    elseif strcmp(rotation_type, 'roll') == 1        
        for i = 2:length(accel_x)         
            theta_ac(i) = -atand(accel_y(i)/sqrt(accel_x(i)^2 + accel_z(i)^2)) + ac_offset;
        end
    
    elseif strcmp(rotation_type, 'yaw') == 1
        % theta_ac cannot be computed for yaw rotation axis, since gravity
        % vector is parallel to rotation axis.
        theta_ac = zeros(length(accel_x),1);
        
    end

end