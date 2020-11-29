function extract_raw_data(raw_file_names, read_directory, save_status, save_directory)



%{
    PURPOSE: To extract collected raw data and save it into a processible 
    .mat file

    WHHAT IT DOES: 1) Reads the collected raw data, 2) Removes poor data, 3)
    Compile  calibration and test data for easier processing 

    WRITTEN ON: 25th January 2020 

    DONE BY: Seung Yun Song <ssong47@illinois.edu>
    
    REFER THE PAPER: "Convenient and Low-Cost Methods of Calculating Human 
    Joint Angles using Inertial Measurement Units without Magnetometers" 
%}    


%{
    LICENSE
     This code "extract_raw_data.m" is placed under the University of Illinois at Urbana-Champaign license
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
 
calibration_lines = [];
data_lines = [];

for i_file = 1:length(raw_file_names)
    
    
    
    

    %% Find speed and rotation type of raw text file
    disp('Extracting Raw Data from Text File...');
    raw_file_name = raw_file_names(i_file);
    disp(raw_file_name);
    raw_file_name_decomposition = regexp(raw_file_name, '_', 'split');
    speed_type = regexprep(raw_file_name_decomposition{1}(3), '.txt', '');
    rotation_type = raw_file_name_decomposition{1}(2);
    current_file_directory = char(strcat(read_directory, raw_file_name));
    
    %% Open raw text file
    fid = fopen(current_file_directory,'r');
    raw_data={};    % all the collected raw data string from serial monitor
    test_start_line = fgetl(fid);    
    raw_data{1,1} = test_start_line;
    line_counter = 1;

    %% Find the lines where calibration and test data starts
    while ischar(test_start_line)       % Start reading from raw text file 
        if strcmp(test_start_line, '================== Calibrating IMUs ==================')
            calibration_line = line_counter;    % Should be approximately 500
        end

        if strcmp(test_start_line, '================== Recording IMU + Encoder Data ==================');
            data_line = line_counter;
        end

        test_start_line = fgetl(fid);
        raw_data{end + 1,1} = test_start_line;
        line_counter = line_counter + 1; 
    end

    fclose(fid);


    %% Extracting Data from Raw Data
    % Combine calibration and raw data into one set of data (full_data for
    % easier processing)
    raw_full_data = [raw_data(calibration_line+1:data_line-15); raw_data(data_line + 1:end - 15)];
    str_full_data = raw_full_data(~cellfun('isempty',raw_full_data)); % remove empty data strings
    full_data  = regexp(str_full_data , ',', 'split');
    all_data = vertcat(full_data{:});
    all_time = (cellfun(@str2num,all_data(:,1))*1e-3);
    
    % Define each data as a variable 
    all_encoder = cellfun(@str2num,all_data(:,2));

    all_imu2_q1 = cellfun(@str2num,all_data(:,3));
    all_imu2_q2 = cellfun(@str2num,all_data(:,4));
    all_imu2_q3 = cellfun(@str2num,all_data(:,5));
    all_imu2_q4 = cellfun(@str2num,all_data(:,6));

    all_imu1_q1 = cellfun(@str2num,all_data(:,7));
    all_imu1_q2 = cellfun(@str2num,all_data(:,8));
    all_imu1_q3 = cellfun(@str2num,all_data(:,9));
    all_imu1_q4 = cellfun(@str2num,all_data(:,10));

    all_gyro_2_x = cellfun(@str2num,all_data(:,11));
    all_gyro_2_y = cellfun(@str2num,all_data(:,12)); 
    all_gyro_2_z = cellfun(@str2num,all_data(:,13));

    all_accel_2_x = cellfun(@str2num,all_data(:,14));
    all_accel_2_y = cellfun(@str2num,all_data(:,15));
    all_accel_2_z = cellfun(@str2num,all_data(:,16));

    all_gyro_1_x = cellfun(@str2num,all_data(:,17));
    all_gyro_1_y = cellfun(@str2num,all_data(:,18)); 
    all_gyro_1_z = cellfun(@str2num,all_data(:,19));

    all_accel_1_x = cellfun(@str2num,all_data(:,20));
    all_accel_1_y = cellfun(@str2num,all_data(:,21));
    all_accel_1_z = cellfun(@str2num,all_data(:,22));


    %% Removing Poor Data
    counter = 1;
    perturb = 0.00001;
    
    % If the quaternion magnitude of IMU 1 and 2 are not close to 1, the data is
    % inaccurate, so remove such data. 
    for i = 2:length(all_time) 
        qa_mag = all_imu1_q1(i)^2+all_imu1_q2(i)^2+all_imu1_q3(i)^2+all_imu1_q4(i)^2;
        qb_mag = all_imu2_q1(i)^2+all_imu2_q2(i)^2+all_imu2_q3(i)^2+all_imu2_q4(i)^2;

        if qa_mag<0.9||qa_mag>1.1
            counter = counter + 1;
            all_imu1_q1(i) = all_imu1_q1(i-1)+perturb;all_imu1_q2(i) = all_imu1_q2(i-1)+perturb;all_imu1_q3(i) = all_imu1_q3(i-1)+perturb;imu1_q4(i) = all_imu1_q4(i-1)+perturb;
            all_time(i) = all_time(i-1)+perturb;
            all_gyro_1_x(i) = all_gyro_1_x(i-1) + perturb;
            all_gyro_1_y(i) = all_gyro_1_y(i-1) + perturb;
            all_gyro_1_z(i) = all_gyro_1_z(i-1) + perturb;
            all_gyro_2_x(i) = all_gyro_2_x(i-1) + perturb;
            all_gyro_2_y(i) = all_gyro_2_y(i-1) + perturb;
            all_gyro_2_z(i) = all_gyro_2_z(i-1) + perturb;

            all_accel_1_x(i) = all_accel_1_x(i-1) + perturb;
            all_accel_1_y(i) = all_accel_1_y(i-1) + perturb;
            all_accel_1_z(i) = all_accel_1_z(i-1) + perturb;

            all_accel_2_x(i) = all_accel_2_x(i-1) + perturb;
            all_accel_2_y(i) = all_accel_2_y(i-1) + perturb;
            all_accel_2_z(i) = all_accel_2_z(i-1) + perturb;

            all_encoder(i) = all_encoder(i-1) + perturb;
        end

        if qb_mag<0.9||qb_mag>1.1
            all_imu2_q1(i) = all_imu2_q1(i-1)+perturb;all_imu2_q2(i) = all_imu2_q2(i-1)+perturb;all_imu2_q3(i) = all_imu2_q3(i-1)+perturb;all_imu2_q4(i) = all_imu2_q4(i-1)+perturb;
            all_time(i) = all_time(i-1)+perturb; 
            all_gyro_1_x(i) = all_gyro_1_x(i-1) + perturb;
            all_gyro_1_y(i) = all_gyro_1_y(i-1) + perturb;
            all_gyro_1_z(i) = all_gyro_1_z(i-1) + perturb;
            all_gyro_2_x(i) = all_gyro_2_x(i-1) + perturb;
            all_gyro_2_y(i) = all_gyro_2_y(i-1) + perturb;
            all_gyro_2_z(i) = all_gyro_2_z(i-1) + perturb;


            all_accel_1_x(i) = all_accel_1_x(i-1) + perturb;
            all_accel_1_y(i) = all_accel_1_y(i-1) + perturb;
            all_accel_1_z(i) = all_accel_1_z(i-1) + perturb;
            all_accel_2_x(i) = all_accel_2_x(i-1) + perturb;
            all_accel_2_y(i) = all_accel_2_y(i-1) + perturb;
            all_accel_2_z(i) = all_accel_2_z(i-1) + perturb;
            all_encoder(i) = all_encoder(i-1) + perturb;
            counter = counter + 1;
        end
    end


    %% Save raw file as .mat file 
    save_raw_file_name = char(strcat(strcat(strcat('raw_',rotation_type), '_'), speed_type));
    
    if strcmp(save_status, 'yes') == 1

        save(strcat(save_directory,save_raw_file_name), 'all_time','all_encoder',...
            'all_imu1_q1','all_imu1_q2', 'all_imu1_q3', 'all_imu1_q4',...
            'all_imu2_q1','all_imu2_q2', 'all_imu2_q3', 'all_imu2_q4',...
            'all_gyro_1_x', 'all_gyro_1_y','all_gyro_1_z',...
            'all_accel_1_x', 'all_accel_1_y', 'all_accel_1_z',...
            'all_gyro_2_x', 'all_gyro_2_y','all_gyro_2_z',...
            'all_accel_2_x', 'all_accel_2_y', 'all_accel_2_z', 'calibration_line', 'data_line');

    end
    
end

disp('');
end

