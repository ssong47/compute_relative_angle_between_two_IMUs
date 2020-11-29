function theta_cf = compute_complementary_filter_angle(alpha, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z, sampling_freq, rot_type, imu_type)
    % WHAT IT DOES: computes angle using complementary filter
    
    % REFERENCE
    % P. Gui, L. Tang, and S. Mukhopadhyay, “MEMS based IMU for tilting 
    % measurement: Comparison of complementary and kalman filter based data
    % fusion,” in 2015 IEEE 10th Conference on Industrial Electronics 
    % and Applications (ICIEA), 2015, pp. 2004–2009,
    % doi: 10.1109/ICIEA.2015.7334442.

    delta_t = 1 / sampling_freq;
    
    inverse_alpha = 1 - alpha;  

    theta_cf = zeros(size(accel_x));
    
    theta_accel = compute_accel_inclination_angle(accel_x, accel_y, accel_z, rot_type, imu_type);
    
    
    if strcmp(rot_type, 'pitch') == 1
        % Negative sign is added to make sure theta_gi has same sign as
        % theta_encoder
        gyro = -gyro_y;
        
    elseif strcmp(rot_type, 'roll') == 1
        gyro = gyro_x;
    
    elseif strcmp(rot_type, 'yaw') == 1
        % Negative sign is added to make sure theta_gi has same sign as
        % theta_encoder
        gyro = -gyro_z;
        
    end
    
    
    for idx = 1:length(theta_cf)
        if idx == 1
            theta_cf(idx) = inverse_alpha * gyro(idx) * delta_t + alpha * theta_accel(idx); 
        else
            theta_cf(idx) = inverse_alpha * (theta_cf(idx - 1) + gyro(idx) * delta_t) + alpha * theta_accel(idx);         
        end
    end
    
    

end