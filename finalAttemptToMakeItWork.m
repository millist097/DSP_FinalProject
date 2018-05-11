[sig1 fs]= audioread('DataSets/duelChannelTest.wav');

left = sig1(:,1)/max(sig1(:,1));
right = sig1(:,2)/max(sig1(:,2));

for i = 10:length(left)
    left(i) = mean(left(i-9:i));
    right(i) = mean(left(i-9:i));
end


t = [1:length(left)]/fs;

plot(t,left)

shortL_1 = left(round(.79*fs):round(1*fs)-1);
shortR_1 = right(round(.79*fs):round(1*fs)-1);
shortR_2 = right(round(3.5*fs):round(3.89*fs)-1);
shortL_2 = left(round(3.5*fs):round(3.89*fs)-1);

figure(2)
subplot(2,1,1)
plot(shortL_1)
subplot(2,1,2)
plot(shortR_1)
angle = 0;
d=3*.0475;
for i =1:17
    corrLR = xcorr(shortR_2((i-1)*500+1:i*500),...
                   shortL_2((i-1)*500+1:i*500));
    plot(corrLR)
    %pause
    [a,n]=max(corrLR);
    n = n-500;
    temp = acos(abs(n)*343/(fs*d))*180/pi
    angle = angle + temp;
end


angle/17
