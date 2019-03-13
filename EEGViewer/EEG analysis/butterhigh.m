function data_filtered = butterhigh(data, Fh, Fs)

    Fch=2*Fh/Fs;
    orderh = 7;
    [bh,ah] = butter(orderh, Fch, 'high');

    data_filtered = data;
    data_filtered = filtfilt(bh, ah, data_filtered);
end