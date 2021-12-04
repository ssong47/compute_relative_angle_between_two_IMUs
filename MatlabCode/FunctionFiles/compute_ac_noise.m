function [avg_noise, var_noise] = compute_ac_noise(read_directory, file_names)
%{
    PURPOSE: Investigating the noise level of accerometers to determine
    proper cut off frequency for low pass filtering acceleromter data

    WHAT IT DOES: Computes the average and variance of the noise
    level of accelerometers for all trials. 

    WRITTEN ON: 27th November 2021 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.

%}    


%{
    LICENSE
     This code "compute_ac_noise.m" is placed under the University of Illinois at Urbana-Champaign license
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


% Intialize the pooled batch accelerometer inclination angle (AC angle)
% and encoder angle 
batch_ac_angle = [];
batch_encoder = [];

% From all trials
for i_file = 1: length(file_names)
    % Load the accelerometer and encoder data from each trial
    load(strcat(read_directory, char(file_names{i_file})), 'ac_angle','encoder');
    
    % Pool the accelerometer and encdoer data together
    batch_ac_angle = [batch_ac_angle; ac_angle];
    batch_encoder = [batch_encoder; encoder];
end


% Compute the noise of accelerometer inclination angle
noise = abs(batch_ac_angle - batch_encoder);

% Compute the average and variance level of noise
avg_noise = mean(noise);
var_noise = var(noise);


end