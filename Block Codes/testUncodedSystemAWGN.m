function BER = testUncodedSystemAWGN(numOfBits)

    % Generate random information Bits
    info = round(rand(1,numOfBits));
    
    %findBERForLowandHighSNR(numOfBits)
    
    stepSize = 1;
     
    EbNo = 0 : stepSize : 10;
    
     %for uncoded system code rate = 1 therefore Eb/No = snr
   
    BER = CalculateBERVsSNR(info,numOfBits,EbNo);
    
    pb = BEPForUncodedSystem(EbNo);
    
%     semilogy(EbNo,BER,'b-o',EbNo,pb,'r-*');
%     legend('Bit Error rate','Bit Error probability');
%     xlabel('Eb/No');
%     ylabel('BER / Bit Error probability');

end

function  BER = CalculateBERVsSNR(info,numOfBits,snr)
    snrSize = size(snr,2);
    BER = zeros(1,snrSize);
     
   % Iterate snr array and find Bit Error rate for each snr value
   for i = 1: snrSize  
      ber = calculateBER(info,numOfBits,snr(i));
      BER(i) = ber;
   end  
      
end


function BER = calculateBER(info,numOfBits,snr)
 % Convert the source symbols for transmission via AWGN
    AWGNinfo = info;
    AWGNinfo(AWGNinfo == 1) = -1;
    AWGNinfo(AWGNinfo == 0) = 1;

    % Add AWGN noise to the info bits
    r = 10.^(snr/10);
    varaince  = 0.5/r;
    s = sqrt(varaince) * randn(1,numOfBits);
    %s = awgn(AWGNinfo,snr);
    
    y = AWGNinfo + s;
   
    y (y <= 0) = -1;

    y (y>0) = 1;

    % Demap the coded bits

    y(y == 1) = 0;

    y(y == -1) = 1;

    %Find how many bits are flipped during the transmission
    z = xor(info,y);
    
    %Calculate Bit Erroe rate
    BER = sum(z)/numOfBits;
     
end


function pb = BEPForUncodedSystem(EbNo)

    E = 10.^(EbNo/10);

    %Bit Error Probability of AWGN channel
    pb = 0.5 *erfc(sqrt(E));

end


function findBERForLowandHighSNR(numOfBits)

    % Generate random information Bits
    info = round(rand(1,numOfBits));
   
    snr = [0,10];
    
    CalculateBERVsSNR(info,numOfBits,snr)
end




