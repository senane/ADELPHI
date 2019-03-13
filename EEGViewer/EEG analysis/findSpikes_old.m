function [spikes] = findSpikes(data, Fs, threshold)

deriv_zcross = zcross(diff(data));
% consider only the zero crossing that happen below threshold
bool_zcross = false(length(data),1);
bool_zcross(deriv_zcross) = true(length(deriv_zcross),1);
bool_belowthreshold = abs(data)<threshold(1);
deriv_zcross = find(and(bool_zcross,bool_belowthreshold));

i_spike = 0;
spikes = [];
i=1;
while i<=length(data)
    if abs(data(i))>threshold(1) && abs(data(i))<threshold(2)
        ii_end = find(deriv_zcross>i,1,'first');
        ii_beg = find(deriv_zcross<i,1,'last');
        if isempty(ii_end)
            i_end = length(data);
        else
            i_end = deriv_zcross(ii_end);
        end
        if isempty(ii_beg)
            i_beg = 1;
        else
            i_beg = deriv_zcross(ii_beg);
        end
        
        duration = (i_end-i_beg)/Fs*1000; %[ms]
        if duration>20 && duration<150
           i_spike = i_spike+1;
           spikes(i_spike).i_beg = i_beg;
           spikes(i_spike).i_end = i_end;
           spikes(i_spike).duration = duration;
           spikes(i_spike).amp = max(data(i_beg:i_end));
        end     
        i=i_end;
    else
       i=i+1; 
    end
end



end