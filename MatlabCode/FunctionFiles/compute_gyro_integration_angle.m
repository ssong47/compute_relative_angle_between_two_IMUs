function theta_gi = compute_gyro_integration_angle(gyro_x, gyro_y, gyro_z, sampling_freq, rotation_type)
    % WHAT IT DOES: computes joint angle using gyroscopic integration 
    
    if strcmp(rotation_type, 'pitch') == 1
        theta_gi = 1 / sampling_freq * cumtrapz(gyro_y);
        
    elseif strcmp(rotation_type, 'roll') == 1
        theta_gi = 1 / sampling_freq * cumtrapz(gyro_x);

    elseif strcmp(rotation_type, 'yaw') == 1
        % Negative sign is added to make sure theta_gi has same sign as
        % theta_encoder
        theta_gi = 1 / sampling_freq * cumtrapz(-gyro_z);

    end




end