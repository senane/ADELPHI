function [ Y ] = notch_filter( data,f0, Bw , Fs)
% notch filter  notch filter (Butterworth filter, bandwidth = 4 Hz, order = 3).
% f0= frequency that has to be removed
% Bw = bandwidth in Hz 

Wn = [2*(f0-Bw/2)/Fs 2*(f0+Bw/2)/Fs];  
N = 3;
[b,a] = butter(N,Wn, 'stop'); 
Y = filtfilt(b,a,data);

end

