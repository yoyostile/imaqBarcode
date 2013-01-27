

function varargout = myCameraGUI(varargin)
% MYCAMERAGUI MATLAB code for mycameragui.fig
%      MYCAMERAGUI, by itself, creates a new MYCAMERAGUI or raises the existing
%      singleton*.
%
%      H = MYCAMERAGUI returns the handle to a new MYCAMERAGUI or the handle to
%      the existing singleton*.
%
%      MYCAMERAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MYCAMERAGUI.M with the given input arguments.
%
%      MYCAMERAGUI('Property','Value',...) creates a new MYCAMERAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before myCameraGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to myCameraGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mycameragui

% Last Modified by GUIDE v2.5 24-Jan-2013 23:14:31

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


javaaddpath('.\core.jar');
javaaddpath('.\javase.jar');

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
handles.video = videoinput('macvideo', 1);
set(handles.video,'TimerPeriod', 0.05, ...
'TimerFcn',['if(~isempty(gco)),'...
'handles=guidata(gcf);'... % Update handles
'image(getsnapshot(handles.video));'... % Get picture using GETSNAPSHOT and put it into axes using IMAGE
'set(handles.cameraAxes,''ytick'',[],''xtick'',[]),'... % Remove tickmarks and labels that are inserted when using IMAGE
'else '...
'delete(imaqfind);'... % Clean up - delete any image acquisition objects
'end']);
triggerconfig(handles.video,'manual');
set(handles.video, 'FramesPerTrigger', 1);
set(handles.video, 'TriggerRepeat', Inf); 


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


% --- Executes on button press in barcode.
function barcode_Callback(hObject, eventdata, handles)
% hObject    handle to barcode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Barcode reader     

%video wird geholt

src = getselectedsource(handles.video);
get(src);
%video properties gesetzt
%Vertical flip einfügen

while true, 
    %Video-Frame wird akquiriert und in frame gespeichert
	trigger(handles.video);
    %pause(1);
	frame = getdata(handles.video, 1);
    sharpness = estimateSharpness(frame);
    %frame = denoise(frame); %schwer optionales denoising, verbraucht viel
    %zu viel Leistung.
    %frame = rgb2gray(frame);
    if sharpness > 2.1, 
        %Ibw = im2bw(frame, graythresh(frame));
        I2 = radonRotate(frame);
        %Ausgabe des prozessierten Frames
        %imshow(I2);
        %Aufruf der 4 verschiedenen Methoden um Codes zu erkennen.
        message_qr = decodeQR(I2)
        message_dm = decodeMatrix(I2)
        message_ean13 = decodeEAN13(I2)
        message_ean8 = decodeEAN8(I2)
    end
    pause(1/10);
    %pause(3);
end


% --- Executes on button press in startStopCamera.
function startStopCamera_Callback(hObject, eventdata, handles)
% hObject handle to startStopCamera (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

% Start/Stop Camera
if strcmp(get(handles.startStopCamera,'String'),'Start Camera')
    % Camera is off. Change button string and start camera.
    set(handles.startStopCamera,'String','Stop Camera')
    start(handles.video)
    

    
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
% hObject    handle to captureImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% frame = getsnapshot(handles.video);
frame = get(get(handles.cameraAxes,'children'),'cdata'); % The current displayed frame
save('testframe.mat', 'frame');
disp('Frame saved to file ''testframe.mat''');


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
    
    videodata = getdata(handles.video);
    save('testvideo.mat', 'videodata');
    disp('Video saved to file ''testvideo.mat''');
    
    start(handles.video); % Restart the camera
    set(handles.startAcquisition,'String','Start Acquisition');
end

% --- Executes when user attempts to close myCameraGUI.
function myCameraGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to myCameraGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
delete(imaqfind);


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
