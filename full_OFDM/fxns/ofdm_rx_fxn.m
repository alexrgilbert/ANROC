

function [y_bb_us,y_bb_hp,y_bb,detected_syms,r, H_hat_avg, L_hat_avg, L,H_hat_pilot,syms_eq,bits,ints]= ofdm_rx_fxn(y, p, d)

    addpath('../helpers');

    [x_stf,x_ltf] = gt_training_fields(p.x_stf_len,p.x_ltf_len,p.delta_fs,p.symbol_time);
    data_length = (p.num_symbols_per_packet * (p.num_carriers + p.num_prefix));
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
        [y_bb_us,y_bb_hp] = downconvert(y, p.Fc, p.RX_Fs, p.BW,p.filter_complex);
    else
        y_bb_us = y; y_bb_hp = y;
    end

    y_bb = downsample(y_bb_us, p.ds_rate);

    [detected_syms,r] = packet_detection_fxn(x_stf(1:(p.x_stf_len/10)), y_bb, (p.x_stf_len + p.x_ltf_len - 5),p.detection_peaks,p.thresh_factor);
    detected_syms_idcs = find(detected_syms);
    num_detected = length(detected_syms_idcs);

    H_hat_avg = zeros(1,p.ltf_subchannels);
    L_hat_avg = zeros(1,p.ltf_subchannels);
    L = zeros(1,p.ltf_subchannels);
    pilots = [];
    syms = [];
    ltfs = [];
    stfs = [];
    freq_offset_avg = 0;
    for i = 1:num_detected
        stf_start_idx = detected_syms_idcs(i);
        stf_end_idx = stf_start_idx + p.x_stf_len - 1;

        m_range = (2 * p.fto_range) + 1;
        course_start_idx = stf_start_idx - p.fto_range;
        course_end_idx = stf_end_idx + p.fto_range + 1;
        if ((stf_start_idx - p.fto_range) < 1)
            course_start_idx = 1;
            m_range = m_range + (stf_start_idx - (p.fto_range+1));
        end


        shift_stf = 0;
        for stf_est = 1:9
            y_stf_course = y_bb(course_start_idx:course_end_idx);
            shift_stf = shift_stf + fine_timing_estimation_fxn(y_stf_course,(p.x_stf_len/10),(p.x_stf_len/10),m_range,p.symbol_time);
            course_start_idx = course_start_idx + (p.x_stf_len/10);
        end
        shift_stf = shift_stf / 10

        ltf_start_idx = detected_syms_idcs(i) + p.x_stf_len;
        ltf_end_idx = ltf_start_idx + p.x_ltf_len - 1;
        course_start_idx = (2*p.num_prefix) + ltf_start_idx - p.fto_range;
        course_end_idx = ltf_end_idx + p.fto_range + 1;
        if ((ltf_end_idx + p.fto_range) > length(y_bb))
            course_end_idx = length(y_bb);
            m_range = m_range + (length(y_bb) - (ltf_start_idx + p.fto_range));
        end
        y_ltf_course = y_bb(course_start_idx:course_end_idx);
        shift_ltf = fine_timing_estimation_fxn(y_ltf_course,p.num_carriers,p.num_carriers,m_range,p.symbol_time)

        shift_data = 0;
        num_fields = 2;
        if i > p.num_train_packets

            num_fields = num_fields + 1;

            data_start_idx = detected_syms_idcs(i) + p.x_stf_len + p.x_ltf_len;
            data_end_idx = data_start_idx + data_length - 1;
            course_start_idx = data_start_idx - p.fto_range;
            course_end_idx = data_end_idx + p.fto_range + 1;

            if ((data_end_idx + p.fto_range) > length(y_bb))
                course_end_idx = length(y_bb);
                m_range = m_range + (length(y_bb) - (data_start_idx + p.fto_range))
            end


            for data_est = 1:(p.num_symbols_per_packet-1)
                y_data_course = y_bb(course_start_idx:course_end_idx);
                shift_data = shift_data + fine_timing_estimation_fxn(y_data_course,p.num_prefix,p.num_carriers,m_range,p.symbol_time);
                course_start_idx = course_start_idx + (p.num_carriers+p.num_prefix);
            end
            shift_data = shift_data / p.num_symbols_per_packet

        end

        shift = (shift_data + shift_stf + shift_ltf) / num_fields

        y_stf = y_bb(stf_start_idx+shift:stf_end_idx+shift);

        stfs = [stfs; y_stf];

        %%%TODO:FREQUENCY OFFSET ESTIMATION
        % [freq_offset] = frequency_offset_estimator_fxn(y,k,N,symbol_time)

        ltf_start_idx = detected_syms_idcs(i) + p.x_stf_len;
        ltf_end_idx = ltf_start_idx + p.x_ltf_len - 1;
        y_ltf = y_bb(ltf_start_idx+shift:ltf_end_idx+shift);

        ltfs = [ltfs; y_ltf];

        [H_hat,L_hat,L] = channel_estimator_fxn(p.delta_fs,p.symbol_time,x_ltf,y_ltf,p.num_carriers,p.num_dead_carriers);

        if i > p.num_train_packets

            data_start_idx = detected_syms_idcs(i) + p.x_stf_len + p.x_ltf_len;
            data_end_idx = data_start_idx + data_length - 1;
            diff = data_end_idx + shift - length(y_bb);
            if diff > 0
                y_bb = [y_bb zeros(1,diff)];
            end
            data = y_bb(data_start_idx+shift:data_end_idx+shift);
            [pilots_packet,syms_packet] =extract_data_fxn(data,p.num_symbols_per_packet,p.num_carriers,...
                                        p.num_prefix,p.num_dead_carriers,p.num_pilots,p.M,p.pilot_idcs,p.dead_idcs);

            pilots = [pilots; pilots_packet];
            syms = [syms syms_packet];
        end

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


    H_hat_pilot = channel_estimator_pilots_fxn(pilots,p.num_carriers,p.pilot,p.pilot_idcs);

    noise_var = noise_estimator_fxn(stfs,ltfs);

%     noise_var = noise_var_est

%     noise_var = 10.^(-200/10);
    [syms_eq,bits,ints] = decode_data_fxn(syms,num_detected-p.num_train_packets,p.num_symbols_per_packet,p.num_carriers,...
                                                        p.num_pilots,p.num_dead_carriers,H_hat_avg,noise_var,p.M,p.pilot_idcs,p.dead_idcs);

%     [syms_eq,bits,ints,~] = decode_data_hw(y_bb,p.x_stf_len,p.x_ltf_len,p.num_prefix,p.num_carriers,p.num_symbols_per_packet,d.H,200,p.M);





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
