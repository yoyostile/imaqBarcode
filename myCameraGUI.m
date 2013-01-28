function varargout = myCameraGUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @myCameraGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @myCameraGUI_OutputFcn, ...
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


% --- Executes just before mycameragui is made visible.
function myCameraGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mycameragui (see VARARGIN)

% Choose default command line output for mycameragui
handles.output = hObject;

% Create video object
% Putting the object into manual trigger mode and then
% starting the object will make GETSNAPSHOT return faster
% since the connection to the camera will already have
% been established.

handles.video = videoinput('winvideo', 1);
set(handles.video,'TimerPeriod', 0.05, ...
'TimerFcn',['if(~isempty(gco)),'...
'handles=guidata(gcf);'... % Update handles
'image(getsnapshot(handles.video));'... % Get picture using GETSNAPSHOT and put it into axes using IMAGE
'set(handles.cameraAxes,''ytick'',[],''xtick'',[]),'... % Remove tickmarks and labels that are inserted when using IMAGE
'else '...
'delete(imaqfind);'... % Clean up - delete any image acquisition objects
'end']);
triggerconfig(handles.video,'manual');
handles.video.FramesPerTrigger = Inf; % Capture frames until we manually stop it

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mycameragui wait for user response (see UIRESUME)
uiwait(handles.myCameraGUI);


% --- Outputs from this function are returned to the command line.
function varargout = myCameraGUI_OutputFcn(hObject, eventdata, handles)
% varargout cell array for returning output args (see VARARGOUT);
% hObject handle to figure
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = hObject;
varargout{1} = handles.output;


