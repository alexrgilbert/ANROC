clc;
clear;
close all;

% x = packet_generator(2);
% 
% 
% h = [1];
% 
% SNR = 20;
% freq_offset = 0;
% y = channel(x, h, freq_offset, SNR);
% 
% 
% 

% 
% detected = packet_detection(z_stf, y);

% SNRs = 0:2:20;
% p_detected = zeros(length(SNRs));
% mod = 2;
% for SNR = 0:2:20
%     detected = 0;
%     for trial = 1:1000
%         x = packet_generator(mod);
%         h = [1];
%         freq_offset = 0;
%         y = channel(x, h, freq_offset, SNR);
%         z_stf = x(1,1:16);
%         detected = detected + packet_detection(z_stf, y);
%     end
%     p_detected((SNR/2) + 1) = detected / 1000;
% end
% figure;
% plot(SNRs, p_detected);

% done = prob_1();


% mod = 4;
% x = packet_generator(mod);
% h = [1, .3, .2];
% H  = fft(h,64);
% freq_offset = 0;
% error_10s = zeros(1,length(0:2:20));
% error_22s = zeros(1,length(0:2:20));
% Hhat_10s = zeros(1,length(0:2:20));
% Hhat_22s = zeros(1,length(0:2:20));
% for SNR = 0:2:20
%     error_10 = 0;
%     error_22 = 0;
%     Hhat_10 = 0;
%     Hhat_22 = 0;
%     for trial = 1:1000
%         H_hat_10 = channel_estimator(SNR, x, h, freq_offset,10);
%         H_hat_22 = channel_estimator(SNR, x, h, freq_offset,22);
%         Hhat_10 = Hhat_10 + H_hat_10;
%         Hhat_22 = Hhat_22 + H_hat_22;
%         error_10 = error_10 + (abs(H(10)-H_hat_10)^2)/(abs(H(10))^2);
%         error_22 = error_22 + (abs(H(22)-H_hat_22)^2)/(abs(H(22))^2);
%     end
%     error_10s((SNR/2) + 1) = error_10 / 1000;
%     error_22s((SNR/2) + 1) = error_22 / 1000;
%     Hhat_10s((SNR/2) + 1) = Hhat_10 / 1000;
%     Hhat_22s((SNR/2) + 1) = Hhat_22 / 1000;
% end
% 
% figure;
% plot(0:2:20, error_10s);
% hold on;
% plot(0:2:20, error_22s);
% legend('10th Carrier','22nd Carrier');
% 
% figure;
% plot(1:1:length(H),abs(H));


M = 4;
h = [1, .3, .2];
H  = fft(h,64);
freq_offset = 0;

