fs = 42000;
T = 1/fs;
N = 2047;
d=3*.0475;

clear M

% M = csvread('459Hz_90d_70cm.csv');
% M = csvread('459Hz_80d_70cm.csv');
% M = csvread('459Hz_70d_70cm.csv');
% M = csvread('459Hz_60d_70cm.csv');
 M = csvread('459Hz_50d_70cm.csv');
% M = csvread('dataTestLong.csv');
figure(1)
stem(M(2:end,4))
title('signal 4')
%M(:,1)-min(M(:,1)); 
M(:,1)=M(:,1)./max(M(:,1));
% M(:,2) = M(:,2)/max(M(:,2));
M(:,4) = M(:,4)./max(M(:,4));
%B =M(:,4)-min(M(:,4));% = M(:,4)/max(M(:,4));

% for j = 1:4
%     for i = 3:length(M(:,1))
%         M(i,j)= mean(M(i-2:i,j));
%     end
% end
figure(2)
stem(M(:,1))
title('Signal 1')
theta=0;
N=2047;
for i = [0:4]
    
   % corrAD= xcorr(M(1+(b*i):b*(i+1),1),M(1+(b*i):b*(i+1),4));
corrAD= xcorr((M(:,1)));
corrAD(N) = corrAD(N)/9;
    [a4,k] = max(abs(corrAD));
    figure(3);
    stem(corrAD);
    title('corralation')
    temp = acos(-N+k*343/(fs*d));
    theta = theta + temp;


end
temp*180/pi;
% 
% corrAD= xcorr(A, B);
% 
% [x, l] = max(abs(corrAD));
% 
% lag = abs(N/2 - l);
% 
% asdf =acosd(l/d)

aoeu4 = fft(M(:,4));
aoeu1 =fft(M(:,1));

mag4 = abs(aoeu4);
mag1 = abs(aoeu1);
[a4,b4]=max(mag4  );
[a1,b1] = max( mag1);
mag4 = mag4.*.01;
mag1 = mag1.*.01;
mag4(b4)=a4;
mag4(1)=0;
mag1(b1)=a1;
mag1(1)=0;
clean4 = real(ifft(mag4.*exp(j*(phase(aoeu4)))));
clean1 = real(ifft(mag1.*exp(j*(phase(aoeu1)))));
figure(5)
subplot(2,1,1)
stem(clean1)
subplot(2,1,2)
stem(clean4)

corrAD = xcorr(clean1(100:300)./max(clean1),clean4(100:300)./max(clean4));
N=200;
d=3*.0475;
figure(6)
stem(corrAD)
[a4,k] = max(corrAD);
    title('corralation')
    temp = acos(abs(-N+k)*343/(fs*d))*180/pi
% 
% delay  =((-800+k)*343/fs);
% abs((delay^2 + d^2)/(2*delay - 2*d*cos(pi/2-theta)))