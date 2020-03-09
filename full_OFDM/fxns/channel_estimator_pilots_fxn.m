function [H_hat_pilot] = channel_estimator_pilots_fxn(pilots,num_carriers,pilot)
    pilots = pilots / pilot;
    pilot_avg = mean(pilots,1);
    pilot_avg = [pilot_avg(1) pilot_avg pilot_avg(end)];
    H_hat_pilot = complex(zeros(1,num_carriers),zeros(1,num_carriers));
    pilot_carriers = [1 8 24 51 61 64];
    j = 1;
    for i = 1:num_carriers
        if (i == pilot_carriers(j))
            H_hat_pilot(i) = pilot_avg(j);
            j = j+1;
        else
            H_hat_pilot(i) = (((pilot_avg(j)-pilot_avg(j-1)) /...
                (pilot_carriers(j)-pilot_carriers(j-1))) * (i - ...
                pilot_carriers(j-1))) + pilot_avg(j-1);
        end
    end

end
