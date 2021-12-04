%{
    PURPOSE: A governing main code to run all function files for computing 
    and analyzing angles calculated using various methods. 

    WHAT IT DOES: extract, filter, compute, compare, and plot angles computed
    using various methods (GI, AC, KF, CF, DMP, MW, MH)

    WRITTEN ON: 27th November 2021 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.

%}    


%{
    LICENSE
     This code "Main.m" is placed under the University of Illinois at Urbana-Champaign license
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

%% Initialization 
% Clear all variables, close all figures
clear all; clc; close all;

% Add directories to necessary files.
addpath(genpath('FunctionFiles'));
addpath('Data');
addpath('Figures');

% Raw text file names to be read
raw_file_txt_names = {'raw_roll_slow.txt', 'raw_roll_medium.txt', 'raw_roll_fast.txt',...
    'raw_pitch_slow.txt', 'raw_pitch_medium.txt', 'raw_pitch_fast.txt',...
    'raw_yaw_slow.txt', 'raw_yaw_medium.txt', 'raw_yaw_fast.txt'};

% Define data type (filtered vs. raw) for processing and plotting
data_type = 'filtered'; 

% Generate a list of file names to be read for extracting, filtering,
% computing angle, comparing angles.
[raw_files_mats, filtered_file_names, angle_file_names, metric_file_names]...
    = generate_file_names(raw_file_txt_names, data_type);

% Get current directory
current_directory = pwd;

% Change the directory to where all the raw data are
read_directory = strcat(pwd,'\Data\');

% Change save_directory to where you want to save the .mat and figure files
save_directory = strcat(pwd,'\Data\');
save_directory_figures = strcat(pwd,'\Figures\');
save_status = 'yes';

% Set sampling frequency of IMU in Hz
sampling_freq = 100;


%% Extract Raw Data 
% It's commented out since it's already done. This is for your reference

% extract_raw_data(raw_file_txt_names, read_directory, save_status, save_directory);


%% Filter Raw Data 
% It's commented out since it's already done. This is for your reference

% filter_raw_data(raw_files_mats, read_directory, save_status, save_directory, sampling_freq);


%% Compute Angle from Raw Data using Various Methods
% It's commented out since it's already done. This is for your reference

% plot_status = 'plot'; % put 'plot' to see the angle plots
% compute_angle(filtered_file_names, read_directory, save_status, save_directory, sampling_freq, data_type, plot_status);


%% Compute AC noise 
% It's already done. This is for your reference

% [avg_ac_noise, var_ac_noise] = compute_ac_noise(read_directory, angle_file_names);


%% Compare Angle Computed from Various Methods
% It's commented out since it's already done. This is for your reference
% Note that this part will take some time

% compare_angle_methods(angle_file_names, read_directory, save_status, save_directory, sampling_freq, data_type);


%% Holistically compare the metric data 
% It's commented out since it's already done. This is for your reference

% tabulate_comparison(metric_file_names, save_directory, save_status);


%% Plot RMSE vs. Time for the above defined raw text files
plot_rmse_data(angle_file_names, metric_file_names, read_directory, save_status, save_directory_figures, data_type)


%% Plot Angle vs. Time for the above defined raw text files
% Define the start and ending time (in minutes) that you want to view. 
xmin = 0; % start time (min)
xmax = 0.5; % end time (min)
plot_angle_data(angle_file_names, read_directory, save_status, save_directory_figures, xmin, xmax)


%% Plot Batch RMSE Results
% Plots RMSE plots for roll, pitch, and yaw for a certain speed (e.g., medium)
% Thus, define three file names for angle_file_names and metric_file_names.
raw_file_txt_names = {'raw_roll_medium.txt', 'raw_pitch_medium.txt', 'raw_yaw_medium.txt'};

[raw_files_mats, filtered_file_names, angle_file_names, metric_file_names]...
    = generate_file_names(raw_file_txt_names, data_type);
plot_rmse_data_batch(angle_file_names, metric_file_names, read_directory, save_status, save_directory_figures, data_type)


%% Plot Batch Error Bar plot
% Plots error bar plots for all rotation axes (roll, pitch, yaw) for all
% speeds (fast, medium, slow). Thus, define nine file names.
raw_file_txt_names = {'raw_roll_slow.txt', 'raw_roll_medium.txt', 'raw_roll_fast.txt',...
    'raw_pitch_slow.txt', 'raw_pitch_medium.txt', 'raw_pitch_fast.txt',...
    'raw_yaw_slow.txt', 'raw_yaw_medium.txt', 'raw_yaw_fast.txt'}; 

[raw_files_mats, filtered_file_names, angle_file_names, metric_file_names]...
    = generate_file_names(raw_file_txt_names, data_type);

plot_error_bar_batch(save_directory, save_status, save_directory_figures);
