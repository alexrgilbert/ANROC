function [ds_audio,frequency] = BinaryDeserializeAudio(s_audio)
word_len_bits = 16;
header_length = 32 * 5;
s_audio_length = binarytouint32(s_audio(1,1:32));
channels = binarytouint32(s_audio(1,65:96));
length = binarytouint32(s_audio(1,97:128));
frequency = binarytouint32(s_audio(1,129:160));

payload_length = s_audio_length - header_length;
ds_audio = zeros(length,channels);

for c=1:channels
    for l=1:length
        lin_idx_start = header_length + (c-1) * length * word_len_bits + (l-1) * word_len_bits + 1;
        lin_idx_end = lin_idx_start + word_len_bits - 1;
        %bits = s_audio(1,lin_idx_start:lin_idx_end)
        %val =binarytoint16(bits)
        ds_audio(l,c) = binarytoint16(s_audio(1,lin_idx_start:lin_idx_end));
    end
end
    
end