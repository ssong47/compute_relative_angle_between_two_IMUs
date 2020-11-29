function theta_clean = remove_data_spike(theta, threshold)
%     WHAT IT DOES: 
%     This function removes data spikes 

theta_filt = medfilt1(theta,3);

is_spike =  abs(theta - theta_filt) > threshold;

theta_clean = theta;

theta_clean(is_spike) = theta_filt(is_spike);




end
