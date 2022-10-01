function fig = fm_gamsfig(varargin)
% FM_GAMSFIG create GUI for Optimal Power Flow settings
%       intended for the GAMS solver.
%
% FIG = FM_GAMSFIG
%
%see OPF structure for settings
%
%Author:    Federico Milano
%Date:      25-Jan-2003
%Update:    07-Feb-2003
%Version:   1.0.2
%
%E-mail:    Federico.Milano@uclm.es
%Web-site:  http://www.uclm.es/area/gsee/Web/Federico
%
% Copyright (C) 2002-2013 Federico Milano

global Settings Path Line OPF GAMS Theme Fig

flussi = {'None';
          'Currents';
          'Active Powers';
          'Apparent Powers'};
metodi = {'Simple Auction';
          'Market Clearing Mechanism';
          'Standard OPF';
          'Voltage Stability OPF';
          'Maximum Loading Condition';
	  'Continuation OPF';
          'Congestion Management'};
tipi = {'Single Period Auction';
        'Multi Period Auction';
        'Pareto Set Auction';
        'Unit Commitment Auction'};
guess = {'Actual Power Flow Solution',
         'Flat Start',};
output = {'fm_gams.lst';
          'psatdata.gms';
          'psatsol.m';
          'psatglobs.gms'};

if nargin
  switch varargin{1}

   case 'method'

    GAMS.method = get(gcbo,'Value');
    hdl = findobj(Fig.gams,'Tag','ListboxLines');
    if GAMS.method == 4 || GAMS.method == 6 || GAMS.method == 7
      set(hdl,'Enable','on')
    else
      set(hdl,'Enable','off')
    end
    hdl = findobj(Fig.gams,'Tag','PopupMenuFlow');
    if GAMS.method == 6
      set(hdl,'Enable','off','Value',2)
      GAMS.flow = 1;
    else
      set(hdl,'Enable','on')
      GAMS.flow = get(hdl,'Value')-1;
    end

   case 'type'

    GAMS.type = get(gcbo,'Value');
    hdl1 = findobj(Fig.gams,'Tag','PopupMenuMethod');
    hdl2 = findobj(Fig.gams,'Tag','ListboxLines');
    switch GAMS.type
     case {2,4}
      set(gcbo,'UserData',GAMS.method)
      set(hdl1,'Enable','on','String',metodi([1,2]),'Value',min(GAMS.method,2))
      set(hdl2,'Enable','on')
      GAMS.method = min(GAMS.method,2);
     case 3
      set(gcbo,'UserData',GAMS.method)
      set(hdl1,'String',metodi,'Enable','off','Value',4)
      set(hdl2,'Enable','on')
      GAMS.method = 4;
     otherwise
      GAMS.method = get(gcbo,'UserData');
      set(hdl1,'String',metodi,'Enable','on','Value',GAMS.method)
      if GAMS.method == 4 || GAMS.method == 6 || GAMS.method == 7
        set(hdl2,'Enable','on')
      else
        set(hdl2,'Enable','off')
      end
    end

   case 'show'

    GAMS.show = ~GAMS.show;
    if GAMS.show,
      set(gcbo,'Checked','on')
    else
      set(gcbo,'Checked','off')
    end

   case 'libinclude'

    GAMS.libinclude = ~GAMS.libinclude;
    if GAMS.libinclude,
      set(gcbo,'Checked','on')
    else
      set(gcbo,'Checked','off')
    end

   case 'loaddir'

    GAMS.loaddir = ~GAMS.loaddir;
    if GAMS.loaddir,
      set(gcbo,'Checked','on')
    else
      set(gcbo,'Checked','off')
    end

   case 'basepl'

    GAMS.basepl = ~GAMS.basepl;
    if GAMS.basepl,
      set(gcbo,'Checked','on')
    else
      set(gcbo,'Checked','off')
    end

   case 'basepg'

    GAMS.basepg = ~GAMS.basepg;
    if GAMS.basepg,
      set(gcbo,'Checked','on')
    else
      set(gcbo,'Checked','off')
    end

   case 'option'

    string = fm_input('Input string:', ...
                      'GAMS Call Option',1,{GAMS.ldir});
    if isempty(string), return, end
    if isempty(string{1})
      string = {GAMS.ldir};
    end
    GAMS.ldir = string{1};

   case 'view'

    file = popupstr(findobj(Fig.gams,'Tag','PopupGamsFile'));
    if ~rem(GAMS.type,2) && strcmp(file,'fm_gams.lst')
      file = 'fm_gams2.lst';
    end
    if GAMS.method == 7 && strcmp(file,'fm_gams.lst')
      file = 'fm_cong.lst';
    end
    if exist([Path.psat,file]) == 2
      fm_text(13,[Path.psat,file])
    else
      fm_choice(['File "',file,'" not found.',char(10), ...
                 'Launch GAMS first or check permissions.'],2)
    end

   case 'omega'

    lasterr('');
    hdl_omeg = findobj(Fig.gams,'Tag','EditText1');
    s_omega = get(hdl_omeg,'String');
    try, eval(['GAMSomega = ',s_omega,';'])
    catch, fm_disp(lasterr,2), set(hdl_omeg,'String',GAMS.omega_s), return, end
    if max(GAMSomega) > 1 || min(GAMSomega) < 0
        fm_disp('The weighting factor must be within the range [0,1].',2)
        set(hdl_omeg,'String',GAMS.omega_s), return
    end
    [ao,bo] = size(GAMSomega);
    if ao > 1 && bo > 1
        fm_disp('The weighting factor must be a vector.',2)
        set(hdl_omeg,'String',GAMS.omega_s), return
    end
    GAMS.omega = GAMSomega;
    GAMS.omega_s = s_omega;
    fm_disp(['Parameter "GAMS.omega" set to "',GAMS.omega_s,'".'],1)

   case 'lmin'

    lasterr('');
    hdl_lmin = findobj(Fig.gams,'Tag','EditText2');
    s_lmin = get(hdl_lmin,'String');

    try, eval(['GAMSlmin = ',s_lmin,';'])
    catch, fm_disp(lasterr,2), set(hdl_lmax,'String',GAMS.lmin_s), return, end
    if max(GAMSlmin) > GAMS.lmax
        fm_disp('lambda_min must be lower than lambda_max.',2)
        set(hdl_lmin,'String',GAMS.lmin_s), return,
    end
    [al,bl] = size(GAMS.lmin);
    if al > 1 && bl > 1
        fm_disp('The loading parameter must be a vector.',2)
        set(hdl_lmin,'String',GAMS.lmin_s), return
    end
    GAMS.lmin = GAMSlmin;
    GAMS.lmin_s = s_lmin;
    fm_disp(['Parameter "GAMS.lmin" set to "',GAMS.lmin_s,'".'],1)

  end
  return