% --- Executes on button press in startStopCamera.
function startStopCamera_Callback(hObject, eventdata, handles)
% hObject handle to startStopCamera (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

% Start/Stop Camera
if strcmp(get(handles.startStopCamera,'String'),'Start Camera')
    % Camera is off. Change button string and start camera.
    set(handles.startStopCamera,'String','Stop Camera')
    set(handles.startAcquisition,'Enable','on');
    set(handles.captureImage,'Enable','on');
else
    % Camera is on. Stop camera and change button string.
    set(handles.startStopCamera,'String','Start Camera')
    stop(handles.video)
    set(handles.startAcquisition,'Enable','off');
    set(handles.captureImage,'Enable','off');
end

% --- Executes on button press in captureImage.
function captureImage_Callback(hObject, eventdata, handles)
frame = get(get(handles.cameraAxes, 'children'), 'cdata');
save('testPic.mat', 'frame');
disp('Bild gespeichert''testPic.mat''');


% --- Executes on button press in startAcquisition.
function startAcquisition_Callback(hObject, eventdata, handles)
% hObject    handle to startAcquisition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Start/Stop acquisition
if strcmp(get(handles.startAcquisition,'String'),'Start Acquisition')
    % Camera is not acquiring. Change button string and start acquisition.
    set(handles.startAcquisition,'String','Stop Acquisition');
    trigger(handles.video);
else
    % Camera is acquiring. Stop acquisition, save video data,
    % and change button string.
    stop(handles.video);
    disp('Saving captured video...');
    
    frames = getdata(handles.video);
    save('testvideo.mat', 'frames');
    disp('Video saved to file ''testvideo.mat''');
    imaqmontage(frames);
    set(handles.startAcquisition,'String','Start Acquisition');
    startStopCamera_Callback(hObject, eventdata, handles);
end

% --- Executes when user attempts to close myCameraGUI.
function myCameraGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to myCameraGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
delete(imaqfind);


%Backlight Compenastion

% --- Executes on selection change in backlightpop.
function backlightpop_Callback(hObject, eventdata, handles)
% hObject    handle to backlightpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns backlightpop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from backlightpop
contents = cellstr(get(hObject,'String'));
a=contents{get(hObject,'Value')};
stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.BacklightCompensation = a;
start(handles.video);

% --- Executes during object creation, after setting all properties.
function backlightpop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to backlightpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Brightness

% --- Executes on slider movement.
function brightnessslider_Callback(hObject, eventdata, handles)
% hObject    handle to brightnessslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global a;
a=round(get(hObject,'Value')); 
set(handles.brightness,'String',num2str(a));
set(hObject, 'Value', a);

stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.Brightness = round(get(hObject,'Value'));
start(handles.video);

% --- Executes during object creation, after setting all properties.
function brightnessslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brightnessslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function brightness_Callback(hObject, eventdata, handles)
% hObject    handle to brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of brightness as text
%        str2double(get(hObject,'String')) returns contents of brightness as a double


% --- Executes during object creation, after setting all properties.
function brightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Color Enable

% --- Executes on selection change in colorpop.
function colorpop_Callback(hObject, eventdata, handles)
% hObject    handle to colorpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns colorpop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colorpop
contents = cellstr(get(hObject,'String'));
a=contents{get(hObject,'Value')};
stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.ColorEnable = a;
start(handles.video);

% --- Executes during object creation, after setting all properties.
function colorpop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%CONTRAST

% --- Executes on slider movement.
function contrastslider_Callback(hObject, eventdata, handles)
% hObject    handle to contrastslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global a;
a=round(get(hObject,'Value')); 
set(handles.contrast,'String',num2str(a));
set(hObject, 'Value', a);

stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.Contrast = round(get(hObject,'Value'));
start(handles.video);

% --- Executes during object creation, after setting all properties.
function contrastslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrastslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function contrast_Callback(hObject, eventdata, handles)
% hObject    handle to contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of contrast as text
%        str2double(get(hObject,'String')) returns contents of contrast as a double



% --- Executes during object creation, after setting all properties.
function contrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in contrastpop.
function contrastpop_Callback(hObject, eventdata, handles)
% hObject    handle to contrastpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns contrastpop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from contrastpop

contents = cellstr(get(hObject,'String'));
a=contents{get(hObject,'Value')};
stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.ContrastMode = a;
start(handles.video);


% --- Executes during object creation, after setting all properties.
function contrastpop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrastpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%EXPOSURE

% --- Executes on slider movement.
function exposureslider_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global a
a=round(get(hObject,'Value')); 
set(handles.exposure,'String',num2str(a));
set(hObject, 'Value', a);

stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.Exposure = round(get(hObject,'Value'));
start(handles.video);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function exposureslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exposureslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function exposure_Callback(hObject, eventdata, handles)
% hObject    handle to exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exposure as text
%        str2double(get(hObject,'String')) returns contents of exposure as a double


% --- Executes during object creation, after setting all properties.
function exposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in exposurepop.
function exposurepop_Callback(hObject, eventdata, handles)
% hObject    handle to exposurepop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns exposurepop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from exposurepop

contents = cellstr(get(hObject,'String'));
a=contents{get(hObject,'Value')};
stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.ExposureMode = a;
start(handles.video);



% --- Executes during object creation, after setting all properties.
function exposurepop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exposurepop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Gain

% --- Executes on slider movement.
function gainslider_Callback(hObject, eventdata, handles)
% hObject    handle to gainslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global a
a=round(get(hObject,'Value')); 
set(handles.gain,'String',num2str(a));
set(hObject, 'Value', a);

stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.Gain = round(get(hObject,'Value'));
start(handles.video);

% --- Executes during object creation, after setting all properties.
function gainslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gainslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function gain_Callback(hObject, eventdata, handles)
% hObject    handle to gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gain as text
%        str2double(get(hObject,'String')) returns contents of gain as a double


% --- Executes during object creation, after setting all properties.
function gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in gainpop.
function gainpop_Callback(hObject, eventdata, handles)
% hObject    handle to gainpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns gainpop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from gainpop
contents = cellstr(get(hObject,'String'));
a=contents{get(hObject,'Value')};
stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.GainMode = a;
start(handles.video);

% --- Executes during object creation, after setting all properties.
function gainpop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gainpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Gamma

% --- Executes on slider movement.
function gammaslider_Callback(hObject, eventdata, handles)
% hObject    handle to gammaslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global a
a=round(get(hObject,'Value')); 
set(handles.gamma,'String',num2str(a));
set(hObject, 'Value', a);

stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.Gamma = round(get(hObject,'Value'));
start(handles.video);

% --- Executes during object creation, after setting all properties.
function gammaslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gammaslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function gamma_Callback(hObject, eventdata, handles)
% hObject    handle to gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gamma as text
%        str2double(get(hObject,'String')) returns contents of gamma as a double


% --- Executes during object creation, after setting all properties.
function gamma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Horizontal Flip

% --- Executes on selection change in hflippop.
function hflippop_Callback(hObject, eventdata, handles)
% hObject    handle to hflippop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hflippop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hflippop
contents = cellstr(get(hObject,'String'));
a=contents{get(hObject,'Value')};
stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.HorizontalFlip = a;
start(handles.video);

% --- Executes during object creation, after setting all properties.
function hflippop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hflippop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Sharpness

% --- Executes on slider movement.
function sharpnessslider_Callback(hObject, eventdata, handles)
% hObject    handle to sharpnessslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global a
a=round(get(hObject,'Value')); 
set(handles.sharpness,'String',num2str(a));
set(hObject, 'Value', a);

stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.Sharpness = round(get(hObject,'Value'));
start(handles.video);

% --- Executes during object creation, after setting all properties.
function sharpnessslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sharpnessslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function sharpness_Callback(hObject, eventdata, handles)
% hObject    handle to sharpness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sharpness as text
%        str2double(get(hObject,'String')) returns contents of sharpness as a double


% --- Executes during object creation, after setting all properties.
function sharpness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sharpness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Vertical Flip

% --- Executes on selection change in vflippop.
function vflippop_Callback(hObject, eventdata, handles)
% hObject    handle to vflippop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns vflippop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from vflippop
contents = cellstr(get(hObject,'String'));
a=contents{get(hObject,'Value')};
stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.VerticalFlip = a;
start(handles.video);



% --- Executes during object creation, after setting all properties.
function vflippop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vflippop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%WhiteBalance

% --- Executes on slider movement.
function whitebalanceslider_Callback(hObject, eventdata, handles)
% hObject    handle to whitebalanceslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global a
a=round(get(hObject,'Value')); 
set(handles.whitebalance,'String',num2str(a));
set(hObject, 'Value', a);

stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.WhiteBalance = round(get(hObject,'Value'));
start(handles.video);

% --- Executes during object creation, after setting all properties.
function whitebalanceslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whitebalanceslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function whitebalance_Callback(hObject, eventdata, handles)
% hObject    handle to whitebalance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of whitebalance as text
%        str2double(get(hObject,'String')) returns contents of whitebalance as a double


% --- Executes during object creation, after setting all properties.
function whitebalance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whitebalance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in whitebalancepop.
function whitebalancepop_Callback(hObject, eventdata, handles)
% hObject    handle to whitebalancepop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns whitebalancepop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from whitebalancepop
contents = cellstr(get(hObject,'String'));
a=contents{get(hObject,'Value')};
stop(handles.video);
src = getselectedsource(handles.video);
get(src);
src.WhiteBalanceMode = a;
start(handles.video);

% --- Executes during object creation, after setting all properties.
function whitebalancepop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whitebalancepop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%ColorSpace

% --- Executes on selection change in colorspacepop.
function colorspacepop_Callback(hObject, eventdata, handles)
% hObject    handle to colorspacepop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns colorspacepop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colorspacepop
contents = cellstr(get(hObject,'String'));
a=contents{get(hObject,'Value')};
vid.ReturnedColorspace=a;


% --- Executes during object creation, after setting all properties.
function colorspacepop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorspacepop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in barcode.
function barcode_Callback(hObject, eventdata, handles)
% hObject    handle to barcode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imaqBarcode(handles);
