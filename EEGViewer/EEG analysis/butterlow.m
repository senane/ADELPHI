function data_filtered = butterlow(data, Fl, Fs)

    Fcl=2*Fl/Fs;
    orderl = 7;
    [bl,al] = butter(orderl, Fcl, 'low');

    data_filtered = data;
    data_filtered = filtfilt(bl, al, data_filtered);
end