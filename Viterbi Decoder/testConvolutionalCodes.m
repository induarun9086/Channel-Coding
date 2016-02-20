function testConvolutionalCodes(numOfBits, puncturing, debug)

    if numOfBits == 0
        info = [1 1 1 0 1 0 0 1];
        numOfBits = size(info, 2);
    else
        info = round(rand(1,numOfBits));
    end
    
    %Apply convolutional Code and get coded stream
    [X1,X2,coded_stream] = convolutionalEncoder(info);
    
    %puncturing Rate = 2/3    
    punctured_stream = zeros(1, ((size(X1,2) / 2) + size(X2,2)));
    
    k = 1;
    for i = 1:4:size(coded_stream,2)
       punctured_stream(1, k)   =  coded_stream(1, i);
       punctured_stream(1, k+1) =  coded_stream(1, i+2);
       punctured_stream(1, k+2) =  coded_stream(1, i+3);
       
       k  = k + 3;
    end
    
    if(puncturing == 1)
        output_stream = punctured_stream;
    else
        output_stream = coded_stream;
    end
    
    if debug == 1
        format long
        display(coded_stream);
        display(punctured_stream);
    end
    
    AWGNinfo(output_stream == 1) = -1;
    AWGNinfo(output_stream == 0) = 1;
    
    snr = 0 : 1 : 10;
    snrSize = length(snr);
    
    numOfCodedBits = size(output_stream,2);
    hBER = zeros(1,snrSize); 
    sBER = zeros(1,snrSize);
    
    v = 2;
    info = padarray(info,[0 v],'post');
       
    for i = 1 : snrSize 
        % Add AWGN noise to the info bits
        r = 10.^(snr(i)/10);
        varaince  = 0.5/r;
        s = sqrt(varaince) * randn(1,numOfCodedBits);
        y = AWGNinfo + s ;
        
        % depuncture if required
        if(puncturing == 1)
            py = y;
            y = zeros(1, size(X1, 2) * 2);
            
            j = 1;
            k = 1;
            for n = 1:3:size(py, 2)
                y(1, j)   = py(1, k);
                y(1, j+1) = 0;
                y(1, j+2) = py(1, k+1);
                y(1, j+3) = py(1, k+2);
                j = j + 4;
                k = k + 3;
            end
        end

        threshold = 0;
        yd = y;
        
        yd (yd <= threshold) = -1;
        yd (yd > threshold) = 1;
        
        % Demap the bits
        yd(yd == 1) = 0;
        yd(yd == -1) = 1;
        
        [dfree, hard_decoded_stream] = viterbiAlgorithm([4, 7], yd, 1, debug);
        
        if i == 1
            hdfree = dfree
        end
            
        [dfree, soft_decoded_stream] = viterbiAlgorithm([4, 7], y, 0, debug);
        
        hz = xor(info, hard_decoded_stream);
        sz = xor(info, soft_decoded_stream);
        
        % Find BER
        hBER(i) = sum(hz)/numOfBits;
        sBER(i) = sum(sz)/numOfBits;
        
    end
     
    BER_uncoded = testUncodedSystemAWGN(numOfBits);
    
    % Plot the BER for syndrome decoding and uncoded system
    semilogy(snr, hBER, 'b-o', snr, sBER, 'r-*', snr, BER_uncoded, 'g-.');
    legend('BER - Convolutional codes - Hard Decoding', 'BER - Convolutional codes - Soft Decoding', 'BER - Uncoded');
    xlabel('SNR');
    ylabel('BER');
    
    format long
    aSymCodingGain = 10 * log10(double(double(hdfree) / double(2)));
    display(aSymCodingGain);
end