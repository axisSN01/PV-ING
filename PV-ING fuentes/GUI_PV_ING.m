function varargout = GUI_PV_ING(varargin)
% GUI_PV_ING M-file for GUI_PV_ING.fig
%      GUI_PV_ING, by itself, creates a new GUI_PV_ING or raises the existing
%      singleton*.
%
%      H = GUI_PV_ING returns the handle to a new GUI_PV_ING or the handle to
%      the existing singleton*.
%
%      GUI_PV_ING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_PV_ING.M with the given input arguments.
%
%      GUI_PV_ING('Property','Value',...) creates a new GUI_PV_ING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_PV_ING_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_PV_ING_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_PV_ING

% Last Modified by GUIDE v2.5 19-Nov-2014 20:54:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_PV_ING_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_PV_ING_OutputFcn, ...
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


% --- Executes just before GUI_PV_ING is made visible.
function GUI_PV_ING_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_PV_ING (see VARARGIN)
% Choose default command line output for GUI_PV_ING
handles.output = hObject;

% Update handles structure

handles.MFilePath=fileparts(which(mfilename));

guidata(hObject, handles);

% UIWAIT makes GUI_PV_ING wait for user response (see UIRESUME)
% uiwait(handles.figure1);

set(handles.edit1, 'String', 'Inicializando Software PV-ING, ESPERE por favor...');


%% cargo imagenes
try
    Unifilar= imread(strcat(handles.MFilePath,'\Images\Unifilar41.tif'));
    axes(handles.axes1);
    imagesc(Unifilar);
    axis off;

    axes(handles.axes2);
    img= imread(strcat(handles.MFilePath,'\Images\PV-ING.png'));
    imagesc(img);
    axis off;
    
catch ME
    disp(ME.identifier);
    disp(ME.message); 
    Unifilar= imread('Unifilar41.tif');
    axes(handles.axes1);
    imagesc(Unifilar);
    axis off;

    axes(handles.axes2);
    img= imread('PV-ING.png');
    imagesc(img);
    axis off;    
end   
    

handles.FieldsDatosRed={'Radiacion' 'Temp_amb' 'V_red_TG' 'P_TCA_SFCR' 'Q_TCA_SFCR' 'P_TS5' 'Q_TS5' 'P_TS1' 'Q_TS1' 'P_TG' 'Q_TG'};

try
    handles.Conf=xlsread(strcat(handles.MFilePath,'\DEFAULTS\ConfigDefault.xls'));
    set(handles.edit2, 'String', num2str(handles.Conf(1)));
    set(handles.edit5, 'String', num2str(handles.Conf(2)));
    set(handles.edit6, 'String', num2str(handles.Conf(3)));
    set(handles.edit7, 'String', num2str(handles.Conf(4)));
    set(handles.edit18, 'String', 'ConfigDefault.xls');
catch ME
    disp(ME.identifier);
    disp(ME.message);
    set(handles.edit18, 'String', 'Clear');
    set(handles.edit2, 'String', '');
    set(handles.edit5, 'String', '');
    set(handles.edit6, 'String', '');
    set(handles.edit7, 'String', '');
    handles.Conf=0;
    NextLog=cat(1, get(handles.edit1, 'String'), {'No se pudo cargar ConfigDefault.xls'});
    set(handles.edit1, 'String',NextLog);
    set(handles.edit1, 'Value', length(NextLog));  
end

try
%%  creo datos de usuario
    handles.modelo=0;
    handles.DatosRed= xlsread(strcat(handles.MFilePath,'/DEFAULTS/redDefault.xls')); 
    handles.TyGSFCR = [handles.DatosRed(:,1) handles.DatosRed(:,2)];
    handles.Vred= handles.DatosRed(:, 3);
    handles.PyQSFCR= [handles.DatosRed(:,4) handles.DatosRed(:,5)];
    handles.PyQTS5= [handles.DatosRed(:,6) handles.DatosRed(:,7)];
    handles.PyQTS1= [handles.DatosRed(:,8) handles.DatosRed(:,9)];
    handles.PyQTG= [handles.DatosRed(:,10) handles.DatosRed(:,11)];
    set(handles.edit11, 'String', 'redDefault.xls');
    set(handles.edit12, 'String', 'redDefault.xls');
    set(handles.edit13, 'String', 'redDefault.xls');
    set(handles.edit14, 'String', 'redDefault.xls');
    set(handles.edit15, 'String', 'redDefault.xls');
    set(handles.edit16, 'String', 'redDefault.xls');
    
