function coded_stream = generateHammingCode(A)
    
    % Define Generator matrix
     G = [1 0 0 0 1 1 0;
          0 1 0 0 1 0 1;
          0 0 1 0 0 1 1;
          0 0 0 1 1 1 1];
    
    % find the size of the sequence
    length = size(A,2);
    %find whether the length is a multiple of 4
    r = mod(length,4);
    
    %length is not a multiple of 4,append zeros to the end
    if(r ~= 0)
        A = [A, zeros(1, 4-r)];
    end
    
    %reshape the info sequence as 4xR matrix
    length = size(A,2);
    numberOfRows = length/4;
    B = reshape( A.', [4 numberOfRows] ).';
   
    %Multiply Info and Generator matrix
    code = B*G;
    code = mod(code,2);
    coded_stream  = code;
 
    %convert the resulting matrix to a vector
    coded_stream = reshape(coded_stream.',1,[]);
    
    %convert the coded bits to symbols
    mapped_stream(coded_stream == 1) = -1;
    mapped_stream(coded_stream == 0) = 1;
   
end