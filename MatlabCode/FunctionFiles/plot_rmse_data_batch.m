function plot_rmse_data_batch(angle_file_names, metric_file_names, read_directory, save_status, save_directory, filter_type)
%{
    PURPOSE: To plot the computed RMSE data for roll,pitch,yaw
    data for a given speed

    WHHAT IT DOES: Plots computed RMSE from different methods (GI, AI, CF,
    KF, DMP, MW, MH) across the time for roll, pitch, and yaw for a given speed. 

    WRITTEN ON: 25th January 2021 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER: "Estimating Relative Angles Using Two Inertial 
    Measurement Units Without Magnetometers" 
%}    


%{
    LICENSE
     This code "plot_rmse_data_batch" is placed under the University of Illinois at Urbana-Champaign license
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


% Define # of columnds of the legend
nLegendCol = 3;

% Define figure size 
figure('Units','inches','Position', [10, 5, 3.5, 5.1]);

% Define save file name
save_file_name = strcat('rmse_',filter_type, '_batch');  

% Add text explaining the rotation type (e.g., "Roll") on top left of each
% subplot 
annotation('textbox', [0.13, 0.837, 1/7, 1/8], 'String', 'ROLL',...
            'FitBoxToText', 'on', 'HorizontalAlignment', 'center',...
            'VerticalAlignment', 'middle', 'LineWidth', 1, 'EdgeColor', 'none',...
            'FontSize', 10, 'FontWeight', 'bold');

annotation('textbox', [0.13, 0.537, 1/7, 1/8], 'String', 'PITCH',...
    'FitBoxToText', 'on', 'HorizontalAlignment', 'center',...
    'VerticalAlignment', 'middle', 'LineWidth', 1, 'EdgeColor', 'none',...
    'FontSize', 10, 'FontWeight', 'bold');

annotation('textbox', [0.13, 0.237, 1/7, 1/8], 'String', 'YAW',...
            'FitBoxToText', 'on', 'HorizontalAlignment', 'center',...
            'VerticalAlignment', 'middle', 'LineWidth', 1, 'EdgeColor', 'none',...
            'FontSize', 10, 'FontWeight', 'bold');

% Define plotting parameters
line_width = 1.0;
line_style = {'-','-','-','-','-','-','--',':',':'};
plot_color = {
                [ 0    0.4470    0.7410],...
                [    0.8500    0.3250    0.0980],...
                [    0.9290    0.6940    0.1250],...
                [    0.4660    0.6740    0.1880],...
                [    0.4940    0.1840    0.5560],...
                [    0.3010    0.7450    0.9330],...
                'm'};
font_size = 10;

disp('Plotting Batch RMSE...');


% Create three subplots (roll, pitch, yaw)
for i_file = 1:3
    subplot(3,1,i_file);

    % Obtain rotation type
    name_decomp = regexp(angle_file_names{i_file}, '_', 'split');
    rot_type = char(name_decomp{1}(3));
    
    % Load Angle Data
    file_name = strcat(read_directory, char(angle_file_names{i_file}));
    load(file_name);
    
    
    % Load Metric Data 
    file_name = strcat(read_directory, char(metric_file_names{i_file}));
    load(file_name);    
    
    

    % Define time in minutes.
    istart = 1;
    iend = length(time);
    time = time(istart:iend)/60; 
    
    % plotting GI
    p(1) = plot(time, master_rmse(istart:iend,1), 'linewidth', line_width,...
        'color', plot_color{1},...
        'linestyle', line_style{1});
    hold on;

    % plotting AC
    if strcmp(rot_type,'yaw') ~= 1
        p(2) = plot(time, master_rmse(istart:iend,2), 'linewidth', line_width,...
            'color', plot_color{2},...
            'linestyle', line_style{2});
    end

    % plotting CF
    p(3) = plot(time, master_rmse(istart:iend,3), 'linewidth', line_width,...
        'color', plot_color{3},...
        'linestyle', line_style{3});

    % plotting KF
    p(4) = plot(time, master_rmse(istart:iend,4), 'linewidth', line_width,...
        'color', plot_color{4},...
        'linestyle', line_style{4});

    % plotting DMP
    p(5) = plot(time, master_rmse(istart:iend,5), 'linewidth', line_width,...
        'color', plot_color{5},...
        'linestyle', line_style{5});

    % plotting MW
    p(6) = plot(time, master_rmse(istart:iend,6), 'linewidth', line_width,...
        'color', plot_color{6},...
        'linestyle', line_style{6});
    

    % plotting MH
    p(7) = plot(time, master_rmse(istart:iend,7), 'linewidth', line_width,...
        'color', plot_color{7},...
        'linestyle', line_style{7});


    % plotting 6deg threshold horizontal line
    p(8) = yline(6, 'k--','LineWidth', line_width);


    % Define X Axis Parameters
    xlim([1.25 25]);
    xticklabels_array = {'1.25','5','10','15','20','25'};
    xticks([1.25, 5, 10, 15, 20, 25]);
    xticklabels(xticklabels_array);
    xlabel('time (min)');

    % Define Y Axis Parameters
    ylabel('RMSE (\circ)');    
    ylim([0 8]);
        yticks([0, 2, 4, 6, 8]);
        yticklabels({'0','2','4','6','8'});

    % Add legend only on the first top subplot
    if i_file == 1
       leg = legend({'GI','AC','CF','KF','DMP', 'MW','MH'},...
                    'Units', 'inches',...
                    'Position', [1.8 4.15 0.5 0.5],...
                    'Orientation', 'horizontal',...
                    'NumColumns', nLegendCol);
        leg.ItemTokenSize = [20,20];
        legend('boxoff') 
    end

    % Define font and line width of outer box
    ax = gca;
    ax.FontSize = font_size;
    ax.FontName = 'Arial';
    ax.LineWidth = line_width - 0.5;
    ax.Box = 'on';
        
end

% Save the figures as .fig, .jpg, .pdf
if strcmp(save_status, 'yes') == 1        
    saveas(gcf, fullfile(save_directory, string(save_file_name)), 'fig');
    exportgraphics(gcf, strcat(fullfile(save_directory, string(save_file_name)), '.jpg'));
    exportgraphics(gcf, strcat(fullfile(save_directory, string(save_file_name)), '.pdf'));
end

end














