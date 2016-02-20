function [dfree, dop] = viterbiAlgorithm(pol, rcvdData, useHard, debug)
    
    %
    % Viterbi Algorithm
    %
    % Inputs
    % - pol    : Polynomial for the convolution coding system as 1xn matrix
    % - rcvdBS : received bit stream at the receiver
    %
    % Output
    % - dop : Decoded output as a 1xM matrix
    %
    
    format hex
    
    % find the number of states from the given size of polynomial
    numberOfStates = uint32(2^size(pol, 2));
    % find number of state bits
    numberOfStateBits = sqrt(double(numberOfStates));
    % possible inputs 
    input = uint32([0 1]);
    % state bit masks 
    states = uint32(2.^(numberOfStateBits:-1:0));
    
    % intialize a observation array 
    obs = zeros(1, (size(rcvdData, 2) / numberOfStateBits), 'uint32');
    % intialize a double observation array 
    dobs = zeros(numberOfStateBits, (size(rcvdData, 2) / numberOfStateBits), 'double');
    
    if(useHard == 1)
        % convert received bit stream into observations
        for i = 1:size(obs, 2)
            ob = uint32(0);
            shift = 0;
            for j = 1:numberOfStateBits
                ob = bitor(ob, bitshift(rcvdData(1, ((i-1)*2)+j), shift));
                shift = shift + 1;
            end

            obs(1,i) = ob;
        end
        
        if debug == 1
            display(obs);
        end
    else
        % convert received bit stream into observations
        for i = 1:size(dobs, 2)
            for j = 1:numberOfStateBits
                dobs(j, i) = rcvdData(1, ((i-1)*2)+j);
            end
        end
        
        format long
        if debug == 1
            display(dobs);
        end
    end
    
    format hex
    
    % list of possible states
    currentState = uint32(0 : 1 : numberOfStates-1);
    % possible next states for the possible inputs for the given polynomial
    nextState =  zeros(size(input, 2),numberOfStates,'uint32');
    % possible output for the possible inputs for the given polynomial
    output = zeros(size(input, 2),numberOfStates,'uint32');
    
    % find the possible next states and output for the given polynomial
    % evaluate for all the possible inputs 
    for i = 1 : 2
        % evaluate for all the possible states 
        for j = 1 : numberOfStates
            % shift the input to the MSB
            temp = input(i) * (numberOfStates);
            % combine input with current state 
            temp = temp + currentState(j);
            % find next state by right-shifting input+currrentstate
            nextState(i,j) = bitshift(temp,-1);
            
            % initialize output
            output(i, j) = uint32(0);
            shift = 0;
            % evaluate for all the elements of the polynomial
            for p = pol
                % evaluate the current polynomial
                op = xorArr(uint32(bitand(uint32(bitand(temp,p)),states)));
                % combine results by left shifting 
                output(i, j) = bitor(output(i, j), bitshift(op, shift));
                shift = shift + 1;
            end
        end
    end
    
    if debug == 1
        display(nextState);
        display(output);
    end
    
    % initialize possible trelis sequences
    pm = zeros(numberOfStates, (size(obs, 2) + 1), 'uint32');
    ib = zeros(numberOfStates, (size(obs, 2) + 1), 'uint32');
    ps = zeros(numberOfStates, (size(obs, 2) + 1), 'uint32');
    % possible infinte (i.e. an unattainable path metric)
    infi = uint32(intmax('uint32'));
    pm(:) = infi;
    pm(1, 1) = uint32(0);
    
    % evaluate for each observation (till last but one)
    for i = 1 : size(obs, 2)
        if useHard == 1
            ob = obs(1, i);
        else
            dob = dobs(:, i);
        end
        % for every state
        for s = currentState
            % because of matlab's index start from 1
            s = s + 1;
            % for every possible input 
            for ip = input
                % because of matlab's index start from 1
                ip = ip + 1;
                
                % calculate branch metric
                if useHard == 1
                    branchMetric = calcHammingDistance(ob, output(ip, s));
                else
                    branchMetric = calcEculidianDistance(dob, output(ip, s), numberOfStateBits);
                end
                
                % find next state
                nextS = nextState(ip, s);
                % because of matlab's index start from 1
                nextS = nextS + 1;
                
                % Update only if current step is possible
                if(pm(s, i) ~= infi)
                    % calculate current path metric
                    pathMetric = uint32(pm(s, i) + branchMetric);
                    
                    % If this step has a better path metric
                    if(pathMetric < pm(nextS, i+1))
                        pm(nextS, i+1) = uint32(pathMetric);
                        ib(nextS, i+1) = (ip - 1);
                        ps(nextS, i+1) = (s - 1);
                    end
                end
            end
        end
    end
    
    if debug == 1
        display(pm);
        display(ib);
        display(ps);
    end
    
    % decoded output vaues
    dop = zeros(1, size(obs, 2), 'uint32');
    
    currIdx = 0;
    minMetric = infi;
    dfree = infi;
    
    % At start find the minimum metric and it's index
    for i = 1:size(pm, 1)
       if(pm(i, size(pm, 2)) < minMetric)
        minMetric = pm(i, size(pm, 2));
        currIdx = i;
       end
       if((pm(i, size(pm, 2)) < dfree) && ((pm(i, size(pm, 2) ~= 0))))
           dfree = pm(i, size(pm, 2));
       end
    end
    
    % traceback from the end 
    for i = size(pm, 2):-1:2
        % Save the current bit and goback to the previous state
        dop(1, i-1) = ib(currIdx, i);
        currIdx = (ps(currIdx,i) + 1);
    end
    
    if debug == 1
        display(dop);
    end
end


% function to xor the given array elements
function [op] = xorArr(ipArr)
    op = uint32(0);
    for ip = ipArr
        if(ip ~= 0)
            op = bitxor(op, uint32(1));
        end
    end
end

% function to calculate the branch metric (Hamming Distance)
function bm = calcHammingDistance(ob, op)
    bm = uint32(0);
    
    res = bitxor(ob, op);
    
    for i = 0:31
        mask = 2 ^ i;
        val = bitand(res, mask);
        if(val ~= 0) 
            bm = bm + uint32(1);
        end
    end
end


% function to calculate the branch metric (Eculidian Distance)
function bm = calcEculidianDistance(dob, op, numberOfStateBits)
    bm = uint32(0);
    
    for i = 0:numberOfStateBits-1
        currBit = bitand(op, (2 ^ i));
        currVal = -1;
        if currBit == 0
            currVal = 1;
        end
        
        bm = bm + uint32((dob(i+1, 1) - currVal) ^ 2);
    end
end
