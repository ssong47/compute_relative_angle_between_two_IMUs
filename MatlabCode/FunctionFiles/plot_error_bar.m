function plot_error_bar(input_avg_data, input_error_data, rot_type)
%{
    PURPOSE: Plots the accuracy of the seven algorithms

    WHAT IT DOES: Plots the average and standard deviation of the RMSE for the 
    various methods (GI, AC, KF, CF, DMP, MW, MH)

    WRITTEN ON: 27th November 2021 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.

%}    


%{
    LICENSE
     This code "plot_error_bar.m" is placed under the University of Illinois at Urbana-Champaign license
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
% Define plotting parameters 
plot_color = {
                    [ 0    0.4470    0.7410],...
                    [    0.8500    0.3250    0.0980],...
                    [    0.9290    0.6940    0.1250],...
                    [    0.4660    0.6740    0.1880],...
                    [    0.4940    0.1840    0.5560],...
                    [    0.3010    0.7450    0.9330],...
                    'm',...
                    [    109/255   80/255    9/255],...
                    [    12/255    88/255    122/255]};
                
line_width = 2;

% Define figure size 
figure('Position', [100, 100, 1024, 400], 'PaperSize', [2 4]);

% For yaw rotations, skip the AC angle, since it cannot be computed
if strcmp(rot_type, 'yaw') == 1
   model_series = input_avg_data(:,[1,3:7]);
   model_error = input_error_data(:,[1,3:7]);
   plot_color = plot_color(2:7);
else % For others, use all angles
   model_series = input_avg_data;
   model_error = input_error_data;
end


% Create bar graph
b = bar(model_series, 'grouped');
ax1 = gca; % Get axis handle

% Change the color of the bar graph to the colors defined above
for i_bar = 1:length(b)
    b(i_bar).EdgeColor = 'none';
    b(i_bar).FaceColor = plot_color{i_bar};
end
hold on

% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(model_series);

% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end

% Draw horizontal 6deg RMSE line 
yline(6, 'k--','LineWidth', line_width);

% Plot the errorbars
errorbar(x', model_series, model_error,'k','linestyle','none','linewidth',line_width-0.5);

% Create a legend and defined ylimit/ticks 
if strcmp(rot_type,'yaw')==1
    legend('GI','CF','KF','DMP', 'MW','MH', 'Location', 'northoutside', 'Orientation', 'horizontal');
    ylim([0 8])
    yticks([0 2 4 6 8])
    disp('yaw')
else
    legend('GI','AC','CF','KF','DMP', 'MW','MH', 'Location', 'northoutside', 'Orientation', 'horizontal');
    ylim([0 8])
    yticks([0 2 4 6 8])
end

% Define x and y labels
ylabel('RMSE (\circ)')
xticklabels({'Slow','Medium','Fast','All'})
hold off

% Define font parameters
ax1.FontSize = 20;
ax1.FontName = 'Arial';
ax1.LineWidth = line_width - 1;

ax2.FontSize = 20;
ax2.FontName = 'Arial';
ax2.LineWidth = line_width - 1;

% Add rotation type text box 
annotation('textbox', [2.7/25, 0.65, 1/7, 1/8], 'String', upper(rot_type),...
                'FitBoxToText', 'on', 'HorizontalAlignment', 'center',...
                'VerticalAlignment', 'middle', 'LineWidth', 1, 'EdgeColor', 'none',...
                'FontSize', 25, 'FontWeight', 'bold')

end