catch ME
    disp(ME.identifier);
    disp(ME.message);
    set(handles.edit11, 'String', 'Clear');
    set(handles.edit12, 'String', 'Clear');
    set(handles.edit13, 'String', 'Clear');
    set(handles.edit14, 'String', 'Clear');
    set(handles.edit15, 'String', 'Clear');
    set(handles.edit16, 'String', 'Clear');
    handles.DatosRed=0;handles.TyGSFCR=0;handles.Vred=0;
    handles.PyQSFCR=0;handles.PyQTS5=0;handles.PyQTS1=0;
    handles.PyQTG=0;
    NextLog=cat(1, get(handles.edit1, 'String'), {'No se pudo cargar redDefault.xls'});
    set(handles.edit1, 'String',NextLog);
    set(handles.edit1, 'Value', length(NextLog));      
end

try
    handles.Eficiencia= xlsread(strcat(handles.MFilePath,'/DEFAULTS/EficienciaDefault.xls'));
    set(handles.edit17, 'String', 'EficienciaDefault.xls');      
catch ME
    disp(ME.identifier);
    disp(ME.message);
    set(handles.edit17, 'String', 'Clear');
    handles.Eficiencia=0;
    NextLog=cat(1, get(handles.edit1, 'String'), {'No se pudo cargar eficiencia'});
    set(handles.edit1, 'String',NextLog);
    set(handles.edit1, 'Value', length(NextLog)); 
end 

try 
    handles.Arreglo=xlsread(strcat(handles.MFilePath,'/DEFAULTS/ArregloDefault.xls'));
    handles.ArregloModelo=ClaseArreglo(handles.Arreglo);    
    set(handles.edit8, 'String', 'ArregloDefault.xls');          
catch ME
    disp(ME.identifier);
    disp(ME.message);
    set(handles.edit8, 'String', 'Clear');
    handles.Arreglo =0;
    handles.ArregloModelo=0;
    NextLog=cat(1, get(handles.edit1, 'String'), {'No se pudo armar Objeto Arreglo'});
    set(handles.edit1, 'String',NextLog);
    set(handles.edit1, 'Value', length(NextLog));
    errordlg('Chequee archivo Arreglo','No se cargo el archivo!!!');
    
end

try 
    handles.Inversor=xlsread(strcat(handles.MFilePath,'/DEFAULTS/InversorDefault.xls'));
    handles.InversorModelo=ClaseInversor(handles.Inversor,handles.Eficiencia);
    set(handles.edit9, 'String', 'InversorDefault.xls');              
catch ME
    disp(ME.identifier);
    disp(ME.message);
    set(handles.edit9, 'String', 'Clear');
    handles.Inversor =0;
    handles.InversorModelo=0; 
    CurrentLog=get(handles.edit1, 'String');
    NextLog= cat(1, CurrentLog, {'No se pudo armar Objeto Inversor'}); 
    set(handles.edit1, 'String',NextLog);
    set(handles.edit1, 'Value', length(NextLog));
    errordlg('Chequee archivo inversor y eficiencia','No se cargo el archivo!!!');    
end


NextLog=cat(1, get(handles.edit1, 'String'), {'Programa Iniciado,proceda'});
set(handles.edit1, 'String',NextLog);
set(handles.edit1, 'Value', length(NextLog)); 

