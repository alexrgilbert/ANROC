function ofdm_proc_fxn(bits, syms, syms_int, signal_bb, signal_bb_ds, signal,...
        detected_syms_gt, detected_syms_gt_ds, y, y_bb_us, y_bb_hp, y_bb,...
         detected_syms, H_hat_avg, L_hat_avg, L, r, p, d)


    num_data_carriers = (p.num_carriers-p.num_dead_carriers-p.num_pilots);
    packet_length = (p.x_stf_len + p.x_ltf_len + (p.num_symbols_per_packet * (p.num_carriers + p.num_prefix))) * p.us_rate;
    train_packet_length = (p.x_stf_len + p.x_ltf_len) * p.us_rate;
    packet_data_syms_length = (p.num_symbols_per_packet * num_data_carriers);
    packet_data_bits_length = packet_data_syms_length * max(log2(p.M),1);


    bits = randi([0,1],1,(p.num_packets*packet_data_bits_length));
    len_bits = length(bits);

    num_symbols = ceil ( len_bits /  (num_data_carriers*max(log2(p.M),1)) );
    num_packets = ceil ( num_symbols /  p.num_symbols_per_packet );

    if p.plot_spectrum == true
        x_bb = downsample(signal_bb(1,1:end), p.ds_rate);
        figure;subplot(3,2,1);periodogram(x_bb,[],length(x_bb),p.BW,'centered');title('Pre-TX: Baseband Downsampled (Post-Proc) Signal Spectrum');
        subplot(3,2,2);periodogram(signal_bb_ds,[],length(signal_bb_ds),p.BW,'centered');title('Pre-TX: Baseband Downsampled Signal Spectrum');
        subplot(3,2,3:4);periodogram(signal_bb,[],length(signal_bb),p.TX_Fs,'centered'); title('Pre-TX: Baseband Upsampled Signal Spectrum');
        subplot(3,2,5:6);periodogram(signal,[],length(signal),p.TX_Fs,'centered'); title('Pre-TX: Upconverted Signal Spectrum');

        figure;subplot(3,2,1:2);periodogram(y,[],length(y),p.TX_Fs,'centered');title('Post-RX: Upconverted Unfiltered Upsampled Signal Spectrum');
        subplot(3,2,3);periodogram(y_bb_hp,[],length(y_bb_hp),p.TX_Fs,'centered');title('Post-RX: Baseband Unfiltered Upsampled Signal Spectrum');
        subplot(3,2,4);periodogram(y_bb_us,[],length(y_bb_us),p.TX_Fs,'centered');title('Post-RX: Baseband Filtered Upsampled Signal Spectrum');
        subplot(3,2,5:6); periodogram(y_bb,[],length(y_bb),p.BW,'centered');title('Post-RX: Baseband Filtered Downsampled Signal Spectrum');
    end

    if p.plot_signal == true
        x_bb = downsample(signal_bb(1,1:end), p.ds_rate);
        figure;subplot(3,2,1);plot(make_time_axis(x_bb,p.BW),abs(x_bb));title('Pre-TX: Baseband Downsampled (Post-Proc) Signal Magnitude');
        subplot(3,2,2);plot(make_time_axis(signal_bb_ds,p.BW),abs(signal_bb_ds));title('Pre-TX: Baseband Downsampled Signal Magnitude');
        subplot(3,2,3:4);plot(make_time_axis(signal_bb,p.TX_Fs),abs(signal_bb)); title('Pre-TX: Baseband Upsampled Signal Magnitude');
        subplot(3,2,5:6);plot(make_time_axis(signal,p.TX_Fs),signal); title('Pre-TX: Upconverted Signal');

        figure;subplot(3,2,1:2);plot(make_time_axis(y,p.RX_Fs),abs(y));title('Post-RX: Upconverted Unfiltered Upsampled Signal Magnitude');
        subplot(3,2,3);plot(make_time_axis(y_bb_hp,p.RX_Fs),abs(y_bb_hp));title('Post-RX: Baseband Unfiltered Upsampled Signal Magnitude');
        subplot(3,2,4);plot(make_time_axis(y_bb_us,p.RX_Fs),abs(y_bb_us));title('Post-RX: Baseband Filtered Upsampled Signal Magnitude');
        subplot(3,2,5:6); plot(make_time_axis(y_bb,p.BW),abs(y_bb));title('Post-RX: Baseband Filtered Downsampled Signal Magnitude');
    end

    if p.plot_comparison == true
        start_idcs_ds = find(detected_syms);
        start_idx_ds = start_idcs_ds(1);

        start_idx = floor(start_idx_ds * p.us_rate);

        start_idcs_gt = find(detected_syms_gt);
        start_idx_gt = start_idcs_gt(1);

        start_idcs_gt_ds = find(detected_syms_gt_ds);
        start_idx_gt_ds = start_idcs_gt_ds(1);

        figure;
        signal_ta = make_time_axis(signal,p.TX_Fs);
        plot(signal_ta(start_idx_gt:end),abs(signal(start_idx_gt:end)));
        hold on;
        y_ta = make_time_axis(y,p.RX_Fs);
        plot(y_ta(start_idx:end),abs(y(start_idx:end)));
        legend('Pre-TX Magnitude', 'Post-RX Magnitude');
        title('Effect of Channel in Time (upsampled upconverted)');

        figure;
        signal_bb_ds_ta = make_time_axis(signal_bb_ds,p.BW);
        plot(signal_bb_ds_ta(start_idx_gt_ds:end),abs(signal_bb_ds(start_idx_gt_ds:end)));
        hold on;
        y_bb_ta = make_time_axis(y_bb,p.BW);
        plot(y_bb_ta(start_idx_ds:end),abs(y_bb(start_idx_ds:end)));
        r_ta = make_time_axis(r,p.BW);
        r_normalized = r / max(r,[],'all');
        plot(r_ta(start_idx_ds:end),r_normalized(start_idx_ds:end));
        stem(r_ta(start_idx_ds:end),detected_syms(start_idx_ds:end));
        legend('Pre-TX', 'Post-RX','Correlation','Detections');
        title('Effect of Channel in Time + Correlation (downconverted downsampled)');
    end

    if p.print_detection == true
        if (length(find(detected_syms)) == length(find(detected_syms_gt_ds)))
                find(detected_syms)-find(detected_syms_gt_ds)
        else
            find(detected_syms)
            find(detected_syms_gt_ds)
        end

    end

    if p.plot_channel_estimation == true
        figure;
        subplot(2,2,1);
        legend_strs = {};
        xlabel('Frequency (delta_fs)');
        stem(1:1:length(H_hat_avg),abs(H_hat_avg),'c'); legend_strs{end+1} = 'H Estimated Mag';
        hold on;
        if d.sim == true
            stem(1:1:length(d.H),abs(d.H),'r'); legend_strs{end+1} = 'H GT Mag';
        end
        stem(1:1:length(L_hat_avg),abs(L_hat_avg),'b'); legend_strs{end+1} = 'L Estimated Mag';
        stem(1:1:length(L),abs(L),'m'); legend_strs{end+1} = 'L GT Mag';
        legend(legend_strs);
         title('Average Channel Estimate vs Actual Magnitude');

         subplot(2,2,2);
         legend_strs = {};
         xlabel('Frequency (delta_fs)');
         stem(1:1:length(H_hat_avg),angle(H_hat_avg),'g'); legend_strs{end+1} = 'H Estimated Phase';
         hold on;
         if d.sim == true
             stem(1:1:length(d.H),angle(d.H),'y'); legend_strs{end+1} = 'H GT Phase';
         end
         stem(1:1:length(L_hat_avg),angle(L_hat_avg),'k'); legend_strs{end+1} = 'L Estimated Phase';
         stem(1:1:length(L),angle(L),'r'); legend_strs{end+1} = 'L GT Phase';
         legend(legend_strs);
          title('Average Channel Estimate vs Actual Phase');

          subplot(2,2,3);
          legend_strs = {};
          xlabel('Frequency (delta_fs)');
          stem(1:1:length(H_hat_avg),real(H_hat_avg),'c'); legend_strs{end+1} = 'H Estimated Real';
          hold on;
          if d.sim == true
              stem(1:1:length(d.H),real(d.H),'r'); legend_strs{end+1} = 'H GT Real';
          end
          stem(1:1:length(L_hat_avg),real(L_hat_avg),'b'); legend_strs{end+1} = 'L Estimated Real';
          stem(1:1:length(L),real(L),'m'); legend_strs{end+1} = 'L GT Real';
          legend(legend_strs);
           title('Average Channel Estimate vs Actual Real');

           subplot(2,2,4);
           legend_strs = {};
           xlabel('Frequency (delta_fs)');
           stem(1:1:length(H_hat_avg),imag(H_hat_avg),'g'); legend_strs{end+1} = 'H Estimated Imaginary';
           hold on;
           if d.sim == true
               stem(1:1:length(d.H),imag(d.H),'y'); legend_strs{end+1} = 'H GT Imaginary';
           end
           stem(1:1:length(L_hat_avg),imag(L_hat_avg),'k'); legend_strs{end+1} = 'L Estimated Imaginary';
           stem(1:1:length(L),imag(L),'r'); legend_strs{end+1} = 'L GT Imaginary';
           legend(legend_strs);
            title('Average Channel Estimate vs Actual Imaginary');
    end
