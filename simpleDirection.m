fs = 42000;
T = 1/fs;
N =2047
d=3*.0475;

clear M

  M = csvread('459Hz_90d_70cm.csv');
% M = csvread('459Hz_80d_70cm.csv');
% M = csvread('459Hz_70d_70cm.csv');
% M = csvread('459Hz_60d_70cm.csv');
% M = csvread('459Hz_50d_70cm.csv');
figure(1)
stem(M(2:end,4))
title('signal 4')
%M(:,1)-min(M(:,1)); 
M(:,1)./max(M(:,1));
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
b=2047;
for i = [0:4]
    
   % corrAD= xcorr(M(1+(b*i):b*(i+1),1),M(1+(b*i):b*(i+1),4));
corrAD= xcorr((M(:,1)));
corrAD(b) = corrAD(b)/9
    [a,k] = max(abs(corrAD));
    figure(3);
    stem(corrAD);
    title('corralation')
    temp = acos(abs(-b+k)*343/(fs*d))
    theta = theta + temp;


end
temp*180/pi
% 
% corrAD= xcorr(A, B);
% 
% [x, l] = max(abs(corrAD));
% 
% lag = abs(N/2 - l);
% 
% asdf =acosd(l/d)
% figure(4)

% aoeu = fft(M(:,4));
% subplot(2,1,1)
% 
% stem(abs(aoeu(2:300)))
% title('DFT')
% subplot(2,1,2)
% stem(phase(aoeu(2:300)))
% 
% delay  =((-800+k)*343/fs);
% (delay^2 + d^2)/(2*delay - 2*d*cos(pi/2-theta))