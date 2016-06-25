function varargout = OneManAcapella(varargin)
% ONEMANACAPELLA MATLAB code for OneManAcapella.fig
%      ONEMANACAPELLA, by itself, creates a new ONEMANACAPELLA or raises the existing
%      singleton*.
%
%      H = ONEMANACAPELLA returns the handle to a new ONEMANACAPELLA or the handle to
%      the existing singleton*.
%
%      ONEMANACAPELLA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ONEMANACAPELLA.M with the given input arguments.
%
%      ONEMANACAPELLA('Property','Value',...) creates a new ONEMANACAPELLA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OneManAcapella_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OneManAcapella_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OneManAcapella

% Last Modified by GUIDE v2.5 17-Jun-2016 23:55:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OneManAcapella_OpeningFcn, ...
                   'gui_OutputFcn',  @OneManAcapella_OutputFcn, ...
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


% --- Executes just before OneManAcapella is made visible.
function OneManAcapella_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OneManAcapella (see VARARGIN)

% Choose default command line output for OneManAcapella
handles.fs = 44100;
handles.bit = 16;
handles.nchannel = 1;


handles.output = hObject;
handles.audioData = cell(10, 1);
handles.modifiedAudio = cell(10,1);
handles.dataProperty = {};
handles.audioCount = 0;
handles.selectedRow = 0;
handles.isModified = false;
handles.current = 0;
set(handles.btnSave, 'String', 'Modify');

handles.recObj = audiorecorder(handles.fs, handles.bit, handles.nchannel);
handles.playObj = 0;

handles.isRecording = false;

background = imread('acapella1.jpg');
axes(handles.axes2);
A = imshow(background);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OneManAcapella wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OneManAcapella_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnAddRecord.
function btnAddRecord_Callback(hObject, eventdata, handles)
% hObject    handle to btnAddRecord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.edtSeconds, 'Enable', 'on');
    set(handles.btnStartRecord, 'Enable', 'on');
    set(handles.rdobtnIsTimeLimit, 'Enable', 'on');
    set(handles.rdobtnIsTimeLimit, 'value', 1);
    set(handles.rdobtnNoTimeLimit, 'Enable', 'on');
    uicontrol(handles.edtSeconds);
    
    

