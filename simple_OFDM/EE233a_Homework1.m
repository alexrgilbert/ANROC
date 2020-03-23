clc;
clear;
close all;

plot_signal_flag = false;

% SNRs = 0:2:20;
% trials = 1:1000;
% p_detected = zeros(1,   length(SNRs));
% mod = 4;
% h = [1];
% freq_offset = 0;
% [x,~,~,~,~,~,~] = packet_generator_with_gt(mod);
% z_stf = x(1,1:16);
% for SNR = SNRs
%     detected = 0;
%     for trial = trials
%
% %         [x,~,~,~,~,~,~] = packet_generator_with_gt(mod);
% %         z_stf = x(1,1:16);
%         if plot_signal_flag
%             if (trial == 1) && (SNR == 20)
%                 figure; plot(1:1:length(x(1,1:160)),abs(x(1,1:160)));title('GT STF Mag');
%                 figure; plot(1:1:length(x(1,1:160)),angle(x(1,1:160)));title('GT STF Phase');
%             end
%         end
%
%         y = channel(x, h, freq_offset, SNR);
%
%         if plot_signal_flag
%             if (trial == 1) && (SNR == 20)
%                 figure; plot(1:1:160,abs(y(1,1:160)));title('Detected STF Mag');
%                 figure; plot(1:1:160,angle(y(1,1:160)));title('Detected STF Phase');
%             end
%         end
%
%         detected = detected + packet_detection_og(z_stf, y);
%     end
%     p_detected((SNR/2) + 1) = detected / length(trials);
% end
% figure;
% plot(SNRs, p_detected);
% title('Detection Prob');
%
% SNRs = 0:2:20;
% trials = 1:1000;
% offsets = zeros(1,length(SNRs));
% mod = 4;
% h = [1];
% freq_offset = 30e3;
% [x,~,~,~,~,~,~] = packet_generator_with_gt(mod);
% stf = x(1,1:160);
% for SNR = SNRs
%     freq_offset_err_rms = 0;
%     for trial = trials
%
% %         [x,~,~,~,~,~,~] = packet_generator_with_gt(mod);
% %         stf = x(1,1:160);
%         if plot_signal_flag
%             if (trial == 1) && (SNR == 20)
%                 figure; plot(1:1:length(x(1,1:160)),abs(x(1,1:160)));title('GT STF Mag');
%                 figure; plot(1:1:length(x(1,1:160)),angle(x(1,1:160)));title('GT STF Phase');
%             end
%         end
%
%         y = channel(x, h, freq_offset, SNR);
%         if plot_signal_flag
%             if (trial == 1) && (SNR == 20)
%                 figure; plot(1:1:160,abs(y(1,1:160)));title('Detected STF Mag');
%                 figure; plot(1:1:160,angle(y(1,1:160)));title('Detected STF Phase');
%             end
%         end
%
%         freq_offset_err_rms = freq_offset_err_rms + (((frequency_offset_estimator(stf, y)/1e3) - (freq_offset/1e3))^2);
%     end
%     freq_offset_err_rms = sqrt( freq_offset_err_rms / length(trials));
%     offsets((SNR/2) + 1) = freq_offset_err_rms;
% end
% figure;
% plot(SNRs, offsets);
% title('Freq Offset RMS');

SNRs = 0:2:20;
trials = 1:20;%1000;
est_errs = zeros(length(SNRs),64);
est_avg_20_errs = zeros(length(SNRs),64);
est_avg_errs = zeros(length(SNRs),64);
block_errs = zeros(1,length(SNRs));
bit_errs = zeros(1,length(SNRs));
mod = 2;
h = [1,0.7,0.5];
h = h/vecnorm(h);
H = fft(h, 64);
H_og = fft([1],64);
% figure;
% plot(abs(H)); hold on;
% title('Channel FFT');
freq_offset = 0;
[x,bits_og,syms_og,num_carriers,prefix_len,num_ofdmsymbols,ltf_len,stf_len] = packet_generator_with_gt(mod);


for SNR = SNRs
    channel_est_err = zeros(1,64);
    channel_est_avg = complex(zeros(1,64),...
                        zeros(1,64));
    channel_est_avg_20 = complex(zeros(1,64),...
                        zeros(1,64));
    for trial = trials

