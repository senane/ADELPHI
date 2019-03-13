function CallBackTimer(obj, event, string_arg)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    
    XX=get(obj,'UserData');
    XX.CountDown=XX.CountDown-1;
    disp(sprintf('CountDown=%d',XX.CountDown)) ;
    set(obj,'UserData',XX);

end