% --- Executes on button press in btnStartRecord.
function btnStartRecord_Callback(hObject, eventdata, handles)
% hObject    handle to btnStartRecord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    %stop no time limit record
    if (handles.isRecording == true)
        handles.isRecording = false;
        stop(handles.recObj);
        
        set(handles.txtCountDown, 'Visible', 'off');
        set(handles.txtCountDown, 'String', 'start in 3 seconds')
        set(handles.edtSeconds, 'Enable', 'off');
        set(handles.btnStartRecord, 'Enable', 'off');
        set(handles.btnStartRecord, 'String', 'start recording');
    
        y = getaudiodata(handles.recObj, 'double');
        audioName = sprintf('newRecord%d',handles.audioCount+1);
        
        duration = length(y)/handles.fs;
        if handles.audioCount ~= 0
            tableData = get(handles.uitableData, 'data');
            [row col] = size(tableData);
            tableData(row+1,:) = {audioName 1 0 duration 1 false;};
            handles.audioData{row+1} = y;
            set(handles.uitableData, 'data', tableData);
        else
            tableData = {audioName 1 0 duration 1 false;};
            handles.audioData{1} = y;
            set(handles.uitableData, 'data', tableData);
        end
        handles.audioCount = handles.audioCount + 1;
        guidata(hObject, handles);
        plot((1:length(y))/handles.fs, y); xlabel('Time (sec)'); ylabel('Amplitude');
        set(handles.btnStartRecord, 'String', 'Start Recording');
        return
    end
    
    
    isTimeLimit = get(handles.rdobtnIsTimeLimit, 'value');

    duration = str2double(get(handles.edtSeconds, 'String'));
    if isTimeLimit == 1
        if ~isnumeric(duration) || duration == 0
            errMsg = 'Please input correct number';
            set(handles.edtSeconds, 'String', errMsg);
            return
        end
    else
        duration = 10;
    end
    
    handles.recObj=audiorecorder(handles.fs, handles.bit, handles.nchannel);
	handles.recObj.TimerPeriod = 0.025;
    y = zeros(1, handles.fs*duration);
    
    axes(handles.axes1);
    h = plot((1:length(y)) / handles.fs, y);
    cursor = line(0*[1 1], [1 -1], 'color', 'r', 'linewidth', 2);
    axis([-inf inf -1 1]);
    handles.recObj.TimerFcn = {@dynamicDraw, handles.recObj, h, cursor, duration, handles.fs, isTimeLimit};
    %recObj.StopFcn = {@endRecording};
    set(handles.txtCountDown, 'Visible', 'on');
    pause(1);
    set(handles.txtCountDown, 'String', 'start in 2 seconds')
    pause(1);
    set(handles.txtCountDown, 'String', 'start in 1 seconds')
    pause(1);
    set(handles.txtCountDown, 'String', 'Start Recording')
    
    
    if (isTimeLimit == 1)
        recordblocking(handles.recObj, duration);
        
        set(handles.txtCountDown, 'Visible', 'off');
        set(handles.txtCountDown, 'String', 'start in 3 seconds')
        set(handles.edtSeconds, 'Enable', 'off');
        set(handles.btnStartRecord, 'Enable', 'off');
        
        
        y = getaudiodata(handles.recObj, 'double');

        audioName = sprintf('newRecord%d',handles.audioCount+1);
        if handles.audioCount ~= 0
            tableData = get(handles.uitableData, 'data');
            [row col] = size(tableData);
            tableData(row+1,:) = {audioName 1 0 duration 1 false;};
            handles.audioData{row+1} = y;
            set(handles.uitableData, 'data', tableData);
        else
            handles.audioData{1} = y;
            tableData = {audioName 1 0 duration 1 false;};
            set(handles.uitableData, 'data', tableData);
        end
        handles.audioCount = handles.audioCount + 1;
        guidata(hObject, handles);
        plot((1:length(y))/handles.fs, y); xlabel('Time (sec)'); ylabel('Amplitude');
    else
        record(handles.recObj);
        handles.isRecording = true;
        set(handles.btnStartRecord, 'String', 'Stop Recording');
        guidata(hObject, handles);
    end
    set(handles.rdobtnIsTimeLimit, 'Enable', 'off');
    set(handles.rdobtnNoTimeLimit, 'Enable', 'off');
        
    
    
    


function edtSeconds_Callback(hObject, eventdata, handles)
% hObject    handle to edtSeconds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtSeconds as text
%        str2double(get(hObject,'String')) returns contents of edtSeconds as a double


% --- Executes during object creation, after setting all properties.
function edtSeconds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtSeconds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sldVolume_Callback(hObject, eventdata, handles)
% hObject    handle to sldVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
vol = get(handles.sldVolume, 'Value');
pitch = get(handles.sldPitch, 'Value');
speed = get(handles.sldSpeed, 'Value');
set(handles.txtVolume, 'String', num2str(vol));
current = handles.audioData{handles.selectedRow};
current = speedModify(pitchModify(current, pitch), speed) * vol;
if handles.playObj ~= 0
    stop(handles.playObj);
end
if length(current) > handles.fs*3
    current = current(1:handles.fs*3);
end
handles.playObj = audioplayer(current, handles.fs);
playblocking(handles.playObj);

% --- Executes during object creation, after setting all properties.
function sldVolume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sldPitch_Callback(hObject, eventdata, handles)
% hObject    handle to sldPitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
vol = get(handles.sldVolume, 'Value');
pitch = get(handles.sldPitch, 'Value');
speed = get(handles.sldSpeed, 'Value');
set(handles.txtPitch, 'String', num2str(pitch));
current = handles.audioData{handles.selectedRow};
current = speedModify(pitchModify(current, pitch), speed) * vol;
if handles.playObj ~= 0
    stop(handles.playObj);
