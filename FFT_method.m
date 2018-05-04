fs = 16000;
T = 1/fs;

M = csvread('dataTest.csv');
figure(3)
stem(M(:,4))
M(:,1) = M(:,1)/max(M(:,1));
M(:,2) = M(:,2)/max(M(:,2));
M(:,3) = M(:,3)/max(M(:,3));
M(:,4) = M(:,4)/max(M(:,4));

for j = 1:4
    for i = 3:length(M(:,1))
        M(i,j)= mean(M(i-2:i,j));
    end
end
channelA_FFT=fft(M(:,1));
channelB_FFT = fft(M(:,2));
channelC_FFT = fft(M(:,3));
channelD_FFT = fft(M(:,4));


stem(M(:,4))
phaseDiff_A_B = 1.*(-phase(channelA_FFT)+phase(channelB_FFT));
phaseDiff_A_C = 1.*(-phase(channelA_FFT)+phase(channelC_FFT));
phaseDiff_A_D = 1.*(-phase(channelA_FFT)+phase(channelD_FFT));

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


delta_L = 343.*phaseDiff_A_B(35:45).*T./(2*pi);

angles =  abs(acos(delta_L/.0457));%*180/pi;
angles*180/pi
d =.0475;
%L = (delta_L.^2 - delta_L* + .0457^2)./(delta_L.*(-1))

%L2 = (.0457^2)./delta_L

L3 = (delta_L.^2 + d^2 - delta_L.*d.*cos(angles));
L3 = L3./(d.*cos(angles)-2.*delta_L)
