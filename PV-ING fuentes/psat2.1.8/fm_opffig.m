function fig = fm_opffig(varargin)
% FM_OPFFIG create GUI for Optimal Power Flow settings
%
% HDL = FM_OPFFIG
%
%see OPF structure for settings
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Updte:     08-Feb-2003
%Version:   1.0.2
%
%E-mail:    Federico.Milano@uclm.es
%Web-site:  http://www.uclm.es/area/gsee/Web/Federico
%
% Copyright (C) 2002-2013 Federico Milano

global Settings Path OPF Theme Fig

if nargin
  switch varargin{1}

   case 'vlimits'

    a = fm_input({'Vmax','Vmin'},'Voltage Limits',1, ...
                 {num2str(OPF.vmax),num2str(OPF.vmin)},'off');
    if ~isempty(a)
      try
        OPF.vmax = str2num(a{1});
      catch
        fm_disp('Maximum voltage limit couldn''t be changed')
        OPF.vmax = 1.2;
      end
      try
        OPF.vmin = str2num(a{2});
      catch
        OPF.vmin = 0.8;
        fm_disp('Minimum voltage limit couldn''t be changed')
      end
    end
    if isempty(OPF.vmax)
      fm_disp('Maximum voltage limit couldn''t be changed')
      OPF.vmax = 1.2;
    end
    if isempty(OPF.vmin)
      fm_disp('Minimum voltage limit couldn''t be changed')
      OPF.vmax = 0.8;
    end

   case 'flows'

    OPF.enflow = ~OPF.enflow;
    hdl = findobj(Fig.opf,'Tag','PopupMenu2');
    if OPF.enflow,
      set(gcbo,'Checked','on')
      set(hdl,'Enable','on');
    else
      set(gcbo,'Checked','off')
      set(hdl,'Enable','off');
    end

   case 'voltages'

    OPF.envolt = ~OPF.envolt;
    if OPF.envolt,
      set(gcbo,'Checked','on')
    else
      set(gcbo,'Checked','off')
    end

   case 'reactive'

    OPF.enreac = ~OPF.enreac;
    if OPF.enreac,
      set(gcbo,'Checked','on')
    else
      set(gcbo,'Checked','off')
    end

   case 'tiebreak'

    OPF.tiebreak = ~OPF.tiebreak;
    if OPF.tiebreak,
      set(gcbo,'Checked','on')
    else
      set(gcbo,'Checked','off')
    end

   case 'omega'

    lasterr('');
    hdl_omeg = findobj(Fig.opf,'Tag','EditText1');
    s_omega = get(hdl_omeg,'String');
    try, eval(['OPFomega = ',s_omega,';'])
    catch, fm_disp(lasterr,2), set(hdl_omeg,'String',OPF.omega_s), return, end
    if max(OPFomega) > 1 || min(OPFomega) < 0
        fm_disp('The weighting factor must be within the range [0,1].',2)
        set(hdl_omeg,'String',OPF.omega_s), return
    end
    [ao,bo] = size(OPFomega);
    if ao > 1 && bo > 1
        fm_disp('The weighting factor must be a vector.',2)
        set(hdl_omeg,'String',OPF.omega_s), return
    end
    OPF.omega = OPFomega;
    OPF.omega_s = s_omega;
    fm_disp(['Parameter "OPF.omega" set to "',OPF.omega_s,'".'],1)

   case 'lmin'

    lasterr('');
    hdl_lmin = findobj(Fig.opf,'Tag','EditText2');
    s_lmin = get(hdl_lmin,'String');

    try
      eval(['OPFlmin = ',s_lmin,';'])
    catch
      fm_disp(lasterr,2),
      set(hdl_lmin,'String',OPF.lmin_s)
      return
    end
    if max(OPFlmin) > OPF.lmax
      fm_disp('Lambda_min must be less than Lambda_max.',2)
      set(hdl_lmin,'String',OPF.lmin_s), return,
    end
    [al,bl] = size(OPFlmin);
    if al > 1 || bl > 1
      fm_disp('The loading parameter must be a scalar.',2)
      set(hdl_lmin,'String',OPF.lmin_s)
      return
    end
    OPF.lmin = OPFlmin;
    OPF.lmin_s = s_lmin;
    fm_disp(['Parameter "OPF.lmin" set to "',OPF.lmin_s,'".'],1)

  end
  return
