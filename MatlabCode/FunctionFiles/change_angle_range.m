function theta_after = change_angle_range(rot_type, theta_before, x_1,y_1,z_1, x_2,y_2,z_2)
    
    % WHAT IT DOES: Changes the angle range from (-180 to 180) to (0 -
    % 360) degrees

    
    if strcmp(rot_type, 'pitch') == 1
        % Define a vector that is normal to the plane at which the two IMU
        % vectors reside in
        cross_vector = cross(x_1,x_2);

        % Obtain the projection of the cross product vector on a reference
        % vector of IMU 2 that is perpendicular to the previous two
        % vectors.
        % If the sign_vector is (+), the angle is between 0 to 180.
        % If the sign vector is (-), the angle is between -180 to 0.
        
        sign_vector = dot(cross_vector,y_2)';

        flag = 0;

        theta_after = zeros(length(theta_before),1); % angle after range increase
        
        ref_angle = 0;
        
        for i=2:length(theta_before)
            
            theta_after(i) = theta_before(i);
            
            % Whenever the sign_vector is negative, the angle range is
            % changed from (-180, 0) to (180, 360). 
            % Flag is needed to 
            if (sign_vector(i) < 0) && (flag == 0)
                % Unfortunately, the sign of DMP angle does not change exactly at 0
                % degrees or 180 degrees. The sign change angles is not
                % consistent. 
                % To handle this arbitrary sign change, we used 
                % the angle right before the sign change. 
                % Flag is used to indicate when the sign change is occuring
                % (flag == 1) and when is not occuring (flag == 0)
                
                ref_angle = theta_before(i-1);
                theta_after(i) = ref_angle - abs(ref_angle - theta_before(i));
                flag = 1;

            elseif (sign_vector(i) < 0) && (flag == 1)
                theta_after(i) = ref_angle - abs(ref_angle - theta_before(i));

            elseif sign_vector(i) > 0
                flag = 0;

            end
        end

        

    elseif strcmp(rot_type, 'roll') == 1
        cross_vector = cross(y_1,y_2);

        sign_vector = dot(cross_vector,x_2)';

        flag = 0;

        theta_after = zeros(length(theta_before),1);
        ref_angle = 0;
        for i=2:length(theta_before)

            theta_after(i) = theta_before(i);

            if (sign_vector(i) < 0) && (flag == 0)
                ref_angle = theta_before(i-1);
                
                theta_after(i) = (ref_angle - theta_before(i)) + ref_angle;
                flag = 1;

            elseif (sign_vector(i) < 0) && (flag == 1)
                theta_after(i) = (ref_angle - theta_before(i)) + ref_angle;

            elseif sign_vector(i) > 0
                flag = 0;
            end 
        end
        
    elseif strcmp(rot_type, 'yaw') == 1
        
        cross_vector = cross(y_1,y_2);

        % For yaw, the negative sign is needed to equate the signs of encoder and angle
        sign_vector = -dot(cross_vector,z_2)';
        
        flag = 0;

        theta_after = zeros(length(theta_before),1);
        ref_angle = 0;
        
        for i=2:length(theta_before)
            
            theta_after(i) = theta_before(i);
            
            if (sign_vector(i) < 0) && (flag == 0)
                ref_angle = theta_before(i-1);
                theta_after(i) = ref_angle - abs(ref_angle - theta_before(i));
                flag = 1;

            elseif (sign_vector(i) < 0) && (flag == 1)
                theta_after(i) = ref_angle - abs(ref_angle - theta_before(i));

            elseif sign_vector(i) > 0
                flag = 0;

            end
        end        
        
    end

end
