function transmissionWithSPC(numOfBits)

    A = [1 1 0 1 0 0 1 0 0 1 1 1];
    x = generateSPC(A);
    
    y = x;
    y(2) = xor(y(2),1);
    y(8) = xor(y(8),1);
    y(15) = xor(y(15),1);
    y(20) = xor(y(20),1);
    
    info_words = getPossibleInfoWords(3);
    code_words = zeros(8,6);

    for i = 1 : length(info_words)
        info_word = info_words(i,:);
        code = generateSPC(info_word);
        code_words(i,:) = code;
    end
    
    estimated_info = decoder(code_words,y,1);    

    % Generate Info bits
    info = round(rand(1,numOfBits));
    
    % Apply SPC and get coded stream
    coded_stream = generateSPC(info);
    
    % Convert the coded stream to symbols for transmission via AWGN
    AWGNinfo(coded_stream == 1) = -1;
    AWGNinfo(coded_stream == 0) = 1;
    
    snr = 0 : 1 : 10;
    snrSize = length(snr);

    numOfCodedBits = size(coded_stream,2);
    BER = zeros(1,snrSize);
    BER_soft = zeros(1,snrSize);
    
    % map the code words to -1 and 1 for SD
    code_words_soft = code_words;
    code_words_soft(code_words_soft == 1) = -1;
    code_words_soft(code_words_soft == 0) = 1;

    for i = 1 : snrSize 
        % Add AWGN noise to the info bits
        r = 10.^(snr(i)/10);
        varaince  = 0.5/r;
        s = sqrt(varaince) * randn(1,numOfCodedBits);
        y = AWGNinfo + s;
        
        % Demap the bits for HD
        hard(y <= 0 ) = 1;
        hard(y > 0 ) = 0;
        
        % Apply Hard decision decoding
        estimated_info = decoder(code_words,hard,1);  
        
        % Find the bits which are flipped during transmission
        z = xor(info,estimated_info);
        
        % Find BER
        BER(i) = sum(z)/numOfBits;
       
        % Apply soft decision decoding
        estimated_info_soft = decoder(code_words_soft,y,2);
        
        % Demap the bits
        estimated_info_soft(estimated_info_soft == 1) = 0;
        estimated_info_soft(estimated_info_soft == -1) = 1;

        % Find the bits which are flipped during transmission    
        z = xor(info,estimated_info_soft);
        
        % Find BER
        BER_soft(i) = sum(z)/numOfBits;
                
    end
    
    format shortEng
    format compact
    
    display(BER_soft);
    
    % Find the BER of uncoded system
    BER_uncoded = testUncodedSystemAWGN(numOfBits);
    
    % Plot the BER for HD,SD and uncoded system
    semilogy(snr,BER,'b-o',snr,BER_soft,'r-*',snr,BER_uncoded,'g-.');
    legend('BER - HD','BER - SD','BER - Uncoded');
    xlabel('SNR');
    ylabel('BER');
      
end