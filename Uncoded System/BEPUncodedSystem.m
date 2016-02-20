function BEPUncodedSystem()

r = 0:0.5:10;

display(r);
% Eb/No = 10 ^ (SNR/10)
E = 10.^(r/10);

%Bit Error Probability of AWGN channel
pb = 0.5 *erfc(sqrt(E))

semilogy(r,pb),title('Bit Error Probability for uncoded binary transmission');
xlabel('Eb/No');
ylabel('Bit Error Probability');


end