end


if Fig.opf, figure(Fig.opf), return, end

rs = 0.4344/0.5;
dy = (0.5-0.4344)/0.5;
df = 1+1.35*(0.5-0.4344);
flussi = {'Currents';
          'Active Powers';
          'Apparent Powers'};
metodi = {'Newton Direction';
          'Mehrotra Predictor/Corrector'};
tipi   = {'Single OPF';
          'Pareto Set';
          'Dayly Forecast';
          'ATC (by CPF)';
          'ATC (by sensitivity analysis)'};
guess  = {'Flat Start',
          'Actual Power Flow Solution'};

if strcmp(Settings.platform,'MAC')
  aligntxt = 'center';
  dm = 0.0075;
else
  aligntxt = 'left';
  dm = 0;
end

h0 = figure('Units','normalized', ...
            'Color',Theme.color02, ...
            'Colormap',[], ...
            'CreateFcn', 'Fig.opf = gcf;', ...
            'DeleteFcn', 'Fig.opf = 0;', ...
            'MenuBar','none', ...
            'Name','PSAT-OPF', ...
            'NumberTitle','off', ...
            'PaperPosition',[18 180 576 432], ...
            'PaperUnits','points', ...
            'Position',sizefig(0.5686,0.5), ...
            'Resize','on', ...
            'ToolBar','none', ...
            'FileName','fm_opffig');
fm_set colormap

% Menu File
h1 = uimenu('Parent',h0, ...
            'Label','File', ...
            'Tag','MenuFile');
h2 = uimenu('Parent',h1, ...
            'Callback','close(gcf)', ...
            'Label','Exit', ...
            'Tag','NetSett', ...
            'Accelerator','x');
% Menu Edit
h1 = uimenu('Parent',h0, ...
            'Label','Edit', ...
            'Tag','MenuEdit');
h2 = uimenu('Parent',h1, ...
            'Callback','fm_setting', ...
            'Label','General Settings', ...
            'Tag','ToolSett', ...
            'Accelerator','s');
% Menu Run
h1 = uimenu('Parent',h0, ...
            'Label','Run', ...
            'Tag','MenuRun');
h2 = uimenu('Parent',h1, ...
            'Callback','fm_set opf', ...
            'Label','Run OPF', ...
            'Tag','ToolOPFSett', ...
            'Accelerator','z');
% Menu Options
h1 = uimenu('Parent',h0, ...
            'Label','Options', ...
            'Tag','MenuOpt');
h2 = uimenu('Parent',h1, ...
            'Callback','fm_opffig flows', ...
            'Label','Enable Flow limits', ...
            'Tag','Opt1');
if OPF.enflow,
  set(h2,'Checked','on'),
else,
  set(h2,'Checked','off'),
end
h2 = uimenu('Parent',h1, ...
            'Callback','fm_opffig voltages', ...
            'Label','Enable Voltage Limits', ...
            'Tag','Opt2');
if OPF.envolt,
  set(h2,'Checked','on'),
else,
  set(h2,'Checked','off'),
end
h2 = uimenu('Parent',h1, ...
            'Callback','fm_opffig reactive', ...
            'Label','Enable Reactive Limits', ...
            'Tag','Opt3');
if OPF.enreac,
  set(h2,'Checked','on'),
else,
  set(h2,'Checked','off'),
end
h2 = uimenu('Parent',h1, ...
            'Callback','fm_opffig tiebreak', ...
            'Label','Enforce Tiebreaking', ...
            'Tag','Opt3');
