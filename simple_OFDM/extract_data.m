function data = extract_data(rxsig,stf_len,ltf_len,prefix_len,num_carriers,num_syms)
    data = zeros(1,(num_syms*num_carriers));
    for sym_num = 1:12
            start_index = stf_len + ltf_len + prefix_len + 1 + ((sym_num-1) * (num_carriers + num_syms));
            dest_index = ((sym_num - 1) * num_syms) + 1;
            data(1,dest_index:(dest_index + 64 - 1)) = fft(rxsig(start_index:1:(start_index+64-1)));
    end
end
