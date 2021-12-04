function euler_angle = quaternion2Euler(q0, q1, q2, q3)
    euler_angle = zeros(length(q0), 3);
    
    euler_angle(:,1) = real(atan2d(2 * (q0.*q1 + q2.*q3), 1 - 2*(q1.^2 + q2.^2)));
    
    euler_angle(:,2) = real(asind(2 * (q0.*q2 - q3 .* q1)));
    
    euler_angle(:,3) = real(atan2d(2*(q0.*q3 + q1.*q2), 1 - 2.*(q2.^2 + q3.^2)));


end