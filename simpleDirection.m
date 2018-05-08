fs = 42000;
T = 1/fs;
N =2047
d=3*.0475;



M = csvread('dataTestLong2.csv');
figure(1)
stem(M(2:end,4))
title('signal 4')
M(:,1) = M(:,1)/max(M(:,1));
M(:,2) = M(:,2)/max(M(:,2));
M(:,3) = M(:,3)/max(M(:,3));
M(:,4) = M(:,4)/max(M(:,4));

% for j = 1:4
%     for i = 3:length(M(:,1))
%         M(i,j)= mean(M(i-2:i,j));
%     end
% end
figure(2)
stem(M(:,1))
title('Signal 1')
theta=0;
b=400
for i = [0:4]
    
    corrAD= xcorr(M(1+(b*i):b*(i+1),1),M(1+(b*i):b*(i+1),4));

    [a,k] = max(abs(corrAD));
    figure(3);
    stem(corrAD);
    title('corralation')
    temp = acos(abs(-b+k)*343/(fs*d))
    theta = theta + temp;


end
asdf =180*theta/5/pi
figure(4)

aoeu = fft(M(:,4));
subplot(2,1,1)

stem(abs(aoeu(2:300)))
title('DFT')
subplot(2,1,2)
stem(phase(aoeu(2:300)))

delay  =((-800+k)*343/fs);
(delay^2 + d^2)/(2*delay - 2*d*cos(pi/2-theta))