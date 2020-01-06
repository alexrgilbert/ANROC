%serialize image into [len_s_audio, len_header =24, frequency=32, ]
function [s_audio] = BinarySerializeAudio(audio,length,channels,frequency)
word_len_bits = 16;
header_length = 32 * 5;
s_audio_length = header_length + channels * length * word_len_bits;
s_audio = zeros(1,s_audio_length);
s_audio(1,1:32) = de2bi(s_audio_length,32);
s_audio(1,33:64) = de2bi(32*4,32);
s_audio(1,65:96) = de2bi(channels,32);
s_audio(1,97:128) = de2bi(length,32);
s_audio(1,129:160) = de2bi(frequency,32);
for c=1:channels
    for l=1:length
        lin_idx_start = header_length + (c-1) * length * word_len_bits + (l-1) * word_len_bits + 1;
        lin_idx_end = lin_idx_start + word_len_bits - 1;
        bits = int16tobinary(audio(l,c));
        s_audio(1,lin_idx_start:lin_idx_end) = bits;
    end
end
end

