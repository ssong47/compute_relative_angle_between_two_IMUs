function theta_dmp_final = compute_dmp_angle(R_calibration, R_1_calibration, imu1_q1, imu1_q2, imu1_q3, imu1_q4, imu2_q1, imu2_q2, imu2_q3, imu2_q4, rotation_type, imu_type)
    % WHAT IT DOES: Computes angle using digital motion processing (DMP)
    % DMP is a proprietary algorithm created by TDK-Invensense that
    % computes a 3D quaternion vector representing orientation of the IMU 

    %% Obtaining Angle from IMU Quaternion
    test_data_length = length(imu1_q1); 
    
    theta_dmp = zeros(test_data_length,1); % dmp angle between 0 - 180 and before spike removal 

    spike_count_threshold = 4; % parameter used for removing spikes  
    
    % 3D vector of x,y,z axes of each IMU in 3D space
    x_1 = zeros(3, test_data_length);
    y_1 = zeros(3, test_data_length);
    z_1 = zeros(3, test_data_length);
    
    x_2 = zeros(3, test_data_length);
    y_2 = zeros(3, test_data_length);
    z_2 = zeros(3, test_data_length);


    for i=1:test_data_length
        if strcmp(imu_type, 'moving') == 1 
            % Obtain rotation matrices for each IMU 
            
            R_1 = [2*(imu1_q1(i)^2+imu1_q2(i)^2)-1 2*(imu1_q2(i)*imu1_q3(i)-imu1_q1(i)*imu1_q4(i)) 2*(imu1_q2(i)*imu1_q4(i)+imu1_q1(i)*imu1_q3(i));
              2*(imu1_q2(i)*imu1_q3(i)+imu1_q1(i)*imu1_q4(i)) 2*(imu1_q1(i)^2+imu1_q3(i)^2)-1 2*(imu1_q3(i)*imu1_q4(i)-imu1_q1(i)*imu1_q2(i));
              2*(imu1_q2(i)*imu1_q4(i)-imu1_q1(i)*imu1_q3(i)) 2*(imu1_q3(i)*imu1_q4(i)+imu1_q1(i)*imu1_q2(i)) 2*(imu1_q1(i)^2+imu1_q4(i)^2)-1];

          
            R_2 = [2*(imu2_q1(i)^2+imu2_q2(i)^2)-1 2*(imu2_q2(i)*imu2_q3(i)-imu2_q1(i)*imu2_q4(i)) 2*(imu2_q2(i)*imu2_q4(i)+imu2_q1(i)*imu2_q3(i));
              2*(imu2_q2(i)*imu2_q3(i)+imu2_q1(i)*imu2_q4(i)) 2*(imu2_q1(i)^2+imu2_q3(i)^2)-1 2*(imu2_q3(i)*imu2_q4(i)-imu2_q1(i)*imu2_q2(i));
              2*(imu2_q2(i)*imu2_q4(i)-imu2_q1(i)*imu2_q3(i)) 2*(imu2_q3(i)*imu2_q4(i)+imu2_q1(i)*imu2_q2(i)) 2*(imu2_q1(i)^2+imu2_q4(i)^2)-1];

            
            if strcmp(rotation_type, 'pitch') == 1
                ax = 1;
                R_2_new = R_calibration * R_2;
                ax1 = R_1(:,ax)/norm(R_1(:,ax));
                ax2 = R_2_new(:,ax)/norm(R_2_new(:,ax));

            elseif strcmp(rotation_type, 'roll') == 1
                ax = 2;
                R_2_new = R_calibration * R_2;
                ax1 = R_1(:,ax)/norm(R_1(:,ax));
                ax2 = R_2_new(:,ax)/norm(R_2_new(:,ax));
                
            elseif strcmp(rotation_type, 'yaw') == 1
                ax = 2;
                R_2_new = R_calibration * R_2;
                ax1 = R_1(:,ax)/norm(R_1(:,ax));
                ax2 = R_2_new(:,ax)/norm(R_2_new(:,ax));
                
            end
          
            % Store x,y,z axes for IMU 1,2
            x_2(:,i) = R_2_new(:,1)/norm(R_2_new(:,1));
            y_2(:,i) = R_2_new(:,2)/norm(R_2_new(:,2));
            z_2(:,i) = R_2_new(:,3)/norm(R_2_new(:,3));

            x_1(:,i) = R_1(:,1)/norm(R_1(:,1));
            y_1(:,i) = R_1(:,2)/norm(R_1(:,2));
            z_1(:,i) = R_1(:,3)/norm(R_1(:,3));
            
            
            % Compute theta dmp
            theta_dmp(i,1) = atan2d(norm(cross(ax1,ax2)),dot(ax1,ax2));

        

        elseif strcmp(imu_type, 'stationary') ==1
            
            % For stationary IMU, computation of only one rotation matrix of IMU
            % 1 is needed, since IMU 1 is used as a global reference. 
            
            R_1 = [2*(imu1_q1(i)^2+imu1_q2(i)^2)-1 2*(imu1_q2(i)*imu1_q3(i)-imu1_q1(i)*imu1_q4(i)) 2*(imu1_q2(i)*imu1_q4(i)+imu1_q1(i)*imu1_q3(i));
              2*(imu1_q2(i)*imu1_q3(i)+imu1_q1(i)*imu1_q4(i)) 2*(imu1_q1(i)^2+imu1_q3(i)^2)-1 2*(imu1_q3(i)*imu1_q4(i)-imu1_q1(i)*imu1_q2(i));
              2*(imu1_q2(i)*imu1_q4(i)-imu1_q1(i)*imu1_q3(i)) 2*(imu1_q3(i)*imu1_q4(i)+imu1_q1(i)*imu1_q2(i)) 2*(imu1_q1(i)^2+imu1_q4(i)^2)-1];
          
         
          
            if strcmp(rotation_type, 'pitch') == 1
                ax = 1;     
                ax1 = R_1_calibration(:,ax)/norm(R_1_calibration(:,ax));
                ax2 = R_1(:,ax)/norm(R_1(:,ax));
            elseif strcmp(rotation_type, 'roll') == 1
                ax = 2;
                ax1 = R_1_calibration(:,ax)/norm(R_1_calibration(:,ax));
                ax2 = R_1(:,ax)/norm(R_1(:,ax));

            elseif strcmp(rotation_type, 'yaw') == 1
                ax = 1;
                ax1 = R_1_calibration(:,ax)/norm(R_1_calibration(:,ax));
                ax2 = R_1(:,ax)/norm(R_1(:,ax));
  
            end

            % Compute theta dmp
            theta_dmp(i,1) = atan2d(norm(cross(ax1,ax2)),dot(ax1,ax2));
         
        end


    end
    

    % To change the angle range to 0 - 360 degrees.
    theta_dmp = change_angle_range(rotation_type, theta_dmp,...
                     x_1,y_1,z_1,x_2,y_2,z_2);

    % To remove data spikes
    theta_dmp_final = remove_data_spike(theta_dmp, spike_count_threshold);
  


end




