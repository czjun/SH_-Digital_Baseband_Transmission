function signal1=addNoise(SNR,add_Noise_Signal,rigin_signal)
    N=length(add_Noise_Signal);
    x=randn(1,N);
    noiseSig=(length(add_Noise_Signal));

    sigPower=sum(abs(rigin_signal).^2)/length(rigin_signal)/sqrt(2);
    noisePower=power(10,-SNR/20)*sigPower;
%     noisePower=power(10,(-SNR/20))/sqrt(2);
    for i=1:N
        
        noiseSig(i) = noisePower*x(i);
    end
    signal1=add_Noise_Signal+noiseSig;
end