%         [x,syms,num_carriers,prefix_len,num_ofdmsymbols,ltf_len,stf_len] = packet_generator_with_gt(mod);
        if plot_signal_flag
            if (trial == 1) && (SNR == 20)
                figure; plot(1:1:length(ltf_full),abs(ltf_full));title('GT STF Mag');
                figure; plot(1:1:length(ltf_full),angle(ltf_full));title('GT STF Phase');
            end
        end

        y = channel(x, h, freq_offset, SNR, 50e-9);

        if plot_signal_flag
            if (trial == 1) && (SNR == 20)
                figure; plot(1:1:160,abs(ltf_full));title('Detected STF Mag');
                figure; plot(1:1:160,angle(ltf_full));title('Detected STF Phase');
            end
        end

        [H_hat,L_hat,L,ltf_inv,L_og] = channel_estimator_hw(SNR,x,y);

        if (trial == 1) && ((SNR == 20) || (SNR == 5))%100))
            figure;
            xlabel('Frequency (delta_fs)');
            stem(1:1:length(H),abs(H),'r');
            hold on;
            stem(1:1:length(H_hat),abs(H_hat),'c');
            stem(1:1:length(L_hat),abs(L_hat),'m');
            stem(1:1:length(L),abs(L),'b');
            legend('Actual Magnitude','Estimated Magnitude', ...
                        'L hat Magnitude', 'L Magnitude');
            title('Channel Estimate vs Actual Magnitude');
        end

        if (trial == 1) && ((SNR == 20) || (SNR == 5))%100))
            figure;
            xlabel('Frequency (delta_fs)');
            stem(1:1:length(H),angle(H),'r');
            hold on;
            stem(1:1:length(H_hat),angle(H_hat),'c');
            stem(1:1:length(L_hat),angle(L_hat),'m');
            stem(1:1:length(L),angle(L),'b');
            legend('Actual Phase','Estimated Phase', ...
                        'L hat Phase', 'L Phase');
            title('Channel Estimate vs Actual Phase');
        end

        channel_est_err = channel_est_err + ((((abs(H_hat - H)).^2)./((abs(H)).^2))/length(trials));
        if (trial <= 20)
            channel_est_avg_20 = channel_est_avg_20 + ( H_hat / 20 );
        end
        channel_est_avg = channel_est_avg + ( H_hat / length(trials) );

    end

    channel_est_avg_20_err = (((abs(channel_est_avg_20 - H)).^2)./((abs(H)).^2));
    channel_est_avg_err = (((abs(channel_est_avg - H)).^2)./((abs(H)).^2));
    est_errs((SNR/2)+1,:) = channel_est_err;
    est_avg_errs((SNR/2)+1,:) = channel_est_avg_err;
    est_avg_20_errs((SNR/2)+1,:) = channel_est_avg_20_err;

    [syms,bits,ints,syms_array] = decode_data_hw(x,stf_len,ltf_len,prefix_len,num_carriers,num_ofdmsymbols,H_og,SNR,mod);
    [syms_hat,bits_hat,ints_hat,syms_array_hat] = decode_data_hw(y,stf_len,ltf_len,prefix_len,num_carriers,num_ofdmsymbols,H,SNR,mod);
    [syms_hat_est_20,bits_hat_est_20,ints_hat_est_20,syms_array_est_20] = decode_data_hw(y,stf_len,ltf_len,prefix_len,num_carriers,num_ofdmsymbols,H_hat,SNR,mod);
    [syms_hat_est_all,bits_hat_est_all,ints_hat_est_all,syms_array_est_all] = decode_data_hw(y,stf_len,ltf_len,prefix_len,num_carriers,num_ofdmsymbols,H_hat,SNR,mod);

    bit_errs((SNR/2)+1) = (sum(bits_hat_est_all ~= bits_og)/length(bits_og));

end

figure;
plot(est_errs);
title('Channel Estimation Errors');

figure;
plot(est_avg_20_errs); hold on;
plot(est_avg_errs);
xticks(SNRs)
legend('20 trials','All trials')
title('Channel Estimation Avg Errors');

figure;
xlabel('Frequency (delta_fs)');
stem(1:1:length(H),abs(H),'r');
hold on;
stem(1:1:length(channel_est_avg),abs(channel_est_avg),'c');
stem(1:1:length(H),angle(H),'y');
stem(1:1:length(channel_est_avg),angle(channel_est_avg),'g');
legend('Actual Magnitude','Estimated Magnitude', ...
         'Actual Phase', 'Estimated Phase');
title('Channel Estimate Avg All Trials vs Actual');

figure;
xlabel('Frequency (delta_fs)');
stem(1:1:length(H),abs(H),'r');
hold on;
stem(1:1:length(channel_est_avg_20),abs(channel_est_avg_20),'c');
stem(1:1:length(H),angle(H),'y');
stem(1:1:length(channel_est_avg_20),angle(channel_est_avg_20),'g');
legend('Actual Magnitude','Estimated Magnitude', ...
         'Actual Phase', 'Estimated Phase');
title('Channel Estimate Avg 20 vs Actual');


