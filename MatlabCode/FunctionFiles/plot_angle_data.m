function plot_angle_data(all_angle_file_names, read_directory, save_status, save_directory, xmin, xmax)
%{
    PURPOSE: To visualize the angle vs. time for seven algorithms

    WHAT IT DOES: Plots the angle vs. time for the seven 
                  methods (GI, AC, KF, CF, DMP, MW, MH) as well as the
                  encoder

    WRITTEN ON: 27th November 2021 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.

%}    


%{
    LICENSE
     This code "plot_angle_data.m" is placed under the University of Illinois at Urbana-Champaign license
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

         
for i_file = 1:length(all_angle_file_names)
    
    % Get speed and rotation types
    name_decomp = regexp(all_angle_file_names{i_file}, '_', 'split');
    speed_type = char(name_decomp{1}(4));
    rot_type = char(name_decomp{1}(3));
    fprintf('Plotting Angles vs. Time for %s %s...\n', rot_type, speed_type);

    
    % Define save file name
    save_file_name = strcat('angle_', rot_type, '_', speed_type);

    % Load Angle Data
    file_name = strcat(read_directory, char(all_angle_file_names{i_file}));
    load(file_name);

    % Define time in minutes. 
    istart = 1;
    iend = length(time);% - 2000; % truncate end data since motor stopped at the end
    time = time(istart:iend)/60; 
    

    % Define data for encoder and the seven methods
    angle_master{1} = encoder(istart:iend);
    angle_master{2} = gi_angle(istart:iend);
    angle_master{3} = ac_angle(istart:iend);
    angle_master{4} = cf_angle(istart:iend);
    angle_master{5} = kf_angle(istart:iend);
    angle_master{6} = dmp_angle(istart:iend);
    angle_master{7} = mw_angle(istart:iend);
    angle_master{8} = mh_angle(istart:iend);
    
    ENC{i_file} = encoder;
    
    % Plot (Angles from five Different Methods and Encoder) vs time   
    % Define ploting parameters
    line_width = 2.0;
    line_style = {'-','-','-','-','-','-','-','--',':'};
    marker_size = 2.0;
    plot_color = {  'k',...
                    [ 0    0.4470    0.7410],...
                    [    0.8500    0.3250    0.0980],...
                    [    0.9290    0.6940    0.1250],...
                    [    0.4660    0.6740    0.1880],...
                    [    0.4940    0.1840    0.5560],...
                    [    0.3010    0.7450    0.9330],...
                    'm'};  
    
    % Define figure size and name 
    figure('Units','inches','Position', [3, 3, 15, 4], 'Name', save_file_name);
    
    % Plot Encoder
    plot(time, angle_master{1},...
        'linewidth', line_width + 0.5,...
        'color', plot_color{1},...
        'linestyle', line_style{1});
    hold on
     
    % Plot GI
    plot(time, angle_master{2},...
        'linewidth', line_width,...
        'color', plot_color{2},...
        'linestyle', line_style{2},...
        'MarkerEdgeColor',plot_color{2},...
        'MarkerFaceColor',plot_color{2},...
        'MarkerSize',marker_size);
    
    % For pitch and roll, plot AC. For yaw, do not plt AC angles
    if strcmp(rot_type,'yaw') ~= 1
        % Plot AC
        plot(time, angle_master{3},...
            'linewidth', line_width,...
            'color', plot_color{3},...
            'linestyle', line_style{3},...
            'MarkerEdgeColor',plot_color{3},...
            'MarkerFaceColor',plot_color{3},...
            'MarkerSize',marker_size);
    end
    

    % Plot CF
    plot(time, angle_master{4},...
        'linewidth', line_width,...
        'color', plot_color{4},...
        'linestyle', line_style{4},...
        'MarkerEdgeColor',plot_color{4},...
        'MarkerFaceColor',plot_color{4},...
        'MarkerSize',marker_size);

    % Plot KF 
    plot(time, angle_master{5},...
        'linewidth', line_width,...
        'color', plot_color{5},...
        'linestyle', line_style{5},...
        'MarkerEdgeColor',plot_color{5},...
        'MarkerFaceColor',plot_color{5},...
        'MarkerSize',marker_size);

    % Plot DMP 
    plot(time, angle_master{6},...
        'linewidth', line_width,...
        'color', plot_color{6},...
        'linestyle', line_style{6},...
        'MarkerEdgeColor',plot_color{6},...
        'MarkerFaceColor',plot_color{6},...
        'MarkerSize',marker_size);

    % Plot MW
    plot(time, angle_master{7},...
        'linewidth', line_width,...
        'color', plot_color{7},...
        'linestyle', line_style{7},...
        'MarkerEdgeColor',plot_color{7},...
        'MarkerFaceColor',plot_color{7},...
        'MarkerSize',marker_size);

    % Plot MH
    plot(time, angle_master{8},...
        'linewidth', line_width,...
        'color', plot_color{8},...
        'linestyle', line_style{8},...
        'MarkerEdgeColor',plot_color{8},...
        'MarkerFaceColor',plot_color{8},...
        'MarkerSize',marker_size);


    % Define X and Y axis labels
    xlim([xmin, xmax]); % Change here 
    xlabel('time (min)');
    ylabel('Angle (\circ)');

    % Change font of X/Y labels and line width of the outer box.
    ax = gca;
    ax.FontSize = 20;
    ax.FontName = 'Arial';
    ax.LineWidth = line_width - 0.5;
    
    % Define Legends
    if strcmp(rot_type, 'yaw') ~= 1
        legend('E','GI','AC','CF','KF','DMP', 'MW','MH', 'Location', 'northeast', 'Orientation', 'horizontal');
    else        
        legend('E','GI','CF','KF','DMP', 'MW','MH', 'Location', 'northeast', 'Orientation', 'horizontal');
    end
    
    % Save the figures is .fig, .jpg, .pdf
    if strcmp(save_status, 'yes') == 1        
        saveas(gcf, fullfile(save_directory, string(save_file_name)), 'fig');
        exportgraphics(gcf, strcat(fullfile(save_directory, string(save_file_name)), '.jpg'));
        exportgraphics(gcf, strcat(fullfile(save_directory, string(save_file_name)), '.pdf'));
    end
end
end














