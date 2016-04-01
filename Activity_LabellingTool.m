 %% GUI I/O
function varargout = LabellingTool(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @LabellingTool_OpeningFcn, ...
    'gui_OutputFcn',  @LabellingTool_OutputFcn, ...
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
end
function varargout = LabellingTool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end
function LabellingTool_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for LabellingTool
handles.output = hObject;
clc;
zoom on;
dcm = datacursormode(hObject);
set(dcm,'DisplayStyle','datatip','Enable','off','UpdateFcn',@onDCM);
set(0,'showhiddenhandles','on');
handles.dcm = dcm;
handles.dataText = [];
handles.markerLine1 = [];
handles.markerLine2 = [];
handles.markerNext = [];
handles.marker1 = 0;
handles.marker2 = 0;

handles.colors = {'g','y','r','y','b','m','c','k','k','k','k'};
handles.markerTypes = {'.','+','o','*','x','s','d','^','v','>','<','p','h'};
activityList = {'Sitting','Sit to Stand','Standing','Stand to Sit',...
    'Walking','Stairs Up','Stairs Dw','Not Wearing','Misc','Wheeling','Lying'};
set(handles.popupmenuActivity,'string',activityList);
wearingList = {'Belt','Wrist'};
    
set(handles.popupmenuLocation,'string',wearingList);
set(0,'showhiddenhandles','on');
guidata(hObject, handles);
end

%% Callback Functions
function buttonLoad_Callback(hObject, eventdata, handles)


[filename,pathname] = uigetfile('*');
if filename == 0
    return;
end
[N,~,R] = xlsread([pathname,filename]);
clear T;
cla
hold on;

%initialize variables
handles.R = [];
handles.data = [];
x = 1:size(N,1);
% Sf = round((R{10}-R{1})*100);   %get sampling time from data
% x = x/Sf;
handles.filename = filename(1:end-4);
handles.pathname = pathname;
set(handles.textFileLoaded,'string',[pathname,handles.filename,'.csv']);
plot(handles.mainAxes,x,N(:,2),'b');    %AXIS 1 (Worn on Waist: Vertical) OLD convention
plot(handles.mainAxes,x,N(:,3),'r');    %AXIS 2 (Horiz)
plot(handles.mainAxes,x,N(:,4),'g');    %AXIS 3 (Orthogonal)
legend('X','Y','Z')
col = size(N,2);
handles.activityIndex = col + 1;
handles.locationIndex = col + 2;
N(:,handles.activityIndex) = 0;
N(:,handles.locationIndex) = 0;
handles.ylimits = ylim;
handles.xlimits = xlim;
handles.data = N(:,1:7);
if size(handles.data,2) == handles.locationIndex
    handles.data(:,7:handles.locationIndex) = [];
end
for i = 1:size(R,1)
    handles.R{i,1} = R{i,5};
    handles.R{i,2} = R{i,6};
end

handles.markerLine1 = [];
handles.markerLine2 = [];
set(handles.dcm,'DisplayStyle','datatip','Enable','off','UpdateFcn',@onDCM);
if get(handles.radioLabel,'value');
    set(handles.dcm,'DisplayStyle','datatip','Enable','on','UpdateFcn',@onDCM);
end
guidata(hObject,handles);
end
function buttonLabel_Callback(hObject, eventdata, handles)
hold on
if handles.marker2 > handles.marker1
    m1 = handles.marker1;
    m2 = handles.marker2;
else
    m1 = handles.marker2;
    m2 = handles.marker1;
end

activitySelect = get(handles.popupmenuActivity,'value');
locationSelect = get(handles.popupmenuLocation,'value');

handles.data(m1:m2,handles.activityIndex) = activitySelect;
handles.data(m1:m2,handles.locationIndex) = locationSelect;

plot(handles.mainAxes,m1:m2,handles.data(m1:m2,2),'color',handles.colors{activitySelect},...
    'marker',handles.markerTypes{locationSelect},...
    'MarkerSize',1);
plot(handles.mainAxes,m1:m2,handles.data(m1:m2,3),'color',handles.colors{activitySelect},...
    'marker',handles.markerTypes{locationSelect},...
    'MarkerSize',1);
plot(handles.mainAxes,m1:m2,handles.data(m1:m2,4),'color',handles.colors{activitySelect},...
    'marker',handles.markerTypes{locationSelect},...
    'MarkerSize',1);

guidata(hObject,handles);
end
function buttonExport_Callback(hObject, eventdata, handles)
%file = [handles.pathname,handles.filename,'labeled.xls']; %WRITES XLS
file = [handles.pathname,handles.filename,'labeled.csv'];  %WRITES CSV

activityList = get(handles.popupmenuActivity,'string');
locationList = get(handles.popupmenuLocation,'string');
dataMatrix = cell(size(handles.data,1),size(handles.data,2)+4);
unlabeledNotice = 0;
% for i = 1:size(handles.R,1)   %LUCA: Changed it on 10/15/2013
for i = 1:size(handles.data,1)
    dataMatrix{i,1} = handles.data(i,1);
    dataMatrix{i,2} = handles.data(i,2);
    dataMatrix{i,3} = handles.data(i,3);
    dataMatrix{i,4} = handles.data(i,4);
    dataMatrix{i,5} = handles.data(i,5);
    dataMatrix{i,6} = handles.data(i,6);
    dataMatrix{i,7} = handles.data(i,7);
    if handles.data(i,handles.activityIndex) == 0
        unlabeledNotice = 1;
        dataMatrix{i,8} = 'Not labeled';
        dataMatrix{i,9} = 'Not labeled';
    else
        dataMatrix{i,8} = activityList{handles.data(i,handles.activityIndex)};
        dataMatrix{i,9} = locationList{handles.data(i,handles.locationIndex)};
    end
end

%xlswrite(file,dataMatrix); %WRITES XLS
%WRITES CSV FILE
dataMatrix = dataMatrix(:,1:9);     %remaining cols are emptyS
dataTable = array2table(dataMatrix);
writetable(dataTable,file,'WriteVariableNames',false)

if ~unlabeledNotice
    msgbox(['Finished exporting file: ',file],'File Exported');
else
    messageString{1} = ['Finished exporting file: ',file];
    messageString{2} = '';
    messageString{3} = ['There are unlabeled points in your file.'];
    msgbox(messageString,'File Exported','warn');
end
end
function buttonFillGaps_Callback(hObject, eventdata, handles)
if handles.data == 0
    return;
end
N = handles.data;
activityIndex = handles.activityIndex;
locationIndex = handles.locationIndex;
fillStart = 0;
for i = 1:size(N,1)
    if N(1,activityIndex) == 0
        fillStart = 1;
    end
    
    if fillStart == 1 && N(i,activityIndex) ~= 0
        N(1:i,activityIndex) =  N(i,activityIndex);
        N(1:i,locationIndex) =  N(i,locationIndex);
        fillStart = 0;
        lastActivityValue = N(i,activityIndex);
        lastLocationValue = N(i,locationIndex);
        plot(handles.mainAxes,1:i,handles.data(1:i,2),'color',handles.colors{N(i,activityIndex)},...
            'marker',handles.markerTypes{N(i,locationIndex)},...
            'MarkerSize',1);
        plot(handles.mainAxes,1:i,handles.data(1:i,3),'color',handles.colors{N(i,activityIndex)},...
            'marker',handles.markerTypes{N(i,locationIndex)},...
            'MarkerSize',1);
        plot(handles.mainAxes,1:i,handles.data(1:i,4),'color',handles.colors{N(i,activityIndex)},...
            'marker',handles.markerTypes{N(i,locationIndex)},...
            'MarkerSize',1);
    elseif (N(i,activityIndex) == 0 && fillStart == 0)
        N(i,activityIndex) = lastActivityValue;
        N(i,locationIndex) =  lastLocationValue;
        plot(handles.mainAxes,i-1:i,handles.data(i-1:i,2),'color',handles.colors{N(i,activityIndex)},...
            'marker',handles.markerTypes{N(i,locationIndex)},...
            'MarkerSize',1);
        plot(handles.mainAxes,i-1:i,handles.data(i-1:i,3),'color',handles.colors{N(i,activityIndex)},...
            'marker',handles.markerTypes{N(i,locationIndex)},...
            'MarkerSize',1);
        plot(handles.mainAxes,i-1:i,handles.data(i-1:i,4),'color',handles.colors{N(i,activityIndex)},...
            'marker',handles.markerTypes{N(i,locationIndex)},...
            'MarkerSize',1);
    else
        lastActivityValue = N(i,activityIndex);
        lastLocationValue = N(i,locationIndex);
    end
end
handles.data = N;
guidata(hObject,handles);
msgbox('Finished Filling Gaps');
end
function varargout = buttonMark1_Callback(hObject, eventdata, handles)
if isempty(handles.dataText)
    return;
end
pos = handles.dataText;
x = ones(2,1)*pos(1);
handles.marker1 = pos(1);
hold on
if(~isempty(handles.markerLine1))
    delete(handles.markerLine1)
end
handles.markerLine1 = plot(handles.mainAxes,x,handles.ylimits,'k','linewidth',3);
varargout{1} = handles;
guidata(hObject,handles);
end
function varargout = buttonMark2_Callback(hObject, eventdata, handles)
if isempty(handles.dataText)
    return;
end
pos = handles.dataText;
x = ones(2,1)*pos(1);
handles.marker2 = pos(1);
hold on
if(~isempty(handles.markerLine2))
    delete(handles.markerLine2)
end
handles.markerLine2 = plot(handles.mainAxes,x,handles.ylimits,'m','linewidth',3);
varargout{1} = handles;
guidata(hObject,handles);
end
function buttonMarkNext_Callback(hObject, eventdata, handles)

if isempty(handles.dataText)
    return
end

if isempty(handles.markerNext)
    handles.markerNext = 1;
elseif isempty(handles.markerLine1) && ~isempty(handles.markerLine2)
    handles.markerNext = 1;
elseif ~isempty(handles.markerLine1) && isempty(handles.markerLine2)
    handles.markerNext = 2;
end

if handles.markerNext == 1
    output = buttonMark1_Callback(handles.buttonMark1,eventdata,handles);
    handles = output;
    handles.markerNext = 2;
elseif handles.markerNext == 2
    output = buttonMark2_Callback(handles.buttonMark2,eventdata,handles);
    handles = output;
    handles.markerNext = 1;
else
    disp('Unknown "Next Marker" condition"');
end
guidata(hObject, handles);
end
function panelModes_SelectionChangeFcn(hObject, eventdata, handles)
currentlySelected = eventdata.NewValue;

switch currentlySelected
    case handles.radioZoomIn
        pan off;
        set(handles.dcm,'Enable','off');
        zoom on;
    case handles.radioZoomOut
        pan off;
        set(handles.dcm,'Enable','off');
        zoom out;
        zoom off
    case handles.radioPan
        set(handles.dcm,'Enable','off');
        zoom off;
        pan on;
    case handles.radioLabel
        zoom off;
        pan off;
        set(handles.dcm,'DisplayStyle','datatip','Enable','on','UpdateFcn',@onDCM);
    otherwise
        zoom off;
        pan off;
        set(handles.dcm,'Enable','off');
end
end
function output_txt = onDCM(~,eventObj)
pos = get(eventObj,'Position');
handles = guidata(gcbo);
handles.dataText = pos(1);
output_txt{1,1} = num2str(pos(1));
count = 2;
if size(handles.data,2) == handles.locationIndex
    if ~(handles.data(pos(1),handles.activityIndex) == 0)
        activityList = get(handles.popupmenuActivity,'string');
        output_txt{count,1} = activityList{handles.data(pos(1),handles.activityIndex)};
        count = count + 1;
    end
    if ~(handles.data(pos(1),handles.locationIndex) == 0)
        locationList = get(handles.popupmenuLocation,'string');
        output_txt{count,1} = locationList{handles.data(pos(1),handles.locationIndex)};
    end
end
guidata(gcbo,handles);
end

%% Helper functions


%% Empty functions for GUI Graphics
function mainAxes_ButtonDownFcn(hObject, eventdata, handles)
end
function editLabel1_Callback(hObject, eventdata, handles)
end
function editLabel1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function editLabel2_Callback(hObject, eventdata, handles)
end
function editLabel2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popupmenuActivity_Callback(hObject, eventdata, handles)
end
function popupmenuActivity_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function popupmenuLocation_Callback(hObject, eventdata, handles)
end
function popupmenuLocation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
%%