% if (trial == 1) && ((SNR == 20) || (SNR == 5))%100))
%                 errors = (bits_hat_est ~= bits_og);
errors = (ints == 0);%logical(ones(size(syms)));
figure;
refpts = complex(qammod((0:(mod-1))',mod,'gray','UnitAveragePower',true));
plot(syms(errors),'go','LineWidth',6);
hold on;
plot(syms_hat(errors),'c*','LineWidth',6);
%                 plot(syms_hat_est(errors),'b*','LineWidth',6);
plot(refpts,'r.');
text(real(refpts)+0.1,imag(refpts),num2str((0:mod-1)'))
xlabel('In-Phase');
ylabel('Quadrature');
title('Generated Data');
legend('syms','syms_hat','refpts', ...
'Reference constellation','location','w');

%                 figure;
%                 sym1 = syms_array(1,:);
%                 plot(abs((sym1)).^2);
% end

figure;
plot(SNRs,bit_errs);

% % mod = 4;
% % x = packet_generator(mod);
% % h = [1, .3, .2];tit
% % H  = fft(h,64);
% % freq_offset = 0;
% % error_10s = zeros(1,length(0:2:20));
% % error_22s = zeros(1,length(0:2:20));
% % Hhat_10s = zeros(1,length(0:2:20));
% % Hhat_22s = zeros(1,length(0:2:20));
% % for SNR = 0:2:20
% %     error_10 = 0;
% %     error_22 = 0;
% %     Hhat_10 = 0;
% %     Hhat_22 = 0;
% %     for trial = 1:1000
% %         H_hat_10 = channel_estimator(SNR, x, h, freq_offset,10);
% %         H_hat_22 = channel_estimator(SNR, x, h, freq_offset,22);
% %         Hhat_10 = Hhat_10 + H_hat_10;
% %         Hhat_22 = Hhat_22 + H_hat_22;
% %         error_10 = error_10 + (abs(H(10)-H_hat_10)^2)/(abs(H(10))^2);
% %         error_22 = error_22 + (abs(H(22)-H_hat_22)^2)/(abs(H(22))^2);
% %     end
% %     error_10s((SNR/2) + 1) = error_10 / 1000;
% %     error_22s((SNR/2) + 1) = error_22 / 1000;
% %     Hhat_10s((SNR/2) + 1) = Hhat_10 / 1000;
% %     Hhat_22s((SNR/2) + 1) = Hhat_22 / 1000;
% % end
% %
% % figure;
% % plot(0:2:20, error_10s);
% % hold on;
% % plot(0:2:20, error_22s);
% % legend('10th Carrier','22nd Carrier');
% %
% % figure;
% % plot(1:1:length(H),abs(H));
%
%
% M = 4;
% h = [1];%[1, .3, .2];
% H  = fft(h,64);
% freq_offset = 0;
%
% for SNR = [1e6]%0:2:20
% %     for trial = 1
%         [x,syms,num_carriers,prefix_len,num_syms,ltf_len,stf_len] = packet_generator_with_gt(M);
%
%         figure;
%         refpts = qammod((0:(M-1))',M,'gray','UnitAveragePower',true);
%         plot(syms,'co','LineWidth',6);
%         hold on;
%         plot(refpts,'r*');
%     %         text(real(refpts)+0.1,imag(refpts),num2str((0:3)'))
%         xlabel('In-Phase');
%         ylabel('Quadrature');
%         title('Generated Data');
%         legend('syms','refpts', ...
%             'Reference constellation','location','w');
%
%         y = channel(x, h, freq_offset, SNR);
%
%         H_hat = full_channel_estimator_signal_input(y);
%
%         figure;
%         xlabel('Frequency (delta_fs)');
%         title('Channel Estimate vs Actual');
%         plot(1:1:length(H),abs(H),'r');
%         hold on;
%         plot(1:1:length(H_hat),abs(H_hat),'c');
%         plot(1:1:length(H),angle(H),'y');
%         plot(1:1:length(H_hat),angle(H_hat),'g');
%         legend('Actual Magnitude','Estimated Magnitude', ...
%             'Actual Phase', 'Estimated Phase');
%
%         rx_data = extract_data(y,stf_len,ltf_len,prefix_len,num_carriers,num_syms);
%
%         figure;
%         refpts = qammod((0:(M-1))',M,'gray','UnitAveragePower',true);
%         expected_rx_data = syms;
%         for ofdm_symb = 1:12
%             start_index = (ofdm_symb - 1) * num_carriers + 1;
%             expected_rx_data(start_index:1:(start_index + num_carriers - 1)) = ...
%                 expected_rx_data(start_index:1:(start_index + num_carriers - 1)) .* H;
%         end
%         plot(rx_data,'co','LineWidth',6);
%         hold on;
%         plot(expected_rx_data,'y*');
%         plot(refpts,'r*');
%     %         text(real(refpts)+0.1,imag(refpts),num2str((0:3)'))
%         xlabel('In-Phase');
%         ylabel('Quadrature');
%         title('RX Data');
%         legend('rx_data','expected_rx_data', ...
%             'refpts','location','northeastoutside');
%
%     end
% % end
%
% %
% % symbErr_10s = zeros(1,length(0:2:20));
% % symbErr_22s = zeros(1,length(0:2:20));
% % two_symbErr_10s = zeros(1,length(0:2:20));
% % two_symbErr_22s = zeros(1,length(0:2:20));
% % three_symbErr_10s = zeros(1,length(0:2:20));
% % three_symbErr_22s = zeros(1,length(0:2:20));
% % for SNR = 0:2:20
% % %     Hhat_10 = Hhat_10s((SNR / 2) + 1);
% % %     Hhat_22 = Hhat_22s((SNR / 2) + 1);
% %
% %     for trial = 1%:1000
% %         x = packet_generator(mod);
% %         x_data = x(1,321:length(x));
% %
% %
% %         y = channel(x, h, freq_offset, SNR);
% %
% %         H_hat_10 = channel_estimator_signal_input(10,y);
% %         H_hat_22 = channel_estimator_signal_input(22,y);
% %
% %
% %         y_data = zeros(1,(12*64));
% %         x_data_test = zeros(1,(12*64));
% %         for num_ofdm_symbols = 1:12
% %             start_index = 337 + ((num_ofdm_symbols-1) * 80);
% %             dest_index = ((num_ofdm_symbols - 1) * 64) + 1;
% %             y_data(1,dest_index:(dest_index + 64 - 1)) = fft(y(start_index:1:(start_index+64-1)));
% %             x_data_test(1,dest_index:(dest_index + 64 - 1)) = fft(x(start_index:1:(start_index+64-1)));
% %         end
% %         y_data_10 = y_data(10:64:714) / H_hat_10;
% %         y_sign_10 = complex(sign(real(y_data_10)),sign(imag(y_data_10)));
% %         x_data_10 = x_data_test(10:64:714);
% %         x_sign_10 = complex(sign(real(x_data_10)),sign(imag(x_data_10)));
% %         y_data_22 = y_data(22:64:726) / H_hat_22;
% %         y_sign_22 = complex(sign(real(y_data_22)),sign(imag(y_data_22)));
% %         x_data_22 = x_data_test(22:64:726);
% %         x_sign_22 = complex(sign(real(x_data_22)),sign(imag(x_data_22)));
% %
% %         figure;
% %         refpts = qammod((0:3)',4);
% %         plot(y_data_10,'go');
% %         hold on;
% %         plot(x_data_10,'co');
% %         plot(refpts,'r*');
% % %         text(real(refpts)+0.1,imag(refpts),num2str((0:3)'))
% %         xlabel('In-Phase');
% %         ylabel('Quadrature');
% %         legend('y_data_10','x_data_10', ...
% %             'Reference constellation','location','nw');
% %
% %         tx_sym_10 = qamdemod(x_data_10,4,'gray','UnitAveragePower',true);
% %         rx_sym_10 = qamdemod(y_data_10,4,'gray','UnitAveragePower',true);
% %
% %         tx_sym_22 = qamdemod(x_data_22,4,'gray','UnitAveragePower',true);
% %         rx_sym_22 = qamdemod(y_data_22,4,'gray','UnitAveragePower',true);
% %
% %         symbErr_10s((SNR / 2) + 1) = symbErr_10s((SNR / 2) + 1) + ...
% %             (sum(tx_sym_10 ~= rx_sym_10) / 12);
% %         symbErr_22s((SNR / 2) + 1) = symbErr_10s((SNR / 2) + 1) + ...
% %             (sum(tx_sym_22 ~= rx_sym_22) / 12);
% % %         symbErr_10s((SNR / 2) + 1) = symbErr_10s((SNR / 2) + 1) + ...
% % %             (sum(tx_sym_10 ~= rx_sym_10) / 12000);
% % %         symbErr_22s((SNR / 2) + 1) = symbErr_10s((SNR / 2) + 1) + ...
% % %             (sum(tx_sym_22 ~= rx_sym_22) / 12000);
% %
% %         two_symbErr_10s((SNR / 2) + 1) = two_symbErr_10s((SNR / 2) + 1) + ...
% %             (sum(abs(tx_sym_10 - rx_sym_10) == 2));
% %         two_symbErr_22s((SNR / 2) + 1) = two_symbErr_10s((SNR / 2) + 1) + ...
% %             (sum(abs(tx_sym_22 - rx_sym_22) == 2));
% %         three_symbErr_10s((SNR / 2) + 1) = three_symbErr_10s((SNR / 2) + 1) + ...
% %             (sum(abs(tx_sym_10 - rx_sym_10) == 3));
% %         three_symbErr_22s((SNR / 2) + 1) = three_symbErr_10s((SNR / 2) + 1) + ...
% %             (sum(abs(tx_sym_22 - rx_sym_22) == 3));
% %
% %     end
% % end
