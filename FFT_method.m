fs = 42000;
T = 1/fs;

M = csvread('dataTestLong.csv');
figure(3)
stem(M(2:end,4))
M(:,1) = M(:,1)/max(M(:,1));
M(:,2) = M(:,2)/max(M(:,2));
M(:,3) = M(:,3)/max(M(:,3));
M(:,4) = M(:,4)/max(M(:,4));

for j = 1:3
    for i = 3:length(M(:,1))
        M(i,j)= mean(M(i-2:i,j));
    end
end
channelA_FFT = fft(M(:,1));
channelB_FFT = fft(M(:,2));
channelC_FFT = fft(M(:,3));
channelD_FFT = fft(M(:,4));


stem(M(:,4))
phaseDiff_A_B = -1.*(-phase(channelA_FFT)+phase(channelB_FFT));
phaseDiff_A_C = -1.*(-phase(channelA_FFT)+phase(channelC_FFT));
phaseDiff_A_D = -1.*(-phase(channelA_FFT)+phase(channelD_FFT));

figure(1)
subplot(2,1,2)
stem(phase(channelA_FFT))
ylabel('phase')
subplot(2,1,1)
stem(abs(channelA_FFT(2:end)))
ylabel('mag')

figure(2)
subplot(2,1,2)
stem(phase(channelB_FFT))
ylabel('phase')
subplot(2,1,1)
stem(abs(channelB_FFT(2:end)))
ylabel('mag')
d =.0475;

delta_L_AD = 343.*phaseDiff_A_D(45:65).*T./(2*pi);
delta_L_AC = 343.*phaseDiff_A_C(45:65).*T./(2*pi);
delta_L_AB = 343.*phaseDiff_A_B(45:65).*T./(2*pi);

angles_AD =  acos(delta_L_AD/(d*3));%*180/pi;
a_AD = mean(angles_AD)*180/pi
angles_AC =  acos(delta_L_AC/(d*2));%*180/pi;
a_AC = mean(angles_AC)*180/pi
angles_AB =  acos(delta_L_AB/d);%*180/pi;
a_AB = mean(angles_AB)*180/pi

d =.0475;
%L = (delta_L.^2 - delta_L* + .0457^2)./(delta_L.*(-1))

%L2 = (.0457^2)./delta_L

L3_AD = (delta_L_AD.^2 + (3*d)^2 - delta_L_AD.*(3*d).*cos(angles_AD));
L3_AD = L3_AD./((3*d).*cos(angles_AD)-2.*delta_L_AD);
mean(L3_AD)
L3_AC = (delta_L_AC.^2 + (2*d)^2 - delta_L_AC.*(2*d).*cos(angles_AC));
L3_AC = L3_AC./((2*d).*cos(angles_AC)-2.*delta_L_AC);
mean(L3_AC)
L3_AB = (delta_L_AB.^2 + d^2 - delta_L_AB.*d.*cos(angles_AB));
L3_AB = L3_AB./(d.*cos(angles_AB)-2.*delta_L_AB);
mean(L3_AB)





FinAngleSource = mean((180 - (180 - angles_AC*180/pi)- angles_AD*180/pi));
FinAngleCh4 = mean((180 - angles_AC*180/pi));

Distance = sind(FinAngleCh4)*2*.0457/sind(FinAngleSource)