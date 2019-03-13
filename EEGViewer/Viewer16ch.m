function varargout = Viewer16ch(varargin)
% VIEWER16CH MATLAB code for Viewer16ch.fig
%      VIEWER16CH, by itself, creates a new VIEWER16CH or raises the existing
%      singleton*.
%J
%      H = VIEWER16CH returns the handle to a new VIEWER16CH or the handle to
%      the existing singleton*.
%
%      VIEWER16CH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWER16CH.M with the given input arguments.
%
%      VIEWER16CH('Property','Value',...) creates a new VIEWER16CH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Viewer16ch_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Viewer16ch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Viewer16ch


% Last Modified by GUIDE v2.5 12-Mar-2019 20:26:00



% To Do !!!
% Implement pan button shortcut
% Implement window update from text
% Implement analysis tools


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Viewer16ch_OpeningFcn, ...
                   'gui_OutputFcn',  @Viewer16ch_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Viewer16ch is made visible.
function Viewer16ch_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Viewer16ch (see VARARGIN)

% Choose default command line output for Viewer16ch
handles.output = hObject;

%MODIFIED 10/31/2016 Marcio - 11/15 Senan
%My Own GLOBAL VARIABLES (Separate space in handles object)
%Some of these variables are internal settings, other change at runtime
global bBusy;

handles.ProgressBarPos=0;
handles.ProgressBarMAX=50;
handles.MovieClip=0;
handles.NChannels=4;
handles.SampRate=1000;
handles.window_loaded = 0;
handles.progThresh=0;  
handles.windowsize = 30; %seconds
handles.TLleft = 0; % left limit of x axis of timeline
handles.TLright = 0; % right limit of x axis of timeline
handles.globaltime = 0; % tracks where in the timeline we are looking (time in min)
handles.window_deltaT = 0; % tracks delta between start of the file and the window position (time in min)
handles.SpectWndSize=1; %spectrogram window size and overlap
handles.SpectWndOVR=0;
handles.SpectNFFT=1024;
handles.SpectFmin=0;
handles.SpectFmax=100;
handles.SpectChannel=1;
handles.window_events = 10000;
handles.threshold_events = 0;
handles.threshold_SD_events = 0;
handles.overlap_window_events = 0;
handles.num_decision_windows = 5;
handles.num_positive_windows = 4;
handles.method_events = 1;
handles.method_names = {'Coastline', 'Power', 'Band power', 'LassoGLM'};

% % define, for each method that was defined to find events, what parameters
% % can be set 
% handles.method_params{1} = [];
% handles.method_params{2} = [];
% handles.method_params{3} = {'Frequency'};
% handles.method_params{4} = [];
% % also specfify default values for these parameters (as strings)
% handles.method_defaults{1} = [];
% handles.method_defaults{2} = [];
% handles.method_defaults{3} = {'8 12'};
% handles.method_defaults{4} = [];

handles.ed_ep1.String = num2str(handles.window_events/handles.SampRate);
handles.ed_ep2.String = num2str(handles.threshold_events);
handles.ed_ep3.String = num2str(handles.threshold_SD_events);
handles.ed_ep4.String = num2str(handles.num_decision_windows);
handles.ed_ep5.String = num2str(handles.overlap_window_events);
handles.ed_ep6.String = num2str(handles.num_positive_windows);
handles.popupmenu_eventtype.String = handles.method_names;
handles.ev_channels = [1 1 1 1];
handles.event_labels_texts = {'Seizure', 'Artifact', 'Delete label'};
handles.bins_sorted = [];
handles.events_info = [];
handles.events = [];
handles.general_info = [];
handles.events_mode = 0; % 0: AND / 1: OR
handles.checkboxAnd.Value = 1;
handles.checkboxOr.Value = 0;
handles.datawindow = [];
handles.bPipeline = false;
bBusy = false;
handles.list_lastitem = 1;
handles.sorting_type = 1; %1: date, 2: duration
% consistent channel colors (up to 16)
handles.channels_colors =      [0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
      0         0    1.0000
         0    0.5000         0
    1.0000         0         0
         0    0.7500    0.7500
    0.7500         0    0.7500
    0.7500    0.7500         0
    0.2500    0.2500    0.2500
    0.7       0.7       0.7
    1         1         0];  
handles.EEG_vertical_offset = 1.5;
handles.video_formats =  {'.mp4', '.avi'};
filteringoptions.bandstop = false;
filteringoptions.bandstop_freq_low = 58;
filteringoptions.bandstop_freq_high= 62;
filteringoptions.bandpass = false;
filteringoptions.bandpass_freq_low = 8;
filteringoptions.bandpass_freq_high= 20;
% filteringoptions.highpass = false;
% filteringoptions.highpass_freq = 120;
handles.filtering_options = filteringoptions;
handles.bNorm = false;

addpath(genpath('EEG analysis'))
% NF: create a context menu for the listbox so events can be labelled
c = uicontextmenu;
% create items in the menu that correspond to the labels
for i_item = 1:length(handles.event_labels_texts)
    uimenu(c, 'Label', handles.event_labels_texts{i_item}, 'Callback', {@labelEvent, handles, hObject});

end
handles.listbox1.UIContextMenu = c;
set(gcf, 'color', 'w');

