function [ distance, theta ] = CosFunction2( channelA, channelB, channelC, channelCnumber )
%% Input arguments are 3 channels, the first being the reference channel (always channel 1), and the other two channels will be 
%% channel 2 and 3 respectively, for the first calculation, and 2 and 4 for the second calculation (both will be averaged).
%%For the first calculation, enter in 3 for the 4th input on the first
%%calculation, and 4 for the second calculation (in order to correct for
%%distances between the channels 3 and 2, vs 4 and 2 for the 2nd
%%calculation. The output will be distance and angle, as represented by
%%using channel 2 as the source of theta, and vector (2-1) as 0 degrees.

distanceMic = 0.05;
freq = 93300; 
SecondMicNumber = channelCnumber;    
LongerMicDistance = distanceMic*(SecondMicNumber-1);

channelA2 = channelA - min(channelA);
channelB2 = channelB - min(channelB);
channelC2 = channelC - min(channelC);

corr = xcorr(channelA2, channelB2); %xcoor must be translated into C++
corr2 = xcorr(channelA2, channelC2);

figure(1)
stem(corr)

figure(2)
stem(corr2)


[m,n] = max(corr);
[o,p] = max(corr2);

%Midway point is at 254.5 or ~255
delta = abs(n - 255)
delta2 = abs(p - 255)


%Rounded to full integers, notice how far from 20m the final distance
%diverges

t = (delta)/freq;
l = (t*343); %finding the length of the delta length from source
theta = acosd(l/distanceMic);

t2 = (delta2)/freq;
l_2 = (t2*343); %finding the length of the delta length from source
theta2 = acosd(l_2/(LongerMicDistance));
lastTheta = 180-(180-theta)-theta2;

distance = sind(theta2)*(distanceMic*(channelCnumber-2))/sind(lastTheta);


 if 255 - p < 0;
   theta = 180 - theta;
 end


end