for SNR = 0:2:20
    for trial = 1
    
        [x,syms] = packet_generator_with_gt(M);
        
        figure;
        refpts = qammod((0:(M-1))',M,'gray','UnitAveragePower',true);
        plot(syms,'co','LineWidth',6);
        hold on;
        plot(refpts,'r*');
    %         text(real(refpts)+0.1,imag(refpts),num2str((0:3)'))
        xlabel('In-Phase');
        ylabel('Quadrature');
        title('Generated Data');
        legend('syms','refpts', ...
            'Reference constellation','location','w');
        
        y = channel(x, h, freq_offset, SNR);
        
        H_hat = full_channel_estimator_signal_input(y);
        
        figure;
        xlabel('Frequency (delta_fs)');
        title('Channel Estimate vs Actual');
        plot(1:1:length(H),abs(H),'r');
        hold on;
        plot(1:1:length(H_hat),abs(H_hat),'c');
        plot(1:1:length(H),angle(H),'y');
        plot(1:1:length(H_hat),angle(H_hat),'g');
        legend('Actual Magnitude','Estimated Magnitude', ...
            'Actual Phase', 'Estimated Phase');
        
        rx_data = extract_data(y,160,160,16,64,12);
        
        figure;
        refpts = qammod((0:(M-1))',M,'gray','UnitAveragePower',true);
        expected_rx_data = syms;
        for ofdm_symb = 1:12
            start_index = (ofdm_symb - 1) * 64 + 1;
            expected_rx_data(start_index:1:(start_index + 64 - 1)) = ...
                expected_rx_data(start_index:1:(start_index + 64 - 1)) .* H;
        end
        plot(rx_data,'co','LineWidth',6);
        hold on;
        plot(expected_rx_data,'y*');
        plot(refpts,'r*');
    %         text(real(refpts)+0.1,imag(refpts),num2str((0:3)'))
        xlabel('In-Phase');
        ylabel('Quadrature');
        title('RX Data');
        legend('rx_data','expected_rx_data', ...
            'refpts','location','northeastoutside');
        
    end
end

% 
% symbErr_10s = zeros(1,length(0:2:20));
% symbErr_22s = zeros(1,length(0:2:20));
% two_symbErr_10s = zeros(1,length(0:2:20));
% two_symbErr_22s = zeros(1,length(0:2:20));
% three_symbErr_10s = zeros(1,length(0:2:20));
% three_symbErr_22s = zeros(1,length(0:2:20));
% for SNR = 0:2:20
% %     Hhat_10 = Hhat_10s((SNR / 2) + 1);
% %     Hhat_22 = Hhat_22s((SNR / 2) + 1);
%     
%     for trial = 1%:1000
%         x = packet_generator(mod);
%         x_data = x(1,321:length(x));
%         
%         
%         y = channel(x, h, freq_offset, SNR);
%         
%         H_hat_10 = channel_estimator_signal_input(10,y);
%         H_hat_22 = channel_estimator_signal_input(22,y);
%         
%         
%         y_data = zeros(1,(12*64));
%         x_data_test = zeros(1,(12*64));
%         for num_ofdm_symbols = 1:12
%             start_index = 337 + ((num_ofdm_symbols-1) * 80);
%             dest_index = ((num_ofdm_symbols - 1) * 64) + 1;
%             y_data(1,dest_index:(dest_index + 64 - 1)) = fft(y(start_index:1:(start_index+64-1)));
%             x_data_test(1,dest_index:(dest_index + 64 - 1)) = fft(x(start_index:1:(start_index+64-1)));
%         end
%         y_data_10 = y_data(10:64:714) / H_hat_10;
%         y_sign_10 = complex(sign(real(y_data_10)),sign(imag(y_data_10)));
%         x_data_10 = x_data_test(10:64:714);
%         x_sign_10 = complex(sign(real(x_data_10)),sign(imag(x_data_10)));
%         y_data_22 = y_data(22:64:726) / H_hat_22;
%         y_sign_22 = complex(sign(real(y_data_22)),sign(imag(y_data_22)));
%         x_data_22 = x_data_test(22:64:726);
%         x_sign_22 = complex(sign(real(x_data_22)),sign(imag(x_data_22)));
%         
%         figure;
%         refpts = qammod((0:3)',4);
%         plot(y_data_10,'go');
%         hold on;
%         plot(x_data_10,'co');
%         plot(refpts,'r*');
% %         text(real(refpts)+0.1,imag(refpts),num2str((0:3)'))
%         xlabel('In-Phase');
%         ylabel('Quadrature');
%         legend('y_data_10','x_data_10', ...
%             'Reference constellation','location','nw');
% 
%         tx_sym_10 = qamdemod(x_data_10,4,'gray','UnitAveragePower',true);
%         rx_sym_10 = qamdemod(y_data_10,4,'gray','UnitAveragePower',true);
%         
%         tx_sym_22 = qamdemod(x_data_22,4,'gray','UnitAveragePower',true);
%         rx_sym_22 = qamdemod(y_data_22,4,'gray','UnitAveragePower',true);
%         
%         symbErr_10s((SNR / 2) + 1) = symbErr_10s((SNR / 2) + 1) + ...
%             (sum(tx_sym_10 ~= rx_sym_10) / 12);
%         symbErr_22s((SNR / 2) + 1) = symbErr_10s((SNR / 2) + 1) + ...
%             (sum(tx_sym_22 ~= rx_sym_22) / 12);
% %         symbErr_10s((SNR / 2) + 1) = symbErr_10s((SNR / 2) + 1) + ...
% %             (sum(tx_sym_10 ~= rx_sym_10) / 12000);
% %         symbErr_22s((SNR / 2) + 1) = symbErr_10s((SNR / 2) + 1) + ...
% %             (sum(tx_sym_22 ~= rx_sym_22) / 12000);
%         
%         two_symbErr_10s((SNR / 2) + 1) = two_symbErr_10s((SNR / 2) + 1) + ...
%             (sum(abs(tx_sym_10 - rx_sym_10) == 2));
%         two_symbErr_22s((SNR / 2) + 1) = two_symbErr_10s((SNR / 2) + 1) + ...
%             (sum(abs(tx_sym_22 - rx_sym_22) == 2));
%         three_symbErr_10s((SNR / 2) + 1) = three_symbErr_10s((SNR / 2) + 1) + ...
%             (sum(abs(tx_sym_10 - rx_sym_10) == 3));
%         three_symbErr_22s((SNR / 2) + 1) = three_symbErr_10s((SNR / 2) + 1) + ...
%             (sum(abs(tx_sym_22 - rx_sym_22) == 3));
%         
%     end 
% end


