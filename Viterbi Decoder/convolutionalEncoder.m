function [X1,X2,output] = convolutionalEncoder(info)
    
    % Initial conditions 
    uk1 = 0;
    uk2 = 0;
    
    %pad zeros for termination
    v = 2;
    b = padarray(info,[0 v],'post');
    
    %get the size of the info bits
    n =size(b,2)*2;
    
    X1 = zeros(1,size(b,2));
    X2 = zeros(1,size(b,2));
    
    output = zeros(1,n);
    
    j = 1;
    %Iterate the infobits
    for i = 1 : length(b)
       
        uk = b(i);
        
        % output the input bit (systematic code)
        x1 = uk;
        % xor all the states
        x21 = xor(uk,uk1);
        x2 = xor(x21,uk2);
        % shift the states to current value
        uk2 = uk1;
        uk1 = uk;    
        % store the output
        output(j:j+1) = [x1,x2];
        j = j+2;
        
        X1(i) = x1;
        X2(i) = x2;
        
    end
        
end