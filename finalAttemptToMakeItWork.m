[sig1 fs]= audioread('DataSets/threeHellos_andaclap.wav');

left = sig1(:,1)/max(sig1(:,1));
right = sig1(:,2)/max(sig1(:,2));


t = [1:length(left)]/fs;

plot(t,left)

shortL_3 = left(round(5.106*fs):round(5.393*fs)-1);
shortR_3 = right(round(5.106*fs):round(5.393*fs)-1);
shortR_clap = right(round(9.89*fs):round(10.13*fs)-1);
shortL_clap = left(round(9.89*fs):round(10.13*fs)-1);
shortL_1 = left(round(.879*fs):round(1.184*fs)-1);
shortR_1 = right(round(.879*fs):round(1.184*fs)-1);
shortL_2 = left(round(3.102*fs):round(3.412*fs)-1);
shortR_2 = right(round(3.102*fs):round(3.412*fs)-1);


figure(2)
subplot(2,1,1)
plot(shortL_1)
subplot(2,1,2)
plot(shortR_1)
angle = 0;
d=3*.035;
figure(3)
k = 50;

for i =1:200
    corrLR = xcorr(shortL_clap((i-1)*k+1:i*k),...
                   shortR_clap((i-1)*k+1:i*k));
    plot(corrLR)
    
    %pause
    [a,n(i)]=max(corrLR);
    n(i) = n(i)-k;
    temp = acos(abs(n(i))*343/(fs*d))*180/pi
    angle = angle + temp;
end


angle/200
