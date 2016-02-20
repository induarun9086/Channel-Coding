function estimated_info = syndromeDecoding(info,y)

       y(3) = xor(y(3),1);

       G = [1 0 0 0 1 1 0;
            0 1 0 0 1 0 1;
            0 0 1 0 0 1 1;
            0 0 0 1 1 1 1];
     
        p=G(1:4,5:7);
        
        H=cat(2,p',eye(3));
                
        Ht = transpose(H);
               
        numOfCodedBits = length(y);
        
        numOfInfoBits = length(info);
                
        syntable = constructSyndromeTable(Ht);

        y = reshape(y,7,numOfCodedBits/7).';
            
        info = reshape(info,4,numOfInfoBits/4).';
         
        syndrome = mod(y*Ht,2);
    
        syndrome_de = bi2de(syndrome,'left-msb');         
        
        corrvect = syntable(1+syndrome_de,:);
      
        correctedcode = rem(corrvect+y,2);
        
        estimated_info = correctedcode(1:end,1:4);
        
        estimated_info = reshape(estimated_info.',1,[]);
               
end


function syndrome_table = constructSyndromeTable(Ht)
        
        % s = e * Ht
        i = eye(7);
        
        e = zeros(8,7);
    
        e(2:end,1:end) = fliplr(i);
    
        syn = e*Ht;
    
        syndrome_de = bi2de(syn,'left-msb');
        
        syndrome_table = zeros(8,7);

        for i = 1: size(syndrome_de,1)
            index = 1+syndrome_de(i);
            syndrome_table(index,:) = e(i,:);
        end               

end

