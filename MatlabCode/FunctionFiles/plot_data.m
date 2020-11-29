function plot_data(all_angle_file_names, all_metric_file_names, read_directory, save_status, save_directory)
%{
    PURPOSE: To plot and tabulate the computed angles data

    WHHAT IT DOES: Plots computed angle from different methods (GI, AI, CF,
    KF, DMP) across the time. Plots RMSE plot for different methods across
    time. Tabulate key metrics involving time delay, RMSE. 

    WRITTEN ON: 25th January 2020 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER: "Convenient and Low-Cost Methods of Calculating Human 
    Joint Angles using Inertial Measurement Units without Magnetometers" 
%}    


%{
    LICENSE
     This code "plot_data" is placed under the University of Illinois at Urbana-Champaign license
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


         
for i_file = 1:length(all_angle_file_names)
    disp('Plotting Computed Angles and Metrics...');

    directory = read_directory;


    name_decomp = regexp(all_angle_file_names{i_file}, '_', 'split');
    speed_type = regexprep(name_decomp{1}(3), '.mat', '');
    rot_type = name_decomp{1}(2);

    save_angle_file_name = strcat(strcat(strcat('angle_',rot_type), '_'), speed_type);
    save_rmse_file_name = strcat(strcat(strcat('rmse_',rot_type), '_'), speed_type);

    %% Load Angle Data
    file_name = strcat(directory, char(all_angle_file_names{i_file}));
    load(file_name);


    %% Load Metric Data 
    file_name = strcat(directory, char(all_metric_file_names{i_file}));
    load(file_name);


    %% Find data in the respective time zones
    % While this is not used for IMU study, it can be useful metric as an
    % appendix
    for i_zone = 1:4
        time_master{i_zone} = time(index{i_zone}(1):index{i_zone}(2));
        angle_master{i_zone}{1}{1} = ai_angle_1(index{i_zone}(1):index{i_zone}(2));
        angle_master{i_zone}{2}{1} = ai_angle_2(index{i_zone}(1):index{i_zone}(2));
        angle_master{i_zone}{3}{1} = ai_angle(index{i_zone}(1):index{i_zone}(2));

        angle_master{i_zone}{1}{2} = gi_angle_1(index{i_zone}(1):index{i_zone}(2));
        angle_master{i_zone}{2}{2} = gi_angle_2(index{i_zone}(1):index{i_zone}(2));
        angle_master{i_zone}{3}{2} = gi_angle(index{i_zone}(1):index{i_zone}(2));

        angle_master{i_zone}{1}{3} = cf_angle_1(index{i_zone}(1):index{i_zone}(2));
        angle_master{i_zone}{2}{3} = cf_angle_2(index{i_zone}(1):index{i_zone}(2));
        angle_master{i_zone}{3}{3} = cf_angle(index{i_zone}(1):index{i_zone}(2));

        angle_master{i_zone}{1}{4} = kf_angle_1(index{i_zone}(1):index{i_zone}(2));
        angle_master{i_zone}{2}{4} = kf_angle_2(index{i_zone}(1):index{i_zone}(2));
        angle_master{i_zone}{3}{4} = kf_angle(index{i_zone}(1):index{i_zone}(2));

        angle_master{i_zone}{1}{5} = dmp_angle_1(index{i_zone}(1):index{i_zone}(2));
        angle_master{i_zone}{2}{5} = dmp_angle_2(index{i_zone}(1):index{i_zone}(2));
        angle_master{i_zone}{3}{5} = dmp_angle(index{i_zone}(1):index{i_zone}(2));

        angle_master{i_zone}{4}{1} = encoder(index{i_zone}(1):index{i_zone}(2));
    end


    %% Compute RMSE Average and STD 
    % While this is not used for IMU study, it can be useful metric as an
    % appendix
    for i_method = 1:5
        for i_zone = 1:4
            for i_imu = 1:3
                   rmse_avg_master{i_zone}{i_imu}{i_method} = mean(div_master_rmse{i_zone}{i_imu}(:,i_method));       
                   rmse_std_master{i_zone}{i_imu}{i_method} = std(div_master_rmse{i_zone}{i_imu}(:,i_method));
            end     
        end
    end


    %% Plot (Angles from five Different Methods and Encoder) vs time at three different time zones
    line_width = 3;
    line_style = {'-',':',':','--','--','-.'};
    plot_color = {'k',[57 106 177]/256, [62 150 81]/256, [218 124 48]/256,[204 37 41]/256,[107 76 154]/256 };
    marker_size = 2;
    
    % The definition of three time zones
    time_begin = [4.76, 14.76, 24.76];
    time_end = [4.999, 14.999, 24.9999];
    time_str = {{'4.76', '5'},{'14.76','15'},{'24.76','25'}};
    

    figure('Position', [100, 100, 1024, 400], 'PaperSize', [2 4]);
    for i_plot = 1:3
        subplot(1,3,i_plot);
        
        % Plot Encoder
        plot(time_master{i_plot}/60, angle_master{i_plot}{4}{1},...
            'linewidth', line_width + 0.5,...
            'color', plot_color{1},...
            'linestyle', line_style{1});
        hold on

        if strcmp(rot_type,'yaw') ~= 1
            % Plot AI
            plot(time_master{i_plot}/60, angle_master{i_plot}{3}{1},...
                'linewidth', line_width,...
                'color', plot_color{2},...
                'linestyle', line_style{2},...
                'MarkerEdgeColor',plot_color{2},...
                'MarkerFaceColor',plot_color{2},...
                'MarkerSize',marker_size);
        end  
        
        if strcmp(rot_type,'yaw') == 1
            % Plot GI
            plot(time_master{i_plot}/60, angle_master{i_plot}{3}{2},...
                'linewidth', line_width,...
                'color', plot_color{3},...
                'linestyle', line_style{3},...
                'MarkerEdgeColor',plot_color{3},...
                'MarkerFaceColor',plot_color{3},...
                'MarkerSize',marker_size);
        end
        
        if strcmp(rot_type,'yaw') ~= 1
            % Plot CF
            plot(time_master{i_plot}/60, angle_master{i_plot}{3}{3},...
                'linewidth', line_width,...
                'color', plot_color{4},...
                'linestyle', line_style{4},...
                'MarkerEdgeColor',plot_color{4},...
                'MarkerFaceColor',plot_color{4},...
                'MarkerSize',marker_size);
            
            % Plot KF 
            plot(time_master{i_plot}/60, angle_master{i_plot}{3}{4},...
                'linewidth', line_width,...
                'color', plot_color{5},...
                'linestyle', line_style{5},...
                'MarkerEdgeColor',plot_color{5},...
                'MarkerFaceColor',plot_color{5},...
                'MarkerSize',marker_size);
        end 
        
        % Plot DMP 
        plot(time_master{i_plot}/60, angle_master{i_plot}{3}{5},...
            'linewidth', line_width,...
            'color', plot_color{6},...
            'linestyle', line_style{6},...
            'MarkerEdgeColor',plot_color{6},...
            'MarkerFaceColor',plot_color{6},...
            'MarkerSize',marker_size);
     
        % "time_decrement" is used for setting the x axis limit for
        % visualization purposes
        time_decrement = 400;
        
        xlim([(time_master{i_plot}(end - time_decrement))/60, time_master{i_plot}(end)/60]);
        ylim([0 200]);
        xlabel('time (min)');
        ylabel('Angle (\circ)');
        xticks([time_begin(i_plot) time_end(i_plot)]);
        xticklabels(time_str{i_plot}); 
        
        ax1 = gca;
        ax1.FontSize = 20;
        ax1.FontName = 'Arial';
        ax1.LineWidth = line_width - 1;
        
    end
    
    % Save the figures as .fig, .jpg, .pdf
    if strcmp(save_status, 'yes') == 1        
        saveas(gcf, fullfile(save_directory, string(save_angle_file_name)), 'fig');
        exportgraphics(gcf, strcat(fullfile(save_directory, string(save_angle_file_name)), '.jpg'));
        exportgraphics(gcf, strcat(fullfile(save_directory, string(save_angle_file_name)), '.pdf'));
    end
    


    %% RMSE Plot 
    figure('Position', [100, 100, 1024, 500]);
    t_index = length(div_master_rmse{4}{3}(:,1));
    time = time_master{4}(1:t_index)/60 - time_master{4}(1)/60;

    
    % plotting AI 
    if strcmp(rot_type,'yaw') ~= 1
        p(1) = plot(time, div_master_rmse{4}{3}(:,1), 'linewidth', line_width, 'color', [57 106 177]/256,'linestyle', line_style{2});
        
    end
    hold on;
    
    % plotting GI
    p(2) = plot(time, div_master_rmse{4}{3}(:,2), 'linewidth', line_width, 'color', [62 150 81]/256,'linestyle', line_style{3});
    
    % plotting CF, KF
    if strcmp(rot_type,'yaw') ~= 1
        p(3) = plot(time, div_master_rmse{4}{3}(:,3), 'linewidth', line_width, 'color', [218 124 48]/256,'linestyle', line_style{4});
        p(4) = plot(time, div_master_rmse{4}{3}(:,4), 'linewidth', line_width, 'color', [204 37 41]/256,'linestyle', line_style{5});
    end
    
    % plotting DMP
    p(5) = plot(time, div_master_rmse{4}{3}(:,5), 'linewidth', line_width, 'color', [107 76 154]/256,'linestyle', line_style{6});
    
    p(6) = yline(6, 'k--','LineWidth', line_width);

    % Finding and plotting the time at which the RMSE of GI or DMP exceeds
    % the threshold value (6 degrees of RMSE)
    if strcmp(rot_type,'yaw') ~= 1
        gi_rmse_limit = find_time_rmse_limit(time, div_master_rmse{4}{3}(:,2));
        
        if (gi_rmse_limit ~= 0)
            xline(gi_rmse_limit, 'k--','LineWidth', line_width);
        end
        
        if strcmp(rot_type, 'roll') == 1
            if strcmp(speed_type,'slow') == 1
                xticks_array = sort(round([0,gi_rmse_limit, 5, 15, 20, 25],1));
                annotation_str = '(a)';
            elseif strcmp(speed_type,'medium') == 1
                xticks_array = sort(round([0,gi_rmse_limit, 5, 15, 20, 25],1));
                annotation_str = '(b)';
            elseif strcmp(speed_type,'fast') == 1
                xticks_array = sort(round([0, 5, 10, 15, 20, 25],1));
                annotation_str = '(c)';
            end
        elseif strcmp(rot_type, 'pitch') == 1
            if strcmp(speed_type,'slow') == 1
                xticks_array = sort(round([0, gi_rmse_limit, 10, 15, 20, 25],1));
                annotation_str = '(a)';
            elseif strcmp(speed_type, 'medium') == 1
                xticks_array = sort(round([0, gi_rmse_limit,  5, 15, 20, 25],1));
                annotation_str = '(b)';
            elseif strcmp(speed_type, 'fast') == 1 
                xticks_array = sort(round([gi_rmse_limit, 5, 10, 15, 20, 25],1));
                annotation_str = '(c)';
            end
        end
        
        xticklabels_array = strsplit(num2str(xticks_array));
        xticks(xticks_array);
        xticklabels(xticklabels_array);
        
        xlabel('time (min)');
        ylabel('RMSE (\circ)');
        ylim([0 8]);
        yticks([0, 2, 4, 6, 8]);
        yticklabels({'0','2','4','6','8'});
        xlim([0 25]);
        
        legend('AI','GI','CF','KF','DMP', 'Location', 'northeast', 'Orientation', 'horizontal');
        
    else
        gi_rmse_limit = find_time_rmse_limit(time, div_master_rmse{4}{3}(:,2));
        dmp_rmse_limit = find_time_rmse_limit(time, div_master_rmse{4}{3}(:,5));
        
        if (gi_rmse_limit ~= 0)
            xline(gi_rmse_limit, 'k--','LineWidth', line_width);
        end
        if (dmp_rmse_limit ~= 0)
            xline(dmp_rmse_limit, 'k--','LineWidth', line_width);
            
        end
        

        
        xlabel('time (min)');
        ylabel('RMSE (\circ)');
        ylim([0 20]);
        yticks([0, 6, 10, 15, 20]);%, 30, 40, 50]);
        yticklabels({'0','6','10', '15','20'});%,'30','40','50'});
        
        if strcmp(speed_type,'slow') == 1
            xticks_array = sort(round([gi_rmse_limit, dmp_rmse_limit, 5, 10, 15, 20, 25],1));
            annotation_str = '(a)';
        elseif strcmp(speed_type, 'medium') == 1
            xticks_array = sort(round([gi_rmse_limit, dmp_rmse_limit, 5, 15, 20, 25],1));
            annotation_str = '(b)';
        elseif strcmp(speed_type, 'fast') == 1 
            xticks_array = sort(round([dmp_rmse_limit, 5, 15, 20, 25],1));
            annotation_str = '(c)';
        end
        
        xticklabels_array = strsplit(num2str(xticks_array));
        xticks(xticks_array);
        xticklabels(xticklabels_array);
        xlim([0 25]);
        
        legend('GI','DMP', 'Location', 'northeast','Orientation', 'horizontal');
        

    end

    annotation_dim = [.125 .625 .1 .3];

    a = annotation('textbox',annotation_dim,'String',annotation_str,'FitBoxToText','on',...
                    'BackgroundColor',[1 1 1], 'LineWidth', line_width-1, 'Margin', 3,...
                    'HorizontalAlignment', 'center');
    a.FontSize = 30;
    a.FontWeight = 'bold';
    

    ax2 = gca;
    ax2.FontSize = 20;
    ax2.FontName = 'Arial';
    ax2.LineWidth = line_width - 1;
    ax2.Box = 'on';
    
    % Save the figures as .fig, .jpg, .pdf
    if strcmp(save_status, 'yes') == 1        
        saveas(gcf, fullfile(save_directory, string(save_rmse_file_name)), 'fig');
        exportgraphics(gcf, strcat(fullfile(save_directory, string(save_rmse_file_name)), '.jpg'));
        exportgraphics(gcf, strcat(fullfile(save_directory, string(save_rmse_file_name)), '.pdf'));
    end
        
end
end














