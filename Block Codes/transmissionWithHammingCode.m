function transmissionWithHammingCode(numOfBits)
    %Generate possible Info words
    info_words = getPossibleInfoWords(4);
    
    code_words = zeros(16,7);
    
    %Get the possible code words
    for i = 1 : length(info_words)
        info_word = info_words(i,:);
        code = generateHammingCode(info_word);
        code_words(i,:) = code;
    end
    
    
    % Generate Info bits
    info = round(rand(1,numOfBits));
    
    % Apply Hamming Code and get coded stream
    coded_stream = generateHammingCode(info);
    
    % Convert the coded stream to symbols for transmission via AWGN
    AWGNinfo(coded_stream == 1) = -1;
    AWGNinfo(coded_stream == 0) = 1;
    
    snr = 0 : 1 : 10;
    snrSize = length(snr);

    numOfCodedBits = size(coded_stream,2);
    BER = zeros(1,snrSize); 
       
     for i = 1 : snrSize 
        % Add AWGN noise to the info bits
        r = 10.^(snr(i)/10);
        varaince  = 0.5/r;
        s = sqrt(varaince) * randn(1,numOfCodedBits);
        y = AWGNinfo + s;
        
        y (y <= 0) = -1;
        y (y>0) = 1;
        
        % Demap the bits
        y(y == 1) = 0;
        y(y == -1) = 1;
             
        %Decode the bits
        estimated_info =  syndromeDecoding(info,y);
        
        z = xor(info,estimated_info);
        
        % Find BER
        BER(i) = sum(z)/numOfBits;
        
     end
     
     display(BER);
     
     % Find the BER of uncoded system
    BER_uncoded = testUncodedSystemAWGN(numOfBits);
    
    % Plot the BER for syndrome decoding and uncoded system
    semilogy(snr,BER,'b-o',snr,BER_uncoded,'g-.');
    legend('BER - Syndrome Decoding','BER - Uncoded');
    xlabel('SNR');
    ylabel('BER');
    

end


