function CallBackTimerStart(obj, event, string_arg)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    %disp(sprintf('Hello World!X=%d y=%d',1,1)) ;
    %out=12;
    disp('Start');
    XX=get(obj,'UserData');
    XX.CountDown=get(obj,'TasksToExecute');
    set(obj,'UserData',XX);

end

