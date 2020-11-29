function [R_calibration, R_1_calibration]= compute_calib_matrix(c_imu1_q1, c_imu1_q2, c_imu1_q3, c_imu1_q4, ...
                          c_imu2_q1, c_imu2_q2, c_imu2_q3, c_imu2_q4)

   
    % WHAT IT DOES: Computes calibration matrix for DMP calculation to
    % align the IMU 2 (Moving IMU) to IMU 1 (Stationary IMU)
    
    %% Obtaining Calibration Matrix 

    length_calibration = length(c_imu1_q1);
    R_1_calibration = zeros(3);
    R_2_calibration = zeros(3);

    for i = 2:length_calibration

        % set up rotation matrix for both IMUs (can be found in any robotics textbooks)
        R_1 = [2*(c_imu1_q1(i)^2+c_imu1_q2(i)^2)-1 2*(c_imu1_q2(i)*c_imu1_q3(i)-c_imu1_q1(i)*c_imu1_q4(i)) 2*(c_imu1_q2(i)*c_imu1_q4(i)+c_imu1_q1(i)*c_imu1_q3(i));
              2*(c_imu1_q2(i)*c_imu1_q3(i)+c_imu1_q1(i)*c_imu1_q4(i)) 2*(c_imu1_q1(i)^2+c_imu1_q3(i)^2)-1 2*(c_imu1_q3(i)*c_imu1_q4(i)-c_imu1_q1(i)*c_imu1_q2(i));
              2*(c_imu1_q2(i)*c_imu1_q4(i)-c_imu1_q1(i)*c_imu1_q3(i)) 2*(c_imu1_q3(i)*c_imu1_q4(i)+c_imu1_q1(i)*c_imu1_q2(i)) 2*(c_imu1_q1(i)^2+c_imu1_q4(i)^2)-1];

        R_2 = [2*(c_imu2_q1(i)^2+c_imu2_q2(i)^2)-1 2*(c_imu2_q2(i)*c_imu2_q3(i)-c_imu2_q1(i)*c_imu2_q4(i)) 2*(c_imu2_q2(i)*c_imu2_q4(i)+c_imu2_q1(i)*c_imu2_q3(i));
              2*(c_imu2_q2(i)*c_imu2_q3(i)+c_imu2_q1(i)*c_imu2_q4(i)) 2*(c_imu2_q1(i)^2+c_imu2_q3(i)^2)-1 2*(c_imu2_q3(i)*c_imu2_q4(i)-c_imu2_q1(i)*c_imu2_q2(i));
              2*(c_imu2_q2(i)*c_imu2_q4(i)-c_imu2_q1(i)*c_imu2_q3(i)) 2*(c_imu2_q3(i)*c_imu2_q4(i)+c_imu2_q1(i)*c_imu2_q2(i)) 2*(c_imu2_q1(i)^2+c_imu2_q4(i)^2)-1];   
        
          
        % Sum the rotation matrices for each IMU for averaging later  
        R_1_calibration = R_1_calibration + R_1;
        
        R_2_calibration = R_2_calibration + R_2;

    end
    
    % Compute the average of the calibration matrixes of IMU 1
    % This matrix will be used to calculate only the orientation of IMU 1.
    % 
    R_1_calibration = R_1_calibration / length_calibration; 
    
    % Compute the average of the calibration matrixes that establishes global reference frame for IMU 2
    % This matrix will be used to calculate the orientation of IMU 2.
    R_calibration = R_1_calibration * R_2_calibration'; 
    
    
    

end