end

if Fig.gams, figure(Fig.gams), return, end

if strcmp(Settings.platform,'MAC')
  aligntxt = 'center';
  dm = 0.0075;
else
  aligntxt = 'left';
  dm = 0;
end

[u,w] = system('gams');
if u
  fm_choice('GAMS is not properly installed on your system.',2)
  return
end

rs = 0.4344/0.5;
dy = (0.5-0.4344)/0.5;
df = 1+1.35*(0.5-0.4344);
if Line.n
  lines  = fm_strjoin('line_',num2str(Line.fr),'_', ...
                  num2str(Line.to));
  lines = ['<none>'; lines];
else
  lines = {'<none>'};
end
if GAMS.line > Line.n, GAMS.line = 0; end

h0 = figure('Units','normalized', ...
            'Color',Theme.color02, ...
            'Colormap',[], ...
            'CreateFcn', 'Fig.gams = gcf;', ...
            'DeleteFcn', 'Fig.gams = 0;', ...
            'MenuBar','none', ...
            'Name','PSAT-GAMS', ...
            'NumberTitle','off', ...
            'PaperPosition',[18 180 576 432], ...
            'PaperUnits','points', ...
            'Position',sizefig(0.58,0.5000), ...
            'Resize','on', ...
            'ToolBar','none', ...
            'FileName','fm_gamsfig');
fm_set colormap

% Menu File
h1 = uimenu('Parent',h0, ...
            'Label','File', ...
            'Tag','MenuFile');
h2 = uimenu('Parent',h1, ...
            'Callback','fm_gamsfig view', ...
            'Label','View GAMS Output', ...
            'Tag','OTV', ...
            'Accelerator','g');
h2 = uimenu('Parent',h1, ...
            'Callback','close(gcf)', ...
            'Label','Exit', ...
            'Tag','NetSett', ...
            'Accelerator','x', ...
            'Separator','on');

