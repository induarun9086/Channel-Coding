function info_words = getPossibleInfoWords(word_length)
    length = 2^word_length;
    info_words = zeros(length,word_length); 
    for i = 1 : length
        out = dec2bin(i-1, word_length)-'0';
        info_words(i,:) = out; 
    end
end
