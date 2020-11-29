function [time_rmse_limit]= find_time_rmse_limit(time, rmse_data)

rmse_time = time(1:length(rmse_data));

time_rmse_limit = 0;

for i_data = 1:length(rmse_data)
    if rmse_data(i_data) > 6
       time_rmse_limit = rmse_time(i_data);
       break
    end
end


end