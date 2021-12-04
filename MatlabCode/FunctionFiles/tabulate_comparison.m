function tabulate_comparison(file_names, save_directory, save_status)
%{
    PURPOSE: Tabualtes the comparisons of the performance of the seven methods using simple
    metrics (e.g., average RMSE)

    WHAT IT DOES: Computes the average and standard deviation of the RMSE for the 
    various methods (GI, AC, KF, CF, DMP, MW, MH) and organizes the data in
    table form

    WRITTEN ON: 27th November 2021 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.

%}    


%{
    LICENSE
     This code "tabulate_comparison.m" is placed under the University of Illinois at Urbana-Champaign license
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
             

% Initialize pooled RMSE arrays to compute avg and std 
batch_error_avg = zeros(1,7);
batch_error_std = zeros(1,7);

% Initialize row names of the table
row_names = {};

% For each trial
for i_file = 1:length(file_names)
    % Load the master_rmse 
    file_name = char(strcat(file_names{i_file},'.mat'));
    file_decomp = strsplit(file_name, {'.','_'});
    load(file_name, 'master_rmse')
    
    % Compute and Pool the avg and std RMSE values 
    batch_error_avg = [batch_error_avg; mean(master_rmse)];
    batch_error_std = [batch_error_std; std(master_rmse)];
    
    % Define table name 
    table_name = 'rmse_table';
   
    % Define row names of the table as 'rotation type'_'speed' (e.g., pitch_slow)
    row_names{i_file} = strcat(file_decomp{4}, ' ', file_decomp{5});
end

% Define column names of the table as the seven methods
var_names = {'GI','AC','CF','KF','DMP','MW','MH'};

% Define last row as 'AVG'
row_names{i_file+1} = 'AVG';

% Compute pooled average and std of the table  
avg_error = mean(batch_error_avg(2:end,:), 1);
avg_error_std = mean(batch_error_std(2:end,:), 1);

% Combine the computed metrics and pooled metrics together
batch_error_array = [batch_error_avg(2:end,:); avg_error];
batch_error_std_array = [batch_error_std(2:end,:); avg_error_std];

% Create Table for average and std of RMSE 
batch_error_table = table(batch_error_array(:,1),...
                          batch_error_array(:,2),...
                          batch_error_array(:,3),...
                          batch_error_array(:,4),...
                          batch_error_array(:,5),...
                          batch_error_array(:,6),...
                          batch_error_array(:,7),...
                          'VariableNames',var_names,...
                          'RowNames', row_names');
                      
batch_error_std_table = table(batch_error_std_array(:,1),...
                          batch_error_std_array(:,2),...
                          batch_error_std_array(:,3),...
                          batch_error_std_array(:,4),...
                          batch_error_std_array(:,5),...
                          batch_error_std_array(:,6),...
                          batch_error_std_array(:,7),...
                          'VariableNames',var_names,...
                          'RowNames', row_names');


% Save the table
if strcmp(save_status, 'yes') == 1
    save(strcat(save_directory, strcat(table_name, '.mat')), 'batch_error_table', 'batch_error_std_table');
end

end

