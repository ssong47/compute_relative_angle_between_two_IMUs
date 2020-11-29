function [theta_ai] = compute_accel_inclination_angle(accel_x, accel_y, accel_z, rotation_type, imu_type)
    
    % WHAT IT DOES: computes accelerometer inclincation angle according to
    
    % REFERENCE              
    % https://www.analog.com/media/en/technical-documentation/application-notes/AN-1057.pdf
    
    
    theta_ai = zeros(length(accel_x),1);

    % Need to use different equations depending on rotation axis
    if strcmp(rotation_type, 'pitch') == 1
        flag = 0;
        for i = 2:length(accel_x)            
            % 90 is added to ensure theta_ai starts from 0 deg
            theta_ai(i) = -(atand(accel_x(i)/sqrt(accel_y(i)^2 + accel_z(i)^2)) + 90);

%             % To prevent inversion of computed angle
            if (sign(accel_z(i)) < 0) && (strcmp(imu_type,'moving') == 1)  && (flag == 0)
                
                ref_angle = theta_ai(i-1);
                if (sign(accel_x(i)) < 0)
                    theta_ai(i) = abs(ref_angle - theta_ai(i)) + ref_angle;
                elseif (sign(accel_x(i)) > 0)
                    theta_ai(i) = ref_angle - abs(ref_angle - theta_ai(i));
                end
                flag = 1;
                
            elseif (sign(accel_z(i)) < 0) && (strcmp(imu_type,'moving') == 1)  && (flag == 1)
                
                if (sign(accel_x(i)) < 0)
                    theta_ai(i) = abs(ref_angle - theta_ai(i)) + ref_angle;
                elseif (sign(accel_x(i)) > 0)
                    theta_ai(i) = ref_angle - abs(ref_angle - theta_ai(i));
                end
                
            elseif (sign(accel_z(i)) > 0) 
                flag = 0;
            end
    
        end
                
    elseif strcmp(rotation_type, 'roll') == 1        
        flag = 0;
        for i = 2:length(accel_x)         
            % 90 is added to ensure theta_ai starts from 0 deg
            theta_ai(i) = atand(accel_y(i)/sqrt(accel_x(i)^2 + accel_z(i)^2)) + 90;

            
            
            % To prevent inversion of computed angle
            if (sign(accel_z(i)) < 0) && (strcmp(imu_type,'moving') == 1)  && (flag == 0)
                ref_angle = theta_ai(i-1);
                if (sign(accel_y(i)) > 0)
                    theta_ai(i) = abs(ref_angle - theta_ai(i)) + ref_angle;
                elseif (sign(accel_y(i)) < 0)
                    theta_ai(i) = ref_angle - abs(ref_angle - theta_ai(i));
                end
                flag = 1;
            elseif (sign(accel_z(i)) < 0) && (strcmp(imu_type,'moving') == 1)  && (flag == 1)
                if (sign(accel_y(i)) > 0)
                    theta_ai(i) = abs(ref_angle - theta_ai(i)) + ref_angle;
                elseif (sign(accel_y(i)) < 0)
                    theta_ai(i) = ref_angle - abs(ref_angle - theta_ai(i));
                end
            elseif (sign(accel_z(i)) > 0) 
                flag = 0;
            end

        end
    
    elseif strcmp(rotation_type, 'yaw') == 1
        % theta_ai cannot be computed for yaw rotation axis, since gravity
        % vector is parallel to rotation axis.
        theta_ai = zeros(length(accel_x),1);
        
    end

end