function plot_error_bar_batch(save_directory_tables, save_status, save_directory)
%{
    PURPOSE: To visualize the accuracies for the seven algorithms using box
    plots for all three rotation axes for a given speed.

    WHAT IT DOES: Plots the three error bar subplots for the averages and standard deviations of the 
                    seven methods (GI, AC, KF, CF, DMP, MW, MH) for three rotations (roll, pitch, yaw)
                    for a given speed.  

    WRITTEN ON: 27th November 2021 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.

%}    

%{
    LICENSE
     This code "plot_error_bar_data.m" is placed under the University of Illinois at Urbana-Champaign license
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

nLegendCol = 4; % # of columns for the legend

% Define plotting parameters
plot_color = {
                    [    0    0.4470    0.7410],...
                    [    0.8500    0.3250    0.0980],...
                    [    0.9290    0.6940    0.1250],...
                    [    0.4660    0.6740    0.1880],...
                    [    0.4940    0.1840    0.5560],...
                    [    0.3010    0.7450    0.9330],...
                    'm'};    
line_width = 1;
font_size = 10;

% Define figure size 
figure('Units', 'inches', 'Position', [10, 5, 3.5, 5.1]);

% Add rotation type (e.g., ROLL) to each subplot 
annotation('textbox', [0.13, 0.837, 1/7, 1/8], 'String', 'ROLL',...
            'FitBoxToText', 'on', 'HorizontalAlignment', 'center',...
            'VerticalAlignment', 'middle', 'LineWidth', 1, 'EdgeColor', 'none',...
            'FontSize', font_size, 'FontWeight', 'bold');

annotation('textbox', [0.13, 0.537, 1/7, 1/8], 'String', 'PITCH',...
            'FitBoxToText', 'on', 'HorizontalAlignment', 'center',...
            'VerticalAlignment', 'middle', 'LineWidth', 1, 'EdgeColor', 'none',...
            'FontSize', font_size, 'FontWeight', 'bold');

annotation('textbox', [0.13, 0.237, 1/7, 1/8], 'String', 'YAW',...
            'FitBoxToText', 'on', 'HorizontalAlignment', 'center',...
            'VerticalAlignment', 'middle', 'LineWidth', 1, 'EdgeColor', 'none',...
            'FontSize', font_size, 'FontWeight', 'bold');

% Load the RMSE data 
file_name = strcat(save_directory_tables, '/rmse_table.mat');
load(file_name)

% Define average and std RMSE 
N = height(batch_error_table);
batch_error = table2array(batch_error_table(1:N-1,:));
batch_error_std = table2array(batch_error_std_table(1:N-1,:));

% For all rotation types,
for i_rot = 1:3
    % Make a subplot
    subplot(3,1,i_rot)    
    
    % Define each rotation type
    if i_rot == 1
        rot_type = 'roll';
    elseif i_rot == 2
        rot_type = 'pitch';
    elseif i_rot == 3
        rot_type = 'yaw';
    end
    
    % Define the average and std RMSE for given rotation type
    i_start = 3*(i_rot-1) + 1;
    i_end = i_start + 2;    
    if strcmp(rot_type, 'yaw') == 1 % For yaw, skip AC angles
       model_avg = batch_error(i_start:i_end,[1,3:7]);
       model_std = batch_error_std(i_start:i_end,[1,3:7]);
       plot_color = plot_color([1,3:7]);
    else % for pitch and roll, use all angles
       model_avg = batch_error(i_start:i_end,:);
       model_std = batch_error_std(i_start:i_end,:);
    end

    % Define bar plot
    b = bar(model_avg, 'grouped');

    % Change color of bar plot
    for i_bar = 1:length(b)
        b(i_bar).EdgeColor = 'none';
        b(i_bar).FaceColor = plot_color{i_bar};
    end
    hold on 
    
    % Calculate the number of groups and number of bars in each group
    [ngroups,nbars] = size(model_avg);

    % Get the x coordinate of the bars
    x = nan(nbars, ngroups);
    for i = 1:nbars
        x(i,:) = b(i).XEndPoints;
    end

    % Plot the errorbars
    errorbar(x', model_avg, model_std,'k','linestyle','none','linewidth',line_width-0.5);
    
    % Draw the 6deg RMSE horizontal line 
    yline(6, 'k--','LineWidth', line_width);

    % Define X and Y label parameters
    ylim([0 8])
    yticks([0 2 4 6 8])
    ylabel('RMSE (\circ)')
    xticklabels({'Slow','Medium','Fast','All'})
    hold off

    % Define font sizes and change line width of outer boxes
    ax = gca; % obtain axis handle
    ax.FontSize = font_size;
    ax.FontName = 'Arial';
    ax.LineWidth = line_width - 0.5;

    if i_rot == 1 % Display legend only at the top subplot 
       leg = legend({'GI','AC','CF','KF','DMP', 'MW','MH'},...
                    'Units', 'inches',...
                    'Position', [2 4.32 0.5 0.5],...
                    'Orientation', 'horizontal',...
                    'NumColumns', nLegendCol);
        legend('boxoff')
     
        leg.ItemTokenSize = [10,10]; % make legend lines smaller
    end
end

% Save the figures as .fig, .jpg, .pdf
if strcmp(save_status, 'yes') == 1        
    save_file_name = 'boxplot_batch';
    saveas(gcf, fullfile(save_directory, string(save_file_name)), 'fig');
    exportgraphics(gcf, fullfile(save_directory, strcat(save_file_name, '.jpg')));
    exportgraphics(gcf, fullfile(save_directory, strcat(save_file_name, '.pdf')));
end

end