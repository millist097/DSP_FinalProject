
%Assumed to be the input data
a = zeros(1, 255);
b = zeros(1, 255);
c = zeros(1, 255);
d = zeros(1, 255);

a(50) = 1000; %Channel 1 (Always present in the functions)
b(68) = 1000; %Channel 2 (angle and distance reference)
c(123) = 1000;%Channel 3 further from channel 1 than channel 2
d(214) = 1000;%Channel 4 further from channel 1 than channel 3

%In this case, the sound is assumed to originate 20 meters directly above
%channel 1. 


%How the functions will be called in a running program continously
[distance,bearing] = CosFunction2(a, b, c, 3)
[distance2,bearing2] = CosFunction2(a, b, d, 4)

distanceAvg = (distance+distance2)/2
bearingAvg = (bearing+bearing2)/2