end
if length(current) > handles.fs*3
    current = current(1:handles.fs*3);
end
handles.playObj = audioplayer(current, handles.fs);
playblocking(handles.playObj);

% --- Executes during object creation, after setting all properties.
function sldPitch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldPitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sldSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to sldSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
vol = get(handles.sldVolume, 'Value');
pitch = get(handles.sldPitch, 'Value');
speed = get(handles.sldSpeed, 'Value');
set(handles.txtSpeed, 'String', num2str(speed));
current = handles.audioData{handles.selectedRow};
current = speedModify(pitchModify(current, pitch), speed) * vol;
if handles.playObj ~= 0
    stop(handles.playObj);
end
if length(current) > handles.fs*3
    current = current(1:handles.fs*3);
end
handles.playObj = audioplayer(current, handles.fs);
playblocking(handles.playObj);


% --- Executes during object creation, after setting all properties.
function sldSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rdobtnIsTimeLimit.
function rdobtnIsTimeLimit_Callback(hObject, eventdata, handles)
% hObject    handle to rdobtnIsTimeLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    isTimeLimit = get(handles.rdobtnIsTimeLimit, 'value');
    if isTimeLimit
        set(handles.rdobtnNoTimeLimit, 'value', 0);
        set(handles.edtSeconds, 'Enable', 'on');
    else
        set(handles.rdobtnNoTimeLimit, 'value', 1);
    end
% Hint: get(hObject,'Value') returns toggle state of rdobtnIsTimeLimit


% --- Executes on button press in rdobtnNoTimeLimit.
function rdobtnNoTimeLimit_Callback(hObject, eventdata, handles)
% hObject    handle to rdobtnNoTimeLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    NoTimeLimit = get(handles.rdobtnNoTimeLimit, 'value');
    if NoTimeLimit
        set(handles.rdobtnIsTimeLimit, 'value', 0);
        set(handles.edtSeconds, 'Enable', 'off');
    else
        set(handles.rdobtnIsTimeLimit, 'value', 1);
    end
% Hint: get(hObject,'Value') returns toggle state of rdobtnNoTimeLimit



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnLoad.
function btnLoad_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    filename = uigetfile({'*.wav;','All Files' });
    [y, fs] = audioread(filename);
    filelength = length(y(:, 1));  
    y = y(:,1);
    if handles.audioCount ~= 0
        tableData = get(handles.uitableData,'Data');
        [row col] = size(tableData);
        tableData(row+1, :) = {filename 1 0 filelength/fs 1 false};
        handles.audioData{row+1} = y;
    else
        tableData = {filename 1 0 filelength/fs 1 false};
        handles.audioData{1} = y;
    end
    %newData = [oldData; {filename 1 0 length 1 0}];
    set(handles.uitableData,'Data', tableData);
    guidata(hObject, handles);
    

% --- Executes on button press in btnDelete.
function btnDelete_Callback(hObject, eventdata, handles)
% hObject    handle to btnDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    tableData = get(handles.uitableData, 'Data');
    checkbox = tableData(:,6);
    %checkbox = checkbox.';
    index = find([checkbox{:}] == 1);
    for i = length(index): -1: 1
        tableData(index(i), :) = []; 
        handles.audioData(index(i)) = [];
    end
    handles.audioCount = handles.audioCount - length(index);
    guidata(hObject, handles);
    set(handles.uitableData,'Data', tableData);
    disp(size(tableData))

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    disp(handles.audioCount);
    sound(handles.audioData{handles.audioCount},16000);


function edtTestPlay_Callback(hObject, eventdata, handles)
% hObject    handle to edtTestPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtTestPlay as text
%        str2double(get(hObject,'String')) returns contents of edtTestPlay as a double


% --- Executes during object creation, after setting all properties.
function edtTestPlay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtTestPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnTestPlay.
function btnTestPlay_Callback(hObject, eventdata, handles)
% hObject    handle to btnTestPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tableData = get(handles.uitableData, 'data');
checkbox = [tableData{:,6}];
idx = find(checkbox == 1);