end



%     ltf_idx = find(detected_syms) + x_stf_len;
%     y_ltf = y_bb(ltf_idx:(ltf_idx + x_ltf_len - 1));
%
%     [H_hat,L_hat,L] = channel_estimator_sim_audio(SNR,delta_fs,symbol_time,x_ltf,y_ltf);
%
%     if (sum(detected_syms ~= detected_syms_gt) == 0)
%         cnt = cnt + 1;
%         H_hat_avg = H_hat_avg + (H_hat / num_train_packets);
%     end
%
% end
%
% if SNR == SNR%100))
%     figure;
%     xlabel('Frequency (delta_fs)');
%     title('Channel Estimate vs Actual');
%     stem(1:1:length(H),abs(H),'r');
%     hold on;
%     stem(1:1:length(H_hat_avg),abs(H_hat_avg),'c');
%     stem(1:1:length(H),angle(H),'y');
%     stem(1:1:length(H_hat_avg),angle(H_hat_avg),'g');
%     stem(1:1:length(L_hat),abs(L_hat),'b');
%     stem(1:1:length(L_hat),angle(L_hat),'k');
%     stem(1:1:length(L_hat),abs(L),'m');
%     stem(1:1:length(L_hat),angle(L),'r');
%     legend('Actual Magnitude','Estimated Magnitude', ...
%              'Actual Phase', 'Estimated Phase',...
%              'L magnitude', 'L Phase',...
%              'L hat magnitude', 'L hat phase');
% end
