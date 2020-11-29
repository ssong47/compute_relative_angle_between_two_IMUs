function theta_kf = compute_kalman_filter_angle(Q, R, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z, sampling_freq, rotation_type, imu_type)
    % WHAT IT DOES: computes angle using kalman filter 
    
    % REFERENCE
    % P. Gui, L. Tang, and S. Mukhopadhyay, “MEMS based IMU for tilting 
    % measurement: Comparison of complementary and kalman filter based data
    % fusion,” in 2015 IEEE 10th Conference on Industrial Electronics 
    % and Applications (ICIEA), 2015, pp. 2004–2009,
    % doi: 10.1109/ICIEA.2015.7334442.


    % Array of measurement updates using accelerometer measurements
    theta_hat_accel = compute_accel_inclination_angle(accel_x, accel_y, accel_z, rotation_type, imu_type);

    
    if strcmp(rotation_type, 'pitch') == 1
        % Negative sign is added to make sure theta_gi has same sign as
        % theta_encoder
        gyro = -gyro_y;

    elseif strcmp(rotation_type, 'roll') == 1
        gyro = gyro_x;

    elseif strcmp(rotation_type, 'yaw') == 1
        % Negative sign is added to make sure theta_gi has same sign as
        % theta_encoder
        gyro = -gyro_z;

    end

    % State Space Model
    delta_t = 1 / sampling_freq;
    A = [1 -delta_t; 0 1];
    B = [delta_t; 0];
    C = [1 0; 0 0];
    P = eye(2);


    state_estimate = [0 0]'; % initial condition of state estimate
    
    theta_hat_kalman    = zeros(1, length(accel_x)); % estimate of angle
    bias_theta_kalman   = zeros(1, length(accel_x)); % estimate of bias of gyro

    for i = 2:length(accel_x)
  
        % Update the input (u_k)
        theta_dot = gyro(i);

        % Predict the state (x_k)
        state_estimate = A * state_estimate + B * [theta_dot];

        % Predict the error covariance matrix 
        P = A * P * A' + Q;

        % Update the measurement 
        measurement = [theta_hat_accel(i) 0]'; 

        % Update the new output measurement using measurement and state
        % estimate
        y_tilde = measurement - C * state_estimate;

        % Obtain Kalman Gain
        S = R + C * P * C';
        K = P * C' * (S^-1);

        % Update new state estimate combining prediction and update terms 
        state_estimate = state_estimate + K * y_tilde;

        % Update new error covariance matrix using Kalman Gain
        P = (eye(2) - K * C) * P;

        theta_hat_kalman(i)    = state_estimate(1);
        bias_theta_kalman(i)   = state_estimate(2);
    end
    theta_kf = theta_hat_kalman.';

end