if OPF.tiebreak,
  set(h2,'Checked','on'),
else,
  set(h2,'Checked','off'),
end
h2 = uimenu('Parent',h1, ...
            'Callback','fm_opffig vlimits', ...
            'Label','Set Voltage Limits', ...
            'Tag','Opt4');

%a = fm_input({'Vmax','Vmin'},'OPF settings',1,{num2str(OPF.vmax),num2str(OPF.vmin)},'off')


h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'ForegroundColor',Theme.color03, ...
               'Position',[0.025 0.275*rs 0.95 0.675*df], ...
               'Style','frame', ...
               'Tag','Frame1');

% Popup Menus
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback', 'OPF.method = get(gcbo,''Value'');', ...
               'FontName', Theme.font01, ...
               'ForegroundColor',Theme.color05,  ...
               'Position',[0.608  0.79*rs+dy  0.342  0.06*rs], ...
               'String',metodi, ...
               'Style','popupmenu', ...
               'Tag','PopupMenu1', ...
               'Value',OPF.method);
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback', 'OPF.flow = get(gcbo,''Value'');', ...
               'ForegroundColor',Theme.color05, ...
               'FontName', Theme.font01,  ...
               'Position',[0.608 0.64*rs+dy  0.342  0.06*rs], ...
               'String',flussi, ...
               'Style','popupmenu', ...
               'Tag','PopupMenu2', ...
               'Value',OPF.flow);
if OPF.enflow
  set(h1,'Enable','on')
else
  set(h1,'Enable','off')
end
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left',  ...
               'Position',[0.608  0.71*rs+dy  0.3  0.05*rs], ...
               'String','Flow Limits', ...
               'Style','text', ...
               'Tag','StaticText11');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left',  ...
               'Position',[0.608  0.86*rs+dy  0.3  0.05*rs], ...
               'String','Solving Method', ...
               'Style','text', ...
               'Tag','StaticText12');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback', 'OPF.type = get(gcbo,''Value'');', ...
               'ForegroundColor',Theme.color05, ...
               'FontName', Theme.font01,  ...
               'Position',[0.608 0.49*rs+dy  0.342  0.06*rs], ...
               'String',tipi, ...
               'Style','popupmenu', ...
               'Tag','PopupMenu3', ...
               'Value',OPF.type);
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left', ...
               'Position',[0.608  0.56*rs+dy  0.3  0.05*rs], ...
               'String','OPF Type', ...
               'Style','text', ...
               'Tag','StaticText11');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback', 'OPF.flatstart = get(gcbo,''Value'');', ...
               'ForegroundColor',Theme.color05, ...
               'FontName', Theme.font01, ...
               'Position',[0.608 0.49*rs  0.342  0.06*rs], ...
               'String',guess, ...
               'Style','popupmenu', ...
               'Tag','PopupMenu4', ...
               'Value',OPF.flatstart);
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left', ...
               'Position',[0.608  0.56*rs  0.3  0.05*rs], ...
               'String','Initial Guess', ...
               'Style','text', ...
               'Tag','StaticText11');

% Pushbuttons
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color03, ...
               'Callback','fm_set opf', ...
               'FontWeight','bold', ...
               'ForegroundColor',Theme.color09, ...
               'Position',[0.608  0.33*rs  0.16  0.0882*rs+1.5*dm], ...
               'String','Run OPF', ...
               'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'Callback','close(gcf)', ...
               'Position',[0.794  0.33*rs  0.16  0.0882*rs+1.5*dm], ...
               'String','Close', ...
               'Tag','Pushbutton2');

