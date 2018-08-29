function [] = CIC(N)

    load('sigma-delta.mat');
    h1=zeros(1,N);
    h1(1:N)=1/N;
    h2=conv(h1,h1);
    h3=conv(h2,h1);
    
    figure(1)
    
    subplot(311)
    
    stem(h1), grid on
    xlim([1 N])
    
    subplot(312)
    
    stem(h2), grid on
    xlim([1 2*N-1])
    
    subplot(313)
    
    stem(h3), grid on
    xlim([1 3*N-2])
    
    figure(2)
    
    Fs=1/SampleTime;
    f=linspace(-Fs/2, Fs/2,length(sigma_delta_out_zeros));
    t=0:SampleTime:(length(sigma_delta_out_zeros)-1)*SampleTime;
    
    subplot(211)
    
    plot(t,sigma_delta_out_zeros), grid on
    xlim([0 (length(sigma_delta_out_zeros)-1)*SampleTime])
    
    subplot(212)
    
    plot(f,fftshift(abs(fft(sigma_delta_out_zeros)))), grid on
    xlim([-Fs/2 Fs/2])
    
    figure(3)
    
    %%Filtro Sinc1
    
    Sincout=downsample(conv(h1,sigma_delta_out_zeros),N);
    f=linspace(-Fs/(N*2), Fs/(N*2),length(Sincout));
    t=0:N*SampleTime:(length(Sincout)-1)*SampleTime*N;
    
    subplot(231)
    
    plot(t,Sincout), grid on
    
    subplot(234)
    
    plot(f,fftshift(abs(fft(Sincout)))), grid on
    xlim([-Fs/(2*N) Fs/(2*N)])
    
    %%Filtro Sinc2
    
    Sincout=downsample(conv(h2,sigma_delta_out_zeros),N);
    f=linspace(-Fs/(N*2), Fs/(N*2),length(Sincout));
    t=0:N*SampleTime:(length(Sincout)-1)*SampleTime*N;
    
    subplot(232)
    
    plot(t,Sincout), grid on
    xlim([0 (length(Sincout)-1)*SampleTime*N])
    
    subplot(235)
    
    plot(f,fftshift(abs(fft(Sincout)))), grid on
    xlim([-Fs/(2*N) Fs/(2*N)])
    
    %%Filtro Sinc3
    
    Sincout=downsample(conv(h3,sigma_delta_out_zeros),N);
    f=linspace(-Fs/(N*2), Fs/(N*2),length(Sincout));
    t=0:N*SampleTime:(length(Sincout)-1)*SampleTime*N;
    
    subplot(233)
    
    plot(t,Sincout), grid on
    xlim([0 (length(Sincout)-1)*SampleTime*N])
    
    subplot(236)
    plot(f,fftshift(abs(fft(Sincout)))), grid on
    xlim([-Fs/(2*N) Fs/(2*N)])
end