% Menu Edit
h1 = uimenu('Parent',h0, ...
            'Label','Edit', ...
            'Tag','MenuEdit');
h2 = uimenu('Parent',h1, ...
            'Callback','fm_setting', ...
            'Label','General Settings', ...
            'Tag','ToolSett', ...
            'Accelerator','s');
h2 = uimenu('Parent',h1, ...
            'Callback','fm_cpffig', ...
            'Label','CPF Settings', ...
            'Tag','ToolOPFSett', ...
            'Accelerator','c');
h2 = uimenu('Parent',h1, ...
            'Callback','fm_opffig', ...
            'Label','OPF Settings', ...
            'Tag','ToolCPFSett', ...
            'Accelerator','o');

% Menu Run
h1 = uimenu('Parent',h0, ...
            'Label','Run', ...
            'Tag','MenuRun');
h2 = uimenu('Parent',h1, ...
            'Callback','fm_gams', ...
            'Label','Run GAMS', ...
            'Tag','ToolOPFSett', ...
            'Accelerator','z');

% Menu Options
h1 = uimenu('Parent',h0, ...
            'Label','Options', ...
            'Tag','MenuOpt');
h2 = uimenu('Parent',h1, ...
            'Callback','fm_gamsfig show', ...
            'Label','Enable Output', ...
            'Tag','OTV', ...
            'Accelerator','v');
if GAMS.show,
  set(h2,'Checked','on'),
else,
  set(h2,'Checked','off'),
end
h2 = uimenu('Parent',h1, ...
            'Callback','fm_gamsfig libinclude', ...
            'Label','Include GAMS Call Options', ...
            'Tag','OTV', ...
            'Accelerator','i');
if GAMS.libinclude,
  set(h2,'Checked','on'),
else,
  set(h2,'Checked','off'),
end
h2 = uimenu('Parent',h1, ...
            'Callback','fm_gamsfig loaddir', ...
            'Label','Use load directions for MLC', ...
            'Tag','OTV', ...
            'Accelerator','l');
if GAMS.loaddir,
  set(h2,'Checked','on'),
else,
  set(h2,'Checked','off'),
end
h2 = uimenu('Parent',h1, ...
            'Callback','fm_gamsfig basepl', ...
            'Label','Use base load powers', ...
            'Tag','OBC', ...
            'Accelerator','b');
if GAMS.basepl,
  set(h2,'Checked','on'),
else,
  set(h2,'Checked','off'),
end
h2 = uimenu('Parent',h1, ...
            'Callback','fm_gamsfig basepg', ...
            'Label','Use base generator powers', ...
            'Tag','OBC', ...
            'Accelerator','p');
if GAMS.basepg,
  set(h2,'Checked','on'),
else,
  set(h2,'Checked','off'),
end
h2 = uimenu('Parent',h1, ...
            'Callback','fm_gamsfig option', ...
            'Label','Edit GAMS Call Options', ...
            'Tag','OTV', ...
            'Accelerator','e');
h2 = uimenu('Parent',h1, ...
            'Callback','fm_tviewer', ...
            'Label','Select Text Viewer', ...
            'Tag','OTV', ...
            'Accelerator','t', ...
            'Separator', 'on');

% Menu Links
h1 = uimenu('Parent',h0, ...
            'Label','Links', ...
            'Tag','MenuLink');
h2 = uimenu('Parent',h1, ...
            'Callback','web(''http://www.gams.com'');', ...
            'Label','GAMS website', ...
            'Tag','GAMSLink');
h2 = uimenu('Parent',h1, ...
            'Callback','web(''http://www.cs.wisc.edu/math-prog/matlab.html'')', ...
            'Label','Matlab-GAMS interface website', ...
            'Tag','MGLink');

% Frame
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'ForegroundColor',Theme.color03, ...
               'Position',[0.025 0.275*rs 0.95 0.675*df], ...
               'Style','frame', ...
               'Tag','Frame1');

% List Box
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left',  ...
               'Position',[0.35 0.86*rs+dy 0.4*0.6552 0.05*rs], ...
               'String','Line Selection', ...
               'Style','text', ...
               'Tag','StaticText12');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback', 'GAMS.line = get(gcbo,''Value'')-1; GAMS.line = GAMS.line(end); set(gcbo,''Value'',GAMS.line+1)', ...
               'FontName', Theme.font01, ...
               'ForegroundColor',Theme.color05,  ...
               'Max', 100, ...
               'Position',[0.35 0.49*rs 0.4*0.6552  0.4440], ...
               'String',lines, ...
               'Style','listbox', ...
               'Tag','ListboxLines', ...
               'Value',GAMS.line+1);
