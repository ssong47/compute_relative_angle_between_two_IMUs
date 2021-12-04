clc; close all; clear all; 

%% Get proper file directories
cd 'C:\Users\77bis\Box\PVRM\Research Studies\IMU Study\Code\MatlabCode\'
addpath('FunctionFiles');
addpath('Data_2');
addpath('Figures');
addpath(genpath('Madgwick'));

%% Read the filtered data
data_type = 'raw';
rot_type = 'roll';
speed_type = 'fast';
file_type = '.mat';

file_name = strcat(data_type,'_',rot_type,'_',speed_type,file_type);

read_dir = strcat('C:\Users\77bis\Box\PVRM\Research Studies\IMU Study\Code\MatlabCode\Data_2\', file_name);
raw_data = load(read_dir);

%% Organize the filtered data to input into Madgwick algorithm
time = raw_data.all_time;


if strcmp(rot_type, 'pitch') == 1
% IMU 1 (stationary)
gyroscope_1 = [raw_data.all_gyro_1_y, raw_data.all_gyro_1_x, raw_data.all_gyro_1_z];
accelerometer_1 = [raw_data.all_accel_1_y, raw_data.all_accel_1_x, raw_data.all_accel_1_z];

% IMU 2 (moving)
gyroscope_2 = [raw_data.all_gyro_2_y, raw_data.all_gyro_2_x, raw_data.all_gyro_2_z];
accelerometer_2 = [raw_data.all_accel_2_y, raw_data.all_accel_2_x, raw_data.all_accel_2_z];

elseif strcmp(rot_type, 'roll') == 1
% IMU 1 (stationary)
gyroscope_1 = [raw_data.all_gyro_1_x, raw_data.all_gyro_1_y, raw_data.all_gyro_1_z];
accelerometer_1 = [raw_data.all_accel_1_x, raw_data.all_accel_1_y, raw_data.all_accel_1_z];

% IMU 2 (moving)
gyroscope_2 = [raw_data.all_gyro_2_x, raw_data.all_gyro_2_y, raw_data.all_gyro_2_z];
accelerometer_2 = [raw_data.all_accel_2_x, raw_data.all_accel_2_y, raw_data.all_accel_2_z];

elseif strcmp(rot_type, 'yaw') == 1

% IMU 1 (stationary)
gyroscope_1 = [raw_data.all_gyro_1_y, raw_data.all_gyro_1_z, raw_data.all_gyro_1_x];
accelerometer_1 = [raw_data.all_accel_1_y, raw_data.all_accel_1_z, raw_data.all_accel_1_x];

% IMU 2 (moving)
gyroscope_2 = [raw_data.all_gyro_2_y, raw_data.all_gyro_2_z, raw_data.all_gyro_2_x];
accelerometer_2 = [raw_data.all_accel_2_y, raw_data.all_accel_2_z, raw_data.all_accel_2_x];

end

% Encoder
% encoder = raw_data.encoder_filt;
encoder = raw_data.all_encoder;

%% Setup Madgwick and Mahony algorithm
madgwick_q_1 = zeros(length(time), 4);
madgwick_q_2 = zeros(length(time), 4);
mahony_q_1 = zeros(length(time), 4);
mahony_q_2 = zeros(length(time), 4);

kp = 1.0;
ki = 0.3;
Mahony_1 = MahonyAHRS('SamplePeriod', dt, 'Kp', kp,'Ki', ki);
Mahony_2 = MahonyAHRS('SamplePeriod', dt, 'Kp', kp,'Ki', ki);

dt = 1/sampling_frequency;
beta = 0.2; % 0.2 
Madgwick_1 = MadgwickAHRS('SamplePeriod', dt, 'Beta', beta);
Madgwick_2 = MadgwickAHRS('SamplePeriod', dt, 'Beta', beta);


%% Compute Madgwick and Mahony angles
for t = 1:length(time)
    Madgwick_1.UpdateIMU(gyroscope_1(t,:) * (pi/180), accelerometer_1(t,:));
    madgwick_q_1(t, :) = Madgwick_1.Quaternion;
    
    Madgwick_2.UpdateIMU(gyroscope_2(t,:) * (pi/180), accelerometer_2(t,:));
    madgwick_q_2(t, :) = Madgwick_2.Quaternion;
    
    Mahony_1.UpdateIMU(gyroscope_1(t,:) * (pi/180), accelerometer_1(t,:));
    mahony_q_1(t, :) = Mahony_1.Quaternion;
    
    Mahony_2.UpdateIMU(gyroscope_2(t,:) * (pi/180), accelerometer_2(t,:));
    mahony_q_2(t, :) = Mahony_2.Quaternion;
end 


madgwick_euler_1 = quatern2euler(quaternConj(madgwick_q_1)) * (180/pi);	% use conjugate for sensor frame relative to Earth and convert to degrees.
madgwick_euler_2 = quatern2euler(quaternConj(madgwick_q_2)) * (180/pi);

mahony_euler_1 = quatern2euler(quaternConj(mahony_q_1)) * (180/pi);	% use conjugate for sensor frame relative to Earth and convert to degrees.
mahony_euler_2 = quatern2euler(quaternConj(mahony_q_2)) * (180/pi);

if strcmp(rot_type,'roll') == 1
    i_angle = 1;
    asign = -1;
elseif strcmp(rot_type, 'pitch') == 1
    i_angle = 1;
    asign = 1;
elseif strcmp(rot_type, 'yaw') == 1
    i_angle = 3;
    asign = 1;
end

madgwick_angle_1 = madgwick_euler_1(:,i_angle); % handle_inversion(euler_1, rot_type);
madgwick_angle_2 = madgwick_euler_2(:,i_angle); % handle_inversion(euler_2, rot_type);
madgwick_angle = asign * (madgwick_angle_1 - madgwick_angle_2); 

mahony_angle_1 = mahony_euler_1(:, i_angle);
mahony_angle_2 = mahony_euler_2(:, i_angle);
mahony_angle = asign * (mahony_angle_1 - mahony_angle_2); 



%% Compute RMSE 
window_size = 6000;
reference_imu_1 = -90*ones(length(encoder),1);
[rmse_madgwick_1, rmse_avg_rmse_madgwick_1, rmse_std_rmse_madgwick_1] = compute_rmse_array(reference_imu_1, madgwick_angle_1, window_size);
[rmse_madgwick_2, rmse_avg_rmse_madgwick_2, rmse_std_rmse_madgwick_2] = compute_rmse_array(encoder, -madgwick_angle_2, window_size);
[rmse_madgwick, rmse_avg_rmse_madgwick, rmse_std_rmse_madgwick] = compute_rmse_array(encoder, madgwick_angle, window_size);

[rmse_mahony_1, rmse_avg_rmse_mahony_1, rmse_std_rmse_mahony_1] = compute_rmse_array(reference_imu_1, mahony_angle_1, window_size);
[rmse_mahony_2, rmse_avg_rmse_mahony_2, rmse_std_rmse_mahony_2] = compute_rmse_array(encoder, -mahony_angle_2, window_size);
[rmse_mahony, rmse_avg_rmse_mahony, rmse_std_rmse_mahony] = compute_rmse_array(encoder, mahony_angle, window_size);


%% Plot Madgwick Angles
% figure()
% plot(madgwick_euler_2(:,1))
% hold on
% plot(madgwick_euler_2(:,2))
% plot(madgwick_euler_2(:,3))
% legend('e1','e2','e3')

figure('Name', '[IMU 1]');
plot(time, madgwick_angle_1, 'r-');
hold on;
plot(time, mahony_angle_1, 'g-');
title('Madgwick & Mahony angles');
xlabel('Time (s)');
ylabel('Angle (deg)');
legend('Madgwick', 'Mahony');
hold off;

figure('Name', '[IMU 2]');
hold on;
plot(time, encoder, 'k');
plot(time, madgwick_angle, 'r-');
plot(time, mahony_angle, 'g-'); 
title('Madgwick & Mahony angles');
xlabel('Time (s)');
ylabel('Angle (deg)');
legend('encoder', 'Madgwick', 'Mahony');
hold off;


figure('Name', 'RMSE')
plot(time, rmse_madgwick)
hold on;
plot(time, rmse_mahony)
xlabel('Time (s)');
ylabel('RMSE (deg)');
legend('Madgwick','Mahony')
hold off;

%% Compute RMSE 
window_size = 6000;
reference_imu_1 = -90*ones(length(encoder),1);
[rmse_madgwick_1, rmse_avg_rmse_madgwick_1, rmse_std_rmse_madgwick_1] = compute_rmse_array(reference_imu_1, madgwick_angle_1, window_size);
[rmse_madgwick_2, rmse_avg_rmse_madgwick_2, rmse_std_rmse_madgwick_2] = compute_rmse_array(encoder, -madgwick_angle_2, window_size);
[rmse_madgwick, rmse_avg_rmse_madgwick, rmse_std_rmse_madgwick] = compute_rmse_array(encoder, madgwick_angle, window_size);


%% Compute Time Delay
clear t;
t{1}(1) = 0;
t{1}(2) = 5 * 60;

t{2}(1) = 5 * 60;
t{2}(2) = 15 * 60;

t{3}(1) = 15 * 60;
t{3}(2) = 25 * 60;

index{1}(1) = 1;
[a2, index{1}(2)] = min(abs(time - t{1}(2)));

[b1, index{2}(1)] = min(abs(time - t{2}(1)));
[b2, index{2}(2)] = min(abs(time - t{2}(2)));

[c1, index{3}(1)] = min(abs(time - t{3}(1)));
[c2, index{3}(2)] = min(abs(time - t{3}(2)));

index{4}(1) = 1;
index{4}(2) = length(time);
    
master_rmse_array{1} = [rmse_madgwick_1];
master_rmse_array{2} = [rmse_madgwick_2];
master_rmse_array{3} = [rmse_madgwick];

master_temp = master_rmse_array;

for i_imu = 1:3
    for i_zone = 1:4
%         if master_temp{i_imu}(1,2) == 0
%             master_temp{i_imu}(1:window_size-1,:) = [];
%         end

        end_index = index{i_zone}(2) - window_size;

        div_master_rmse{i_zone}{i_imu}= master_temp{i_imu}(index{i_zone}(1):end_index,:);

    end
end


max_lag = 100; % max_lag is the maximum amount of time needed for searching for the time delay
    
time_lag = {};

for i_zone = 1:4
    div_master_delay{i_zone}{1} = finddelay(encoder(index{i_zone}(1):index{i_zone}(2)), 90+madgwick_angle_2(index{i_zone}(1):index{i_zone}(2)) , max_lag);
    div_master_delay{i_zone}{2} = finddelay(encoder(index{i_zone}(1):index{i_zone}(2)), madgwick_angle(index{i_zone}(1):index{i_zone}(2)) , max_lag);

end
    
    
    



