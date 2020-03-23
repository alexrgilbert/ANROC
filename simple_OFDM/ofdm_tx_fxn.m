function [bits, syms, syms_int, signal_bb, signal_bb_ds, signal,...
     detected_syms_gt, detected_syms_gt_ds] = ofdm_tx_fxn(p)

    num_data_carriers = (p.num_carriers-p.num_dead_carriers-p.num_pilots);
    packet_data_syms_length = (p.num_symbols_per_packet * num_data_carriers);
    packet_data_bits_length = packet_data_syms_length * max(log2(p.M),1);

    bits = randi([0,1],1,(p.num_packets*packet_data_bits_length));
    len_bits = length(bits);

    num_symbols = ceil ( len_bits /  (num_data_carriers*max(log2(p.M),1)) );
    num_packets = ceil ( num_symbols /  p.num_symbols_per_packet );

    bits = [bits zeros(1,((num_packets * packet_data_bits_length) - len_bits))];

    syms = [];
    syms_int = [];
    signal_bb_ds = [];
    signal_bb = [];

    detected_syms_gt_ds = [];
    detected_syms_gt = [];
    bits_idx = 1;

    for i = 1:(num_packets + p.num_train_packets)

        % if (p.random_start_flag || (i > 1))

        [padding_ds,padding_len_ds,padding,padding_len] = generate_padding(p.random_range,p.us_rate);
        signal_bb = [signal_bb padding];
        signal_bb_ds = [signal_bb_ds padding_ds];
        detected_syms_gt_ds = [detected_syms_gt_ds padding_ds];
        detected_syms_gt = [detected_syms_gt padding];
        % end

        if i <= p.num_train_packets

            packet_bits = [];
            [x_ds,x,~,~] = packet_generator_fxn(p.M,packet_bits,p.x_stf_len,...
             p.x_ltf_len,p.delta_fs,p.symbol_time,p.us_rate,p.num_symbols_per_packet,p.num_carriers,...
             p.num_prefix,p.num_dead_carriers,p.num_pilots);

             signal_bb = [signal_bb x];
             signal_bb_ds = [signal_bb_ds x_ds];

              detected_syms_gt_ds = [detected_syms_gt_ds 1 zeros(1,(length(x_ds)-1))];
               detected_syms_gt = [detected_syms_gt 1 zeros(1,(length(x)-1))];
        else
            packet_bits = bits(1,bits_idx:bits_idx+packet_data_bits_length-1);
            bits_idx = bits_idx + packet_data_bits_length;
            [x_ds,x,syms_packet,syms_int_packet] = packet_generator_fxn(p.M,packet_bits,p.x_stf_len,...
             p.x_ltf_len,p.delta_fs,p.symbol_time,p.us_rate,p.num_symbols_per_packet,p.num_carriers,...
             p.num_prefix,p.num_dead_carriers,p.num_pilots);

             signal_bb = [signal_bb x];
             signal_bb_ds = [signal_bb_ds x_ds];
             syms = [syms syms_packet];
             syms_int = [syms_int syms_int_packet];

             detected_syms_gt_ds = [detected_syms_gt_ds 1 zeros(1,(length(x_ds)-1))];
              detected_syms_gt = [detected_syms_gt 1 zeros(1,(length(x)-1))];
        end
   end

   % % % Add Padding After ?
   [padding_ds,padding_len_ds,padding,padding_len] = generate_padding(p.random_range,p.us_rate);
   signal_bb = [signal_bb padding];
   signal_bb_ds = [signal_bb_ds padding_ds];
   detected_syms_gt_ds = [detected_syms_gt_ds padding_ds];
   detected_syms_gt = [detected_syms_gt padding];

   if p.upconvert == true
       signal = upconvert(signal_bb,p.Fc,p.TX_Fs);
   else
       signal = signal_bb;
   end

    if (p.random_start_flag == true)
        [padding_ds,padding_len_ds,padding,padding_len] = generate_padding(p.random_range,p.us_rate);
        signal = [padding signal];
        signal_bb = [padding signal_bb];
        signal_bb_ds = [padding_ds signal_bb_ds];
        detected_syms_gt_ds = [padding_ds detected_syms_gt_ds];
        detected_syms_gt = [padding detected_syms_gt];

        [padding_ds,padding_len_ds,padding,padding_len] = generate_padding(p.random_range,p.us_rate);
        signal = [signal padding];
        signal_bb = [signal_bb padding];
        signal_bb_ds = [signal_bb_ds padding_ds];
        detected_syms_gt_ds = [detected_syms_gt_ds padding_ds];
        detected_syms_gt = [detected_syms_gt padding_ds];
    end

end