if GAMS.method ~= 4 && GAMS.method ~= 6 && GAMS.method ~= 7
  set(h1,'Enable','off')
end

% Popup Menus
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback', 'fm_gamsfig method', ...
               'FontName', Theme.font01, ...
               'ForegroundColor',Theme.color05,  ...
               'Position',[0.6552  0.79*rs+dy  0.45*0.6552  0.06*rs], ...
               'String',metodi, ...
               'Style','popupmenu', ...
               'Tag','PopupMenuMethod', ...
               'Value',GAMS.method);
if GAMS.type == 2 || GAMS.type == 4
  set(h1,'String',metodi([1,2]))
end
if GAMS.method == 4 && GAMS.type == 3
  set(h1,'Enable','off')
end
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback', 'GAMS.flow = get(gcbo,''Value'')-1;', ...
               'ForegroundColor',Theme.color05, ...
               'FontName', Theme.font01,  ...
               'Position',[0.6552 0.64*rs+dy  0.45*0.6552  0.06*rs], ...
               'String',flussi, ...
               'Style','popupmenu', ...
               'Tag','PopupMenuFlow', ...
               'Value',GAMS.flow+1);
if GAMS.method == 6
  set(h1,'Enable','off','Value',2)
  GAMS.flow = 2;
end

h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left',  ...
               'Position',[0.6552  0.71*rs+dy  0.45*0.6552  0.05*rs], ...
               'String','Flow Limits', ...
               'Style','text', ...
               'Tag','StaticText11');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left',  ...
               'Position',[0.6552 0.86*rs+dy 0.45*0.6552 0.05*rs], ...
               'String','Optimization Model', ...
               'Style','text', ...
               'Tag','StaticText12');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback', 'fm_gamsfig type', ...
               'ForegroundColor',Theme.color05, ...
               'FontName', Theme.font01,  ...
               'Position',[0.6552 0.49*rs+dy 0.45*0.6552 0.06*rs], ...
               'String',tipi, ...
               'Style','popupmenu', ...
               'Tag','PopupMenuType', ...
               'UserData',GAMS.method, ...
               'Value',GAMS.type);
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left', ...
               'Position',[0.6552 0.56*rs+dy 0.45*0.6552 0.05*rs], ...
               'String','Solution Type', ...
               'Style','text', ...
               'Tag','StaticText11');
h1 = uicontrol('Parent', h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback', 'GAMS.flatstart = get(gcbo,''Value'')-1;', ...
               'ForegroundColor',Theme.color05, ...
               'FontName', Theme.font01, ...
               'Position',[0.6552 0.49*rs 0.45*0.6552 0.06*rs], ...
               'String',guess, ...
               'Style','popupmenu', ...
               'Tag','PopupMenu2', ...
               'Value',GAMS.flatstart+1);
h1 = uicontrol('Parent', h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left', ...
               'Position',[0.6552 0.56*rs 0.45*0.6552 0.05*rs], ...
               'String','Initial Guess', ...
               'Style','text', ...
               'Tag','StaticText11');

h1 = uicontrol('Parent', h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'Callback', '', ...
               'FontName', Theme.font01, ...
               'Position',[0.05 0.49*rs  0.4*0.6552  0.06*rs], ...
               'String',output, ...
               'Style','popupmenu', ...
               'Tag','PopupGamsFile', ...
               'Value',1);
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left', ...
               'Position',[0.05  0.56*rs  0.4*0.6552 0.05*rs], ...
               'String','GAMS Input/Output File', ...
               'Style','text', ...
               'Tag','StaticText11');
% Pushbuttons
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color03, ...
               'Callback','fm_gams', ...
               'FontWeight','bold', ...
               'ForegroundColor',Theme.color09, ...
               'Position',[0.05  0.33*rs-2*dm  0.2833  0.0882*rs+2*dm], ...
               'String','Run GAMS', ...
               'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'Callback','close(gcf)', ...
               'Position',[0.6633  0.33*rs-2*dm  0.2833  0.0882*rs+2*dm], ...
               'String','Close', ...
               'Tag','Pushbutton2');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'Callback','fm_gamsfig view', ...
               'Position',[0.3583  0.33*rs-2*dm  0.2833  0.0882*rs+2*dm], ...
               'String','View GAMS Output', ...
               'Tag','Pushbutton2');

