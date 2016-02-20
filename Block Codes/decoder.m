function estimated_info = decoder(code_words,y,decoder_type)
    % Find the length of y   
    l = length(y);
    % find number of rows
    numberOfRows = l/6;
    % reshape y such that each row contais the transmitted sequence
    y = reshape( y.', [6 numberOfRows] ).';
    
    estimated_info = zeros(numberOfRows,3);
    for i = 1 : numberOfRows
         % get each sequence        
         info = y(i,:);
         % repeat it for length of code words
         rep_info = repmat(info,length(code_words),1);
         index = 0;
         
         if(decoder_type == 1)
             % If HD, compute minimum value of Hamming distance
             [hamming_distance,index] = min(sum((xor(rep_info,code_words)),2));
         elseif (decoder_type == 2)
             % If SD, compute minimum value of square Euclidean distance
             [euclidean_distance,index] = min(sum(((rep_info - code_words).^2),2));
         end
          
         % Find the coded sequence
         estimated_code = code_words(index,:);
         % first three bits of coded sequence woule be the estimated info
         estimated_info(i,:) = estimated_code(1:3);
    end
        estimated_info = reshape(estimated_info.',1,[]);
end