% Helps iniltialize listbox1 and event detection info object
handles = updateEventsList(handles);
updateGeneralInfoWindow(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Viewer16ch wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Viewer16ch_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% NEED TO IMPLEMENT / DEBUG
% TEST

% is this still useful? !!!

pos = get(hObject,'Value');
Yrange = get(handles.axesEPhys,'YLim');
Xrange = get(handles.axesEPhys,'XLim');
Ythresh = (Yrange(2) - Yrange(1))*(pos/100) + Yrange(1);
axes(handles.axesEPhys);
hold off;
for k=1:4
    if (get(handles.(strcat('chbox_ch',num2str(k))),'Value'))
        plot(handles.chdata(:, (k+1)));
        hold on;
    end
end
set (handles.axesEPhys,'XLim',Xrange,'YLim',Yrange);
plot(Xrange, [Ythresh Ythresh]);
hold off;
handles.progThresh=Ythresh;
guidata (hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function axesPanView_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesPanView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesPanView
set(gca, 'YTick', [])
set(gca, 'YTicklabel', [])

% --------------------------------------------------------------------
function menu_SigParam_Callback(hObject, eventdata, handles)
% hObject    handle to menu_SigParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Untitled_7_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function testtab_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bBusy;

if ~bBusy
    handles=PlotEEG(handles);

    ax = handles.axesPanView;
    handles.TLleft = ax.XLim(1);
    handles.TLright = ax.XLim(2);
    handles=PlotTimeline(handles, true);

    %handles = LoadVid(handles);
end
guidata(hObject,handles);

function edit_sec_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec as text
%        str2double(get(hObject,'String')) returns contents of edit_sec as a double


% --- Executes during object creation, after setting all properties.
function edit_sec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_min_Callback(hObject, eventdata, handles)
% hObject    handle to edit_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_min as text
%        str2double(get(hObject,'String')) returns contents of edit_min as a double


% --- Executes during object creation, after setting all properties.
function edit_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_hour_Callback(hObject, eventdata, handles)
% hObject    handle to edit_hour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_hour as text
%        str2double(get(hObject,'String')) returns contents of edit_hour as a double


% --- Executes during object creation, after setting all properties.
function edit_hour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_hour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_date_Callback(hObject, eventdata, handles)
% hObject    handle to edit_date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_date as text
%        str2double(get(hObject,'String')) returns contents of edit_date as a double


% --- Executes during object creation, after setting all properties.
function edit_date_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_windowsize_Callback(hObject, eventdata, handles)
% hObject    handle to ed_windowsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_windowsize as text
%        str2double(get(hObject,'String')) returns contents of ed_windowsize as a double


% --- Executes during object creation, after setting all properties.
function ed_windowsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_windowsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% !!!vid
% --- Executes on button press in pb_play.
% function pb_play_Callback(hObject, eventdata, handles)
% hObject    handle to pb_play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%movie(immovie(handles.frames), 1, handles.framerate_est);
% global bVideoStopped;
% axes(handles.axesVideo)
% for i=handles.i_play:size(handles.frames,4)
%     tic
%     imshow(handles.frames(:,:,:,i))
%     %handles = updateVideotime(handles, i/size(handles.frames,4));
%     drawnow;
%     toc
%     pause(1/handles.framerate_est);
%     if bVideoStopped
%         bVideoStopped = false;
%         handles.i_play = 1;
%         axes(handles.axesVideo)
%         imshow(handles.frames(:,:,:,1))
%         break;
%     end
% end
% guidata(hObject,handles);

% --- Executes on button press in stopvideo.
%  function stopvideo_Callback(hObject, eventdata, handles)
% hObject    handle to stopvideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global bVideoStopped;
% bVideoStopped = true;


% --- Executes during object creation, after setting all properties.
% function axesVideotime_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to axesVideotime (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: place code in OpeningFcn to populate axesVideotime
% % box on
% % area([0 0], [1 1])
% % xlim([0 1])
% % set(gca,'xtick',[])
% % set(gca,'xticklabel',[])
% % set(gca,'ytick',[])
% % set(gca,'yticklabel',[])
% % handles.axesVideotime = gca;
% % guidata(hObject,handles);


% function handlesOut = updateVideotime(handles, val)
% % updates the video time bar
% axes(handles.axesVideotime);
% area([0 val], [1 1])
% xlim([0 1])
% set(gca,'xtick',[])
% set(gca,'xticklabel',[])
% set(gca,'ytick',[])
% set(gca,'yticklabel',[])
% handlesOut = handles;


% xleft = handles.axesEPhys.XLim(1);
% deltaT = handles.window_deltaT*60 + xleft; %convert to seconds, adding EEG window zoom offset
% Tindex=floor(deltaT*10);
% framenumber = handles.ctsframes(Tindex);
% ActualFrameRate= framenumber /(Tindex/10); %Might be a poor estimate.
% 
% WMPtime = framenumber / 30;
% 
% %Adjusting rate
% rate= ActualFrameRate/30;
% 
% mc = handles.hvid;
% mc.settings.rate = rate;
% mc.controls.currentPosition = WMPtime;
% mc.Controls.play;
% % hold off;
% % axes(handles.axesVideo);
% %          % Read one frame at a time.
% %             for k = 1 : size(handles.MovieClip, 1)
% %                  image(squeeze(handles.MovieClip(k,:,:,:)));
% %                  set(handles.axesVideo,'xtick',[],'ytick',[]);
% %                  pause(1/30);
% %                  % Todo - fix to handles
% %                  %pause(1/1000);
% %                  %movie (mov);
% %                  
% %                  if (rem(k,30)==0)
% %                      set(handles.textFameNum,'string',num2str(floor(k/30))); 
% %                  end
% %                      
% %                      
% %                  drawnow;
% %             end



% --- Executes on button press in loadvideo.
function loadvideo_Callback(hObject, eventdata, handles)
% hObject    handle to loadvideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% !!!vid
%%% VIDEO READING:
% can handle 3 different types of videos
% 1: video with same name as .bin and .cts file for timing
% 2: video with same name as .bin without .cts file, frame rate is assumed
% to be constant and calculated from duration and number of frames
% 3: video with different name as .bin, frame rate assumed to be constant

% find video corresponding to current recording
rec_id = find(handles.globaltime<handles.bins_sorted.endtime,1);
% first try to find video with matching name (old format)
vid_name = handles.bins_sorted.name{rec_id}(1:end-4);
vid_path = handles.bins_sorted.filepath;
formats = handles.video_formats; 
bSuccess = false;
for i_f = 1:length(formats)
   try  %#ok<TRYNC>
       vidstr = [vid_path vid_name formats{i_f}];
       v = VideoReader(vidstr);  %#ok<TNMLP>
       bSuccess = true;
       break;
   end
end
if ~bSuccess
    % if loading video with same name didn't work, try to find video that
    % contains that recording
    rec_id_vid = find(handles.globaltime>handles.bins_sorted.video_starttime);
    if ~isempty(rec_id_vid)
       rec_id_vid = rec_id_vid(end);
       vid_name = handles.bins_sorted.video_names{rec_id_vid}(1:end-4);
       vid_path = handles.bins_sorted.filepath;
       formats = handles.video_formats; 
       for i_f = 1:length(formats)
          try  %#ok<TRYNC>
              vidstr = [vid_path vid_name formats{i_f}];
              v = VideoReader(vidstr);  %#ok<TNMLP>
              bSuccess = true;
              break;
          end
       end 
       if bSuccess
           % get the time of the video
           deltaT_video = floor((handles.globaltime-handles.bins_sorted.video_starttime(rec_id_vid))*60);
           bSuccess = false;
           if deltaT_video<v.Duration
               h = waitbar(0, 'Opening video file');
               vidFrame = readFrame(v);
               v.CurrentTime = deltaT_video;
               count = 1;
               % here it can be assumed that the frame rate is kept
               dur = floor(handles.windowsize*v.FrameRate);
               while count<=dur && v.hasFrame()
                    vidFrame = readFrame(v);
                    frames(:,:,:,count) = double(vidFrame)/255;
                    count = count+1;
                    waitbar(count/dur, h, 'Loading frames');
               end
               handles.frames = frames;
               handles.i_play = 1;
               axes(handles.axesVideo)
               try 
                   close(handles.videohandle);
               end
               close(h)
               bSuccess = true;
               handles.videohandle = implay(frames, v.FrameRate);
          end
       end
    end   
else
    % check if there is a .cts file with timing info
    % estimate frame rate       
    ctsstr = [vid_path vid_name '.cts'];
    fid = fopen(ctsstr);
    if fid > 0 % the cts file could be opened
        ctsframes = fread(fid, [1 inf], 'uint32', 5*4); % the frame number at each 100ms timepoint recorded by NI
        fclose(fid);
        framerate_est = v.Duration*v.FrameRate/((handles.bins_sorted.endtime(rec_id) - handles.bins_sorted.starttime(rec_id))*60);
        handles.framerate_est = framerate_est;
        % get time of beginning
        deltaT = handles.globaltime - handles.bins_sorted.starttime(rec_id);
        % find corresponding frame number in the cts file
        framenum = ctsframes(floor(deltaT*60*10)); % convert in seconds and then in periods of 100 ms
        % find this frame as a timepoint accounting for the perceived framerate
        curTime = framenum/v.FrameRate;
        % old way !!!
        % curTime = floor(deltaT*60*framerate_est/v.FrameRate);
    else % no cts file found, frame rate is assumed to be consistent
        framerate_est = v.Duration*v.FrameRate/((handles.bins_sorted.endtime(rec_id) - handles.bins_sorted.starttime(rec_id))*60);
        deltaT = handles.globaltime - handles.bins_sorted.starttime(rec_id);
        % time in video in seconds
        curTime = deltaT*60*framerate_est/v.FrameRate;
    end
    vidFrame = readFrame(v);
    v.CurrentTime = curTime; % seconds
    dur = floor(handles.windowsize*framerate_est); % frames
    frames = zeros([size(vidFrame) dur]);

    count = 1;
    h = waitbar(0, 'Opening video file');
    while count<=dur && v.hasFrame()
        vidFrame = readFrame(v);
        frames(:,:,:,count) = double(vidFrame)/255;
        count = count+1;
        waitbar(count/dur, h, 'Loading frames');
    end
    handles.frames = frames;
    handles.i_play = 1;
    axes(handles.axesVideo)
    try  %#ok<TRYNC>
        close(handles.videohandle);
    end
    close(h)
    handles.videohandle = implay(frames, framerate_est);
end

if ~bSuccess
    % all options have been tried to find a video
    errordlg('No corresponding video could be found', 'Error')
end
guidata(hObject,handles);


% !!!vid
% function OutHandles=ProgressBar(handles,StartStop)
% 
% strProgress=repmat('.',1,handles.ProgressBarMAX);
% if (StartStop==1)
%     handles.ProgressBarPos=handles.ProgressBarPos+1; 
%     if (handles.ProgressBarPos>handles.ProgressBarMAX) 
%         handles.ProgressBarPos=1;    
%     end
%     strProgress(handles.ProgressBarPos)='*';    
% else
%     handles.ProgressBarPos=0;
% end
% set(handles.text_videoprogressbar,'string',strProgress);  
% drawnow;
% OutHandles=handles;


% --- Executes on mouse press over axes background.
function axesVideo_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axesPanView_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesPanView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.bins_sorted)
    % Check if a subject is loaded 
    axes(handles.axesPanView);
    t = handles.timeline;
    bs = handles.bins_sorted;
    cP = get(handles.axesPanView,'Currentpoint');

    index = find(bs.endtime > cP(1, 1),1);
    bFileExists= bs.starttime(index) < cP(1, 1);

    subject = handles.bins_sorted.name{1}(1:5);
    handles.window_loaded = 0;
    if (bFileExists)
        strtemp=strcat(['[' subject '] ' 'The file exists: '],bs.name(index));
        deltaT = cP(1,1) - bs.starttime(index);

        handles.window_deltaT = deltaT;
        tempname = bs.name{index};
        handles.window_filename=tempname(1:(length(tempname)-4));
        handles.window_filepath = bs.filepath;
        handles.window_loaded = 1;
    else
        strtemp = ['[' subject '] ' 'NO FILE FOR THE INTERVAL'] ;
    end

    datemod = cP(1,1)/(60*24)+bs.initialtime;

    set(handles.ed_subjname, 'string', strtemp);

    set(handles.edit_date, 'string', datestr(datemod,'YYYY-mmm-DD'));
    set(handles.edit_hour, 'string', datestr(datemod,'HH'));
    set(handles.edit_min, 'string', datestr(datemod,'MM'));
    set(handles.edit_sec, 'string', datestr(datemod,'SS'));

    handles.globaltime = cP(1,1); %globaltime in minutes

    assignin ('base','modtime',handles.globaltime);
    assignin ('base','Ponto',cP);

    handles.TLleft = handles.axesPanView.XLim(1);
    handles.TLright = handles.axesPanView.XLim(2);

    assignin ('base','modtime',handles.globaltime);
    assignin ('base','Ponto',cP);
    assignin ('base','left',handles.TLleft);

    handles=PlotTimeline(handles, true);
end

guidata(hObject, handles);


function ed_subjname_Callback(hObject, eventdata, handles)
% hObject    handle to ed_subjname (see GCBO)

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_subjname as text
%        str2double(get(hObject,'String')) returns contents of ed_subjname as a double


% --- Executes during object creation, after setting all properties.
function ed_subjname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_subjname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_eventtype.
function popupmenu_eventtype_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_eventtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_eventtype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_eventtype
% links pop up menu to the items of the list to allow labeling
selItem = get(hObject,'Value');
handles.method_events = selItem;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_eventtype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_eventtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% !!! delete?
% --- Executes on selection change in popupmenu_viewmodality.
function popupmenu_viewmodality_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_viewmodality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_viewmodality contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_viewmodality


% --- Executes during object creation, after setting all properties.
function popupmenu_viewmodality_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_viewmodality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%% Edit boxes for the event detection parameters
function ed_ep1_Callback(hObject, eventdata, handles)
% hObject    handle to ed_ep1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_ep1 as text
%        str2double(get(hObject,'String')) returns contents of ed_ep1 as a double
handles.window_events = str2double(get(hObject,'String'));
% convert to samples
handles.window_events = round(handles.window_events*handles.SampRate);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ed_ep1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ep1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ed_ep2_Callback(hObject, eventdata, handles)
% hObject    handle to ed_ep2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_ep2 as text
%        str2double(get(hObject,'String')) returns contents of ed_ep2 as a double
handles.threshold_events = str2double(get(hObject,'String'));
handles.ed_ep3.String = '0';
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ed_ep2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ep2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ed_ep3_Callback(hObject, eventdata, handles)
% hObject    handle to ed_ep3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_ep3 as text
%        str2double(get(hObject,'String')) returns contents of ed_ep3 as a double
handles.threshold_SD_events = str2double(get(hObject,'String'));
handles.ed_ep2.String = '0';
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ed_ep3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ep3 (see GCBO)

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ed_ep4_Callback(hObject, eventdata, handles)
% hObject    handle to ed_ep4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_ep4 as text
%        str2double(get(hObject,'String')) returns contents of ed_ep4 as a double
handles.num_decision_windows = str2num(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ed_ep4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ep4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ed_ep5_Callback(hObject, eventdata, handles)
% hObject    handle to ed_ep5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_ep5 as text
%        str2double(get(hObject,'String')) returns contents of ed_ep5 as a double
handles.overlap_window_events = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ed_ep5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ep5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ed_ep6_Callback(hObject, eventdata, handles)
% hObject    handle to ed_ep6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_ep6 as text
%        str2double(get(hObject,'String')) returns contents of ed_ep6 as a double
handles.num_positive_windows = str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ed_ep6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ep6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_loadsubj.
function handlesOut = pb_loadsubj_Callback(hObject, eventdata, handles)
% hObject    handle to pb_loadsubj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% NF: allow for the possibility to use that function specifying a subject
% from the handles and not opening the dedicated ui (if the pipeline mode
% is on)
if handles.bPipeline
    handles = clearEvents(handles);
    temp.filename = handles.pipeline_filename;
    temp.filepath = handles.pipeline_foldername;
else
    [temp.filename, temp.filepath] = uigetfile('*.bin');
    if ~ischar(temp.filename) || ~ischar(temp.filepath)
    	return;
    else
      handles = clearEvents(handles);
      handles = updateEventsList(handles);
      updateGeneralInfoWindow(handles);
    end
end

temp.strDir = dir(temp.filepath);

allsplits = strsplit(temp.filename,'-');
animalname = allsplits{1};
timeline.filepath = temp.filepath;

% NF: read the metadata to obtain the number of channels
% sampling rate bug solved, initialize it here
fid = fopen([temp.filepath temp.filename]);
metadata = fread(fid, 3, 'int'); % contains Fs, nchannels_analog, nchannels_digital
fclose(fid);
handles.SampRate = metadata(1);
handles.NChannels = metadata(2);
nchannels = handles.NChannels;
% NF :create checkboxes as a function of the number of channels (pos 1100
% 450-100)
% max 16 channels
% 2 groups of checkboxes (display and events)
% event detection checkboxes
positions = linspace(450,200,17);
used_positions = (8-floor(nchannels/2):8+ceil(nchannels/2))+1;
positions = positions(used_positions);
handles.ev_channels = ones(1,nchannels);
for i_ch = 1:nchannels
    c = uicontrol(handles.figure1,'Style','checkbox',...
                    'String',['Ch' num2str(i_ch)],...
                    'Value',1,'Position',[1305 positions(i_ch) 50 20], 'Callback', {@eventcheckbox_callback handles hObject});
    c.UserData = i_ch;
end
% displayed channels checkboxes
positions = linspace(450,200,17);
used_positions = (8-floor(nchannels/2):8+ceil(nchannels/2))+1;
positions = positions(used_positions);
handles.display_channels = ones(1,nchannels);
for i_ch = 1:nchannels
    c = uicontrol(handles.figure1,'Style','checkbox',...
                    'String',['Ch' num2str(i_ch)],...
                    'Value',1,'Position',[45 positions(i_ch) 50 20], 'Callback', {@displaycheckbox_callback handles hObject});
    c.UserData = i_ch;
end

samprate = handles.SampRate;
counter = 0;
for k = 1:length(temp.strDir)
   t1 = temp.strDir(k);
   allsplits1 = strsplit(t1.name,'-');
   if (strcmp(animalname,allsplits1{1}))
        starttime=datenum(str2num(allsplits1{2}(1:4)),str2num(allsplits1{2}(5:6)),str2num(allsplits1{2}(7:8)),...
            str2num(allsplits1{3}(1:2)),str2num(allsplits1{3}(3:4)),str2num(allsplits1{3}(5:6)));
        
        % timestamp is included in datastream so use nchannels + 1
        sec = (t1.bytes - 12)/(8*(nchannels+1))/samprate;
        if (sec < 10) 
            sec=10; 
        end
        
        endtime = starttime + sec/(24*3600);
        counter = counter + 1;
        timeline.starttime(counter) = starttime;
        timeline.endtime(counter) = endtime;
        timeline.name{counter} = t1.name;
        
        % 1 for bin, 0 for other
        timeline.type(counter) = double(strcmp('.bin', t1.name((length(t1.name)-3):length(t1.name))));     
        % NF: save video files information in bins_sorted as well!!!
        % type = 2 for video files
        if ~timeline.type(counter)
            bIsVideo = false;
            for i_f = 1:length(handles.video_formats)
                bIsVideo = bIsVideo || ...
                    strcmp(handles.video_formats{i_f}, t1.name((length(t1.name)-3):length(t1.name)));
            end
            timeline.type(counter)=double(2*bIsVideo);
        end         
   end
end

[data_sorted,indices_sorted]=sort(timeline.starttime);

timeline.starttime = timeline.starttime(indices_sorted);
timeline.endtime = timeline.endtime(indices_sorted);
timeline.name = timeline.name(indices_sorted);
timeline.type = timeline.type(indices_sorted);

bins_sorted.filepath = temp.filepath;
bins_sorted.name = timeline.name(find(timeline.type == 1));
bins_sorted.starttime = timeline.starttime(find(timeline.type == 1));
bins_sorted.endtime = timeline.endtime(find(timeline.type == 1));
bins_sorted.type = timeline.type(find(timeline.type == 1));
% add the video names and times
bins_sorted.video_names = timeline.name(find(timeline.type == 2));
bins_sorted.video_starttime = timeline.starttime(find(timeline.type == 2));

%Initial time is saved in days
tempstart = bins_sorted.starttime(1);
bins_sorted.initialtime=tempstart;

%Time will be converted to minutes for this purpose. 
bins_sorted.starttime = (bins_sorted.starttime - tempstart)*24*60;
bins_sorted.endtime = (bins_sorted.endtime - tempstart)*24*60;
bins_sorted.video_starttime = (bins_sorted.video_starttime - tempstart)*24*60;

handles.TLleft = bins_sorted.starttime(1);
handles.TLright = bins_sorted.endtime(length(bins_sorted.endtime));

set(handles.ed_subjname, 'string', ['[' bins_sorted.name{1}(1:5) ']']);

handles.bins_sorted=bins_sorted;
handles.timeline=timeline;
handles=PlotTimeline(handles, false);
% clear EEG and Spect plots
cla(handles.axesSpectro);
cla(handles.axesEPhys);
cla(handles.axesVideo);
guidata(hObject, handles);
handlesOut = handles;


function ReturnHandle=PlotEEG(handles)
% hObject    handle to Untitled_5 (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

global bBusy;

% handles.window_filepath
% handles.window_filename


try
if ~bBusy
%     tic;
    bBusy = true;
    handles.windowsize = str2num(get(handles.ed_windowsize, 'string'));
    opener = strcat(handles.window_filepath, handles.window_filename, '.bin');
    fid = fopen(opener);
    metadata = fread(fid, 3, 'int'); % contains Fs, nchannels_analog, nchannels_digital

    deltaT = handles.window_deltaT*60; %window_deltaT is in minutes so convert to seconds
    handles.SampRate = metadata(1);
    handles.NChannels = metadata(2);

    EEGOffset = floor(deltaT * handles.SampRate) * (handles.NChannels + 1);
    fread(fid, EEGOffset, 'double');

    chdata = fread(fid,[(handles.NChannels + 1), handles.windowsize*handles.SampRate],'double');
    chdata=chdata';
    handles.chdata = chdata;
    if handles.filtering_options.bandstop
        f0 = (handles.filtering_options.bandstop_freq_low+handles.filtering_options.bandstop_freq_high)/2;
        bw = handles.filtering_options.bandstop_freq_high-handles.filtering_options.bandstop_freq_low;
        ch = 2:(handles.NChannels + 1);
        for i_ch = ch(logical(handles.display_channels))
            handles.chdata(:,i_ch) = notch_filter(handles.chdata(:,i_ch),f0,bw,handles.SampRate);
        end
    end
    if handles.filtering_options.bandpass
        fL = handles.filtering_options.bandpass_freq_low;
        fH = handles.filtering_options.bandpass_freq_high;
        ch = 2:(handles.NChannels + 1);
        for i_ch = ch(logical(handles.display_channels))
            handles.chdata(:,i_ch) = butterlow(handles.chdata(:,i_ch),fH,handles.SampRate);
            handles.chdata(:,i_ch) = butterhigh(handles.chdata(:,i_ch),fL,handles.SampRate);
        end
    end
    if handles.bNorm
        for i_ch=1:size( handles.chdata,2)
             handles.chdata(:,i_ch) = handles.chdata(:,i_ch)-mean(handles.chdata(:,i_ch));
             handles.chdata(:,i_ch) = handles.chdata(:,i_ch)/std(handles.chdata(:,i_ch));
        end
    end

    fclose(fid); 
    axes(handles.axesEPhys);
    chanelsToPlot=zeros (1,handles.NChannels);
    TimeAxis=1:1:size(handles.chdata,1);
    TimeAxis=(TimeAxis-1)/handles.SampRate;
    
%     disp('read')
%     toc
    
    % NF: offset to have separate plots of EEG channels
    EEG_vertical_offset = handles.EEG_vertical_offset;
    EEG_offset_counter = 0;
    hold off;
    for k=1:handles.NChannels
        if handles.display_channels(k)
            plot(TimeAxis,squeeze(handles.chdata(:, (k+1)))+EEG_offset_counter*EEG_vertical_offset,...
                'color', handles.channels_colors(k,:));
            % write channel number in text
            text(TimeAxis(end)*1.02, EEG_offset_counter*EEG_vertical_offset, ['ch' num2str(k)], 'color', handles.channels_colors(k,:))
            EEG_offset_counter = EEG_offset_counter+1;
            hold on;
            chanelsToPlot(k)=1;
        end
    end
    if ~isempty(handles.events)
        % find if an event is in the current window to plot 
        ev_info = handles.events_info;
        ev_toplot = [];
        for i_ev = 1:length(ev_info)
            if (ev_info(i_ev).globaltime*60>=handles.globaltime*60 && ev_info(i_ev).globaltime*60<=handles.globaltime*60+handles.windowsize)...
                    || (ev_info(i_ev).globaltime*60+ev_info(i_ev).duration <= handles.globaltime*60+handles.windowsize &&...
                        ev_info(i_ev).globaltime*60+ev_info(i_ev).duration >= handles.globaltime*60) || ...
                        (ev_info(i_ev).globaltime*60<=handles.globaltime*60 && ev_info(i_ev).globaltime*60+ev_info(i_ev).duration >= handles.globaltime*60+handles.windowsize)
                ev_toplot = [ev_toplot i_ev];
            end
        end
        % plot areas for the events found
        for i_ev = 1:length(ev_toplot)
            event_id = ev_toplot(i_ev);
            time = (handles.events_info(event_id).globaltime-handles.globaltime)*60;
            dur = handles.events_info(event_id).duration;
            area([time time+dur], ones(1,2)*sum(chanelsToPlot)*EEG_vertical_offset, 'FaceAlpha', 0.2,...
               'EdgeAlpha', 0.2);
            area([time time+dur], ones(1,2)*-2, 'FaceAlpha', 0.2,...
               'EdgeAlpha', 0.2);
        end
    end
    xlim([0 handles.windowsize])
    ylim([-EEG_vertical_offset/2, (sum(chanelsToPlot)-1/2)*EEG_vertical_offset])
    xlabel('Time (s)');
    ylabel('Voltage (mV)');

    
    hold off;
    WNDsize=handles.SpectWndSize*handles.SampRate;
    WNDovr=handles.SpectWndOVR*handles.SampRate;
    NFFT=handles.SpectNFFT;

    if (isfield(handles, 'chdataSpect'))
        handles=rmfield(handles, 'chdataSpect');
        handles=rmfield(handles, 'chdataSpectFreq');
        handles=rmfield(handles, 'chdataSpectTime');
    end

    for k=1:handles.NChannels
        [handles.chdataSpect(k,:,:),handles.chdataSpectFreq,handles.chdataSpectTime]=spectrogram(squeeze(handles.chdata(:,(k+1))),WNDsize,WNDovr,NFFT,handles.SampRate);
    end

    FnewInd=find((handles.chdataSpectFreq>handles.SpectFmin) & (handles.chdataSpectFreq<handles.SpectFmax));
    handles.chdataSpectFnewInd=FnewInd;
    axes(handles.axesSpectro);

    imagesc(handles.chdataSpectTime,handles.chdataSpectFreq(FnewInd)...
    ,(flipud(abs(squeeze(handles.chdataSpect(handles.SpectChannel,FnewInd,:))))));
    yticks_freqs = round(linspace(min(handles.chdataSpectFreq(FnewInd)), max(handles.chdataSpectFreq(FnewInd))...
        ,6),-1);
    yticks_labels = cell(1,6);
    for i_label = 1:6
        yticks_labels{i_label} = num2str(yticks_freqs(6-i_label+1));
    end
    set(gca, 'ytick', fliplr(max(handles.chdataSpectFreq(FnewInd))-yticks_freqs));
    set(gca, 'yticklabel', yticks_labels);
    % colorbar ('southoutside');
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    % NF: make color coding of spectrogram constant
    % caxis([0 50])
    
%     disp('spec')
%     toc
    
    linkaxes([handles.axesSpectro handles.axesEPhys],'x');
    %drawnow;
    
%     disp('linkdraw')
%     toc

    % NF: check if visualization window is open, if yes update the plots
    if ishandle(handles.datawindow)
        figure(handles.datawindow);
        EEG_offset_counter = 0;

        chdata_filt = handles.chdata;
        for i_ch = 2:size(handles.chdata,2)
            chdata_filt(:,i_ch) = (handles.chdata(:,i_ch));
        end

        %%% plot the raw EEG signal
        s1 = subplot(2,1,1);
        hold off;  
        for k=1:handles.NChannels
            if handles.display_channels(k)
                plot(TimeAxis,squeeze(handles.chdata(:, (k+1)))+EEG_offset_counter*EEG_vertical_offset,...
                'color', handles.channels_colors(k,:));
                % write channel number in text
                text(TimeAxis(end)*1.02, EEG_offset_counter*EEG_vertical_offset, ['ch' num2str(k)], 'color', handles.channels_colors(k,:))
                EEG_offset_counter = EEG_offset_counter+1;
                hold on;
                chanelsToPlot(k)=1;
            end
        end
        if ~isempty(handles.events)
            % plot areas for the events found
            for i_ev = 1:length(ev_toplot)
                event_id = ev_toplot(i_ev);
                time = (handles.events_info(event_id).globaltime-handles.globaltime)*60;
                dur = handles.events_info(event_id).duration;
                area([time time+dur], ones(1,2)*sum(chanelsToPlot)*EEG_vertical_offset, 'FaceAlpha', 0.2,...
                   'EdgeAlpha', 0.2);
                area([time time+dur], ones(1,2)*-2, 'FaceAlpha', 0.2,...
                   'EdgeAlpha', 0.2);
            end
        end
        xlabel('Time (s)');
        ylabel('Voltage (mV)');
        xlim([0 handles.windowsize])
        ylim([-EEG_vertical_offset/2, (sum(chanelsToPlot)-1/2)*EEG_vertical_offset])
        hold off;

        %%% plot the spectrogram data
        s2 = subplot(2,1,2);
        imagesc(handles.chdataSpectTime,handles.chdataSpectFreq(FnewInd),(flipud(...
            abs(squeeze(handles.chdataSpect(handles.SpectChannel,FnewInd,:))))));
        colorbar ('southoutside');
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        set(gca, 'ytick', fliplr(max(handles.chdataSpectFreq(FnewInd))-yticks_freqs));
        set(gca, 'yticklabel', yticks_labels);
        caxis([0 50])
        linkaxes([s1 s2],'x');  
    end
    bBusy = false;
    ReturnHandle=handles;   
else
    ReturnHandle=handles;
end

catch e
    % plot debugging !!!
    disp('ERROR IN PLOTTING')
    disp(e.message);
    bBusy = 0;
    ReturnHandle=handles;
end






% if isfield(handles,'ctsframes')
%     handles = rmfield(handles,'ctsframes');
% end
% 
% 6
%     
% vidstr = strcat(handles.window_filepath, handles.window_filename, '.mp4')
% ctsstr = strcat(handles.window_filepath, handles.window_filename, '.cts');
% 
% 7
% mc = handles.hvid;
% media = mc.newMedia(vidstr);
% 
% mc.CurrentMedia = media;
% mc.Controls.pause;
% 8
% fid = fopen(ctsstr);
% 
% handles.ctsframes = fread(fid, [1 inf], 'uint32', 5*4); % the frame number at each 100ms timepoint recorded by NI
% % We are assming that every 100ms interrupt contains exaclty 100ms with of
% % EEG data. This might not be true. In that case, the COUNT of EEG samples
% % per NI interrupt should be saved in the CTS file
% 
% fclose(fid);
% outHandles=handles;
% 
% % function outHandles=LoadVid(handles)
% % 
% % 
% % axes(handles.axesVideo);
% % opener = strcat(handles.window_filepath, handles.window_filename, '.mp4');
% % v = VideoReader(opener);
% % if (isfield(handles, 'MovieClip'))
% %     handles=rmfield(handles, 'MovieClip');
% % end
% % 
% % handles.MovieClip = zeros(floor(handles.windowsize*v.FrameRate),v.Height,v.Width,v.BitsPerPixel/8, 'uint8');
% % 
% % v.CurrentTime=handles.window_deltaT*60;
% % %v.CurrentTime=0;
% % for k = 1:(handles.windowsize*v.FrameRate)
% %     handles.MovieClip(k,:,:,:)=readFrame(v);
% %     if (rem(k,10)==0)
% %         handles=ProgressBar(handles,1);
% %     end   
% % end
% % assignin('base','movieclip',handles.MovieClip);
% % assignin('base','movieViedeoReader',v);
% % handles=ProgressBar(handles,0);
% % outHandles=handles;


% --- Executes on button press in pb_EEGright.
function pb_EEGright_Callback(hObject, eventdata, handles)
% hObject    handle to pb_EEGright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bBusy;
if ~bBusy
    handles.TLleft = handles.axesPanView.XLim(1);
    handles.TLright = handles.axesPanView.XLim(2);
    handles.window_deltaT = handles.window_deltaT + handles.windowsize/60;
    handles.globaltime = handles.globaltime + handles.windowsize/60;
    handles.TLleft = handles.TLleft + handles.windowsize/60;
    handles.TLright = handles.TLright + handles.windowsize/60;

    handles=PlotEEG(handles);
    handles=PlotTimeline(handles, true);
    guidata(hObject,handles);
end

% --- Executes on button press in pb_EEGleft.
function pb_EEGleft_Callback(hObject, eventdata, handles)
% hObject    handle to pb_EEGleft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bBusy;
if ~bBusy
    handles.TLleft = handles.axesPanView.XLim(1);
    handles.TLright = handles.axesPanView.XLim(2);
    handles.window_deltaT = handles.window_deltaT - handles.windowsize/60;
    handles.globaltime = handles.globaltime - handles.windowsize/60;
    handles.TLleft = handles.TLleft - handles.windowsize/60;
    handles.TLright = handles.TLright - handles.windowsize/60;

    handles=PlotEEG(handles);
    handles=PlotTimeline(handles, true);
end
guidata(hObject,handles);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
global bBusy;
if ~bBusy
    if ~strcmp(cellstr(get(hObject,'String')),'No events') % check that the list is not empty and displaying no events        
        index_selected = handles.i_sorted(handles.listbox1.Value);
        % NF: update the plots if an element in the list is clicked
        offset_display = 5; % in seconds, shift of event to the right in display
        handles.globaltime = max(handles.events_info(index_selected).globaltime - offset_display/60,0);
        handles.window_deltaT = max(handles.events_info(index_selected).deltaT - offset_display/60,0);
        % handles.window_filepath not modified here, carfeful if other subject is 
        % loaded to erase the events!
        handles.window_filepath = handles.bins_sorted.filepath;
        % NF: do not use recording id to decide which file is loaded as it can
        % give unstable results (if one file is added or missing), use
        % globaltime instead
        %handles.window_filename = handles.bins_sorted.name{handles.events_info(index_selected).recording_id}(1:end-4);
        rec_id = find(handles.globaltime<handles.bins_sorted.endtime,1);
        handles.window_filename = handles.bins_sorted.name{rec_id}(1:end-4);

        % also update the date displayed
        datemod = handles.globaltime/(60*24)+handles.bins_sorted.initialtime; 
        set(handles.edit_date, 'string', datestr(datemod,'YYYY-mmm-DD'));
        set(handles.edit_hour, 'string', datestr(datemod,'HH'));
        set(handles.edit_min, 'string', datestr(datemod,'MM'));
        set(handles.edit_sec, 'string', datestr(datemod,'SS'));

        % store the last selected item from the list
        handles.list_lastitem = handles.listbox1.Value;

        % update the plots
        handles = PlotEEG(handles);
        handles = PlotTimeline(handles, true);
        % in case the selected item item was overriden by the action below,
        % reestablish it after plotting
         %pause(0.05);
        handles.listbox1.Value = handles.list_lastitem;
    end
else
    % NF: revert the selection back to what it was before
    handles.listbox1.Value = handles.list_lastitem;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_findevents.
function handlesOut = pb_findevents_Callback(hObject, eventdata, handles)
% hObject    handle to pb_findevents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.bins_sorted)
    if sum(handles.ev_channels > 0)
        handles.sorting_type = 1;
        [events, events_info, general_info] = getEvents(handles, handles.method_events); 
        handles.events = events;
        handles.events_info = events_info;
        handles.general_info = general_info;
        handles.event_labels = cell(1,length(events)); 
        % NF: write the obtained items in the listbox
        % update Value prop so that it goes to first event
        handles.listbox1.Value = 1;
        handles = updateEventsList(handles);
        % update general info window
        updateGeneralInfoWindow(handles)
    else
        msgbox('No channel selected', 'Error','error');
    end
else
    msgbox('No data loaded', 'Error','error');
end
handles.i_sorted = 1:length(handles.events);
guidata(hObject, handles);
handlesOut = handles;


function [events, events_info, general_info] = getEvents(handles, method)
% NF: finds events for the current subject
% loop through the files corresponding to one subject

% I: Read general parameters for event detection from the GUI
general_info.method = method;
general_info.params = {handles.window_events,...
                      handles.threshold_events,...
                      handles.threshold_SD_events,...
                      handles.num_decision_windows,...
                      handles.num_positive_windows};
general_info.channels = handles.ev_channels;
general_info.overlap = handles.overlap_window_events;
if handles.events_mode == 0
    general_info.mode = 'AND';
elseif handles.events_mode == 1
    general_info.mode = 'OR';
end
general_info.optionsString = '';

% II:  In case specific options have to be specified for a certain model
% it is done here
% string to write options of detection in the event file
if method == 3
    prompt = {'Frequency Band [Hz]: '};
    dlg_title = 'Freq band method parameters';
    num_lines = 1;
    defaultans = {'8 12'};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    if ~isempty(answer)
        handles.freq_band=str2num(answer{1}); %#ok<ST2NM>
        general_info.optionsString = answer{1};
    else
        general_info.optionsString = defaultans{1};
    end
end
if method == 4
    [filename, pathname] =  uigetfile('*.mat');
    s = load([pathname filename]);
    if isfield(s, 'optimalModel') 
        general_info.optionsString = [pathname filename];
        optimalModel = s.optimalModel;
        if length(optimalModel)>1
            % implement later !!!
        end
        % read the parameters for normalization
        m = optimalModel.m;
        sd = optimalModel.sd;
        % read PCA coefficients
        coeff = optimalModel.coeff;
        % read manual paramters of the model
        manual_params = optimalModel.manual_params;
        % read model used
        Mdl = optimalModel.Mdl;
    else
        errordlg('Not a valid file', 'Error');
    end
    % hardcoded defaults
    params.features = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 19 20];
    params.chans = [1 2 3];
end


% III: Iterate through all the files from this animal
ev_id = 0; % index to iterate through the cell of strings 
% containing the events (events)
events = [];
events_info = [];
sel_ch = [0 handles.ev_channels] == 1;
h = waitbar(0, [handles.bins_sorted.name{1}(1:5) ': Finding events']);
for i = 1:length(handles.bins_sorted.name)
    opener = strcat(handles.bins_sorted.filepath, ...
        handles.bins_sorted.name{i});
    fid = fopen(opener);
    try
        metadata = fread(fid, 3, 'int'); % contains Fs, nchannels_analog, nchannels_digital
    catch
        disp('error reading metadata')
        disp(opener);
    end
    Fs = metadata(1);
    Nchans = metadata(2);
    data = fread(fid,[(handles.NChannels + 1), inf], 'double');
    % close the file that was open
    fclose(fid);
    data=data';
    window_events = handles.window_events;
    
    % determine the overlap in samples
    ovl = handles.overlap_window_events*handles.window_events;
    % IV: for each file, compute metric 
    metric = zeros(length(1:window_events-ovl:(size(data,1)-window_events)),sum(handles.ev_channels));
    k = 0;
    if method == 1 % coastline
        for j = 1:window_events-ovl:(size(data,1)-(window_events))
            k = k+1;
            metric(k,:) = sum(abs(diff(data(j:j+window_events-1,sel_ch))),1);
        end  
    elseif method == 2 % absolute value of sum
        for j = 1:window_events-ovl:(size(data,1)-(window_events))
            k = k+1;
            metric(k,:) = sum(abs(data(j:j+window_events-1,sel_ch)),1);
        end
    elseif method == 3 % power in a specific band
        window_size = handles.SpectWndSize*Fs; % spectrogram window size and overlap
        overlap = handles.SpectWndOVR*Fs;
        nfft = handles.SpectNFFT;
        band = handles.freq_band;
        for j = 1:window_events-ovl:(size(data,1)-(window_events))
            k = k+1;
            [metric_temp, freq] = pwelch(data(j:j+window_events-1,sel_ch), window_size, overlap,...
            nfft, handles.SampRate);
            metric(k,:) = mean(metric_temp(and(freq>=band(1), freq<=band(2)),:),1);
        end 
    elseif method == 4
        data = preproc(data, Fs, false);
        for j = 1:window_events-ovl:(size(data,1)-(window_events))
            k = k+1;
            features(k,:) = getEEGfeatures(data(j:j+window_events-1,sel_ch),Fs,params);
        end 
        features = zscore(features);
        features = (features-repmat(m,[size(features,1),1]))./repmat(sd,[size(features,1),1]) *coeff;
        scores = MdlPredict(Mdl, features, optimalModel.name, manual_params);
        metric = repmat(scores(:,end), [1, sum(handles.ev_channels)]);
    end  
    
    % V: Determine the threshold and infer which windows contain events
    % read the threshold that will be used from the GUI
    threshold_events = max([handles.threshold_events*ones(1,sum(handles.ev_channels)); ...
        mean(metric,1)+handles.threshold_SD_events*std(metric,1)],[],1);
    isEvent = zeros(size(metric,1),size(metric,2));
    
    for i_ch = 1:size(metric,2)
        isEvent(:,i_ch) = metric(:,i_ch) > threshold_events(i_ch);
    end
    % find events (depending if AND or OR was chosen)
    if size(metric,2)>1 % only relevant if more than one channel of course
        if handles.events_mode == 0 % AND
            isEvent = all(isEvent,2);
        elseif handles.events_mode == 1 % OR
            isEvent = any(isEvent,2);
        end  
    end
    nPeriods = round(1/(1-handles.overlap_window_events)); % number of periods in a window
    % take a decision on every period of overlap between windows based on
    % the average of all windows containing that period
    ev_matrix = zeros(nPeriods, size(metric,1));
    % dimensions of this matrix are the the number
    % decision windows in a sliding window x decision windows where windows overlap
    % insert the windows in the ev_matrix 
    for i_window=1:size(metric,1)-nPeriods
        for i_period = 1:nPeriods
            ev_matrix(i_period, i_window+i_period-1) = isEvent(i_window);
        end
    end
    
    if min(size(ev_matrix))>1
        isEvent = round(mean(ev_matrix),1) == 1;
    else
        isEvent = round(ev_matrix) == 1;
    end
    
    % factor in the parameters num_decision_windows and num_positive
    % windows: an event is marked only if n positve windows are found in a
    % certain number of decision windows
    % allows to smooth the event detection and reject more false positives
    isEvent_temp = zeros(size(isEvent));
    for j = floor(handles.num_decision_windows/2)+1:length(isEvent)-ceil(handles.num_decision_windows/2)
        if sum(isEvent(j-floor(handles.num_decision_windows/2):j+ceil(handles.num_decision_windows/2)-1))>=...
                handles.num_positive_windows
            isEvent_temp(j-floor(handles.num_decision_windows/2):j+ceil(handles.num_decision_windows/2)-1) = 1;
        end
    end
    isEvent = isEvent_temp;
    
    ev = find(isEvent); % events as relative index of decision window
    
    % VI: Write the events in a structure for saving
    interval = window_events*(1-handles.overlap_window_events); %length in samples of the decison windows
    if ~isempty(ev)
        ev_id = ev_id + 1;
        % compute the event as a number of days after the first recording
        event_seconds = round((ev(1)-1)*interval/handles.SampRate); % seconds after beginning of recording
        % for each event a duration is computed
        duration_temp = handles.window_events;
        % for each event, information relevant for plotting is saved in a
        % struct
        events_info(ev_id).recording_id = i;
        events_info(ev_id).deltaT = event_seconds/60;
        events_info(ev_id).globaltime = handles.bins_sorted.starttime(i)...
            + events_info(ev_id).deltaT; % in minutes       
        nWindows = 0;
        for j = 2:length(ev)
            nWindows = nWindows+1;
            if ev(j) - ev(j-1) > 1
                % new event: write duration of previous event
                events_info(ev_id).duration = duration_temp/handles.SampRate; % in secs
                duration_temp = interval;
                % write information of the new event
                ev_id = ev_id+1;
                event_seconds = round((ev(j)-1)*interval/handles.SampRate); % seconds after beginning of recording
                events_info(ev_id).recording_id = i;
                events_info(ev_id).deltaT = event_seconds/60;
                events_info(ev_id).globaltime = handles.bins_sorted.starttime(i)...
                    + events_info(ev_id).deltaT; % in minutes
            else
                duration_temp = duration_temp + interval;
            end
        end
        % write duration of last event
        events_info(ev_id).duration = duration_temp/handles.SampRate; % in secs
    end
    try
        waitbar(i/length(handles.bins_sorted.name), h, [handles.bins_sorted.name{1}(1:5) ': Finding events (' num2str(i+1) '/' num2str(length(handles.bins_sorted.name)) ')']);
    catch
        % if waitbar has been closed, interrupt event detection
        msgbox('Operation -finding events- interrupted', 'Error','error');
        break;
    end
end
% display general information about the events in the GUI
try
    close(h);
catch % progress bar has been interrupted
    events = [];
    events_info = [];
    general_info = [];
    % empty events so interruption can be detected later
end
if ~isempty(events_info)
    % create the variable 'events' that contains the strings to be
    % displayed in the list 
    events = cell(1,length(events_info));
    for i_event = 1:length(events_info)
       events{i_event} = event2string(events_info(i_event), handles.bins_sorted);
    end
    % write outcome of detection in general info
    general_info.event_proportion = sum([events_info.duration])/60/sum([handles.bins_sorted.endtime]...
        -[handles.bins_sorted.starttime]); % proportion of the samples that are considered events
    general_info.nevents = length(events_info); % number of events
end

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function edOVR_Callback(hObject, eventdata, handles)
% hObject    handle to edOVR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edOVR as text
%        str2double(get(hObject,'String')) returns contents of edOVR as a double


% --- Executes during object creation, after setting all properties.
function edOVR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edOVR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edSizeWnd_Callback(hObject, eventdata, handles)
% hObject    handle to edSizeWnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edSizeWnd as text
%        str2double(get(hObject,'String')) returns contents of edSizeWnd as a double


% --- Executes during object creation, after setting all properties.
function edSizeWnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edSizeWnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_Spectrogram_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Spectrogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% creates a dialog for specifying the parameters for the spectrogram
prompt = {'Size of discrete window (s):','Overlap between windows (s):','NNFT (window in number of samples):','Minimum Freq cutoff:','Maximum Freq cutoff:'};
dlg_title = 'Spectrogram parameters';
num_lines = 1;
defaultans = {num2str(handles.SpectWndSize),num2str(handles.SpectWndOVR),num2str(handles.SpectNFFT),num2str(handles.SpectFmin),num2str(handles.SpectFmax)};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
if ~isempty(answer)
    handles.SpectWndSize=str2double(answer{1}); %spectrogram window size and overlap
    handles.SpectWndOVR=str2double(answer{2});
    handles.SpectNFFT=str2double(answer{3});
    handles.SpectFmin=str2double(answer{4});
    handles.SpectFmax=str2double(answer{5});
end
guidata(hObject, handles);

function OutHandles=PlotTimeline(handles, flag_refreshOnly)
% NF: added the possibility to update only the green 'globaltime' line and
% not replot the whole timeline everytime (significantly improves
% performance when plotting big dataset)

% if flag is positive, just delete the globaltime line
% note: not perfect yet, if button is pushed repeately, the line is not
% properly deleted!!!
global bBusy;

if ~bBusy
    bBusy = true;
    if flag_refreshOnly
        delete(handles.handle_globaltime);
    end
    axes(handles.axesPanView);
    set(handles.axesPanView,'XLim', [handles.TLleft, handles.TLright]);
    bins_sorted = handles.bins_sorted;

    if ~flag_refreshOnly
        %Lets make the labels: every 6 hours for every day from beggining to end
        xTicksNumbers = zeros(1,2*length(bins_sorted.starttime));
        xTicksLabels = cell(1,2*length(bins_sorted.starttime));
        cla(handles.axesPanView); 
        hold on;
        for k = 1:length(bins_sorted.starttime)
            plot([bins_sorted.starttime(k) bins_sorted.starttime(k)], [0 1],'r');
            plot([bins_sorted.endtime(k) bins_sorted.endtime(k)], [0 1],'b');
            plot([bins_sorted.starttime(k) bins_sorted.endtime(k)], [.1 .1],'k');
            xTicksNumbers (2*(k-1)+1) = bins_sorted.starttime(k);
            xTicksNumbers (2*(k-1)+2) = bins_sorted.endtime(k);
            xTicksLabels {2*(k-1)+1} = datestr(bins_sorted.starttime(k)/24/60+bins_sorted.initialtime,'(mmm)DD - HH:MM');
            xTicksLabels {2*(k-1)+2} = datestr(bins_sorted.endtime(k)/24/60+bins_sorted.initialtime,'(mmm)DD - HH:MM:');
        end

        [xTicksNumbers, i] = sort(xTicksNumbers);
        %set(gca, 'xtick', xTicksNumbers); % !!!

        xTicksLabels = xTicksLabels(i);
        %set(gca, 'xticklabel', xTicksLabels); % !!!
    end

    handles.handle_globaltime = plot([handles.globaltime handles.globaltime], [0 1], 'g');
    set(handles.axesPanView,'XLim', [handles.TLleft, handles.TLright]);

    h = zoom;
    h.Motion = 'horizontal';
    h = pan;
    h.Motion = 'horizontal';

    assignin ('base','time',handles.globaltime);
    
    set(gca, 'Ytick', 0)
    set(gca, 'Yticklabel', 0)
    
    bBusy = false;
end
OutHandles=handles;


% --- Executes on selection change in popupSpectChSel.
function popupSpectChSel_Callback(hObject, eventdata, handles)
% hObject    handle to popupSpectChSel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupSpectChSel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupSpectChSel

% select channel to display in spectrogram
handles.SpectChannel=get(hObject,'Value');
handles = PlotEEG(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupSpectChSel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupSpectChSel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axesVideo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% !!!vid handles.hvid = actxcontrol('WMPlayer.OCX.7',[0 0 320 240],gcf);
guidata(hObject, handles);
% Hint: place code in OpeningFcn to populate axesVideo


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
% switch eventdata.Key
%     case 'leftarrow'
%         pb_EEGleft_Callback(hObject, eventdata, handles);
%     case 'rightarrow'
%         pb_EEGright_Callback(hObject, eventdata, handles);
% end
%         

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key
    case 'leftarrow'
        pb_EEGleft_Callback(hObject, eventdata, handles);
    case 'rightarrow'
        pb_EEGright_Callback(hObject, eventdata, handles);
end
      

% --- Executes on button press in gotobutton.
function gotobutton_Callback(hObject, eventdata, handles)
% hObject    handle to gotobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% datemod = cP(1,1)/(60*24)+bs.initialtime;
%     
% set(handles.ed_subjname, 'string', strtemp);
% 
% set(handles.edit_date, 'string', datestr(datemod,'YYYY-mmm-DD'));
% set(handles.edit_hour, 'string', datestr(datemod,'HH'));
% set(handles.edit_min, 'string', datestr(datemod,'MM'));
% set(handles.edit_sec, 'string', datestr(datemod,'SS'));
% 
% handles.globaltime = cP(1,1); %globaltime in minutes
global bBusy;

if ~bBusy
    if ~isempty(handles.bins_sorted)
        % if a date is specfied, allows to go to that date
        date_str = get(handles.edit_date, 'string');
        hour_str = get(handles.edit_hour, 'string');
        min_str = get(handles.edit_min, 'string');
        sec_str = get(handles.edit_sec, 'string');

        try
            time = datenum([date_str ' ' hour_str ' ' min_str ' ' sec_str], ...
                 'yyyy-mmm-dd HH MM SS');
            handles.globaltime = (time - handles.bins_sorted.initialtime)*24*60;
        catch
            disp('message that date is incorrect!');
        end

        bs = handles.bins_sorted;
        index = find(bs.endtime > handles.globaltime,1);
        bFileExists= bs.starttime(index) < handles.globaltime;
        subject = handles.bins_sorted.name{1}(1:5);
        handles.window_loaded = 0;
        if (bFileExists)
            strtemp=strcat(['[' subject '] ' 'The file exists: '],bs.name(index));
            deltaT = handles.globaltime - bs.starttime(index);

            handles.window_deltaT = deltaT;
            tempname = bs.name{index};
            handles.window_filename=tempname(1:(length(tempname)-4));
            handles.window_filepath = bs.filepath;
            handles.window_loaded = 1;
        else
            strtemp = ['[' subject '] ' 'NO FILE FOR THE INTERVAL'] ;
        end
        set(handles.ed_subjname, 'string', strtemp);

        handles = PlotTimeline(handles, true);
        handles = PlotEEG(handles);
    end
end
guidata(hObject, handles);


function generalinfo_Callback(hObject, eventdata, handles)
% hObject    handle to generalinfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of generalinfo as text
%        str2double(get(hObject,'String')) returns contents of generalinfo as a double


% --- Executes during object creation, after setting all properties.
function generalinfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to generalinfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in testbutton.
function testbutton_Callback(hObject, eventdata, handles)
% hObject    handle to testbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%% NF: for debug purposes !!!
axes(handles.axesSpectro);
handles.windowsize = str2num(get(handles.ed_windowsize, 'string'));
id = round(handles.window_deltaT*60*handles.SampRate/handles.window_events)+1;
range = round(handles.windowsize*handles.SampRate/handles.window_events)-1;
t = linspace(0,handles.windowsize-handles.window_events/handles.SampRate,range+1)...
    +handles.window_events/handles.SampRate/2;
% plot(t,handles.metric_cell{1}(id:id+range));
% plot(t,handles.metric_cell{1}(id:id+range),'x');
index = find(handles.bins_sorted.endtime > handles.globaltime,1);
bar(t,handles.metric_cell{index}(id:id+range), 1);
hold on;
plot(linspace(-1,handles.windowsize+1,5), ones(1,5)*handles.thresholds(1));
xlim([0,handles.windowsize]);
hold off;
% F = getframe(handles.figure1); 
% Image = frame2im(F);
% imwrite(Image, 'Image.jpg')
% uncomment to save picture!


% --- Executes on key press with focus on listbox1 and none of its controls.
function listbox1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% allows creation and labeling of events from keyboard
key = str2double(eventdata.Key);
if ~isempty(key)
    if key <= length(handles.event_labels_texts) && key > 0
        source.Label  = handles.event_labels_texts{key};
        callbackdata = [];
        labelEvent(source, callbackdata, handles, hObject);
    end
    if strcmp(eventdata.Key, 'c')
        addevent_Callback(handles.addevent, [], handles);
    end
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over listbox1.
function listbox1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% NF: update menu so labelEvent gets the updated handles structure and
% the updated labels 
c = uicontextmenu;
for i_item = 1:length(handles.event_labels_texts)
    uimenu(c, 'Label', handles.event_labels_texts{i_item}, 'Callback', {@labelEvent, handles, hObject});
end
handles.listbox1.UIContextMenu = c;


function labelEvent(source, callbackdata, handles, hObject)
% NF: labels event from contextual menu
index_selected = handles.listbox1.Value;
list_contents = cellstr(get(hObject,'String'));
if strcmp(source.Label, 'Delete label')
    list_contents{index_selected} = handles.events{handles.i_sorted(index_selected)};
    handles.event_labels{handles.i_sorted(index_selected)} = [];
else
    list_contents{index_selected} = [handles.events{handles.i_sorted(index_selected)} ' ' source.Label];
    handles.event_labels{handles.i_sorted(index_selected)} = source.Label;
end
  
handles.listbox1.String = list_contents;
listTop = handles.listbox1.ListboxTop; % save it so list display doesn't jump
drawnow;
handles.listbox1.ListboxTop = listTop; % put list's slider back in position
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_detection_Callback(hObject, eventdata, handles)
% hObject    handle to menu_detection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% NF: choice of parameters for event detection/labeling
% display promt
prompt = {'Events labels:'};
dlg_title = 'Event detection parameters';
num_lines = 1;
defaultans{1} = [];
for i = 1:length(handles.event_labels_texts)-1
    if i == length(handles.event_labels_texts)-1
        defaultans{1} = [defaultans{1} handles.event_labels_texts{i}];
    else
        defaultans{1} = [defaultans{1} handles.event_labels_texts{i} ', '];
    end
end
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

%%% processing of answers
if ~isempty(answer)
    % field: Event labels
    answer_labels = answer{1};
    k_comma = findstr(answer_labels, ',');
    if ~isempty(k_comma)
        labels{1} = answer_labels(1:k_comma(1)-1); % read first one
        labels{length(k_comma)+1} = answer_labels(k_comma(end)+2:end); % read last one
        if length(k_comma) > 1 % read middle if more than one comma
            for i = 2:length(k_comma)
                labels{i} = answer_labels(k_comma(i-1)+2:k_comma(i)-1);
            end
        end
    else
        if ~isempty(answer_labels) % only one item
            labels{1} = answer_labels;
        end
    end
    if ~isempty(labels)
        labels{length(labels) + 1} = 'Delete label';
    else
        labels{1} = 'Delete label';
    end
    handles.event_labels_texts = labels;
end
guidata(hObject, handles); 
       


%%% NF: check boxes for AND and OR for event detection, only one 
% can be checked at the same time

% --- Executes on button press in checkboxOr.
function checkboxOr_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxOr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxOr
isChecked = get(hObject,'Value');
if isChecked && handles.events_mode == 0
    handles.checkboxAnd.Value = 0;
    handles.events_mode = 1;
elseif ~isChecked && handles.events_mode == 1
    set(hObject,'Value',1);
end
guidata(hObject, handles);

% --- Executes on button press in checkboxAnd.
function checkboxAnd_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAnd
isChecked = get(hObject,'Value');
if isChecked && handles.events_mode == 1
    handles.checkboxOr.Value = 0;
    handles.events_mode = 0;
elseif ~isChecked && handles.events_mode == 0
    set(hObject,'Value',1);
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function eventdetection_Callback(hObject, eventdata, handles)
% hObject    handle to eventdetection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function saveevents_Callback(hObject, eventdata, handles)  
% save events that have been assgned a label only
if ~isempty(handles.events_info) 
    % check if events are actually going to be written
    nEventsLabeled = 0;
    for i_event = 1:length(handles.event_labels)
        nEventsLabeled = nEventsLabeled + ~isempty(handles.event_labels{i_event});
    end
    if nEventsLabeled == 0
        animal = handles.bins_sorted.name{1}(1:5);
        msgbox([animal ': No events to save'], 'Error','error');
    else
        if isempty(handles.general_info) % only custom events have been entered
            % create trivial 'general_info'
            general_info.method = 0;
            general_info.params{1} = 0;
            general_info.params{2} = 0;
            general_info.params{3} = 0;
            general_info.params{4} = 0;
            general_info.params{5} = 0;
            general_info.optionsString = '';
            general_info.channels = [0 0 0 0];
            general_info.mode = 'AND';
            general_info.event_proportion = 0;
            general_info.nevents = 0;
            writeCSV(general_info, handles.events_info, handles.event_labels, handles.bins_sorted, 'labeled', 1);
        else
            writeCSV(handles.general_info, handles.events_info, handles.event_labels, handles.bins_sorted, 'labeled', 1);
        end
    end
else
    animal = handles.bins_sorted.name{1}(1:5);
    msgbox([animal ': No events to save'], 'Error','error');
end


function writeCSV(general_info, events_info, event_labels, bins_sorted, options, bPrompt)
% NF: 
% general info contains information to write in the header
% events_info from handles gives start-time and duration
% event_labels are the annotations
% bins_sorted allows to access filepath and name
% options: labeled or all
% bPrompt: specify if user should be prompted in case of override or if a
% default behavior should be applied

name = [bins_sorted.name{1}(1:5) '-' options '_' 'events_' num2str(general_info.method) '_' ...
    num2str(general_info.params{1}) ' ' num2str(general_info.params{2}) ' '...
    num2str(general_info.params{3}) ' ' num2str(general_info.params{4}) ' ' num2str(general_info.params{4}) '.csv'];

% check if a folder events already exists, if not create it
if exist([bins_sorted.filepath 'events\'], 'dir') ~= 7
    mkdir(bins_sorted.filepath, 'events');
end

filename = [bins_sorted.filepath  'events\' name];
% NF: check if the file already exists and if it should be overwritten
files = dir([bins_sorted.filepath  'events\']);
count = 0;
for i_file=1:length(files)
    if length(files(i_file).name) >= length(name)
        if strcmp(name(1:end-4), files(i_file).name(1:end-7)) ||...
            strcmp(name(1:end-4), files(i_file).name(1:end-4))
            count = count+1;
        end
    end
end
if count>0
    if bPrompt
         % ask user if he wants the file overwritten
         newname = [name(1:end-4) '(' num2str(count+1) ')' name(end-3:end)];
         if count>1
             name = [name(1:end-4) '(' num2str(count) ')' name(end-3:end)];
         end        
         % Construct a questdlg with three options
        choice = questdlg('File exists already',...
            name, ...
            'Overwrite',['Save as ' newname],'Cancel', 'Cancel');
        % Handle response
        switch choice
            case 'Overwrite'
                filename = [bins_sorted.filepath  'events\' name];
            case ['Save as ' newname]
                name = newname;
                filename = [bins_sorted.filepath  'events\' newname];
            case 'Cancel'
                return;
            case ''
                return;
        end
    else
        newname = [name(1:end-4) '(' num2str(count+1) ')' name(end-3:end)];
        name = newname;
        filename = [bins_sorted.filepath  'events\' newname];
    end
end

fileID = fopen(filename,'w');
% write the header
fprintf(fileID,'%d\n', general_info.method);
fprintf(fileID,'%d\n', general_info.params{1});
fprintf(fileID,'%f\n', general_info.params{2});
fprintf(fileID,'%f\n', general_info.params{3});
fprintf(fileID,'%f\n', general_info.params{4});
fprintf(fileID,'%f\n', general_info.params{5});
fprintf(fileID,'%s\n', general_info.optionsString);
fprintf(fileID,'%d, %d, %d, %d\n', general_info.channels);
fprintf(fileID,'%f\n', general_info.overlap);
fprintf(fileID,'%s\n', general_info.mode);
fprintf(fileID,'%d\n', general_info.nevents);

% write the data
formatSpec = '%d, %d, %f, %f, %s\n';
toWrite = cell(length(event_labels),2);
toWrite(:,1) = num2cell(1:length(events_info));
toWrite(:,2) = {events_info.recording_id}; % index of the recording where event happened
toWrite(:,3) = {events_info.globaltime}; % in minutes
toWrite(:,4) = {events_info.duration}; % in seconds
toWrite(:,5) = event_labels; % labels
% remove rows that have no labels if specified
if strcmp(options, 'labeled')
    for i_toWrite = size(toWrite,1):-1:1
        if isempty(toWrite{i_toWrite, end}) % if there is no label
            toWrite(i_toWrite, :) = []; % delete the row
        end
    end
% if all events are to be written, write unlabeled events as 'none' to
% facilitate reading
elseif strcmp(options, 'all')
   for i_label = size(toWrite,1):-1:1
        if isempty(toWrite{i_label, end}) % if there is no label
            toWrite{i_label, end} = 'None'; % delete the row
        end
    end
end
% formatted writing
for row = 1:size(toWrite,1)
    fprintf(fileID,formatSpec,toWrite{row, :});
end
%close file
fclose(fileID);
msgbox(['Events written to ' name], 'Events saved');


% --------------------------------------------------------------------
function saveraw_Callback(hObject, eventdata, handles)
% hObject    handle to saveraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.events_info) 
    % check if events are actually going to be written
    writeCSV(handles.general_info, handles.events_info, handles.event_labels, handles.bins_sorted, 'all', ~handles.bPipeline);
else
    animal = handles.bins_sorted.name{1}(1:5);
    msgbox([animal ': No events to save'], 'Error','error');
end


function handlesOut = readCSV(handles, fileID)
% NF: reads a csv file where events have been stored
% read header first

% if CSV file is edited in excel, the structure is slightly modified,
% this is handled below
% handles.general_info.method = fscanf(fileID, '%d', [1 1]);
% handles.general_info.params{1} = fscanf(fileID,'%d', [1 1]);
% handles.general_info.params{2} = fscanf(fileID,'%f', [1 1]);
% handles.general_info.params{3} = fscanf(fileID,'%f', [1 1]);
% handles.general_info.params{4} = fscanf(fileID,'%f, %f', [1 2]);
% handles.general_info.channels = fscanf(fileID,'%d, %d, %d, %d', [1 4]);
% handles.general_info.overlap = fscanf(fileID,'%f', [1 1]);
% handles.general_info.mode = fscanf(fileID,'%s', [1 1]);
% handles.general_info.nevents = fscanf(fileID,'%d', [1 1]);

% method
strtemp = fgets(fileID);
commas = [strfind(strtemp,',') length(strtemp)];
handles.general_info.method = str2double(strtemp(1:commas(1)));
% param 1 (window size)
strtemp = fgets(fileID);
commas = [strfind(strtemp,',') length(strtemp)];
handles.general_info.params{1} = str2double(strtemp(1:commas(1)));
% param 2 (threshold absolute)
strtemp = fgets(fileID);
commas = [strfind(strtemp,',') length(strtemp)];
handles.general_info.params{2} = str2double(strtemp(1:commas(1)));
% param 3 (threshold relative to SD)
strtemp = fgets(fileID);
commas = [strfind(strtemp,',') length(strtemp)];
handles.general_info.params{3} = str2double(strtemp(1:commas(1)));
% param 4 (freq bands or number of decision windows)
strtemp = fgets(fileID);
commas = [strfind(strtemp,',') length(strtemp)];
if length(commas)== 1 || isnan(str2double(strtemp(commas(1):commas(2))))
    handles.general_info.params{4} = str2double(strtemp(1:commas(1)));
    % param 5 (number of decision windows)
    strtemp = fgets(fileID);
    commas = [strfind(strtemp,',') length(strtemp)];
    handles.general_info.params{5} = str2double(strtemp(1:commas(1)));
    % supplementary options string
    strtemp = fgets(fileID);
    handles.general_info.optionsString = strtemp(1:end-1);
else
    handles.general_info.params{4} = [str2double(strtemp(1:commas(1))) ...
    str2double(strtemp(commas(1):commas(2)))];
    warning('An old file format is being used.')
end
% channels used 
strtemp = fgets(fileID);
commas = [strfind(strtemp,',') length(strtemp)];
handles.general_info.channels = [str2double(strtemp(1:commas(1))) ...
    str2double(strtemp(commas(1):commas(2))) ...
    str2double(strtemp(commas(2):commas(3))) ...
    str2double(strtemp(commas(3):commas(4)))];
% overlap
strtemp = fgets(fileID);
commas = [strfind(strtemp,',') length(strtemp)];
handles.general_info.overlap = str2double(strtemp(1:commas(1)));
    % in older files overlap is not present, determines how 
    % mode is read
% mode
if isnan(handles.general_info.overlap)
    handles.general_info.overlap = 0;
    handles.general_info.mode = strtemp(1:3);
else
    strtemp = fgets(fileID);
    handles.general_info.mode = strtemp(1:3);
end
% nevents
strtemp = fgets(fileID);
commas = [strfind(strtemp,',') length(strtemp)];
handles.general_info.nevents = str2double(strtemp(1:commas(1)));


% read the data
formatSpec = '%d, %d, %f, %f';
i_read = 0;
while ~feof(fileID)
    data_temp = fscanf(fileID,formatSpec, [1 4]);
    label_temp = fscanf(fileID,', %s', [1 1]);
    i_read = i_read + 1;
    try
        dataRead(i_read, 1:4) = num2cell(data_temp);
        dataRead{i_read, 5} = label_temp;
    catch 
        % still tries to read once while at end of file
        % implement safeguard here in case csv file is corrupt!!!
    end
end

% process the data that was read and distribute it in the structures 
% contained in handles

% distribute data to right structures
for i_event = 1:size(dataRead,1)
    handles.events_info(i_event).recording_id = [dataRead{(i_event),2}];
    handles.events_info(i_event).globaltime = [dataRead{(i_event),3}];
    handles.events_info(i_event).duration = [dataRead{(i_event),4}];
end

% first remove the 'None' tags in the labels
for i_label = size(dataRead,1):-1:1
    if strcmp(dataRead{i_label, 5}, 'None') % if there is 'None' as label
        dataRead{i_label, 5} = []; % delete the label
    end
end
handles.event_labels = dataRead(:,5);

% reconstitute the rest of the event data from what was read
bs = handles.bins_sorted;
handles.general_info.event_proportion = sum([handles.events_info.duration])...
    /60/sum([bs.endtime]-[bs.starttime]);
events = cell(1,length(handles.events_info));
for i_event = 1:length(handles.events_info)
   % timing of events from begining of recordings
   % NF: do not use recording_id (see listbox1_callback)
   rec_id = find(handles.events_info(i_event).globaltime<bs.endtime,1);
   % !!!: issue error if events are out of recordings
   % implement better error handling
   if isempty(rec_id)
       warning(['Recording for event ' num2str(i_event) ' was not found'])
   end
%    handles.events_info(i_event).deltaT = handles.events_info(i_event).globaltime...
%        -bs.starttime(handles.events_info(i_event).recording_id); % minutes after beginning of recording
   handles.events_info(i_event).deltaT = handles.events_info(i_event).globaltime...
       -bs.starttime(rec_id); % minutes after beginning of recording
   events{i_event} = event2string(handles.events_info(i_event), bs);
end
handles.events = events;

handlesOut = handles;


% --------------------------------------------------------------------
function loadevents_Callback(hObject, eventdata, handles)
% hObject    handle to loadevents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% NF: import event data
    % if wrong subj loaded, no import
    % or if no subject loaded, no import

if isempty(handles.bins_sorted)    
    % no subject is loaded, bins_sorted does not exist
    msgbox('No subject loaded', 'Error','error');    
else
    [fileName,pathName,~] = uigetfile('*.csv');
    if isstr(fileName)
        if strcmp(fileName(1:5), handles.bins_sorted.name{1}(1:5))
            disp(handles.listbox1.Value);
            handles = clearEvents(handles);
            % read the CSV
            fileID = fopen([pathName fileName]);
            handlesOut = readCSV(handles, fileID);
            handles = handlesOut;
            fclose(fileID);
            % set index of list to 1 to avoid errors
            handles.listbox1.Value = 1;
            % reestablish sorting to default (by date)
            handles.sorting_type = 1;
            handles.i_sorted = 1:length(handles.events);
            % update the list and the info window
            handles = updateEventsList(handles);
            updateGeneralInfoWindow(handles)
            guidata(hObject, handles);
        else
            % not the right subject loaded
            msgbox('Events do not correspond to subject', 'Error','error');
        end  
    end
end


% --- Executes on button press in addevent.
function addevent_Callback(hObject, eventdata, handles)
% hObject    handle to addevent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% add event sorting compatibility
if isempty(handles.bins_sorted)    
    % no subject is loaded, bins_sorted does not exist
    msgbox('No subject loaded', 'Error','error');  
else
    prompt = {'Timing [s]:' 'Duration [s]'};
    dlg_title = 'Add event:';
    num_lines = 1;
    defaultans{1} = '0';
    defaultans{2} = '0';
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    if ~isempty(answer)
        timing = str2double(answer{1});
        duration = str2double(answer{2});
        bs = handles.bins_sorted; 
        globaltime = handles.globaltime + timing/60;
        recording_id = find(bs.endtime > globaltime,1);
        deltaT = globaltime-bs.starttime(recording_id);
        % write information of the new event
        new_event_info.recording_id = recording_id;
        new_event_info.deltaT = deltaT;
        new_event_info.globaltime = globaltime;
        new_event_info.duration = duration;
        % find where to integrate it in the current events
        if isempty(handles.events_info)
            id_new_event = 1;
            handles.i_sorted = 1;
        else
            id_new_event = find(globaltime < [handles.events_info.globaltime], 1);
            if isempty(id_new_event) 
               id_new_event = length(handles.events)+1;    
            else
               % in this case: prepare a spot for the new event in the structures
               for i=length(handles.events)+1:-1:id_new_event+1
                    handles.events{i} = handles.events{i-1};
                    handles.events_info(i) = handles.events_info(i-1);
                    handles.event_labels{i} = handles.event_labels{i-1};
               end
            end
        end
        % write the new event in the structures
        handles.events_info(id_new_event).recording_id = new_event_info.recording_id;
        handles.events_info(id_new_event).deltaT = new_event_info.deltaT;
        handles.events_info(id_new_event).globaltime = new_event_info.globaltime;
        handles.events_info(id_new_event).duration = new_event_info.duration;

        handles.events{id_new_event} = event2string(new_event_info, bs);
        handles.event_labels{id_new_event} = '';
        % sort the events according to the previously used sorting 
        % and update the list
        handles = sortEvents(handles, handles.sorting_type);
        % set focus back on the list and display new event
        uicontrol(handles.listbox1);
        handles.listbox1.Value = find(handles.i_sorted == id_new_event);
        listbox1_Callback(handles.listbox1, eventdata, handles)
        % since handles are updated through the listbox callback,
        % read the new handles
        handles = guidata(handles.listbox1);
        
        % update the general info   
        guidata(hObject, handles);
    end
end


function event = event2string(event_info, bs)
% create a string to display in the list from an event's information
event_seconds = event_info.globaltime*60; % convert to seconds for calculation of date
event_days = floor(event_seconds/3600/24);
event_hours = floor((event_seconds-event_days*3600*24)/3600);
event_mins = floor((event_seconds-event_days*3600*24-event_hours*3600)/60);
event_secs = round(event_seconds-event_days*3600*24-event_hours*3600-event_mins*60);
% create the strings
event_days_str = sprintf('%03d',event_days);
event_hours_str = sprintf('%02d',event_hours);
event_mins_str = sprintf('%02d',event_mins);
event_secs_str = sprintf('%02d',event_secs);
event_str = [event_days_str ' - ' event_hours_str ':' event_mins_str ':'...
    event_secs_str];
event = event_str;
% duration of events for list display
event = [event ' / ' ...
datestr(event_info.duration/3600/24, 'HH:MM:SS')];
   

function updateGeneralInfoWindow(handles)
% updates the general event detection info display
if ~isempty(handles.events_info)
    if length(handles.general_info.params)==4
        s{1} = ['Method: ' num2str(handles.general_info.method)];
        s{2} = ['Window size: ' num2str(handles.general_info.params{1})];
        s{3} = ['Threshold: ' num2str(handles.general_info.params{2})];
        s{4} = ['Threshold (x SD): ' num2str(handles.general_info.params{3})];
        s{5} = ['Freq bands: ' num2str(handles.general_info.params{4})];
        s{6} = ['Overlap: ' num2str(handles.general_info.overlap)];
        s{7} = ['Number of events: ' num2str(handles.general_info.nevents)];
        s{8} = ['Event proportion: ' num2str(handles.general_info.event_proportion)];
        s{9} = ['Channel(s) selected: ' num2str(find(handles.general_info.channels > 0))];
        s{10} = ['Mode: ' handles.general_info.mode];
        s{11} = 'Warning: old file format';
    else
        s{1} = ['Method: ' num2str(handles.general_info.method)];
        s{2} = ['Window size: ' num2str(handles.general_info.params{1})];
        s{3} = ['Threshold: ' num2str(handles.general_info.params{2})];
        s{4} = ['Threshold (x SD): ' num2str(handles.general_info.params{3})];
        s{5} = ['Num decision windows: ' num2str(handles.general_info.params{4})];
        s{6} = ['Num positive windows: ' num2str(handles.general_info.params{5})];
        s{7} = ['Options: ' handles.general_info.optionsString];
        s{8} = ['Overlap: ' num2str(handles.general_info.overlap)];
        s{9} = ['Number of events: ' num2str(handles.general_info.nevents)];
        s{10} = ['Event proportion: ' num2str(handles.general_info.event_proportion)];
        s{11} = ['Channel(s) selected: ' num2str(find(handles.general_info.channels > 0))];
        s{12} = ['Mode: ' handles.general_info.mode];
    end
else
    s{1} =  'No events';
end
set(handles.generalinfo, 'String', s);
    
    
function handlesOut = updateEventsList(handles)
% updates the events list
if isempty(handles.events)
	handles.listbox1.String = 'No events';
    handles.listbox1.Value = 1;
else
    strlist = cell(1,length(handles.events));
    for i = 1:length(handles.events)
        strlist{i} = [handles.events{i} ' ' handles.event_labels{i}];
    end
    if handles.sorting_type == 2
        dur = [handles.events_info.duration];
        [~, i_sorted] = sort(dur);
        strlist = strlist(i_sorted);
        handles.i_sorted = i_sorted;
    end
    handles.listbox1.String = strlist;
end
handlesOut = handles;
    

function handlesOut = clearEvents(handles)
% routine to clear all variables associated with events
% note: it is called when loadsubj is called to avoid conflicts and errors
handles.events = [];
handles.events_info = [];
handles.event_labels = [];
handles.general_info = [];
handlesOut = handles;


% --------------------------------------------------------------------
function signalwindow_Callback(hObject, eventdata, handles)
% hObject    handle to signalwindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% NF: window to plot the signals in a bigger size, gets updated at the same
% time as the usual plots
global bBusy;

if ~bBusy
    if  isempty(handles.datawindow) || ~ishandle(handles.datawindow) 
        handles.datawindow = figure('Name','Data Window','NumberTitle','off');
        set(gcf,'units','normalized','outerposition',[0 0 1 1])
        subplot(2,1,1)
        subplot(2,1,2)
        handles = PlotEEG(handles);
        guidata(hObject, handles);
    end
end


% --------------------------------------------------------------------
function processpipeline_Callback(hObject, eventdata, handles)
% hObject    handle to processpipeline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% NF: does not load a subject, simply calculates the events for all the
% subject found in the specified folder and their (first layer of) subfolders
foldername = uigetdir();

if ischar(foldername)
    handles.bPipeline = true;
    % get the first binary files
    files = dir([foldername '/*.bin']);
    subfolders = cell(1,length(files));
    % get the subfolders
    dirinfo = dir(foldername);
    dirinfo(~[dirinfo.isdir]) = [];
    % find the binary files in the subfolders
    if ~isempty(dirinfo)
        for i=1:length(dirinfo)
            if ~strcmp(dirinfo(i).name,'.') && ~strcmp(dirinfo(i).name,'..')
                files_sub = dir([foldername '\' dirinfo(i).name '/*.bin']);
                if ~isempty(files_sub)
                    sub = cell(1,length(files_sub));
                    for j = 1:length(files_sub)
                        sub{j} = dirinfo(i).name;
                    end
                    files = [files files_sub];   
                    subfolders = [subfolders(:) sub(:)];
                end
            end
        end
    end

    % iterate through all the files that were found and find events with the
    % specified parameters and save the events
    processedSubj = [];
    i_subj = 0;
    for i=1:length(files)
        if ~isempty(processedSubj)
            bFound = false;
            for j=1:length(processedSubj)
                if strcmp(files(i).name(1:5), processedSubj(j))
                    bFound = true;
                    break;
                end
            end
        else
            bFound = false;
        end
        if ~bFound 
            % subject was not processed, execute pipeline
            handles.pipeline_foldername = [foldername '\' subfolders{i} '\'];
            handles.pipeline_filename = files(i).name;
            handles = pb_loadsubj_Callback(handles.pb_loadsubj, [], handles);
            handles = pb_findevents_Callback(handles.pb_findevents, [], handles);
            saveraw_Callback(handles.saveraw, [], handles)
            % mark subject as processed
            i_subj = i_subj+1;
            processedSubj{i_subj} = files(i).name(1:5);
        end
    end
    % finally, update the handles
    handles.bPipeline = false;
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function spikehistogram_Callback(hObject, eventdata, handles)
% hObject    handle to spikehistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.bins_sorted)    
    % no subject is loaded, bins_sorted does not exist
    msgbox('No subject loaded', 'Error','error');    
else
    bs = handles.bins_sorted;
    % extract the days of recording
    i_day = 0;
    days = [];
    for i = 1:length(bs.name)
        bFound = false;
        for j=1:length(days)
            if strcmp(bs.name{i}(7:end-11), days{j})
                bFound = true;
            end
        end
        if ~bFound
            i_day = i_day+1;
            days{i_day} = bs.name{i}(7:end-11);
        end
    end
    [selection, ok] = listdlg('liststring', days);
    if ok
        if ~isempty(selection)
            % prepare the subplot environment (adapted to 16/9 resolution)
            sb_columns = round(sqrt(16/9*length(selection)));
            sb_lines = ceil(length(selection)/sb_columns);
            edges = 0:1:4000;
            hw = waitbar(0,'Analyzing...');
            f = figure('units','normalized','outerposition',[0 0 1 1]);
            set(f,'Name',[bs.name{1}(1:5) ' - Spike histogram']);
            for i=1:length(selection)
                figure(f);
                subplot(sb_lines, sb_columns, i);
                hold on;
                dVdt = [];
                for i_recording=1:length(bs.name) % loops through all recordings and checks if they are 
                    % for the current day
                    if strcmp(days{selection(i)}, bs.name{i_recording}(7:end-11))                     
                        % open the bin file
                        opener = strcat(bs.filepath, bs.name{i_recording});
                        fid = fopen(opener);
                        try
                            metadata = fread(fid, 3, 'int'); % contains Fs, nchannels_analog, nchannels_digital
                        catch
                            disp(opener);
                        end
                        handles.SampRate = metadata(1);
                        handles.NChannels = metadata(2);
                        data = fread(fid,[(handles.NChannels + 1), inf], 'double'); 
                        fclose(fid);
                        data=data';
                        sel_ch = [0 handles.ev_channels] == 1;
                        data = data(:,sel_ch);
                        % generate the plots
                        % spike histogram
                        dVdt_rectified = abs(diff(data)*handles.SampRate);
                        win = 16; %[ms]
                        win = round(win*10.^-3*handles.SampRate);
                        dVdt_temp = zeros(length(1:win:size(dVdt_rectified,1)-win),size(data,2));                     
                        for i_ch = 1:size(data,2)
                            k = 0;
                            for i_win = 1:win:size(dVdt_rectified,1)-win
                                k=k+1;
                                dVdt_temp(k,i_ch) = max(dVdt_rectified(i_win:i_win+win-1,i_ch));
                            end
                        end
                        dVdt = [dVdt; dVdt_temp];
                    end
                end
                N = histcounts(dVdt, edges);
                if i==1 % save the data for the first day selected for comparison
                    %dVdt_0 = reshape(dVdt,size(dVdt,1)*size(dVdt,2),1);
                else
                    %dVdt = reshape(dVdt,size(dVdt,1)*size(dVdt,2),1);
                    %[h,p] = kstest2(dVdt, dVdt_0)
                end
                title(days{selection(i)})
                x = movmean(edges,2);
                x = x(2:end);
                bar(x, log(N),'EdgeColor','none')
                xlim([0,2000])
                hold off;
                waitbar(i/length(selection),hw)
            end
            close(hw)
        end
    end
end


% --------------------------------------------------------------------
function ml_learn_Callback(hObject, eventdata, handles)
% hObject    handle to ml_learn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% NF: machine learning - learning from manually labeled set

window_size = 5000; % window used for the learning in samples
overlap = 0.5; % not used yet !!!
data_epochs = [];
features = [];
labels = [];
labels_epochs = [];
%%% find labeled recordings that will be used for the machine learning
foldername = uigetdir();

if ischar(foldername)
    handles.bPipeline = true; % don't forget reset!!!
    % get the events .csv files
    files = dir([foldername '/*.csv']);
    % animal folder is per default the parent folder (!!!)
    sep = strfind(foldername, '\');
    handles.pipeline_foldername = foldername(1:sep(end));
    for i_file = 1:length(files)
        animal = files(i_file).name(1:5);
        % find the associate binary file(s)
        files_animals = dir([handles.pipeline_foldername '/*.bin']);
        handles.pipeline_filename = [];
        for i_file_animal = 1:length(files_animals)
            if strcmp(animal, files_animals(i_file_animal).name(1:5));
                handles.pipeline_filename = files_animals(i_file_animal).name;
            end
        end
        % load the animal's data 
        handles = pb_loadsubj_Callback(handles.pb_loadsubj, [], handles);
        % load the events
        fileID = fopen([foldername '\' files(i_file).name]);
        handles = readCSV(handles, fileID);
        fclose(fileID);
        
        % prepare the structures for data loading
        bs = handles.bins_sorted;              
        events_info = handles.events_info;
        labels_text = handles.event_labels;
        % generate actual labels and features from the event structures
        for i_ev=1:length(events_info)
            % for each labeled event pull the data and assign a numeric label
            start = events_info(i_ev).deltaT*60*handles.SampRate;
            dur = events_info(i_ev).duration*handles.SampRate;
            % read the label
            l=-1;
            if strcmp(labels_text{i_ev}, 'Seizure')
                l = 1;
            elseif strcmp(labels_text{i_ev}, 'Normal')
                l=0;
            end 

            if l>-1
                % read the corresponding data
                opener = strcat(bs.filepath, bs.name{events_info(i_ev).recording_id});
                fid = fopen(opener);
                metadata = fread(fid, 3, 'int'); % contains Fs, nchannels_analog, nchannels_digital
                Fs = metadata(1);
                nChan = metadata(2);
                EEGOffset = floor(start) * (nChan + 1);
                fread(fid, EEGOffset, 'double');
                data = fread(fid,[(nChan + 1), dur],'double');
                data=data(2:5,:)';

                params.chans = 1:2; % !!!
                params.features = [1:21]; % !!!
                params.outputNames = 1;
                [~, feat_names] = getEEGfeatures(data, Fs, params);
                params.outputNames = 0;
                nFeat = length(feat_names);
                features_temp = zeros(length(1:window_size:length(data)-mod(length(data),window_size)), nFeat);
                labels_temp = ones(length(1:window_size:length(data)-mod(length(data),window_size)),1)*l;
                labels_epochs_temp = ones(length(data),1)*l;
                k=0;
                for i_win=1:window_size:length(data)-mod(length(data),window_size)
                    k=k+1;
                    features_temp(k,:) = getEEGfeatures(data(i_win:i_win+window_size-1,:), Fs, params);
                end
                features = [features; features_temp];
                labels = [labels; labels_temp];
                data = data(1:length(data)-mod(length(data),window_size),:);
                data_epochs = [data_epochs; data];
                labels_epochs = [labels_epochs; labels_epochs_temp];
            end
        end
     end
end
handles.bPipeline = false;

%%% train a model on the dataset and return the accuracy
Mdl = fitcnb(features,labels); % set crossval on !!!
% see holdout
cvMdl = crossval(Mdl);
labels_test = kfoldPredict(cvMdl);
k=0;
for i=1:window_size:length(data_epochs)
   k=k+1;
   labels_test_epochs(i:i+window_size-1) = labels_test(k); 
end
e = kfoldLoss(cvMdl);

Mdl = fitcsvm(features,labels); % set crossval on !!!
% see holdout
cvMdl = crossval(Mdl);
labels_test = kfoldPredict(cvMdl);
k=0;
for i=1:window_size:length(data_epochs)
   k=k+1;
   labels_test_epochs(i:i+window_size-1) = labels_test(k); 
end
e = kfoldLoss(cvMdl);

figure;
hold on;
plot(features)
plot(labels)
plot(labels_test)
hold off;
figure
hold on;
t = (1:length(data_epochs))/handles.SampRate;
plot(t,data_epochs);
plot(t,labels_epochs,'linewidth', 2);
plot(t,labels_test_epochs, 'linewidth', 2);
legend('EEG', 'Training labels', 'Classifier output')
xlabel('Time [s]');
hold off;

% --------------------------------------------------------------------
function plotfeatures_Callback(hObject, eventdata, handles)
% hObject    handle to plotfeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% NF: plot the selected features for the currently displayed segment of
% data
if isempty(handles.bins_sorted)    
    % no subject is loaded, bins_sorted does not exist
    msgbox('No subject loaded', 'Error','error');    
else
    bs = handles.bins_sorted;
    % fetch the current data
    data = handles.chdata(:,2:end);
    channels = 1:size(data,2);
    channels_text = cell(1,length(channels));
    for i_ch = 1:length(channels)
        channels_text{i_ch} = num2str(channels(i_ch));
    end
    % get data from 2 hours around the period of interest to consitute a
    % baseline: data_baseline;   
    opener = strcat(handles.window_filepath, handles.window_filename, '.bin');
    fid = fopen(opener);
    metadata = fread(fid, 3, 'int'); % contains Fs, nchannels_analog, nchannels_digital
    deltaT = handles.window_deltaT*60; %window_deltaT is in minutes so convert to seconds
    % push deltaT an hour back if possible
    window_baseline = 3600;% in [s];
    deltaT = max(deltaT-window_baseline/2,0);
    handles.SampRate = metadata(1);
    handles.NChannels = metadata(2);
    EEGOffset = floor(deltaT * handles.SampRate) * (handles.NChannels + 1);
    fread(fid, EEGOffset, 'double');
    try
        data_baseline = fread(fid,[(handles.NChannels + 1), window_baseline*handles.SampRate],'double');
    catch
        data_baseline = fread(fid,[(handles.NChannels + 1), inf],'double');
    end
    data_baseline=data_baseline(2:end,:)';
    [sel_channels, ok] = listdlg('liststring',channels_text);
    if ok
        if ~isempty(sel_channels)
            data = data(:,sel_channels);
            data_baseline = data_baseline(:,sel_channels);
            feat_names = {'1: RMS'
                                  '2: Coastline'
                                  '3: Band power'
                                  '4: Band power normalized'
                                  '5: Spectral edge frequency'
                                  '6: Skewness'
                                  '7: Kurtosis'
                                  '8: Autocorrelation function'
                                  '9: Hjorth: activity'
                                  '10: Hjorth: mobility'
                                  '11: Hjorth: complexity'
                                  '12: Maximum cross-correlation'
                                  '13: Coherence'
                                  '14: Non-linear energy'
                                  '15: Spectral entropy'
                                  '16: State entropy'
                                  '17: Response entropy'
                                  '18: Sample entropy'
                                  '19: Renyi entropy'
                                  '20: Shannon entropy'
                                  '21: Spikes'
                                  '22: Fractal dimension'
                                  '23: Phase synchronization index'
                                  '24: HFOs'};
            [sel_feat, ok] = listdlg('liststring',feat_names);
            if ok
                if ~isempty(sel_feat)
                    win = 5000; % make it selectable!!!
                    prompt = {'Window length [samples]'};
                    dlg_title = 'Parameters';
                    num_lines = 1;
                    defaultans = {num2str(win)};
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                    win = str2double(answer{1});
                    params.features = sel_feat;
                    params.outputNames = true; % run the function once with names as output so 
                        % the names of the features are stored
                    [~, feat_names] = getEEGfeatures(data, handles.SampRate, params);
                    params.outputNames = false;
                    nFeat = length(feat_names);
                    features = zeros(length(1:win:size(data,1)-win), nFeat);
                    features_baseline = zeros(length(1:win:size(data_baseline,1)-win), nFeat);
                    k=0;
                    i_progress = 0;
                    total_progress = length(features)+length(features_baseline);
                    h = waitbar(0, 'Calculating features');
                    % store std of dataset to claculate sample entropy
                    std_baseline = std(data_baseline,1);
                    params.r = 0.2*std_baseline;
                    % obtain baseline values for the features
                    for i=1:win:size(data_baseline,1)-win
                        k = k+1;
                        i_progress = i_progress+1;
                        features_baseline(k,:) = getEEGfeatures(data_baseline(i:i+win-1,:), handles.SampRate, params); 
                        waitbar(i_progress/total_progress, h, ['Calculating features: ' num2str(i_progress/total_progress*100) '%']);
                    end
                    k = 0;
                    for i=1:win:size(data,1)-win
                        k=k+1;
                        i_progress = i_progress+1;
                        features(k,:) = getEEGfeatures(data(i:i+win-1,:), handles.SampRate, params); 
                        waitbar(i_progress/total_progress, h, ['Calculating features: ' num2str(i_progress/total_progress*100) '%']);
                    end
                    close(h);
                    % norm the features using the baseline features
                    mean_features = mean(features_baseline, 1);
                    sd_features = std(features_baseline, 1);
                    sd_features(1,sd_features==0) = ones(1,sum(sd_features==0));
                    features = (features-repmat(mean_features, [size(features,1) 1]))./...
                        repmat(sd_features, [size(features,1) 1]);
                    % plot change of features with time
                    im = figure('units','normalized','outerposition',[0 0 1 1]);
                    set(im,'Name',[bs.name{1}(1:5) ' - EEG features']);
                    nwins = length(1:win:size(data,1)-win);
                    s1 = subplot('Position', [0.15 0.8 0.8 0.15]);
                    TimeAxis=1:1:size(handles.chdata,1);
                    TimeAxis=(TimeAxis-1)/handles.SampRate;
                    plot(TimeAxis, data);
                    xlim([TimeAxis(1), TimeAxis(end)])
                    ylim([-1.5 1.5]);
                    s2 = subplot('Position', [0.15 0.1 0.8 0.6]);
                    hold on;
                    imagesc(TimeAxis, 1:size(features,2),features');
                    %colorbar
                    caxis([-5 5])
                    xlim([TimeAxis(1), TimeAxis(end)])
                    ylim([0.5 nFeat+0.5]);
                    set(im.CurrentAxes, 'yTick', 1:size(features,2));
                    set(im.CurrentAxes, 'yTickLabel', feat_names);
                    set(im.CurrentAxes, 'xTick', []);
                    set(gca,'fontsize', 7)
                    linkaxes([s1 s2],'x');
                end
            end
        end
    end
end


% --------------------------------------------------------------------
function pca_Callback(hObject, eventdata, handles)
% hObject    handle to pca (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% !!! needs update due to recording id problems

% NF: computes a PCA on selected days and displays the result
if isempty(handles.bins_sorted)    
    % no subject is loaded, bins_sorted does not exist
    msgbox('No subject loaded', 'Error','error');    
else
    bs = handles.bins_sorted;
        % extract the days of recording
    i_day = 0;
    days = [];
    for i = 1:length(bs.name)
        bFound = false;
        for j=1:length(days)
            if strcmp(bs.name{i}(7:end-11), days{j})
                bFound = true;
            end
        end
        if ~bFound
            i_day = i_day+1;
            days{i_day} = bs.name{i}(7:end-11);
        end
    end
    [selection, ok] = listdlg('liststring', days);
    if ok
        if ~isempty(selection)                      
            % fetch the current data to display channels
            chdata = handles.chdata(:,2:end);
            channels = 1:size(chdata,2);
            channels_text = cell(1,length(channels));
            for i_ch = 1:length(channels)
                channels_text{i_ch} = num2str(channels(i_ch));
            end
            [sel_channels, ok] = listdlg('liststring',channels_text);
            if ok
                if ~isempty(sel_channels)
                    feat_names = {'1: RMS'
                                  '2: Coastline'
                                  '3: Band power'
                                  '4: Band power normalized'
                                  '5: Spectral edge frequency'
                                  '6: Skewness'
                                  '7: Kurtosis'
                                  '8: Autocorrelation function'
                                  '9: Hjorth: activity'
                                  '10: Hjorth: mobility'
                                  '11: Hjorth: complexity'
                                  '12: Maximum cross-correlation'
                                  '13: Coherence'
                                  '14: Non-linear energy'
                                  '15: Spectral entropy'
                                  '16: State entropy'
                                  '17: Response entropy'
                                  '18: Sample entropy'
                                  '19: Renyi entropy'
                                  '20: Shannon entropy'
                                  '21: Spikes'};
                    [sel_feat, ok] = listdlg('liststring',feat_names);
                    if ok
                        if ~isempty(sel_feat)                
                            win = 5000; % make it selectable!!!
                            params.features = sel_feat;
                            params.outputNames = true; % run the function once with names as output so 
                                % the names of the features are stored   
                            chdata = chdata(:,sel_channels);
                            [~, feat_names] = getEEGfeatures(chdata, handles.SampRate, params);
                            params.outputNames = false;
                            nFeat = length(feat_names);
                            h = waitbar(0, 'Calculating PCA');
                            features = [];
                            labels = [];
                            lengths = zeros(1, length(bs.name));
                            for i=1:length(selection) % iterate through the selected days
                                for i_recording=1:length(bs.name) % loops through all recordings and checks if they are 
                                    % for the current day
                                    if strcmp(days{selection(i)}, bs.name{i_recording}(7:end-11))                     
                                        % open the bin file
                                        opener = strcat(bs.filepath, bs.name{i_recording});
                                        fid = fopen(opener);
                                        try
                                            metadata = fread(fid, 3, 'int'); % contains Fs, nchannels_analog, nchannels_digital
                                        catch
                                            disp(opener);
                                        end
                                        handles.SampRate = metadata(1);
                                        handles.NChannels = metadata(2);
                                        data = fread(fid,[(handles.NChannels + 1), inf], 'double'); 
                                        fclose(fid);
                                        data=data';
                                        data = data(:,2:end);
                                        data = data(:,sel_channels);
                                        features_temp = zeros(length(1:win:size(data,1)-win), nFeat);
                                        labels_temp = zeros(length(1:win:size(data,1)-win), 1);
                                        if ~isempty(handles.events_info)
                                            ids = [handles.events_info.recording_id] == i_recording;
                                            evs = handles.events_info(ids);
                                            labs = handles.event_labels(ids);
                                            for i_ev = 1:length(evs)
                                                start = evs(i_ev).deltaT*60*handles.SampRate;
                                                dur = evs(i_ev).duration*handles.SampRate;
                                                % read the label
                                                if strcmp(labs{i_ev}, 'Seizure')
                                                    i_start = round(start/win);
                                                    i_end = round((start+dur)/win);
                                                    labels_temp(i_start:i_end) = ones(length(i_start:i_end),1);
                                                end 
                                            end
                                        end
                                        % store std of dataset to claculate sample entropy
                                        std_baseline = std(data,1);
                                        params.r = 0.2*std_baseline;
                                        % obtain values for the features
                                        k = 0;
                                        for i_win=1:win:size(data,1)-win
                                            k=k+1;                                           
                                            features_temp(k,:) = getEEGfeatures(data(i_win:i_win+win-1,:), handles.SampRate, params);                                            
                                        end
                                        waitbar(i/length(selection), h);
                                        % norm the features 
                                        features_temp = zscore(features_temp);
                                        features = [features; features_temp];
                                        labels = [labels; labels_temp];
                                        lengths(i_recording) = length(features_temp);
                                    end
                                end
                            end
                            % calculate the PCA for the selected days and
                            % plot the result
                            assignin('base', 'names', feat_names)
                            [coeff,score,latent,tsquared,explained,mu] = pca(features);
                            figure;
                            bar(explained);
                            figure;
                            bar(coeff(:,1))
                            set(gca, 'xtick', 1:length(feat_names))
                            set(gca, 'xticklabel', feat_names)
                            set(gca, 'xticklabelrotation', 90)
                            figure;
                            bar(coeff(:,2))
                            set(gca, 'xtick', 1:length(feat_names))
                            set(gca, 'xticklabel', feat_names)
                            set(gca, 'xticklabelrotation', 90)
                            figure
                            bar(coeff(:,3))
                            set(gca, 'xtick', 1:length(feat_names))
                            set(gca, 'xticklabel', feat_names)
                            set(gca, 'xticklabelrotation', 90)
                            figure;
                            l = unique(labels);
                            colors = get(gca, 'colororder');
                            hold on;
                            for i_l = 1:length(l)
                                 scatter3(score(labels==l(i_l),1), score(labels==l(i_l),2),...
                                    score(labels==l(i_l),3), [], colors(i_l,:), 'filled');
                            end
                            hold off;
                            legend('Ictal', 'Non-ictal');
                            xlabel('PC1')
                            ylabel('PC2')
                            zlabel('PC3')
                            scores_cell = cell(1,length(lengths));
                            i_write = 1;
                            for i_length = 1:length(lengths)
                                scores_cell{i_length} = score(i_write:i_write+lengths(i_length)-1,1:3);
                                i_write = i_write+lengths(i_length);
                            end
                            assignin('base', 'scores_cell', scores_cell);
                            close(h);
                        end                   
                    end
                end
            end
        end
    end
end

%%% NF: functions handling the sorting of the events list
% note: all these functions keep as a background information the sorting by
% date
% --------------------------------------------------------------------
function sortevents_Callback(hObject, eventdata, handles)
% hObject    handle to sortevents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% the default menu that open options below


% --------------------------------------------------------------------
function bydate_Callback(hObject, eventdata, handles)
% hObject    handle to bydate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = sortEvents(handles, 1);
listbox1_Callback(handles.listbox1, eventdata, handles)
guidata(hObject, handles);

% --------------------------------------------------------------------
function byduration_Callback(hObject, eventdata, handles)
% hObject    handle to byduration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = sortEvents(handles, 2);
listbox1_Callback(handles.listbox1, eventdata, handles)
guidata(hObject, handles);

function handlesOut = sortEvents(handles, type)
handlesOut = handles;
if type == 1
    i_sorted = 1:length(handles.events);
    handles.i_sorted = i_sorted;
    handles.sorting_type = 1;
    handlesOut = updateEventsList(handles);
elseif type == 2
    dur = [handles.events_info.duration];
    [~, i_sorted] = sort(dur);
    handles.i_sorted = i_sorted;
    handles.sorting_type = 2;
    handlesOut = updateEventsList(handles);
end
    

function eventcheckbox_callback(source, callbackdata, handles, hObject)
% NF: function to handle changes in the programmatically created checkboxes
% obtain the handles
handles = guidata(source);
% write the modification in
handles.ev_channels(source.UserData) = source.Value;
% store the handles
guidata(source, handles);


function displaycheckbox_callback(source, callbackdata, handles, hObject)
% NF: function to handle changes in the programmatically created checkboxes
% obtain the handles
handles = guidata(source);
% write the modification in
handles.display_channels(source.UserData) = source.Value;
% store the handles
handles = PlotEEG(handles);
guidata(source, handles);


% --------------------------------------------------------------------
function assignlabels_Callback(hObject, eventdata, handles)
% hObject    handle to assignlabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
window_size = 5000; % window used for the learning in samples
overlap = 0.5; % not used yet !!!
features = [];
labels = [];
%%% find labeled recordings that will be used for the machine learning
foldername = uigetdir();

% needs update due to the rcording_id problem!!!

if ischar(foldername)
    handles.bPipeline = true; % don't forget reset!!!
    % get the events .csv files
    files = dir([foldername '/*.csv']);
    % animal folder is per default the parent folder (!!!)
    sep = strfind(foldername, '\');
    handles.pipeline_foldername = foldername(1:sep(end));
    for i_file = 1:length(files)
        animal = files(i_file).name(1:5);
        % find the associate binary file(s)
        files_animals = dir([handles.pipeline_foldername '/*.bin']);
        handles.pipeline_filename = [];
        for i_file_animal = 1:length(files_animals)
            if strcmp(animal, files_animals(i_file_animal).name(1:5));
                handles.pipeline_filename = files_animals(i_file_animal).name;
            end
        end
        % load the animal's data 
        handles = pb_loadsubj_Callback(handles.pb_loadsubj, [], handles);
        % load the events
        fileID = fopen([foldername '\' files(i_file).name]);
        handles = readCSV(handles, fileID);
        fclose(fileID);
        
        % prepare the structures for data loading
        bs = handles.bins_sorted;              
        events_info = handles.events_info;
        labels_text = handles.event_labels;
        % compute the features for the whole dataset
        for i = 1:length(bs)             
            opener = strcat(bs.filepath, bs.name{i});
            fid = fopen(opener);
            try
                metadata = fread(fid, 3, 'int'); % contains Fs, nchannels_analog, nchannels_digital
            catch
                disp('error reading metadata')
                disp(opener);
            end
            Fs = metadata(1);
            handles.NChannels = metadata(2);
            data = fread(fid,[(handles.NChannels + 1), inf], 'double');
            % close the file that was open
            fclose(fid);
            data=data(2:handles.NChannels+1,:)';
            
            % find seizures in labels for the current recording
            labels0 = zeros(size(data,1),1);
            for i_ev=1:length(events_info)
                % for each labeled seizure write the label
                if strcmp(labels_text{i_ev}, 'Seizure') && events_info(i_ev).recording_id == i
                    start = round(events_info(i_ev).deltaT*60*Fs);
                    dur = round(events_info(i_ev).duration*Fs);
                    labels0(start:start+dur-1) = ones(length(start:start+dur-1),1);
                    % % label preictal data (60 sec)!!!
                    % labels0(max(start-60*Fs,1):start-1) = 2*ones(length(max(start-60*Fs,1):start-1),1);
                end
            end
                    
            % calculate the features for the current recording
            params.chans = 1; % !!!
            params.features = [1:4]; % !!!
            params.outputNames = 1;
            [~, feat_names] = getEEGfeatures(data, Fs, params);
            params.outputNames = 0;
            nFeat = length(feat_names);
            features_temp = zeros(length(1:window_size:length(data)-mod(length(data),window_size)), nFeat);
            labels_temp = zeros(length(1:window_size:length(data)-mod(length(data),window_size)),1);
            i_win_vec = 1:window_size:length(data)-mod(length(data),window_size);  
            tic
            parfor k=1:length(i_win_vec)
                %k=k+1;
                i_win = i_win_vec(k);
                features_temp(k,:) = getEEGfeatures(data(i_win:i_win+window_size-1,:), Fs, params);
                labels_temp(k) = round(mean(labels0(i_win:i_win+window_size-1)));
            end
            toc
            features = [features; features_temp];
            labels = [labels; labels_temp];
        end    
    end
end
handles.bPipeline = false;



% --------------------------------------------------------------------
function createdataset_Callback(hObject, eventdata, handles)
% hObject    handle to createdataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% NF: machine learning - learning from manually labeled set

% !!! perform check or not
doCheck = false;

% create string for the msgbox
msg_string = [];
msg_i = 1;

% parameters to create the data set (default values)
preictal_s = 3600; % read one hour of pre-ictal data
szbuffer_s = 30; % min distance between 'pre-ictal' and ictal data
normal_s = 3600; % for each normal period, the length that is read
szdist_s = 7200; % min distance between 'normal' and ictal data
ratio_normalpreictal = 1; % ration between normal and prei-ictal periods to be read

prompt = {'Pre-ictal period length [s]:',...
    'Minimal distance between pre-ictal and ictal periods [s]: ',...
    'Normal period length [s]:',...
    'Minimal distance between normal and pre-ictal periods [s]: ',...
    'Ratio normal/pre-ictal periods: '};
dlg_title = 'Dataset parameters';
num_lines = 1;
defaultans = {num2str(preictal_s), num2str(szbuffer_s), num2str(normal_s), num2str(szdist_s), num2str(ratio_normalpreictal)};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
preictal_s = str2double(answer{1}); 
szbuffer_s = str2double(answer{2}); 
normal_s = str2double(answer{3}); 
szdist_s = str2double(answer{4}); 
ratio_normalpreictal = str2double(answer{5});


label_names = {'Normal', 'Pre-ictal', 'Seizure'};
dataset_params.preictal_s = preictal_s; 
dataset_params.szbuffer_s = szbuffer_s;
dataset_params.normal_s = normal_s; 
dataset_params.szdist_s = szdist_s; 
dataset_params.ratio_normalpreictal = ratio_normalpreictal;

%%% find labeled recordings that will be used for the machine learning
foldername = uigetdir('', 'Select folder that contains the events files');
% choose directory to save dataset
savefoldername = uigetdir('', 'Select folder to save the data');
h = waitbar(0, 'Creating dataset...');
if ischar(foldername) && ischar(savefoldername)
    handles.bPipeline = true; 
    % get the events .csv files
    files = dir([foldername '/*.csv']);
    % animal folder is per default the parent folder (!!!)
    sep = strfind(foldername, '\');
    handles.pipeline_foldername = foldername(1:sep(end));
    for i_file = 1:length(files)
        data_all = single([]); % will be used to write all the data
        labels = single([]); % labels for each data point (0 for normal, 1 for pre-ictal, 2 for seizure)
        animal_id = single([]); % identifies which chunk of data corresponds to which animal
        sample_globaltime = single([]); % keeps globaltime for extracted data segments
        i_sample = [];
        part = 1;
        animal = files(i_file).name(1:5);
        animal_name = animal;
        % find the associated binary file(s)
        files_animals = dir([handles.pipeline_foldername '/*.bin']);
        handles.pipeline_filename = [];
        for i_file_animal = 1:length(files_animals)
            if strcmp(animal, files_animals(i_file_animal).name(1:5))
                handles.pipeline_filename = files_animals(i_file_animal).name;
            end
        end
        % load the animal's data 
        handles = pb_loadsubj_Callback(handles.pb_loadsubj, [], handles);
        % load the events
        fileID = fopen([foldername '\' files(i_file).name]);
        handles = readCSV(handles, fileID);
        fclose(fileID);
        
        % prepare the structures for data loading
        bs = handles.bins_sorted;              
        events_info = handles.events_info;
        labels_text = handles.event_labels;
        % generate actual labels and features from the event structures
        nSz = 0; % count the seizures
        nPi = 1;
        sz_globaltime = [];
        for i_ev=1:length(events_info)
            % for each labeled seizure pull the data and assign a label 
            start = events_info(i_ev).deltaT*60*handles.SampRate;
            dur = events_info(i_ev).duration*handles.SampRate;
            % read the label
            if strcmp(labels_text{i_ev}, 'Seizure')
                % read the corresponding data
                rec_id = find(events_info(i_ev).globaltime<handles.bins_sorted.endtime,1);
                opener = strcat(bs.filepath, bs.name{rec_id});
                fid = fopen(opener);
                metadata = fread(fid, 3, 'int'); % contains Fs, nchannels_analog, nchannels_digital
                Fs = metadata(1);
                nChan = metadata(2);
                % for each seizure add a one hour pre-ictal period (if
                % possible) plus the buffer period
                EEGOffset = max(0,(floor(start)-Fs*(preictal_s+szbuffer_s))*(nChan + 1));
                fread(fid, EEGOffset, 'double');
                data = fread(fid,[(nChan + 1), max(0,min(Fs*preictal_s, floor(start)-Fs*szbuffer_s))],'double');
                if ~isempty(data)
                    data=data(2:5,:)';
                    % choose to include or not the pre-ictal period
                    tit = ['Pre-ictal EEG period ' num2str(nPi) ' (' animal ')'];
                    if doCheck
                        c = perioddialog(data, Fs, tit);
                    else
                        c = true;
                    end
                    % store the data in the data_all matrix
                    if c
                        i_sample = [i_sample length(data_all)+1];
                        data_all = [data_all; data];
                        labels = [labels ones(1,size(data,1))*1];
                        animal_id = [animal_id ones(1,size(data,1))*i_file];
                        nPi = nPi+1;
                        sample_globaltime = [sample_globaltime, ...
                            handles.bins_sorted.starttime(rec_id)+...
                            max(0,(floor(start)/Fs-(preictal_s+szbuffer_s))/60)];
                    end
                end
                % advance through ictal buffer
                fread(fid,[(nChan + 1), min(Fs*szbuffer_s, floor(start))],'double');
                % read seizure data and store it
                data = fread(fid,[(nChan + 1), dur],'double');
                data=data(2:5,:)';
                fclose(fid);
                i_sample = [i_sample length(data_all)+1];
                data_all = [data_all; data];
                labels = [labels ones(1,size(data,1))*2]; 
                animal_id = [animal_id ones(1,size(data,1))*i_file];
                nSz = nSz+1;
                % save the globaltime of the seizures for later
                sz_globaltime = [sz_globaltime events_info(i_ev).globaltime];
                sample_globaltime = [sample_globaltime events_info(i_ev).globaltime];
            end
        end
        % for each seizure, find a period of normal data that is minimally
        % min_sz_dist seconds away from a seizure
        normal_count = 0;
        time_span = bs.endtime(end)-bs.starttime(1); 
        while normal_count<nSz*ratio_normalpreictal
            % pick period randomly
            beg = bs.starttime(1)+round(rand*time_span);
            % find recording where this start time is to be found
            index = find(bs.starttime <= beg);
            index = index(end);
            % check conditions to select the period
            % interictal: has to be later than the first seizure of the
            % epileptic phase
            if beg+normal_s/60<bs.endtime(index) && beg>min(sz_globaltime)
                if min(abs(sz_globaltime-beg))>szdist_s/60
                    % read and append the data
                    opener = strcat(bs.filepath, bs.name{index});
                    fid = fopen(opener);
                    metadata = fread(fid, 3, 'int'); 
                    deltaT = beg-bs.starttime(index); 
                    EEGOffset = floor(deltaT*60*Fs) * (nChan + 1);
                    fread(fid, EEGOffset, 'double');
                    data = fread(fid,[(nChan + 1), normal_s*Fs],'double');
                    data=data(2:5,:)';
                    fclose(fid);
                    %figure()
                    %plot(data) 
                    tit = ['Normal EEG period ' num2str(normal_count+1) '/' num2str(floor(nSz*ratio_normalpreictal)) ' (' animal ')'];
                    if doCheck
                        c = perioddialog(data, Fs, tit);
                    else
                        c = true;
                    end
                    if c
                        i_sample = [i_sample length(data_all)+1];
                        data_all = [data_all; data];
                        labels = [labels zeros(1,size(data,1))];
                        animal_id = [animal_id ones(1,size(data,1))*i_file];
                        normal_count = normal_count+1; 
                        sample_globaltime = [sample_globaltime beg];
                    end
                    % if matrix is big, do intermediary save to free memory
                    if length(data_all)>50*3600*Fs
                        name = [savefoldername '\' animal datestr(now,'yyyy-mm-dd') '_part' num2str(part)];
                        part = part+1;
                        save(name, 'data_all', 'label_names', 'labels', 'animal_name',...
                            'dataset_params', 'sample_globaltime', 'i_sample', '-v7.3');
                        msg_string{msg_i} = ['Data written to ' name];
                        msg_i = msg_i+1;
                        msgbox(msg_string, 'replace');
                        data_all = single([]); 
                        labels = single([]);  
                        animal_id = single([]); 
                        sample_globaltime = single([]);
                        i_sample = [];
                    end
                end
            end
        end
        % also save the parameters used in the creation of the dataset
        if part>1
            name = [savefoldername '\' animal datestr(now,'yyyy-mm-dd') '_part' num2str(part)];
        else
            name = [savefoldername '\' animal datestr(now,'yyyy-mm-dd')];
        end
            save(name, 'data_all', 'label_names', 'labels', 'animal_name',...
                    'dataset_params', 'sample_globaltime', 'i_sample', '-v7.3');
        msg_string{msg_i} = ['Data written to ' name];
        msg_i = msg_i+1;
        msgbox(msg_string, 'replace');
        waitbar(i_file/length(files), h);
    end
else
    errordlg('An invalid directory was chosen');
end
handles.bPipeline = false;
close(h);


function c = perioddialog(data, Fs, tit)
    d = dialog('Position',[100 100 1200 600],'Name',tit);
    global choice;
    choice = 0;
    
    ax1 = axes('Parent', d, 'Position',[0.2 0.15 0.7 0.35]);
    zoom
    
    ax2 = axes('Parent', d, 'Position',[0.2 0.6 0.7 0.35]);
    
    toggle = uicontrol('Parent',d,...
           'Style','checkbox',...
           'Position',[20 100 100 25],...
           'String','Include',...
           'Callback',@toggle_callback);
    
    btn = uicontrol('Parent',d,...
           'Position',[20 50 70 25],...
           'String','Close',...
           'Callback','delete(gcf)');
       
    plot(ax2, (1:size(data,1))/Fs, data)
    xlabel(ax2,'Time [s]')
    try
        [p,f] = pwelch(data, min(Fs*10,size(data,1)), min(Fs*10,size(data,1))/2, 2^nextpow2(min(Fs*10,size(data,1))), Fs);
        plot(ax1, f, 20*log10(p))
    catch
       disp('test')
       
    end
    ylabel(ax1,'20log_{10}(Pxx)')
    xlabel(ax1,'Frequency [Hz]')
       
    % Wait for d to close before running to completion
    uiwait(d);
    c = choice;

function toggle_callback(toggle, event)
        global choice;
        choice = toggle.Value;       


% --------------------------------------------------------------------
function savewindowdata_Callback(hObject, eventdata, handles)
% hObject    handle to savewindowdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.bins_sorted)    
    % no subject is loaded, bins_sorted does not exist
    msgbox('No subject loaded', 'Error','error');    
else
    bs = handles.bins_sorted;
    % fetch the current data
    data = handles.chdata(:,2:end);
    foldername = uigetdir();
    if ischar(foldername)
        fid = fopen([foldername '\\data_window.bin'], 'w');
        fwrite(fid, single(data'), 'float32')
        fclose(fid);
        %save([foldername '\\data_window.mat'], 'data')
    else
        msgbox('No folder selected, data not saved', 'Error','error'); 
    end
end


% --------------------------------------------------------------------
function filteringdisplay_Callback(hObject, eventdata, handles)
% hObject    handle to filteringdisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = filterdialog(handles.filtering_options);
handles.filtering_options = answer;
handles = PlotEEG(handles);
guidata(hObject, handles);


function ret = filterdialog(defaultans)
    d = dialog('Position',[400 400 300 200],'Name','Filtering options');
    global answer;
    answer = defaultans;
    global bApply;
    bApply = false;

    
     % bandstop filter
    toggle_bandstop = uicontrol('Parent',d,...
           'Style','checkbox',...
           'Value', defaultans.bandstop,...
           'Position',[20 150 100 25],...
           'String','Band-stop filter',...
           'Callback',@toggle_callback_bandstop);
       
    frequency_bandstop_low = uicontrol('Parent',d,...
           'Style','edit',...
           'String', num2str(defaultans.bandstop_freq_low),...
           'Position',[150 150 40 25],...
           'Callback',@edit_callback_bandstop_low);
       
    frequency_bandstop_high = uicontrol('Parent',d,...
           'Style','edit',...
           'String', num2str(defaultans.bandstop_freq_high),...
           'Position',[220 150 40 25],...
           'Callback',@edit_callback_bandstop_high);
    
    % bandpass filter
    toggle_bandpass = uicontrol('Parent',d,...
           'Style','checkbox',...
           'Value', defaultans.bandpass,...
           'Position',[20 100 100 25],...
           'String','Band-pass filter',...
           'Callback',@toggle_callback_bandpass);
       
    frequency_bandpass_low = uicontrol('Parent',d,...
           'Style','edit',...
           'String', num2str(defaultans.bandpass_freq_low),...
           'Position',[150 100 40 25],...
           'Callback',@edit_callback_bandpass_low);
       
    frequency_bandpass_high = uicontrol('Parent',d,...
           'Style','edit',...
           'String', num2str(defaultans.bandpass_freq_high),...
           'Position',[220 100 40 25],...
           'Callback',@edit_callback_bandpass_high);
       
%     % high pass filter  
%     toggle_highpass = uicontrol('Parent',d,...
%            'Style','checkbox',...
%            'Value', defaultans.highpass,...
%            'Position',[20 100 100 25],...
%            'String','High-pass filter',...
%            'Callback',@toggle_callback_highpass);
% 
%     frequency_highpass = uicontrol('Parent',d,...
%            'Style','edit',...
%            'String', num2str(defaultans.highpass_freq),...
%            'Position',[150 100 40 25],...
%            'Callback',@edit_callback_highpass_freq);
       
    
    btn = uicontrol('Parent',d,...
           'Position',[20 30 70 25],...
           'String','Apply',...
           'Callback',@apply_callback);
       
       
    % Wait for d to close before running to completion
    uiwait(d)
    if bApply
        ret = answer;
    else
        ret = defaultans;
    end
 
function toggle_callback_bandstop(toggle, event)
    global answer;
    answer.bandstop = toggle.Value;   
    
function edit_callback_bandstop_low(edit, event)
    global answer;
    answer.bandstop_freq_low = str2double(edit.String); 
    
function edit_callback_bandstop_high(edit, event)
    global answer;
    answer.bandstop_freq_high = str2double(edit.String);     
    
    
function toggle_callback_bandpass(toggle, event)
    global answer;
    answer.bandpass = toggle.Value;   
    
function edit_callback_bandpass_low(edit, event)
    global answer;
    answer.bandpass_freq_low = str2double(edit.String); 
    
function edit_callback_bandpass_high(edit, event)
    global answer;
    answer.bandpass_freq_high = str2double(edit.String); 
    
% function toggle_callback_highpass(toggle, event)
%     global answer;
%     answer.highpass = toggle.Value;   
%     
% function edit_callback_highpass_freq(edit, event)
%     global answer;
%     answer.highpass_freq = str2double(edit.String); 

function apply_callback(button, event) %#ok<*INUSD>
    global bApply;
    bApply = true;
    delete(gcf)


% --------------------------------------------------------------------
function changescale_Callback(hObject, eventdata, handles)
% hObject    handle to changescale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.EEG_vertical_offset = 1.5;
handles.sliderscale.Value = 1.5;
handles = PlotEEG(handles);
guidata(hObject, handles);

% --- Executes on slider movement.
function sliderscale_Callback(hObject, eventdata, handles)
% hObject    handle to sliderscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
scale = get(hObject,'Value');
handles.EEG_vertical_offset = scale;
handles = PlotEEG(handles);
set(hObject, 'Enable', 'off');
drawnow;
set(hObject, 'Enable', 'on');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --------------------------------------------------------------------
function createdatasetepilept_Callback(hObject, eventdata, handles)
% hObject    handle to createdatasetepilept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% !!! perform check or not
doCheck = false;

% create string for the msgbox
msg_string = [];
msg_i = 1;

% parameters to create the data set (default values)
period_s = 3600; % length of periods to read
interval_s = 24*3600; % interval between the periods

prompt = {'Period length [s]:',...
    'Distance between periods [s]: '};
dlg_title = 'Dataset parameters';
num_lines = 1;
defaultans = {num2str(period_s), num2str(interval_s)};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
period_s = str2double(answer{1}); 
interval_s = str2double(answer{2}); 


dataset_params.period_s = period_s; 
dataset_params.interval_s = interval_s; %#ok<STRNU>

%%% find labeled recordings that will be used for the machine learning
foldername = uigetdir('', 'Select folder that contains the events files');
% choose directory to save dataset
savefoldername = uigetdir('', 'Select folder to save the data');
h = waitbar(0, 'Creating dataset...');
if ischar(foldername) && ischar(savefoldername)
    handles.bPipeline = true; 
    % get the events .csv files
    files = dir([foldername '/*.csv']);
    % animal folder is per default the parent folder (!!!)
    sep = strfind(foldername, '\');
    handles.pipeline_foldername = foldername(1:sep(end));
    for i_file = 1:length(files)
        data_all = single([]); % will be used to write all the data
        labels = single([]); % labels for each data point (0 for normal, 1 for pre-ictal, 2 for seizure)
        animal_id = single([]); % identifies which chunk of data corresponds to which animal
        sample_globaltime = single([]); % keeps globaltime for extracted data segments
        i_sample = [];
        part = 1;
        animal = files(i_file).name(1:5);
        animal_name = animal;
        % find the associated binary file(s)
        files_animals = dir([handles.pipeline_foldername '/*.bin']);
        handles.pipeline_filename = [];
        for i_file_animal = 1:length(files_animals)
            if strcmp(animal, files_animals(i_file_animal).name(1:5))
                handles.pipeline_filename = files_animals(i_file_animal).name;
            end
        end
        % load the animal's data 
        handles = pb_loadsubj_Callback(handles.pb_loadsubj, [], handles);
        % load the events
        fileID = fopen([foldername '\' files(i_file).name]);
        handles = readCSV(handles, fileID);
        fclose(fileID);
        
        % prepare the structures for data loading
        bs = handles.bins_sorted;              
        events_info = handles.events_info;
        labels_text = handles.event_labels;
        % find the time of the first seizure
        sz_globaltime = Inf;
        for i_ev=1:length(events_info)
            % for each labeled seizure pull the data and assign a label 
            start = events_info(i_ev).globaltime;
            % read the label
            if strcmp(labels_text{i_ev}, 'Seizure')
                if start<sz_globaltime
                    sz_globaltime=start;
                end
            end
        end
        % pick up periods with a specified interval
        for beg = bs.starttime(1)+interval_s/60:interval_s/60:bs.endtime(end)
            % find recording where this start time is to be found
            index = find(bs.starttime <= beg);
            index = index(end);
            % read data in the recording
            data = [];
            length_toread = period_s;
            deltaT = beg-bs.starttime(index); 
            while true
                opener = strcat(bs.filepath, bs.name{index});
                fid = fopen(opener);
                metadata = fread(fid, 3, 'int');
                Fs = metadata(1);
                nChan = metadata(2);
                EEGOffset = floor(deltaT*60*Fs) * (nChan + 1);
                fread(fid, EEGOffset, 'double');
                data = [data fread(fid,[(nChan + 1), length_toread*Fs],'double')];
                fclose(fid);
                try 
                    if size(data,2)/Fs>=period_s || bs.starttime(index+1)-bs.endtime(index)>1
                        break;
                    else
                        if index +1<length(bs.starttime)
                            index = index+1;
                            length_toread = period_s-size(data,2)/Fs;
                            deltaT = 0;
                        else
                            break;
                        end
                    end
                catch
                    break;
                end
            end
            if ~isempty(data)
                data=data(2:5,:)';
                % calculate time from first seizure
                time_from_sz = sz_globaltime-beg;
                % write read data in the vectors
                i_sample = [i_sample length(data_all)+1];
                data_all = [data_all; data];
                labels = [labels time_from_sz*ones(1,size(data,1))];
                animal_id = [animal_id ones(1,size(data,1))*i_file];
                sample_globaltime = [sample_globaltime beg];
                % if matrix is big, do intermediary save to free memory
                if length(data_all)>50*3600*Fs
                    name = [savefoldername '\' animal datestr(now,'yyyy-mm-dd') '_part' num2str(part)];
                    part = part+1;
                    save(name, 'data_all', 'labels', 'animal_name',...
                        'dataset_params', 'sample_globaltime', 'i_sample', '-v7.3');
                    msg_string{msg_i} = ['Data written to ' name];
                    msg_i = msg_i+1;
                    msgbox(msg_string, 'replace');
                    data_all = single([]); 
                    labels = single([]);  
                    animal_id = single([]); 
                    sample_globaltime = single([]);
                    i_sample = [];
                end
            end
        end
        % also save the parameters used in the creation of the dataset
        if part>1
            name = [savefoldername '\' animal datestr(now,'yyyy-mm-dd') '_part' num2str(part)];
        else
            name = [savefoldername '\' animal datestr(now,'yyyy-mm-dd')];
        end
            save(name, 'data_all', 'labels', 'animal_name',...
                    'dataset_params', 'sample_globaltime', 'i_sample', '-v7.3');
        msg_string{msg_i} = ['Data written to ' name];
        msg_i = msg_i+1;
        msgbox(msg_string, 'replace');
        waitbar(i_file/length(files), h);
    end
else
    errordlg('An invalid directory was chosen');
end
handles.bPipeline = false;
close(h);


% --------------------------------------------------------------------
function eventtimeplot_Callback(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
% hObject    handle to eventtimeplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.bins_sorted)    
    % no subject is loaded, bins_sorted does not exist
    msgbox('No subject loaded', 'Error','error');
elseif isempty(handles.events_info)
    msgbox('No events loaded', 'Error','error');
else
    event_labels = handles.event_labels;
    for i = 1:length(event_labels)
        if isempty(event_labels{i})
            event_labels{i} = 'Unlabeled';
        end
    end
    ul = unique(event_labels);
    if length(ul)>1
        [sel_labels, ok] = listdlg('liststring',ul);
        if ok
            if ~isempty(sel_labels)  
                labels = ul(sel_labels);
                bEvent = false(1,length(handles.events_info));
                for i = 1:length(handles.events_info)
                    bEvent(i) = ismember(event_labels{i},labels);
                end
            end
        end
    else
        bEvent = true(1,length(handles.events_info));
    end
    ev_labels = handles.event_labels(bEvent); %#ok<*NASGU>
    times = [handles.events_info(bEvent).globaltime];
    times = times/(60*24)+handles.bins_sorted.initialtime;
    times = mod(times,1)*24;
    % plot the times
    f=figure;
    set(f,'name', 'Event timings');
    set(f,'position', [513 450 828 264]);
    scatter(times, linspace(0,1,length(times)), 'filled');
    h = 0:2:24;
    set(gca, 'xtick', h)
    h_string = cell(1,length(h));
    for i = 1:length(h)
        h_string{i} = [num2str(h(i)) ':00'];
    end
    set(gca, 'xticklabel', h_string)
    xlabel('Time of the day')
    xlim([0 24]);
    set(gca, 'ytick', [])
    choice = questdlg('Export data?','Data save', 'Yes','No','No');
    switch choice
        case 'Yes'
            [filename, pathname] = uiputfile('event_timings.mat','Save file name');
            save([pathname, filename], 'times', 'ev_labels');
        case 'No'
            return;
        case ''
            return;
    end      
end
    
    
    
    
    



% --------------------------------------------------------------------
% function togglenormalization_Callback(hObject, eventdata, handles)
% % hObject    handle to togglenormalization (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% handles.bNorm = ~handles.bNorm;
% guidata(hObject, handles);

function generateseizuresdates_Callback(hObject, eventdata, handles)
% hObject    handle to generateseizuresdates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.bins_sorted)    
    % no subject is loaded, bins_sorted does not exist
    msgbox('No subject loaded', 'Error','error');
elseif isempty(handles.events_info)
    msgbox('No events loaded', 'Error','error');
else
    event_labels = handles.event_labels;
    for i = 1:length(event_labels)
        if isempty(event_labels{i})
            event_labels{i} = 'Unlabeled';
        end
    end
    ul = unique(event_labels);
    if length(ul)>1
        [sel_labels, ok] = listdlg('liststring',ul);
        if ok
            if ~isempty(sel_labels)  
                labels = ul(sel_labels);
                bEvent = false(1,length(handles.events_info));
                for i = 1:length(handles.events_info)
                    bEvent(i) = ismember(event_labels{i},labels);
                end
            end
        end
    else
        bEvent = true(1,length(handles.events_info));
    end
    ev_labels = handles.event_labels(bEvent); %#ok<*NASGU>
    times = [handles.events_info(bEvent).globaltime];
    times = times/(60*24)+handles.bins_sorted.initialtime;
    choice = questdlg('Export data?','Data save', 'Yes','No','No');
    switch choice
        case 'Yes'
            [filename, pathname] = uiputfile([handles.bins_sorted.name{1}(1:5) '_event_dates.mat'],'Save file name');
            save([pathname, filename], 'times', 'ev_labels');
        case 'No'
            return;
        case ''
            return;
    end      
end
