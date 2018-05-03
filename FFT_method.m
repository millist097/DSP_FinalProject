fs = 16000;
T = 1/fs;

M = csvread('singleWindowData_45d_50khzFs.csv');

stem(M(:,1))

channelA_FFT=fft(M(:,1));
channelB_FFT = fft(M(:,2));
channelC_FFT = fft(M(:,3));
channelD_FFT = fft(M(:,4));

phaseDiff_A_B = phase(channelA_FFT)-phase(channelB_FFT);
phaseDiff_A_C = phase(channelA_FFT)-phase(channelC_FFT);
phaseDiff_A_D = phase(channelA_FFT)-phase(channelD_FFT);

figure(1)
subplot(2,1,2)
stem(phase(channelA_FFT))
ylabel('phase')
subplot(2,1,1)
stem(abs(channelA_FFT))
ylabel('mag')

figure(2)
subplot(2,1,2)
stem(phase(channelB_FFT))
ylabel('phase')
subplot(2,1,1)
stem(abs(channelB_FFT))
ylabel('mag')