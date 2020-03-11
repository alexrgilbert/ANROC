function ofdm_proc_fxn(bits_gt, syms_gt, ints_gt, signal_bb, signal_bb_ds, signal,...
        detected_syms_gt, detected_syms_gt_ds, y, y_bb_us, y_bb_hp, y_bb,...
         detected_syms, H_hat_avg, L_hat_avg, L, H_hat_pilot,syms_eq,bits,ints,...
          r, p, d)


     addpath('../helpers');

    num_data_carriers = (p.num_carriers-p.num_dead_carriers-p.num_pilots);
    packet_length = (p.x_stf_len + p.x_ltf_len + (p.num_symbols_per_packet * (p.num_carriers + p.num_prefix))) * p.us_rate;
    train_packet_length = (p.x_stf_len + p.x_ltf_len) * p.us_rate;
    packet_data_syms_length = (p.num_symbols_per_packet * num_data_carriers);
    packet_data_bits_length = packet_data_syms_length * max(log2(p.M),1);

    len_bits = p.num_packets*packet_data_bits_length;

    num_symbols = ceil ( len_bits /  (num_data_carriers*max(log2(p.M),1)) );
    num_packets = ceil ( num_symbols /  p.num_symbols_per_packet );

    if p.plot_spectrum == true
        x_bb = downsample(signal_bb(1,1:end), p.ds_rate);
        % figure;subplot(3,2,1);periodogram(x_bb,[],length(x_bb),p.BW,'centered');title('Pre-TX: Baseband Downsampled (Post-Proc) Signal Spectrum');
        figure;
        if p.plot_separate == false
            subplot(3,2,1:2);
        end;
        periodogram(signal_bb_ds,[],length(signal_bb_ds),p.BW,'centered');title('Pre-TX: Baseband Downsampled Signal Spectrum');
        if p.plot_separate == true
            figure;
        else
            subplot(3,2,3:4);
        end
        periodogram(signal_bb,[],length(signal_bb),p.TX_Fs,'centered'); title('Pre-TX: Baseband Upsampled Signal Spectrum');
        if p.plot_separate == true
            figure;
        else
            subplot(3,2,5:6);
        end
        periodogram(signal,[],length(signal),p.TX_Fs,'centered'); title('Pre-TX: Upconverted Signal Spectrum');
        figure;
        if p.plot_separate == false
            subplot(3,2,1:2);
        end
        periodogram(y,[],length(y),p.TX_Fs,'centered');title('Post-RX: Upconverted Unfiltered Upsampled Signal Spectrum');
        if p.plot_separate == true
            figure;
        else
            subplot(3,2,3);
        end
        periodogram(y_bb_hp,[],length(y_bb_hp),p.TX_Fs,'centered');title('Post-RX: Baseband Unfiltered Upsampled Signal Spectrum');
        if p.plot_separate == true
            figure;
        else
            subplot(3,2,4);
        end
        periodogram(y_bb_us,[],length(y_bb_us),p.TX_Fs,'centered');title('Post-RX: Baseband Filtered Upsampled Signal Spectrum');
        if p.plot_separate == true
            figure;
        else
            subplot(3,2,5:6);
        end
         periodogram(y_bb,[],length(y_bb),p.BW,'centered');title('Post-RX: Baseband Filtered Downsampled Signal Spectrum');
    end

    if p.plot_signal == true
        x_bb = downsample(signal_bb(1,1:end), p.ds_rate);