% Parameter for the Optimization
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback', 'fm_gamsfig omega', ...
               'FontName',Theme.font01, ...
               'ForegroundColor',Theme.color05, ...
               'HorizontalAlignment',aligntxt, ...
               'Position',[0.05 0.79*rs+dy-dm 0.4*0.6552 0.06*rs+dm], ...
               'Style','edit', ...
               'String', GAMS.omega_s, ...
               'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left', ...
               'Position',[0.05 0.86*rs+dy 0.4*0.6552 0.05*rs], ...
               'String','Weighting Factor [0,1]', ...
               'Style','text', ...
               'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback', 'fm_gamsfig lmin', ...
               'FontName',Theme.font01, ...
               'ForegroundColor',Theme.color05, ...
               'HorizontalAlignment',aligntxt,  ...
               'Position',[0.05 0.64*rs+dy-dm 0.4*0.6552 0.06*rs+dm], ...
               'Style','edit', ...
               'String', GAMS.lmin_s, ...
               'Tag','EditText2');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left', ...
               'Position',[0.05 0.71*rs+dy 0.4*0.6552 0.05*rs], ...
               'String','Min Loading Parameter', ...
               'Style','text', ...
               'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback','GAMS.lmax = fval(gcbo,GAMS.lmax);', ...
               'FontName',Theme.font01, ...
               'ForegroundColor',Theme.color05, ...
               'HorizontalAlignment',aligntxt, ...
               'Position',[0.05 0.49*rs+dy-dm 0.4*0.6552 0.06*rs+dm], ...
               'Style','edit', ...
               'String', num2str(GAMS.lmax), ...
               'Tag','EditText3');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left', ...
               'Position',[0.05 0.56*rs+dy 0.4*0.6552 0.05*rs], ...
               'String','Max Loading Parameter', ...
               'Style','text', ...
               'Tag','StaticText3');

% Banner
h1 = axes('Parent',h0, ...
          'Box','on', ...
          'CameraUpVector',[0 1 0], ...
          'Color',Theme.color04, ...
          'ColorOrder',Settings.color, ...
          'Layer','top', ...
          'Position',[0.025 0.025*rs 0.2*0.6552 0.225*rs], ...
          'Tag','Axes1', ...
          'XColor',Theme.color02, ...
          'XLim',[0.5 100.5], ...
          'XLimMode','manual', ...
          'XTick',[], ...
          'YColor',Theme.color02, ...
          'YDir','reverse', ...
          'YLim',[0.5 100.5], ...
          'YLimMode','manual', ...
          'YTick',[], ...
          'ZColor',[0 0 0]);
h2 = image('Parent',h1, ...
           'CData',fm_mat('logo_psat'), ...
           'Tag','Axes1Image1', ...
           'XData',[1 101], ...
           'YData',[1 101]);
h1 = axes('Parent',h0, ...
          'Box','on', ...
          'CameraUpVector',[0 1 0], ...
          'Color',Theme.color02, ...
          'ColorOrder',Settings.color, ...
          'Layer','top', ...
          'Position',[0.844 0.025*rs 0.2*0.6552 0.225*rs], ...
          'Tag','Axes1', ...
          'XColor',Theme.color02, ...
          'XLim',[0.5 100.5], ...
          'XLimMode','manual', ...
          'XTick',[], ...
          'YColor',Theme.color02, ...
          'YDir','reverse', ...
          'YLim',[0.5 100.5], ...
          'YLimMode','manual', ...
          'YTick',[], ...
          'ZColor',[0 0 0]);
h2 = image('Parent',h1, ...
           'CData',fm_mat('logo_gams'), ...
           'Tag','Axes1Image1', ...
           'XData',[8 92], ...
           'YData',[8 92]);
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'ForegroundColor', [1 0 0], ...
               'FontSize', 12, ...
               'FontName', 'Times', ...
               'FontWeight', 'bold', ...
               'FontAngle', 'italic',...
               'Position',[0.25 0.1*rs 0.5 0.07*rs], ...
               'String','PSAT-GAMS Interface', ...
               'Style','text', ...
               'Tag','StaticText3');

if nargout > 0, fig = h0; end