% Check Buttons
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'Callback', 'OPF.basepl = get(gcbo,''Value'');', ...
               'HorizontalAlignment','left', ...
               'Position',[0.05 0.33*rs 0.22 0.06], ...
               'Style','checkbox', ...
               'String', 'Use Base Load', ...
               'Tag','CheckboxBaseLoad', ...
               'Value',OPF.basepl);
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'Callback', 'OPF.basepg = get(gcbo,''Value'');', ...
               'HorizontalAlignment','left', ...
               'Position',[0.05 0.395*rs 0.22 0.06], ...
               'Style','checkbox', ...
               'String', 'Use Base Gen.', ...
               'Tag','CheckboxBaseGen', ...
               'Value',OPF.basepg);

% Parameter for the Optimization
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback', 'fm_opffig omega', ...
               'FontName',Theme.font01, ...
               'ForegroundColor',Theme.color05, ...
               'HorizontalAlignment',aligntxt, ...
               'Position',[0.05 0.79*rs+dy 0.22 0.06*rs+dm], ...
               'Style','edit', ...
               'String', OPF.omega_s, ...
               'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left', ...
               'Position',[0.05 0.86*rs+dy+dm 0.22 0.05*rs], ...
               'String','Weighting Factor [0,1]', ...
               'Style','text', ...
               'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback', 'fm_opffig lmin', ...
               'FontName',Theme.font01, ...
               'ForegroundColor',Theme.color05, ...
               'HorizontalAlignment',aligntxt,  ...
               'Position',[0.05 0.637*rs+dy 0.22 0.06*rs+dm], ...
               'Style','edit', ...
               'String', OPF.lmin_s, ...
               'Tag','EditText2');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left', ...
               'Position',[0.05 0.707*rs+dy+dm 0.22 0.05*rs], ...
               'String','Min Loading Parameter', ...
               'Style','text', ...
               'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback','OPF.lmax = fval(gcbo,OPF.lmax);', ...
               'FontName',Theme.font01, ...
               'ForegroundColor',Theme.color05, ...
               'HorizontalAlignment',aligntxt, ...
               'Position',[0.05 0.483*rs+dy 0.22 0.06*rs+dm], ...
               'Style','edit', ...
               'String', num2str(OPF.lmax), ...
               'Tag','EditText3');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left', ...
               'Position',[0.05 0.553*rs+dy+dm 0.22 0.05*rs], ...
               'String','Max Loading Parameter', ...
               'Style','text', ...
               'Tag','StaticText3');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback','OPF.deltat = fval(gcbo,OPF.deltat);', ...
               'FontName',Theme.font01, ...
               'ForegroundColor',Theme.color05, ...
               'HorizontalAlignment',aligntxt,  ...
               'Position',[0.05 0.33*rs+dy 0.22 0.06*rs+dm], ...
               'Style','edit', ...
               'String', num2str(OPF.deltat), ...
               'Tag','EditDeltat');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left', ...
               'Position',[0.05 0.40*rs+dy+dm 0.22 0.05*rs], ...
               'String','Time Interval', ...
               'Style','text', ...
               'Tag','StaticDeltat');

