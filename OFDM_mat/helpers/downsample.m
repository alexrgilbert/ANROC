function [x_downsampled] = downsample(x,ds_rate)
    ds_len = floor(length(x) / ds_rate);
    x_downsampled = complex(zeros(1,ds_len),...
                    zeros(1,ds_len));

    for i = 1:(ds_len)
        upsampled_idcs = (ceil((i-1)*ds_rate)+1):1:((ceil((i)*ds_rate)+1)-1);
        % % % TODO:  BETTER TO JUST CHOOSE ONE OR TAKE AVERAGE?
        x_downsampled(1,i) = (x(1,upsampled_idcs(1)));
        % y_bb_downsampled(1,i) = mean(y_bb(1,upsampled_idcs));
    end
end
