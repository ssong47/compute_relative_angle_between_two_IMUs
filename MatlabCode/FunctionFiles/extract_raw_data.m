function extract_raw_data(raw_file_names, read_directory, save_status, save_directory)

%{
    PURPOSE: To extract collected raw data and save it into a faster and processible 
    .mat file

    WHAT IT DOES: 1) Reads the collected raw data, 2) Removes erroneous data, 3)
    Compile the test data for easier processing 

    WRITTEN ON: 27th November 2021 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER:  S. Y. Song, Y. Pei, and E. T. Hsiao-Wecksler, 
    “Estimating Relative Angles Using Two Inertial Measurement Units Without Magnetometers,” 
    IEEE Sens. J., 2021.
%}    


%{
    LICENSE
     This code "extract_raw_data.m" is placed under the University of Illinois at Urbana-Champaign license
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
 
for i_file = 1:length(raw_file_names)
    
    % Find speed and rotation type of raw text file
    raw_file_name = raw_file_names(i_file);
    raw_file_name_decomposition = regexp(raw_file_name, '_', 'split');
    speed_type = regexprep(raw_file_name_decomposition{1}(3), '.txt', '');
    rotation_type = raw_file_name_decomposition{1}(2);
    fprintf('Extracting Raw Data from Text File for %s %s...\n', rotation_type{1}, speed_type{1});
    
    % Define current file directory
    current_file_directory = char(strcat(read_directory, raw_file_name));
    
    % Open raw text file
    fid = fopen(current_file_directory,'r');
    raw_data={};    % all the collected raw data string from serial monitor
    test_start_line = fgetl(fid);    
    raw_data{1,1} = test_start_line;
    line_counter = 1;

    % Find the lines where test data starts
    while ischar(test_start_line)       % Start reading from raw text file 
        if strcmp(test_start_line, '================== Recording IMU + Encoder Data ==================')
            data_line = line_counter;
        end
        test_start_line = fgetl(fid);
        raw_data{end + 1,1} = test_start_line;
        line_counter = line_counter + 1; 
    end
    fclose(fid);


    % Extracting Data from Raw Data
    % Subtract last 15 data points since motor is not moving at this point.
    raw_full_data = raw_data(data_line + 1:end - 15); 
    
    str_full_data = raw_full_data(~cellfun('isempty',raw_full_data)); % remove empty data packets
    full_data  = regexp(str_full_data , ',', 'split'); % delimit using comma 
    all_data = vertcat(full_data{:});
    all_time = (cellfun(@str2num,all_data(:,1))*1e-3); % units are in (seconds)
    
    % Define each data as a double
    all_encoder = cellfun(@str2num,all_data(:,2)); % units are in (deg)

    all_imu2_q1 = cellfun(@str2num,all_data(:,3)); % unitless (0~1)
    all_imu2_q2 = cellfun(@str2num,all_data(:,4));
    all_imu2_q3 = cellfun(@str2num,all_data(:,5));
    all_imu2_q4 = cellfun(@str2num,all_data(:,6));

    all_imu1_q1 = cellfun(@str2num,all_data(:,7));
    all_imu1_q2 = cellfun(@str2num,all_data(:,8));
    all_imu1_q3 = cellfun(@str2num,all_data(:,9));
    all_imu1_q4 = cellfun(@str2num,all_data(:,10));

    all_gyro_2_x = cellfun(@str2num,all_data(:,11)); % units are in (deg/s)
    all_gyro_2_y = cellfun(@str2num,all_data(:,12)); 
    all_gyro_2_z = cellfun(@str2num,all_data(:,13));

    all_accel_2_x = cellfun(@str2num,all_data(:,14)); % units are in (g's)
    all_accel_2_y = cellfun(@str2num,all_data(:,15));
    all_accel_2_z = cellfun(@str2num,all_data(:,16));

    all_gyro_1_x = cellfun(@str2num,all_data(:,17));
    all_gyro_1_y = cellfun(@str2num,all_data(:,18)); 
    all_gyro_1_z = cellfun(@str2num,all_data(:,19));

    all_accel_1_x = cellfun(@str2num,all_data(:,20)); 
    all_accel_1_y = cellfun(@str2num,all_data(:,21));
    all_accel_1_z = cellfun(@str2num,all_data(:,22));


    % Removing Poor Data
    counter = 1; % counter for # of poor data
    
    % If the quaternion magnitude of IMU 1 and 2 are not close to 1, the data is
    % inaccurate, so remove such data. Note only very few data points are
    % inaccurate. This just a precautionary measure.
    for i = 2:length(all_time) 
        qa_mag = all_imu1_q1(i)^2+all_imu1_q2(i)^2+all_imu1_q3(i)^2+all_imu1_q4(i)^2;
        qb_mag = all_imu2_q1(i)^2+all_imu2_q2(i)^2+all_imu2_q3(i)^2+all_imu2_q4(i)^2;
            
        if qa_mag<0.9||qa_mag>1.1 % if IMU 1 has bad data
            counter = counter + 1;
            all_imu1_q1(i) = all_imu1_q1(i-1);
            all_imu1_q2(i) = all_imu1_q2(i-1);
            all_imu1_q3(i) = all_imu1_q3(i-1);
            all_imu1_q4(i) = all_imu1_q4(i-1);
            all_time(i) = all_time(i-1);
            all_gyro_1_x(i) = all_gyro_1_x(i-1);
            all_gyro_1_y(i) = all_gyro_1_y(i-1);
            all_gyro_1_z(i) = all_gyro_1_z(i-1);
            all_gyro_2_x(i) = all_gyro_2_x(i-1);
            all_gyro_2_y(i) = all_gyro_2_y(i-1);
            all_gyro_2_z(i) = all_gyro_2_z(i-1);

            all_accel_1_x(i) = all_accel_1_x(i-1);
            all_accel_1_y(i) = all_accel_1_y(i-1);
            all_accel_1_z(i) = all_accel_1_z(i-1);
            all_accel_2_x(i) = all_accel_2_x(i-1);
            all_accel_2_y(i) = all_accel_2_y(i-1);
            all_accel_2_z(i) = all_accel_2_z(i-1);

            all_encoder(i) = all_encoder(i-1);
            counter = counter + 1;
        end

        if qb_mag<0.9||qb_mag>1.1 % if IMU 2 has bad data
            all_imu2_q1(i) = all_imu2_q1(i-1);
            all_imu2_q2(i) = all_imu2_q2(i-1);
            all_imu2_q3(i) = all_imu2_q3(i-1);
            all_imu2_q4(i) = all_imu2_q4(i-1);
            all_time(i) = all_time(i-1); 
            all_gyro_1_x(i) = all_gyro_1_x(i-1);
            all_gyro_1_y(i) = all_gyro_1_y(i-1);
            all_gyro_1_z(i) = all_gyro_1_z(i-1);
            all_gyro_2_x(i) = all_gyro_2_x(i-1);
            all_gyro_2_y(i) = all_gyro_2_y(i-1);
            all_gyro_2_z(i) = all_gyro_2_z(i-1);


            all_accel_1_x(i) = all_accel_1_x(i-1);
            all_accel_1_y(i) = all_accel_1_y(i-1);
            all_accel_1_z(i) = all_accel_1_z(i-1);
            all_accel_2_x(i) = all_accel_2_x(i-1);
            all_accel_2_y(i) = all_accel_2_y(i-1);
            all_accel_2_z(i) = all_accel_2_z(i-1);
            all_encoder(i) = all_encoder(i-1);
            counter = counter + 1;
        end
    end


    % Save raw file as .mat file 
    save_raw_file_name = char(strcat(strcat(strcat('raw_',rotation_type), '_'), speed_type));
    
    if strcmp(save_status, 'yes') == 1
        save(strcat(save_directory,save_raw_file_name), 'all_time','all_encoder',...
            'all_imu1_q1','all_imu1_q2', 'all_imu1_q3', 'all_imu1_q4',...
            'all_imu2_q1','all_imu2_q2', 'all_imu2_q3', 'all_imu2_q4',...
            'all_gyro_1_x', 'all_gyro_1_y','all_gyro_1_z',...
            'all_accel_1_x', 'all_accel_1_y', 'all_accel_1_z',...
            'all_gyro_2_x', 'all_gyro_2_y','all_gyro_2_z',...
            'all_accel_2_x', 'all_accel_2_y', 'all_accel_2_z', 'data_line');
    end
    
end

end