testTime = str2double(get(handles.edtTestPlay, 'String'));
arr_len = floor(handles.fs * testTime);

if length(idx) > 1
    % Play selected files
    play = zeros(arr_len,1);
    for i = 1:length(idx)
        temp = handles.audioData{idx(i)};
        cumul_len = 0;
        while cumul_len < arr_len
            if cumul_len + length(temp) <= arr_len
                play( cumul_len+1 : cumul_len+length(temp) ) = play( cumul_len+1 : cumul_len+length(temp) ) + temp;    
            else
                end_idx = arr_len - cumul_len;
                play( cumul_len+1 : arr_len) = play( cumul_len+1 : arr_len) + temp(1 : end_idx);
            end
            cumul_len = cumul_len + length(temp);
        end
    end
    sound(play, handles.fs);
else
    %speedRatio = get(handles.sldSpeed, 'Value');
    %pitchIdx = get(handles.sldPitch, 'Value');
    %volumeRatio = get(handles.sldVolume, 'Value');
    current = handles.audioData{idx};
    %current = speedModify(current, speedRatio);
    %current = pitchModify(current, pitchIdx);
    %current = volumeRatio * current;
    guidata(hObject, handles);
    play = zeros(arr_len,1);
    
    cumul_len = 0;
    while cumul_len < arr_len
        if cumul_len + length(current) <= arr_len
            play( cumul_len+1 : cumul_len+length(current) ) = play( cumul_len+1 : cumul_len+length(current) ) + current;
        else
            end_idx = arr_len - cumul_len;
            play( cumul_len+1 : arr_len) = play( cumul_len+1 : arr_len) + current(1 : end_idx);
        end
        cumul_len = cumul_len + length(current);
    end
    sound(play, handles.fs);
end

% --- Executes during object creation, after setting all properties.
function uitableData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitableData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected cell(s) is changed in uitableData.
function uitableData_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitableData (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
    indice_size = size(eventdata.Indices);
    if indice_size(1) ~= 0
        handles.selectedRow = eventdata.Indices(1);
        guidata(hObject, handles);
    end
    disp(handles.selectedRow)


% --- Executes during object creation, after setting all properties.
function txtSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function txtPitch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function txtVolume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
table = get(handles.uitableData, 'Data');
handles.isModified = ~handles.isModified;
guidata(hObject, handles);
para = [table{handles.selectedRow, 2} table{handles.selectedRow, 3} table{handles.selectedRow, 5}];
if handles.isModified == false
    set(handles.btnSave, 'String', 'Modify');
    set(handles.sldVolume, 'Enable', 'Off');
    set(handles.sldPitch, 'Enable', 'Off');
    set(handles.sldSpeed, 'Enable', 'Off');
    vol = get(handles.sldVolume, 'Value');
    pitch = get(handles.sldPitch, 'Value');
    speed = get(handles.sldSpeed, 'Value');
    table{handles.selectedRow, 2} = vol;
    table{handles.selectedRow, 3} = pitch;
    table{handles.selectedRow, 5} = speed;
    set(handles.uitableData,'Data',table);
    current = handles.audioData{handles.selectedRow};
    handles.audioData{handles.selectedRow} = ...
        speedModify(pitchModify(current, pitch), speed) * vol;
else
    handles.current = handles.audioData{handles.selectedRow};
    set(handles.btnSave, 'String', 'Save');
    set(handles.sldVolume, 'Enable', 'On');
    set(handles.sldVolume, 'Value', para(1));
    set(handles.txtVolume, 'String', para(1));
    set(handles.sldPitch, 'Enable', 'On');
    set(handles.sldPitch, 'Value', para(2));
    set(handles.txtPitch, 'String', para(2));
    set(handles.sldSpeed, 'Enable', 'On');
    set(handles.sldSpeed, 'Value', para(3));
    set(handles.txtSpeed, 'String', para(3));
end
guidata(hObject, handles);
