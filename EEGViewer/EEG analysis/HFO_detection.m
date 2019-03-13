function [detected_events , Norm_filtered_data , locs , pks , event_exist] = HFO_detection(filtered_data, Threshold , elec , HFO) 
% HFO_detection function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning('off','all')
event_exist = 0;

% assumes data is already standardized
Norm_filtered_data          = filtered_data.trial{1}(elec,:);

Std_Ref_Norm_filtered_data  =  std(Norm_filtered_data);
Threshold_event             = Threshold * Std_Ref_Norm_filtered_data;
[pks,locs]                  = findpeaks_native(Norm_filtered_data, 'MinPeakHeight' , Threshold_event);

[m , n] = size(locs);
if (n~=0) && (m~=0) %beginning of the real event_detection if some peaks are detected
    for i = 1:n
        locs(1,i) = filtered_data.time{1}(1, locs(1,i));
    end

    peak = transpose(locs);
    peak_amp = transpose(pks);
    
    %make the dimension in mseconds
    peak = peak * (1000);
    %%find the difference between two peaks in sequence
    Diff_peaks = diff(peak);

    % add the vector to the peak matrix
    for i=1:size(Diff_peaks)
        peak (i,2) = Diff_peaks(i);
    end

    %find the ones that have the right differences between peaks --> place 1 in the next column if true, if not place 2 in the column after
    [m,~] = size(peak);
    
    %save the amp in the column that is not used 
    for i = 1:m
        peak(i,6) = peak_amp(i,1);
    end
   

    if m >= 4 % if it is not then it already does not meet the 4 oscillation criteria
        switch HFO % in case it is ripples or fast ripples the distance between the peaks to be considered are different
             case 'Ripples'
             T1 = 5 ; T2 = 12.5;
             case 'Fast_Ripples'
             T1 = 2 ; T2 = 4; 
        end % end for switch

        for i=1:m
           if  (peak(i,2) >= T1) && (peak(i,2) <= T2) &&  (peak(i+1,2) >= T1) && (peak(i+1,2) <= T2) &&  (peak(i+2,2) >= T1) && (peak(i+2,2) <= T2)  &&  (peak(i+3,2) >= T1) && (peak(i+3,2) <= T2)
           peak(i,3) = 1;
           peak(i+1,3) = 1;
           peak(i+2,3) = 1; 
           peak(i+3,3) = 1;
           peak(i+4,3) = 1;
           end
           if  (peak(i,2) < T1)||(peak(i,2) > T2)
           peak(i,4)=2;
           end
        end
    
        % place 1000 at the start of every event sequence and 2000 at the end of them to avoid i==0 in the for loop which is coming after
        if peak(1,3)==1
        peak(1,5)=1000;
        end

        for i=2:m
            if (peak(i,3)==1) && (peak(i-1,4)==2)
            peak(i,5)=1000;
            end
            if (peak(i,3)==1) && (peak(i,4)==2)
            peak(i,5)=2000;
            end
        end   

        % Keep the ones with more than 4 oscillation in a sequence and store them
        % in detected_events
        j=1;
        for i=1:m
            if peak(i,3) == 1
            detected_events(j,1) = peak(i,1);
            detected_events(j,2) = peak(i,5);
            detected_events(j,3) = peak(i,6);
            j=j+1;
            end
        end

        if j==1 
        event_exist =0;
        detected_events = 0;
        end 
        
    else
    j = 1; %this one is needed since the next condition needs j to be there
    event_exist =0;
    detected_events = 0;
    end % end for if m>=4

if (j~=1) && (m >= 4)
    event_exist = 1; 
end
else 
    %locs(1,1) = 0;
    %pks(1,1) = 0;
    detected_events = 0;
end % end for if (n~=0) && (m~=0)
       

end % end of HFO_detection function