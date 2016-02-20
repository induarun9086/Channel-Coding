function testConvolutionalCodes(numOfBits)

    info = [1 1 1 0 1 0 0 1];    
    [x1,x2,output] = convolutionalEncoder(info);
    
    %info = round(rand(1,numOfBits));
    
    %Apply convolutional Code and get coded stream
    [X1,X2,coded_stream] = convolutionalEncoder(info);
    
    %puncturing Rate = 2/3
    X11 = X1(2:2:size(X1,2));
    
    punctured_stream = zeros(1,size(X11,2)+size(X2,2));
    j = 1;
    k = 1;
    
    for i = 1:size(X11,2)
       punctured_stream(k : k+2) =  [X11(i),X2(j),X2(j+1)];
       k  = k+3;
       j = j+2;
    end
    
    display(punctured_stream)
    
    %Punctured output for R = 2/3
    %output_stream = punctured_stream;
       
    %puncturing R = 1
    
    output_stream = X1; 
    
    AWGNinfo(output_stream == 1) = -1;
    AWGNinfo(output_stream == 0) = 1;
    
    snr = 0 : 1 : 10;
    snrSize = length(snr);
    
    numOfCodedBits = size(output_stream,2);
    BER = zeros(1,snrSize); 
    
    v = 2;
    info = padarray(info,[0 v],'post');
       
     for i = 1 : snrSize 
        % Add AWGN noise to the info bits
        r = 10.^(snr(i)/10);
        varaince  = 0.5/r;
        s = sqrt(varaince) * randn(1,numOfCodedBits);
        y = AWGNinfo + s;
        
        threshold = 0;
        
        y (y <= threshold) = -1;
        y (y > threshold) = 1;
        
        % Demap the bits
        y(y == 1) = 0;
        y(y == -1) = 1;
        
        y = viterbiAlgorithm([5,7],y);
        
        z = xor(info,y);
        
        % Find BER
        BER(i) = sum(z)/numOfBits;
        
     end
     
     BER_uncoded = testUncodedSystemAWGN(numOfBits);
    
    % Plot the BER for syndrome decoding and uncoded system
    semilogy(snr,BER,'b-o',snr,BER_uncoded,'g-.');
    legend('BER - Convolutional codes','BER - Uncoded');
    xlabel('SNR');
    ylabel('BER');
    

end