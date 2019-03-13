function data_out = preproc(data,Fs,bDetrend)  

% bandstop filter line noise (60Hz) and harmonics
for i_chan=1:size(data,2)
    data(:,i_chan) = notch_filter(data(:,i_chan), 60, 4, Fs);
    data(:,i_chan) = notch_filter(data(:,i_chan), 120, 8, Fs);
    data(:,i_chan) = notch_filter(data(:,i_chan), 170, 10, Fs);
end

if bDetrend
    % remove DC component
    for i_chan=1:size(data,2)
        data(:,i_chan) = data(:,i_chan)-mean(data(:,i_chan));
    end
end

data_out=data;