function [raw_files_mats, filtered_file_names, angle_file_names, metric_file_names]...
    = generate_file_names(raw_file_txt_names, data_type)
%{
    PURPOSE: To generate necessary file names for a given list of raw text
    file names 
    
    WHAT IT DOES: Given the raw .txt file names, the function generates 
    a list of necessary file names (e.g., .mat raw files, filtered, angle, metric) 
    associated with the raw text file names 

    WRITTEN ON: 27th November 2021 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.

%}    


%{
    LICENSE
     This code "generate_file_names.m" is placed under the University of Illinois at Urbana-Champaign license
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

% For given raw text file name
for i_file = 1:length(raw_file_txt_names)
    raw_file_name = raw_file_txt_names(i_file);
    % Get the rotation and speed type for a given file
    raw_file_name_decomposition = regexp(raw_file_name, '_', 'split');
    speed_type = regexprep(raw_file_name_decomposition{1}(3), '.txt', '');
    rotation_type = raw_file_name_decomposition{1}(2);
    
    % Define raw (.mat) file names that contain the raw IMU data
    raw_files_mats{i_file} = char(strcat(strcat(strcat('raw_',rotation_type), '_'), speed_type)); 
    
    % Define filtered (.mat) file names that contain filtered IMU data
    filtered_file_names{i_file} = strcat(strcat(strcat('filtered_',rotation_type), '_'), speed_type);

    % Define angle (.mat) file names that contain angles computed using various
    % alglorithms
    angle_file_names{i_file} = strcat(data_type,'_angle_',rotation_type, '_', speed_type);

    % Define metric (.mat) file names that contains RMSE data of various
    % algorithms
    metric_file_names{i_file} = strcat('rmse_',data_type,'_metric_',rotation_type, '_', speed_type);
    
end

end