%         figure;subplot(3,2,1);plot(make_time_axis(x_bb,p.BW),abs(x_bb));title('Pre-TX: Baseband Downsampled (Post-Proc) Signal Magnitude');
        figure;
        if p.plot_separate == false
            subplot(3,2,1:2);
        end
        plot(make_time_axis(signal_bb_ds,p.BW),abs(signal_bb_ds));title('Pre-TX: Baseband Downsampled Signal Magnitude');
        if p.plot_separate == true
            figure;
        else
            subplot(3,2,3:4);
        end
        plot(make_time_axis(signal_bb,p.TX_Fs),abs(signal_bb)); title('Pre-TX: Baseband Upsampled Signal Magnitude');
        if p.plot_separate == true
            figure;
        else
            subplot(3,2,5:6);
        end
        plot(make_time_axis(signal,p.TX_Fs),signal); title('Pre-TX: Upconverted Signal');

        figure;
        if p.plot_separate == false
            subplot(3,2,1:2);
        end
        ta_y = make_time_axis(y,p.RX_Fs);
        plot(ta_y(100:end),abs(y(100:end)));title('Post-RX: Upconverted Unfiltered Upsampled Signal Magnitude');
        if p.plot_separate == true
            figure;
        else
            subplot(3,2,3);
        end
        ta_y_bb_hp = make_time_axis(y_bb_hp,p.RX_Fs);
        plot(ta_y_bb_hp(100:end),real(y_bb_hp(100:end)));title('Post-RX: Baseband Unfiltered Upsampled Signal Magnitude');
        if p.plot_separate == true
            figure;
        else
            subplot(3,2,4);
        end
        ta_y_bb_us = make_time_axis(y_bb_us,p.RX_Fs);
        plot(ta_y_bb_us(100:end),imag(y_bb_us(100:end)));title('Post-RX: Baseband Filtered Upsampled Signal Magnitude');
        if p.plot_separate == true
            figure;
        else
            subplot(3,2,5:6);
        end
        ta_y_bb = make_time_axis(y_bb,p.BW);
        plot(ta_y_bb(100:end),abs(y_bb(100:end)));title('Post-RX: Baseband Filtered Downsampled Signal Magnitude');
    end

    if p.plot_comparison == true
        start_idcs_ds = find(detected_syms);
        start_idx_ds = max(1,-100+start_idcs_ds(1));
        end_idx_ds = start_idcs_ds(end) + (packet_length / p.us_rate) - 1;
        idx_len_ds = end_idx_ds - start_idx_ds;

        start_idx = ceil((start_idx_ds-1) * p.us_rate)+1;
        end_idx = ceil((end_idx_ds-1) * p.us_rate)+1;
        idx_len = end_idx - start_idx;

        start_idcs_gt = find(detected_syms_gt);
        start_idx_gt = max(1,-100+start_idcs_gt(1));
        end_idx_gt = start_idcs_gt(end) + (packet_length) - 1;
        idx_len_gt = end_idx_gt - start_idx_gt;

        start_idcs_gt_ds = find(detected_syms_gt_ds);
        start_idx_gt_ds = max(1,-100+start_idcs_gt_ds(1));
        end_idx_gt_ds = start_idcs_gt_ds(end) + (packet_length / p.us_rate) - 1;
        idx_len_gt_ds = end_idx_gt_ds - start_idx_gt_ds;

        figure;
        max_len = max(idx_len_gt,idx_len);
        signal_ta = make_time_axis(signal,p.TX_Fs);
        plot(signal_ta(start_idx_gt:min(start_idx_gt+max_len,length(signal_ta)))-signal_ta(start_idx_gt),abs(signal(start_idx_gt:min(start_idx_gt+max_len,length(signal)))));
        hold on;
        y_ta = make_time_axis(y,p.RX_Fs);
        plot(y_ta(start_idx:min(start_idx+max_len,length(y_ta)))-y_ta(start_idx),abs(y(start_idx:min(start_idx+max_len,length(y)))));
        legend('Pre-TX Magnitude', 'Post-RX Magnitude');
        title('Effect of Channel in Time (upsampled upconverted)');

        figure;
        max_len = max(idx_len_gt_ds,idx_len_ds);
        signal_bb_ds_ta = make_time_axis(signal_bb_ds,p.BW);
        signal_bb_ds_normalized = signal_bb_ds / max(signal_bb_ds,[],'all');
        plot(signal_bb_ds_ta(start_idx_gt_ds:min(start_idx_gt_ds+max_len,length(signal_bb_ds_ta)))-signal_bb_ds_ta(start_idx_gt_ds),abs(signal_bb_ds_normalized(start_idx_gt_ds:min(start_idx_gt_ds+max_len,length(signal_bb_ds)))));
        hold on;
        y_bb_ta = make_time_axis(y_bb,p.BW);
        y_bb_normalized = y_bb / max(y_bb,[],'all');
        plot(y_bb_ta(start_idx_ds:min(start_idx_ds+max_len,length(y_bb_ta)))-y_bb_ta(start_idx_ds),abs(y_bb_normalized(start_idx_ds:min(start_idx_ds+max_len,length(y_bb)))));
        r_ta = make_time_axis(r,p.BW);
        r_normalized = r / max(r,[],'all');
        plot(r_ta(start_idx_ds:min(start_idx_ds+max_len,length(r_ta)))-r_ta(start_idx_ds),r_normalized(start_idx_ds:min(start_idx_ds+max_len,length(r_normalized))));
        stem(r_ta(start_idx_ds:min(start_idx_ds+max_len,length(r_ta)))-r_ta(start_idx_ds),detected_syms(start_idx_ds:min(start_idx_ds+max_len,length(detected_syms))));
        legend('Pre-TX', 'Post-RX','Correlation','Detections');
        title('Effect of Channel in Time + Correlation (downconverted downsampled)');
    end

    if p.print_detection == true
        start_idcs_ds = find(detected_syms);
        start_idcs_ds = start_idcs_ds - start_idcs_ds(1);
        start_idcs_gt_ds = find(detected_syms_gt_ds);
        start_idcs_gt_ds = start_idcs_gt_ds - start_idcs_gt_ds(1);
        if (length(start_idcs_ds) == length(start_idcs_gt_ds))
            start_idcs_ds-start_idcs_gt_ds
            start_idcs_ds
            start_idcs_gt_ds

        else
            min_length = min(length(start_idcs_ds),length(start_idcs_gt_ds));
            start_idcs_ds(1:min_length)-start_idcs_gt_ds(1:min_length)
            start_idcs_ds
            start_idcs_gt_ds
        end

    end

    if p.plot_channel_estimation == true
        figure;
        subplot(2,2,1);
        legend_strs = {};
        xlabel('Frequency (delta_fs)');
        stem(1:1:length(H_hat_avg),abs(H_hat_avg),'c','*'); legend_strs{end+1} = 'H Estimated Mag';
        hold on;
        if d.sim == true
            stem(1:1:length(d.H),abs(d.H),'r'); legend_strs{end+1} = 'H GT Mag';
        end
        if p.plot_pilot_est == true
            stem(1:1:length(H_hat_pilot),abs(H_hat_pilot),'k','*'); legend_strs{end+1} = 'H Pilot Estimated Mag';
        end
        if p.plot_L == true
            stem(1:1:length(L_hat_avg),abs(L_hat_avg),'b','*'); legend_strs{end+1} = 'L Estimated Mag';
            stem(1:1:length(L),abs(L),'m'); legend_strs{end+1} = 'L GT Mag';
        end
        legend(legend_strs);
         title('Average Channel Estimate vs Actual Magnitude');

         subplot(2,2,2);
         legend_strs = {};
         xlabel('Frequency (delta_fs)');
         stem(1:1:length(H_hat_avg),angle(H_hat_avg),'g','*'); legend_strs{end+1} = 'H Estimated Phase';
         hold on;
         if d.sim == true
             stem(1:1:length(d.H),angle(d.H),'y'); legend_strs{end+1} = 'H GT Phase';
         end
         if p.plot_pilot_est == true
             stem(1:1:length(H_hat_pilot),angle(H_hat_pilot),'c','*'); legend_strs{end+1} = 'H Pilot Estimated Phase';
         end
         if p.plot_L == true
             stem(1:1:length(L_hat_avg),angle(L_hat_avg),'k','*'); legend_strs{end+1} = 'L Estimated Phase';
             stem(1:1:length(L),angle(L),'r'); legend_strs{end+1} = 'L GT Phase';
         end
         legend(legend_strs);
          title('Average Channel Estimate vs Actual Phase');

          subplot(2,2,3);
          legend_strs = {};
          xlabel('Frequency (delta_fs)');
          stem(1:1:length(H_hat_avg),real(H_hat_avg),'c','*'); legend_strs{end+1} = 'H Estimated Real';
          hold on;
          if d.sim == true
              stem(1:1:length(d.H),real(d.H),'r'); legend_strs{end+1} = 'H GT Real';
          end
          if p.plot_pilot_est == true
              stem(1:1:length(H_hat_pilot),real(H_hat_pilot),'k','*'); legend_strs{end+1} = 'H Pilot Estimated Real';
          end
          if p.plot_L == true
              stem(1:1:length(L_hat_avg),real(L_hat_avg),'b','*'); legend_strs{end+1} = 'L Estimated Real';
              stem(1:1:length(L),real(L),'m'); legend_strs{end+1} = 'L GT Real';
          end
          legend(legend_strs);
           title('Average Channel Estimate vs Actual Real');

           subplot(2,2,4);
           legend_strs = {};
           xlabel('Frequency (delta_fs)');
           stem(1:1:length(H_hat_avg),imag(H_hat_avg),'g','*'); legend_strs{end+1} = 'H Estimated Imaginary';
           hold on;
           if d.sim == true
               stem(1:1:length(d.H),imag(d.H),'y'); legend_strs{end+1} = 'H GT Imaginary';
           end
           if p.plot_pilot_est == true
               stem(1:1:length(H_hat_pilot),imag(H_hat_pilot),'c','*'); legend_strs{end+1} = 'H Pilot Estimated Imaginary';
           end
           if p.plot_L == true
               stem(1:1:length(L_hat_avg),imag(L_hat_avg),'k','*'); legend_strs{end+1} = 'L Estimated Imaginary';
               stem(1:1:length(L),imag(L),'r'); legend_strs{end+1} = 'L GT Imaginary';
           end
           legend(legend_strs);
            title('Average Channel Estimate vs Actual Imaginary');
    end

    if p.plot_data == true

        min_length = min(length(bits_gt),length(bits));
        BER = sum((bits_gt(1:min_length) ~= bits(1:min_length)))/min_length;
        BLER = sum((ints_gt(1:min_length) ~= ints(1:min_length)))/min_length;

        errors = ((ints_gt(1:min_length) ~= ints(1:min_length)));
        gt_ones = (ints_gt(1:min_length) == 1);
        gt_zeros = (ints_gt(1:min_length) == 0);

        figure;
        subplot(2,2,1);
        legend_strs = {};
        refpts = complex(qammod((0:(p.M-1))',p.M,'gray','InputType','int','UnitAveragePower',true'));
        plot(syms_eq,'bo'); legend_strs{end+1} = 'Est Syms';
        hold on;
        plot(complex(syms_gt),'go'); legend_strs{end+1} = 'GT Syms';
        plot(refpts,'r*'); legend_strs{end+1} = 'Refpts';
        xlabel('In-Phase');
        ylabel('Quadrature');
        legend(legend_strs);
        title('Received Data');

        subplot(2,2,2);
        legend_strs = {};
        refpts = complex(qammod((0:(p.M-1))',p.M,'gray','InputType','int','UnitAveragePower',true'));
        plot(syms_eq(errors),'bo'); legend_strs{end+1} = 'Est Syms';
        hold on;
        plot(complex(syms_gt),'go'); legend_strs{end+1} = 'GT Syms';
        plot(refpts,'r*'); legend_strs{end+1} = 'Refpts';
        xlabel('In-Phase');
        ylabel('Quadrature');
        legend(legend_strs);
        title('Errors');


        subplot(2,2,3);
        legend_strs = {};
        refpts = complex(qammod(((p.M-1)),p.M,'gray','InputType','int','UnitAveragePower',true'));
        plot(syms_eq(gt_ones),'bo'); legend_strs{end+1} = 'Est Syms';
        hold on;
        plot(complex(syms_gt),'go'); legend_strs{end+1} = 'GT Syms';
        plot(refpts,'r*'); legend_strs{end+1} = 'Refpts';
        xlabel('In-Phase');
        ylabel('Quadrature');
        legend(legend_strs);
        title('GT Ones');


        subplot(2,2,4);
        legend_strs = {};
        refpts = complex(qammod((0),p.M,'gray','InputType','int','UnitAveragePower',true'));
        plot(syms_eq(gt_zeros),'bo'); legend_strs{end+1} = 'Est Syms';
        hold on;
        plot(complex(syms_gt),'go'); legend_strs{end+1} = 'GT Syms';
        plot(refpts,'r*'); legend_strs{end+1} = 'Refpts';
        xlabel('In-Phase');
        ylabel('Quadrature');
        legend(legend_strs);
        title('GT Zeros');


        disp(strcat('BER = ',num2str(BER),' BLER = ',num2str(BLER)));
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
