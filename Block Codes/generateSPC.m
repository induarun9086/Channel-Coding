function coded_stream = generateSPC(A)
    % Input the info sequence
    %A = input('Input your vector:');
    
    % find the size of the sequence
    length = size(A,2);
    %find whether the length is a multiple of 3
    r = mod(length,3);
    
    %length is not a multiple of 3,append zeros to the end
    if(r ~= 0)
        A = [A, zeros(1, 3-r)];
    end
    
    %reshape the info sequence as 3xR matrix
    length = size(A,2);
    numberOfRows = length/3;
    B = reshape( A.', [3 numberOfRows] ).';
    
    coded_stream = zeros(numberOfRows,6);
    %Iterate the rows,as the rows contain the info
    for i = 1 : numberOfRows
        info = B(i,:);
        %Assign the info to the code
        code = info;
        %Apply even parity for the remaining bits
        code(4) = xor(info(1),info(2));
        code(5) = xor(info(2),info(3));
        code(6) = xor(info(1),info(3));
        coded_stream(i,:)  = code;
    end
           
    %convert the resulting matrix to a vector
    coded_stream = reshape(coded_stream.',1,[]);
    
    %convert the coded bits to symbols
    mapped_stream(coded_stream == 1) = -1;
    mapped_stream(coded_stream == 0) = 1;
 
end