handles.IsResultado=false; % inicializo resultado en cero.
handles.resultado=struct();
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_PV_ING_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 %% chequeo simple de datos
try
    handles.DatosRed=horzcat(handles.TyGSFCR, handles.Vred, handles.PyQSFCR, handles.PyQTS5, handles.PyQTS1, handles.PyQTG);
catch ME
    NextLog=cat(1, get(handles.edit1, 'String'), {'error,datos de distinta long.'});
    set(handles.edit1, 'String',NextLog);
    set(handles.edit1, 'Value', length(NextLog));      
    errordlg('columnas de distinta longitud','Error');
    disp(ME.identifier);
    disp(ME.message);
    return;
end

try
    handles.InversorModelo=ClaseInversor(handles.Inversor,handles.Eficiencia);
    handles.ArregloModelo=ClaseArreglo(handles.Arreglo);
    NextLog=cat(1, get(handles.edit1, 'String'), {'Todo Ok, Calculando flujo de potencia...'});
    set(handles.edit1, 'String',NextLog);
    set(handles.edit1, 'Value', length(NextLog));       
    [handles.resultado,handles.IsResultado]=AlgoritmoFlujoPot(handles.ArregloModelo,handles.modelo,handles.InversorModelo,handles.Conf,handles.DatosRed,'UnifilarEdificioNuevoUnne_mdl',handles.MFilePath);%falta pasar modelo
    guidata(hObject, handles);
    GuiResultado(handles.resultado,handles.IsResultado);
catch ME
    NextLog=cat(1, get(handles.edit1, 'String'), {'resultado incompleto, error'});
    set(handles.edit1, 'String',NextLog);
    set(handles.edit1, 'Value', length(NextLog));      
    warndlg('Resultado parcial, ver log de error','Aviso de error no fatal');
    disp(ME.identifier);
    disp(ME.message);     
end  
    guidata(hObject, handles);  

% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Nameconf path]= uigetfile(strcat(handles.MFilePath,'/*.xls'),'Seleccionar archivo de Configuracion');
    if Nameconf == 0
        NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo conf. no leido'});
        set(handles.edit1, 'String',NextLog);
        set(handles.edit1, 'Value', length(NextLog));   
    else  
        try
           fullPath=strcat(path,Nameconf);
           Conf= xlsread(fullPath);
           set(handles.edit2, 'String', num2str(Conf(1)));
           set(handles.edit5, 'String', num2str(Conf(2)));
           set(handles.edit6, 'String', num2str(Conf(3)));
           set(handles.edit7, 'String', num2str(Conf(4)));
           set(handles.edit18, 'String', Nameconf);           
           NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo conf. cargado correctamente'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog));            
           handles.Conf= Conf;
        catch ME
           disp(ME.identifier);
           disp(ME.message);
           warndlg('Problema con la lectura de Configuracion','Aviso de error no fatal');
           NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo conf. no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog));
           
           set(handles.edit2, 'String', 'Clear');
           set(handles.edit5, 'String', 'Clear');
           set(handles.edit6, 'String', 'Clear');
           set(handles.edit7, 'String', 'Clear');
           set(handles.edit18, 'String', 'Clear');                      
           handles.Conf=0;           
        end
    end
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name path]= uigetfile(strcat(handles.MFilePath,'/*.xls'),'Seleccionar archivo de Inversor');
    if Name == 0
           NextLog=cat(1, get(handles.edit1, 'String'), {'Inversor no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog));        
    else  
        try
           if handles.Eficiencia
               fullPath=strcat(path,Name);
               Inversor= xlsread(fullPath);
               handles.InversorModelo=ClaseInversor(Inversor,handles.Eficiencia);
               set(handles.edit9, 'String', Name);
               handles.Inversor= Inversor; % aca reemplazo el handle del arreglo de la sesion
           else
               NextLog=cat(1, get(handles.edit1, 'String'), {'Inversor no leido'});
               set(handles.edit1, 'String',NextLog);
               set(handles.edit1, 'Value', length(NextLog)); 
                handles.Inversor=0;
                handles.InversorModelo=0;           
                warndlg('Debe especificar Eficiencia para inversor','Aviso de error no fatal');
                set(handles.edit9, 'String', 'Clear'); 
           end
        catch ME
           handles.Inversor=0;
           handles.InversorModelo=0;           
           warndlg('Problema con la lectura del inversor','Aviso de error no fatal');
           set(handles.edit9, 'String', 'Clear');
           NextLog=cat(1, get(handles.edit1, 'String'), {'Inversor no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
           disp(ME.identifier);
           disp(ME.message);
        end
    end
guidata(hObject, handles);



% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name path]= uigetfile(strcat(handles.MFilePath,'/*.xls'),'Seleccionar archivo de Arreglo');
    if Name == 0
           NextLog=cat(1, get(handles.edit1, 'String'), {'Arreglo no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
    else  
        try
           fullPath=strcat(path,Name);
           Arreglo= xlsread(fullPath);
           handles.ArregloModelo=ClaseArreglo(Arreglo);
           set(handles.edit8, 'String', Name);
           handles.Arreglo= Arreglo; % aca reemplazo el handle del arreglo de la sesion
        catch ME
           disp(ME.identifier);
           disp(ME.message);           
           warndlg('Problema con la lectura del arreglo','Aviso de error no fatal');
           set(handles.edit8, 'String', 'Clear');
           NextLog=cat(1, get(handles.edit1, 'String'), {'Arreglo no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
           handles.Arreglo= 0;
           handles.ArregloModelo=0;           
        end
    end
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    GuiResultado(handles.resultado,handles.IsResultado);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit11.
function edit11_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name path]= uigetfile(strcat(handles.MFilePath,'/*.xls'),'Seleccionar archivo de Vred[V]');
    if Name == 0
           NextLog=cat(1, get(handles.edit1, 'String'), {'Vred no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
    else  
        try
           fullPath=strcat(path,Name);
           Vred= xlsread(fullPath);
           [filas,columnas]=size(Vred);
           if columnas~=1
               set(hObject, 'String', 'Clear');               
               NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
               set(handles.edit1, 'String',NextLog);
               set(handles.edit1, 'Value', length(NextLog)); 
               warndlg('Problema con la lectura, debe tener solo una columna','Aviso de error no fatal');               
              handles.Vred=0;
               return;
           end
           set(handles.edit11, 'String', Name);
           handles.Vred= Vred; % aca reemplazo el handle del arreglo de la sesion
        catch ME
            disp(ME.identifier);
            disp(ME.message);           
           warndlg('Problema con la lectura de Vred','Aviso de error no fatal');
           set(hObject, 'String', 'Clear');
           NextLog=cat(1, get(handles.edit1, 'String'), {'Vred no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
        end
    end
guidata(hObject, handles);



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit12.
function edit12_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name path]= uigetfile(strcat(handles.MFilePath,'/*.xls'),'Seleccionar archivo de P [Kw]y Q[Kvar]');
    if Name == 0
           NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
    else  
        try
           fullPath=strcat(path,Name);
           PyQTG= xlsread(fullPath);
           [filas,columnas]=size(PyQTG);
           if columnas~=2
               set(hObject, 'String', 'Clear');              
               NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
               set(handles.edit1, 'String',NextLog);
               set(handles.edit1, 'Value', length(NextLog)); 
               warndlg('Problema con la lectura, debe tener solo 2 columnas','Aviso de error no fatal');               
               handles.PyQTG=0; 
               return;
           end
           set(hObject, 'String', Name);
           handles.PyQTG= PyQTG; % aca reemplazo el handle del arreglo de la sesion
        catch ME
           warndlg('Problema con la lectura del archivo','Aviso de error no fatal');
           set(hObject, 'String', 'Clear');
           NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
           disp(ME.identifier);
           disp(ME.message);   
        end
    end
guidata(hObject, handles);



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




% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GuiResultado(handles.resultado,handles.IsResultado);



% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit13.
function edit13_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name path]= uigetfile(strcat(handles.MFilePath,'/*.xls'),'Seleccionar archivo de P [Kw]y Q[Kvar]');
    if Name == 0
           NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
    else  
        try
           fullPath=strcat(path,Name);
           PyQTS1= xlsread(fullPath);
           [filas,columnas]=size(PyQTS1);
           if columnas~=2
           NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
               warndlg('Problema con la lectura, debe tener solo 2 columnas','Aviso de error no fatal');               
                handles.PyQTS1=0;
                set(hObject, 'String', 'clear');              
               return;
           end           
           set(hObject, 'String', Name);
           handles.PyQTS1= PyQTS1; % aca reemplazo el handle del arreglo de la sesion
        catch ME
           warndlg('Problema con la lectura del archivo','Aviso de error no fatal');
           set(hObject, 'String', 'clear');
           NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
           disp(ME.identifier);
           disp(ME.message);   
        end
    end
guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit14.
function edit14_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name path]= uigetfile(strcat(handles.MFilePath,'/*.xls'),'Seleccionar archivo de P [Kw]y Q[Kvar]');
    if Name == 0
           NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
    else  
        try
           fullPath=strcat(path,Name);
           PyQTS5= xlsread(fullPath);
           [filas,columnas]=size(PyQTS5);           
           if columnas~=2
               warndlg('Problema con la lectura, debe tener solo 2 columnas','Aviso de error no fatal');               
               set(hObject, 'String', 'clear');
           NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
               handles.PyQTS5=0;
               return;
           end                 
           set(hObject, 'String', Name);
           handles.PyQTS5= PyQTS5; % aca reemplazo el handle del arreglo de la sesion
        catch ME
           warndlg('Problema con la lectura del archivo','Aviso de error no fatal');
           set(hObject, 'String', 'clear');
           NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
           disp(ME.identifier);
           disp(ME.message);
           handles.PyQTS5=0;           
        end
    end
guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit15.
function edit15_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name path]= uigetfile(strcat(handles.MFilePath,'/*.xls'),'Seleccionar archivo de Tamb [Cº]y G[Kw/m2]');
    if Name == 0
           NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
    else  
        try
           fullPath=strcat(path,Name);
           TyGSFCR= xlsread(fullPath);
           [filas,columnas]=size(TyGSFCR);           
           if columnas~=2
               set(handles.edit1, 'String', 'archivo no leido '); 
               warndlg('Problema con la lectura, debe tener solo 2 columnas','Aviso de error no fatal');               
               set(hObject, 'String', 'clear');
           NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
               handles.TyGSFCR=0; % aca reemplazo el handle del arreglo de la sesion               
               return;
           end                    
           set(hObject, 'String', Name);
           handles.TyGSFCR= TyGSFCR; % aca reemplazo el handle del arreglo de la sesion
        catch ME
           warndlg('Problema con la lectura del archivo','Aviso de error no fatal');
           set(hObject, 'String', 'clear');
           NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
           handles.TyGSFCR=0; % aca reemplazo el handle del arreglo de la sesion                          
           disp(ME.identifier);
           disp(ME.message);   
        end
    end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name path]= uigetfile(strcat(handles.MFilePath,'/*.xls'),'Seleccionar archivo de Eficiencia');
    if Name == 0
           NextLog=cat(1, get(handles.edit1, 'String'), {'Eficiencia no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
    else  
        try
           fullPath=strcat(path,Name);
           Eficiencia= xlsread(fullPath);
           set(handles.edit17, 'String', Name);
           handles.Eficiencia= Eficiencia; % aca reemplazo el handle del arreglo de la sesion
        catch ME
           handles.Eficiencia=0;           
           disp(ME.identifier);
           disp(ME.message);              
           warndlg('Problema con la lectura de eficiencia','Aviso de error no fatal');
           set(handles.edit17, 'String', 'Clear');
           NextLog=cat(1, get(handles.edit1, 'String'), {'Eficiencia no leido'});
           set(handles.edit1, 'String',NextLog);
           set(handles.edit1, 'Value', length(NextLog)); 
        end
    end
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function text2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function text3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function text13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function text5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function text6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function text7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function text8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function text9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function text10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function text11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function text14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
;


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


% --- Executes during object creation, after setting all properties.
function radiobutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function radiobutton2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function Untitled_7_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 try
    handles.DatosRed=horzcat(handles.TyGSFCR, handles.Vred, handles.PyQSFCR, handles.PyQTS5, handles.PyQTS1, handles.PyQTG);
catch ME
       NextLog=cat(1, get(handles.edit1, 'String'), {'error,datos de red de distinta long.'});
       set(handles.edit1, 'String',NextLog);
       set(handles.edit1, 'Value', length(NextLog));     
    errordlg('No guardado, datos de distinta longitud','Error');
    disp(ME.identifier);
    disp(ME.message);
    return;
 end
 
[Name path]= uiputfile(strcat(handles.MFilePath,'/*.xls'),'Guardar archivo de datos de Red');
    if Name == 0
        NextLog=cat(1, get(handles.edit1, 'String'), {'Datos de red  no guardado'});
        set(handles.edit1, 'String',NextLog);
        set(handles.edit1, 'Value', length(NextLog));          
        return;
    else  
        try
        xlswrite(strcat(path,Name),handles.FieldsDatosRed,'Hoja1','A1');     
        xlswrite(strcat(path,Name),handles.DatosRed,'Hoja1','A2')

    catch ME
        NextLog=cat(1, get(handles.edit1, 'String'), {'Datos de red  no guardado'});
        set(handles.edit1, 'String',NextLog);
        set(handles.edit1, 'Value', length(NextLog));  
        errordlg('Datos de red  no guardado','Error'); 
        disp(ME.identifier);
        disp(ME.message);
        end
    end
    
guidata(hObject, handles);



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);



% -- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit16.
function edit16_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[Name path]= uigetfile(strcat(handles.MFilePath,'/*.xls'),'Seleccionar archivo de P [Kw] y Q [KVar]');
    if Name == 0
        NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
        set(handles.edit1, 'String',NextLog);
        set(handles.edit1, 'Value', length(NextLog));  
    else  
        try
           fullPath=strcat(path,Name);
           PyQSFCR= xlsread(fullPath);
           [filas,columnas]=size(PyQSFCR);           
           if columnas~=2
                NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
                set(handles.edit1, 'String',NextLog);
                set(handles.edit1, 'Value', length(NextLog));  
               warndlg('Problema con la lectura, debe tener solo 2 columnas','Aviso de error no fatal');               
               set(hObject, 'String', 'clear');
               handles.PyQSFCR=0; % aca reemplazo el handle del arreglo de la sesion               
               return;
           end                    
           set(hObject, 'String', Name);
           handles.PyQSFCR= PyQSFCR; % aca reemplazo el handle del arreglo de la sesion
        catch ME
           warndlg('Problema con la lectura del archivo','Aviso de error no fatal');
           set(hObject, 'String', 'clear');
        NextLog=cat(1, get(handles.edit1, 'String'), {'Archivo no leido'});
        set(handles.edit1, 'String',NextLog);
        set(handles.edit1, 'Value', length(NextLog));  
           handles.PyQSFCR=0; % aca reemplazo el handle del arreglo de la sesion                          
           disp(ME.identifier);
           disp(ME.message);   
        end
    end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_8_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Construct a questdlg with three options
choice = questdlg('Cerrar PV-ING y abrir Psat?(perdera el progreso no guardado)', ...
	'Warning..', ...
	'Si','Cancelar','Cancelar');
% Handle response
switch choice
    case 'Si'
        delete(handles.figure1);        
        psat;
    case 'Cancelar'
        return;       
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
handles.modelo=0;
guidata(hObject, handles);


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
handles.modelo=1;
guidata(hObject, handles);