% Parameters for the Interior Point routine
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback','OPF.sigma = fval(gcbo,OPF.sigma);', ...
               'FontName',Theme.font01, ...
               'ForegroundColor',Theme.color05, ...
               'HorizontalAlignment',aligntxt, ...
               'Position',[0.35 0.33*rs 0.18 0.06*rs+dm], ...
               'Style','edit', ...
               'String', num2str(OPF.sigma), ...
               'Tag','EditSigma');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left',  ...
               'Position',[0.35 0.40*rs+dm 0.2 0.05*rs], ...
               'String','Centering Parameter', ...
               'Style','text', ...
               'Tag','StaticSigma');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback','OPF.gamma = fval(gcbo,OPF.gamma);', ...
               'FontName',Theme.font01, ...
               'ForegroundColor',Theme.color05, ...
               'HorizontalAlignment',aligntxt, ...
               'Position',[0.35 0.33*rs+dy 0.18 0.06*rs+dm], ...
               'Style','edit', ...
               'String', num2str(OPF.gamma), ...
               'Tag','EditGamma');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left',  ...
               'Position',[0.35 0.40*rs+dy+dm 0.2 0.05*rs], ...
               'String','Safety Factor', ...
               'Style','text', ...
               'Tag','StaticGamma');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback','OPF.eps_mu = fval(gcbo,OPF.eps_mu);', ...
               'FontName',Theme.font01, ...
               'ForegroundColor',Theme.color05, ...
               'HorizontalAlignment',aligntxt,  ...
               'Position',[0.35 0.483*rs+dy 0.18 0.06*rs+dm], ...
               'Style','edit', ...
               'String', num2str(OPF.eps_mu), ...
               'Tag','EditEpsmu');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left',  ...
               'Position',[0.35 0.553*rs+dy+dm 0.2 0.05*rs], ...
               'String',['mu Tolerance'], ...
               'Style','text', ...
               'Tag','StatiEpsmu');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback','OPF.eps1 = fval(gcbo,OPF.eps1);', ...
               'FontName',Theme.font01, ...
               'ForegroundColor',Theme.color05, ...
               'HorizontalAlignment',aligntxt,  ...
               'Position',[0.35 0.637*rs+dy 0.18 0.06*rs+dm], ...
               'Style','edit', ...
               'String', num2str(OPF.eps1), ...
               'Tag','EditEps1');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left',  ...
               'Position',[0.35 0.707*rs+dy+dm 0.2 0.05*rs], ...
               'String','PF eqs. Tolerance', ...
               'Style','text', ...
               'Tag','StaticEps1');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color04, ...
               'Callback','OPF.eps2 = fval(gcbo,OPF.eps2);', ...
               'FontName',Theme.font01, ...
               'ForegroundColor',Theme.color05, ...
               'HorizontalAlignment',aligntxt,  ...
               'Position',[0.35 0.79*rs+dy 0.18 0.06*rs+dm], ...
               'Style','edit', ...
               'String', num2str(OPF.eps2), ...
               'Tag','EditEps2');
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'HorizontalAlignment','left',  ...
               'Position',[0.35 0.86*rs+dy+dm 0.2 0.05*rs], ...
               'String','OF Tolerance', ...
               'Style','text', ...
               'Tag','StaticEps2');

% Banner
h1 = axes('Parent',h0, ...
          'Box','on', ...
          'CameraUpVector',[0 1 0], ...
          'Color',Theme.color04, ...
          'ColorOrder',Settings.color, ...
          'Layer','top', ...
          'Position',[0.025 0.025*rs 0.1289 0.225*rs], ...
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
          'Color',Theme.color04, ...
          'ColorOrder',Settings.color, ...
          'Layer','top', ...
          'Position',[0.84 0.025*rs 0.1289 0.225*rs], ...
          'Tag','Axes1', ...
          'XColor',Theme.color02, ...
          'XLim',[0.5 110.5], ...
          'XLimMode','manual', ...
          'XTick',[], ...
          'YColor',Theme.color02, ...
          'YDir','reverse', ...
          'YLim',[0.5 110.5], ...
          'YLimMode','manual', ...
          'YTick',[], ...
          'ZColor',[0 0 0]);
h2 = image('Parent',h1, ...
           'CData',fm_mat('logo_opf'), ...
           'Tag','Axes1Image1', ...
           'XData',[1 111], ...
           'YData',[1 111]);
h1 = uicontrol('Parent',h0, ...
               'Units', 'normalized', ...
               'BackgroundColor',Theme.color02, ...
               'ForegroundColor', [1 0 0], ...
               'FontSize', 12, ...
               'FontName', 'Times', ...
               'FontWeight', 'bold', ...
               'FontAngle', 'italic',...
               'Position',[0.35 0.1*rs 0.3 0.07*rs], ...
               'String','Optimal Power Flow', ...
               'Style','text', ...
               'Tag','StaticText3');

if nargout > 0, fig = h0; end