%{
    PURPOSE: A governing main code to run all function files for computing 
    and analyzing angles calculated using various methods. 

    WHHAT IT DOES: extract, filter, compute, compare, and plot angles computed
    using various methods (GI, AI, KF, CF, DMP)

    WRITTEN ON: 25th January 2020 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER: "Convenient and Low-Cost Methods of Calculating Human 
    Joint Angles using Inertial Measurement Units without Magnetometers" 
%}    


%{
    LICENSE
     This code "Main.m" is placed under the University of Illinois at Urbana-Champaign license
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

%} 

clear all; clc; close all;

% Add directories to necessary files. 
addpath('FunctionFiles');
addpath('Data');
addpath('Figures');


% Raw text file names to be read
raw_file_txt_names = {'raw_pitch_fast.txt', 'raw_pitch_medium.txt', 'raw_pitch_slow.txt',...
    'raw_roll_fast.txt', 'raw_roll_medium.txt', 'raw_roll_slow.txt',...
    'raw_yaw_fast.txt', 'raw_yaw_medium.txt', 'raw_yaw_slow.txt'};

raw_file_txt_names = {'raw_yaw_fast.txt'};


% Generate a list of file names to be read for extracting, filtering,
% computing angle, comparing angles. 
for i_file = 1:length(raw_file_txt_names)
    raw_file_name = raw_file_txt_names(i_file);
    raw_file_name_decomposition = regexp(raw_file_name, '_', 'split');
    speed_type = regexprep(raw_file_name_decomposition{1}(3), '.txt', '');
    rotation_type = raw_file_name_decomposition{1}(2);
    
    raw_files_mat{i_file} = char(strcat(strcat(strcat('raw_',rotation_type), '_'), speed_type)); 
    
    filtered_file_name{i_file} = strcat(strcat(strcat('filtered_',rotation_type), '_'), speed_type);

    angle_file_names{i_file} = strcat(strcat(strcat('angle_',rotation_type), '_'), speed_type);
    
    metric_file_names{i_file} = strcat(strcat(strcat('metric_',rotation_type), '_'), speed_type);
end


% Get current directory
current_directory = pwd;


% Change the directory to where all the raw data are
read_directory = strcat(pwd,'\Data\');


% Change save_directory to where you want to save the .mat and figure files
save_directory = strcat(pwd,'\Data\');
save_directory_figures = strcat(pwd,'\Figures\');
save_status = 'yes';

% Set sampling frequency in Hz
sampling_freq = 100;

% Extract Raw Data (Comment this step if already done)
extract_raw_data(raw_file_txt_names, read_directory, save_status, save_directory);


% Filter Raw Data (Comment this step if already done)
filter_raw_data(raw_files_mat, read_directory, save_status, save_directory, sampling_freq);


% Compute Angle from Raw Data using Various Methods (Comment this step if already done)
compute_angle(filtered_file_name, read_directory, save_status, save_directory, sampling_freq ); 


% Compare Angle Computed from Various Methods (Comment this step if already done)
compare_angle_methods(angle_file_names, read_directory, save_status, save_directory, sampling_freq );


% Plot and Tabulate Results (Comment this step if already done)
plot_data(angle_file_names, metric_file_names, read_directory, save_status, save_directory_figures)
