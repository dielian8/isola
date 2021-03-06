function varargout = sourcepreepi(varargin)
% SOURCEPREEPI M-file for sourcepreepi.fig
%      SOURCEPREEPI, by itself, creates a new SOURCEPREEPI or raises the existing
%      singleton*.
%
%      H = SOURCEPREEPI returns the handle to a new SOURCEPREEPI or the handle to
%      the existing singleton*.
%
%      SOURCEPREEPI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOURCEPREEPI.M with the given input arguments.
%
%      SOURCEPREEPI('Property','Value',...) creates a new SOURCEPREEPI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sourcepreepi_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sourcepreepi_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sourcepreepi

% Last Modified by GUIDE v2.5 29-Aug-2013 11:19:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sourcepreepi_OpeningFcn, ...
                   'gui_OutputFcn',  @sourcepreepi_OutputFcn, ...
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


% --- Executes just before sourcepreepi is made visible.
function sourcepreepi_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sourcepreepi (see VARARGIN)

% Choose default command line output for sourcepreepi
handles.output = hObject;


% check is this a new run
h=dir('tsources.isl');    
    
if isempty(h); %  new ISOLA run
    set(handles.sdepth,'String','')
    set(handles.dstep,'String','')
    set(handles.nsources,'String','')
    disp('tsources.isl wasn''t found. It seems this is a new run.')
else
    fid = fopen('tsources.isl','r');
    tsource=fscanf(fid,'%s',1);
 
    if strcmp(tsource,'depth')
      % disp('Inversion was done for a line of sources under epicenter.')
      nsources=fscanf(fid,'%i',1);
      distep=fscanf(fid,'%f',1);
      sdepth=fscanf(fid,'%f',1);
      % invtype=fscanf(fid,'%c');
      % update
         set(handles.sdepth,'String',sdepth)
         set(handles.dstep,'String',distep)
         set(handles.nsources,'String',nsources)
      fclose(fid);
      
    else
        
    end    
end



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sourcepreepi wait for user response (see UIRESUME)
% uiwait(handles.sourcepreepi);


% --- Outputs from this function are returned to the command line.
function varargout = sourcepreepi_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles)
% hObject    handle to calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%% check if GREEN folder exists..

h=dir('green');

if isempty(h);
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%% go in GREEN
cd green
%%%%%%DELETE src files
[s,w] = system('del src??.dat');
%% go back
cd ..

%%% check if gmtfiles folder exists..

h=dir('gmtfiles');

if isempty(h);

    button = questdlg('Gmtfiles folder doesn''t exist. Create it ?','Folder error','Yes','No','Yes');
            if strcmp(button,'Yes')
                  disp('Creating gmtfiles folder')
                  mkdir('gmtfiles')
            elseif strcmp(button,'No')
                  disp('Abort')
                  return
            else
                  disp('Abort')
                  return
            end
else
end

%%% check event.isl files with event info

h=dir('event.isl');

if isempty(h); 
  errordlg('Event.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('event.isl','r');
    eventcor=fscanf(fid,'%g',2);
% %%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
    epidepth=fscanf(fid,'%g',1);
    magn=fscanf(fid,'%g',1);
    eventdate=fscanf(fid,'%s',1);
    fclose(fid);
end

%%%%%%%%%%%%    READ DATA..........

%%%%%%%  No of Sources
nsources = str2double(get(handles.nsources,'String'));
%%%%check if tstep is too small....
if nsources > 99
    errordlg('Number of Sources should be less that 99','Error');
      return
else
end
%%%%%%%  Depth step
dstep = str2double(get(handles.dstep,'String'));
%%%%%%%  Starting depth
sdepth = str2double(get(handles.sdepth,'String'));


            %%Prepare arrays ....
            for i=1:nsources
                strdX(i)=0;
                strdY(i)=0;
                strdZ(i)=sdepth+(dstep*(i-1));
            end
            strdZ
            depthrange=['Depth search starts at ' num2str(sdepth) 'km and ends at ' num2str(max(strdZ)) 'km'];
            disp(depthrange)
            
            
             %%%%%%%%OUTPUT TO SRC FILES
             %%%%%%% and tsources.isl !!!!!!!!!
             fid2 = fopen('tsources.isl','w');
                if ispc
                     fprintf(fid2,'%s\r\n','depth');
                     fprintf(fid2,'%i\r\n',nsources);
                     fprintf(fid2,'%f\r\n',dstep);
                     fprintf(fid2,'%f\r\n',sdepth);
                     fprintf(fid2,'%s\r\n','Fixed Epicenter');
                else
                     fprintf(fid2,'%s\n','depth');
                     fprintf(fid2,'%i\n',nsources);
                     fprintf(fid2,'%f\n',dstep);
                     fprintf(fid2,'%f\n',sdepth);
                     fprintf(fid2,'%s\n','Fixed Epicenter');
                end
             fclose(fid2);

            
             %% go in GREEN
             cd green
             
             for i=1:nsources
             %%% find filename
             filename=['src' num2str(i,'%02d') '.dat'];
             %%%% open file
                 fid = fopen(filename,'w');
                    if ispc
                       fprintf(fid,'%s\r\n',' Source parameters');
                       fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
                       fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\r\n',strdY(i),strdX(i), strdZ(i),magn, '''', eventdate, '''');
                    else
                       fprintf(fid,'%s\n',' Source parameters');
                       fprintf(fid,'%s\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
                       fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\n',strdY(i),strdX(i), strdZ(i),magn, '''', eventdate, '''');
                    end
                 fclose(fid);
             end
             %% go back
             cd ..

             
             helpdlg('Files were created OK, you can go on with Green functions. Check CRUSTAL.DAT first','Single Source Info');
             
%%%%%%%%%%%GMT OUTPUT%%%%%%%%%%%%%%%%%%55

         try
             %% go in gmtfile
             cd gmtfiles
             
                 fid = fopen('sources.gmt','w');
                     if ispc
                          fprintf(fid,'%s\r\n','>');
                          for i=1:nsources
                           fprintf(fid,'  %5.10f   %5.10f   %5.10f   %3i\r\n',eventcor(1),eventcor(2), strdZ(i),i);
                          end
                     else
                          fprintf(fid,'%s\n','>');
                          for i=1:nsources
                           fprintf(fid,'  %5.10f   %5.10f   %5.10f   %3i\n',eventcor(1),eventcor(2), strdZ(i),i);
                          end
                     end
                 fclose(fid);   

             %%go back
             cd ..
         catch
             cd ..
         end


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.sourcepreepi)

function dstep_Callback(hObject, eventdata, handles)
% hObject    handle to dstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dstep as text
%        str2double(get(hObject,'String')) returns contents of dstep as a double


% --- Executes during object creation, after setting all properties.
function dstep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sdepth_Callback(hObject, eventdata, handles)
% hObject    handle to sdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdepth as text
%        str2double(get(hObject,'String')) returns contents of sdepth as a double


% --- Executes during object creation, after setting all properties.
function sdepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nsources_Callback(hObject, eventdata, handles)
% hObject    handle to nsources (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nsources as text
%        str2double(get(hObject,'String')) returns contents of nsources as a double


% --- Executes during object creation, after setting all properties.
function nsources_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nsources (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
