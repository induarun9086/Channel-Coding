function coding_gain = codingGain(k,n)
    EbNo = (erfcinv(2*(10^-4)))^2; % SNR of uncoded system
    R = k/n; %Code Rate
    snr_coded  = EbNo* R; % calculate SNR from EbNo and R
    
    coding_gain = EbNo - snr_coded; % calculate the coding gain
end