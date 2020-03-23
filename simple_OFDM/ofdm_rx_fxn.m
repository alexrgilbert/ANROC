

function [y_bb_us,y_bb_hp,y_bb,detected_syms,r, H_hat_avg, L_hat_avg, L]= ofdm_rx_fxn(y, p, d)

    [x_stf,x_ltf] = gt_training_fields(p.x_stf_len,p.x_ltf_len,p.delta_fs,p.symbol_time);

    % num_data_carriers = (num_carriers-num_dead_carriers-num_pilots);
    % packet_length = (x_stf_len + x_ltf_len + (num_symbols_per_packet * (num_carriers + num_prefix))) * us_rate;
    % train_packet_length = (x_stf_len + x_ltf_len) * us_rate;
    % packet_data_syms_length = (num_symbols_per_packet * num_data_carriers);
    % packet_data_bits_length = packet_data_syms_length * max(log2(M),1);
    %
    % len_bits = length(bits);
    %
    % num_symbols = ceil ( len_bits /  (num_data_carriers*max(log2(M),1)) );
    % num_packets = ceil ( num_symbols /  num_symbols_per_packet );

    if p.upconvert == true
        [y_bb_us,y_bb_hp] = downconvert(y, p.Fc, p.RX_Fs, p.BW);
    else
        y_bb_us = y; y_bb_hp = y;
    end

    y_bb = downsample(y_bb_us, p.ds_rate);

    [detected_syms,r] = packet_detection_fxn(x_stf(1:(p.x_stf_len/10)), y_bb, (p.x_stf_len + p.x_ltf_len - 5),p.detection_peaks);
    detected_syms_idcs = find(detected_syms);
    num_detected = length(detected_syms_idcs);

    H_hat_avg = zeros(1,p.ltf_subchannels);
    L_hat_avg = zeros(1,p.ltf_subchannels);
    for i = 1:num_detected
        ltf_start_idx = detected_syms_idcs(i) + p.x_stf_len;
        ltf_end_idx = ltf_start_idx + p.x_ltf_len - 1;
        y_ltf = y_bb(ltf_start_idx:ltf_end_idx);

        [H_hat,L_hat,L] = channel_estimator_fxn(p.delta_fs,p.symbol_time,x_ltf,y_ltf);

        % if i < 25
        %     figure;
        %     legend_strs = {};
        %     xlabel('Frequency (delta_fs)');
        %     stem(1:1:length(H_hat),abs(H_hat),'c'); legend_strs{end+1} = 'H Estimated Magnitude';
        %     hold on;
        %     if d.sim == true
        %         stem(1:1:length(d.H),abs(d.H),'r'); legend_strs{end+1} = 'H GT Magnitude';
        %     end
        %     stem(1:1:length(L_hat),abs(L_hat),'b'); legend_strs{end+1} = 'L Estimated Magnitude';
        %     stem(1:1:length(L),abs(L),'m'); legend_strs{end+1} = 'L GT Magnitude';
        %     legend(legend_strs);
        %      title('Channel Estimate vs Actual Phase');
        %
        %      figure;
        %      legend_strs = {};
        %      xlabel('Frequency (delta_fs)');
        %      stem(1:1:length(H_hat),angle(H_hat),'g'); legend_strs{end+1} = 'H Estimated Phase';
        %      hold on;
        %      if d.sim == true
        %          stem(1:1:length(d.H),angle(d.H),'y'); legend_strs{end+1} = 'H GT Phase';
        %      end
        %      stem(1:1:length(L_hat),angle(L_hat),'k'); legend_strs{end+1} = 'L Estimated Phase';
        %      stem(1:1:length(L),angle(L),'r'); legend_strs{end+1} = 'L GT Phase';
        %      legend(legend_strs);
        %       title('Channel Estimate vs Actual Phase');
        % end

        H_hat_avg = H_hat_avg + (H_hat / num_detected);
        L_hat_avg = L_hat_avg + (L_hat / num_detected);
    end



end

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