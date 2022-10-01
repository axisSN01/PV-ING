%%calculo de penetracion y funcionamiento de la red con D-SFVG
%TERMINOLOGIA: 
%   celda: un cuadrito de 0,7 volts
%   modulo: un panel, (ej. 60 celda en serie).
%   arreglo: combinacion de paneles (ej. 8 paneles en serie, 60*8 celdas en serie)
classdef ClaseArreglo<hgsetget
    properties %%parametro por default: los del arreglo de andres serie 8x(Sunmodule SW240 Poly)
    %%parametros modificables en cada arreglo
    Rp=1362.09;  % Resistencia paralelo del arreglo total.
    Rs=2.44;     % Resistencia serie del total del arreglo.
    P0=1865.5; %1920.0 ideal
    N=60; % numero de celdas en serie por modulo
    Ns=8;  % numero de modulos en serie por arreglo.
    Np=1; % numero de modulos en paralelo por arreglo. aun chequeado. afecta solo a la Icc, lo demas igual.
    Vca0=299.54;
    Icc0= 8.53;
    Points=5000; % numero de puntos par armar la curva.
    %%parametros fijos para cualquier arreglo
    Gama=-0.0045;  %CNPT datos de modulo
    Beta=-0.0037; %CNPT datos de modulo
    m=1.2; %CNPT
    G0=1000; %CNPT
    T0=25+272.15; % en kelvin CNPT
    % atributos internos para curva de 5 parametros
    Vserie=[]; 
    Iserie=[];

    end
    methods
        function a= ClaseArreglo(varargin)%ejemplo arr=Arreglo(1362.09,2.44,1865.8,60,8,1,299.54,8.53,2000)   
                if length(varargin)~=0
                    param=varargin{1};  
                    a.Rp=param(1);
                    a.Rs=param(2);
                    a.P0=param(3);
                    a.N=param(4);
                    a.Ns=param(5);
                    a.Np=param(6);
                    a.Vca0=param(7);
                    a.Icc0=param(8);
                    a.Points=param(9); 

                end
        end
    end
     methods
        function   Pout= get_Pout(a,G,Tamb,modelo)% para G=920, Taire~38 Cº,Tcel~60Cº
            %%chequeo modelos
            if modelo==0                                    % uso modelo ecuacion de potencia
                Taire=Tamb+272.15;                          % llevo Cº a K.
                Tcel=Taire+ 0.0325*G;                        % considero NOCT: 46º, segun paper manu y datos de modulo.
                Pout= (a.P0*G/a.G0)*(1+a.Gama*(Tcel-a.T0)); %[Watts]
            elseif modelo==1                                % uso modelo 5 parametros, valido para un panel (hay q extrapolar al arreglo)                
                Taire=Tamb+272.15;                          % llevo Cº a K.
                Tcel=Taire+ 0.025*G;                        % considero NOCT: 40º, segun paper manu.
                Vt=(6.6173E-5)*Tcel;                        %k/q*T
                Ntot=a.N*a.Ns;                              % valido solo para arreglos en serie
                if (a.Vca0 + a.Beta*Ntot*(Tcel-a.T0) + a.m*Vt*log(G/(a.G0)))>=0
                    Vca=a.Vca0 + a.Beta*Ntot*(Tcel-a.T0) + a.m*Vt*log(G/(a.G0));
                else
                    Vca=a.Vca0 + a.Beta*Ntot*(Tcel-a.T0);
                end %sirve para que no me de tensiones negativas
                Icc= a.Np*(a.Icc0*G/(a.G0)); % variacion de Icc con temperatura, aun no implementado. 
                %% ahora viene el loop donde obtengo PMP, metodo largo
                i=1;
                for Vv=(Icc*(a.Rs)):(Vca/a.Points):Vca; % tension virtual, length points
                    I(i)=Icc*(1-exp((Vv-Vca)/(a.m*Ntot*Vt)))-(Vv/(a.Rp));
                    V(i)=Vv-(I(i))*(a.Rs);
                    i=i+1;
                end
                Pout=max(V.*I);%[Watts]
                set(a,'Vserie',V);
                set(a,'Iserie',I);
                
            else
                error('indice de modelo no definido')
            end
        end
        function Errores= get_ErrModel(a,DatosGyTxls,Horas_estudio) % ej: get_ErrModel('datos_red.xls',24)
        %%
            %%inicializo todo
            args=xlsread(DatosGyTxls); % leo todos los datos de un excel
            %armo parametros
            G=args(:,1);%zeros(144,1); % % en W/m2 
            T=args(:,2); % en Cº            
         %%   chequeo simple de datos
            if not(length(G)==length(T))
                error('vectores de distinta longitud, cehquee G,T');
            end
            
        %% Inicio calculo 
            i=1;
            while (i<=length(G))
                Pmodel0=a.get_Pout(G(i),T(i),0);
                Pmodel1=a.get_Pout(G(i),T(i),1);
                if Pmodel1<=1.0
                    Pmodel1=Pmodel0;
                end
                Errores.ErrAbs(i)=abs(Pmodel0-Pmodel1);       
                Errores.ErrRel1(i)=100.0*(Errores.ErrAbs(i)/Pmodel1);
                Errores.ErrRel0(i)=100.0*(Errores.ErrAbs(i)/Pmodel0); 
                i=i+1;
            end
            Errores.Media.ABS=median(Errores.ErrAbs);
            Errores.Media.Rel0=median(Errores.ErrRel0); 
            Errores.Media.Rel1=median(Errores.ErrRel1);                        
        %% plots de salida
            t=(1:length(G))*Horas_estudio/length(G); % escalo base de tiempo a HorasEstudio       
            figure('Name','curva errores absolutos entre modelos en f(t)')
            plot(t,Errores.ErrAbs),title('ErrAbs en f(t)'),xlabel('t[Hs]'),ylabel('Err[Abs]'),grid('minor');       
            hold on;
            plot(t,ones(1,length(G)).*Errores.Media.ABS);
            figure('Name','curva errores realtivo a modelo 1 en f(t) )')
            plot(t,Errores.ErrRel1),title('ErrRelativo a modelo1 en f(t)'),xlabel('t[Hs]'),ylabel('ErrRell1[%]'),grid('minor');       
            hold on;
            plot(t,ones(1,length(G)).*Errores.Media.Rel1);
            
            figure('Name','curva errores realtivo a modelo 0 en f(t) )')
            plot(t,Errores.ErrRel0),title('ErrRelativo a modelo0 en f(t)'),xlabel('t[Hs]'),ylabel('ErrRell0[%]'),grid('minor');       
            hold on;
            plot(t,ones(1,length(G)).*Errores.Media.Rel0);
            
        end
        function [V,I,P]=plot_model1(a,G,Tamb)
            Pout= a.get_Pout(G,Tamb,1);
            V=a.Vserie;
            I=a.Iserie;
            P=V.*I;
            figure('Name','curvas de PMP, 5 parametros')
                subplot(2,1,1);
                plot(V,I),title('I en f(V)'),xlabel('Volts'),ylabel('Amper'),grid('minor');
                subplot(2,1,2);  
                plot(V,P),title('Potencia en f (V)'),xlabel('Volts'),ylabel('P[W]'),grid('minor');                
            
        end
        
        function Errores = get_ErrMedicion(a,DatosGyTxls,PdcMedidaxls, Horas_estudio) % ej: get_ErrMedicion('datos_red.xls','Pdc_medidida.xls',24)
        %%
            %%inicializo todo
            args=xlsread(DatosGyTxls); % leo todos los datos de un excel            
            %armo parametros
            G=args(:,1);%zeros(144,1); % % en W/m2 
            T=args(:,2); % en Cº
            Preal=xlsread(PdcMedidaxls);
            
         %%   chequeo simple de datos
            if not(length(G)==length(T) && length(T)==length(Preal))
                error('vectores de distinta longitud, cehquee G,T y Preal');
            end
            
        %% Inicio calculo 
            i=1;
            while (i<=length(G))
                Pmodel0=a.get_Pout(G(i),T(i),0);
                Pmodel1=a.get_Pout(G(i),T(i),1);
                
                Errores.Abs0VsReal(i)=abs(Pmodel0-Preal(i)); 
                Errores.Abs1VsReal(i)=abs(Pmodel1-Preal(i));                 
                Errores.Rel1VsReal(i)=100.0*(Errores.Abs1VsReal(i)/Preal(i));
                Errores.Rel0VsReal(i)=100.0*(Errores.Abs0VsReal(i)/Preal(i));                
                i=i+1;
            end
            
            Errores.Media.Abs0VsReal=median(Errores.Abs0VsReal);
            Errores.Media.Abs1VsReal=median(Errores.Abs1VsReal); 
            Errores.Media.Rel1VsReal=median(Errores.Rel1VsReal); 
            Errores.Media.Rel0VsReal=median(Errores.Rel0VsReal);  
        %% plots de salida
            t=(1:length(G))*Horas_estudio/length(G); % escalo base de tiempo a HorasEstudio       
            figure('Name','curva errores absolutos entre modelo 0 y Potenca Real)')
            plot(t,Errores.Abs0VsReal),title('ErrAbs modelo 0 y Preal en f(t)'),xlabel('t[Hs]'),ylabel('Err[Abs]'),grid('minor');
            
            figure('Name','curva errores absolutos entre modelo 1 y Potenca Real)')
            plot(t,Errores.Abs1VsReal),title('ErrAbs modelo 1 y Preal en f(t)'),xlabel('t[Hs]'),ylabel('Err[Abs]'),grid('minor'); 

            figure('Name','curva errores realtivo a modelo 1 en f(t) )')
            plot(t,Errores.Rel1VsReal),title('ErrRelativo a Preal de modelo1 en f(t)'),xlabel('t[Hs]'),ylabel('ErrRell1[%]'),grid('minor');       

            figure('Name','curva errores realtivo a modelo 0 en f(t) )')
            plot(t,Errores.Rel0VsReal),title('ErrRelativo a Preal de modelo0 en f(t)'),xlabel('t[Hs]'),ylabel('ErrRell0[%]'),grid('minor');              
            
        end       
     
         function [Pmodel0 Pmodel1]= get_Pout_serie(a,serieGyTxls,Horas_estudio)
            %%
                %%inicializo todo
                args=xlsread(serieGyTxls); % leo todos los datos de un excel            
                %armo parametros
                G=args(:,1);%zeros(144,1); % % en W/m2 
                T=args(:,2); % en Cº    
             %%   chequeo simple de datos
                if not(length(G)==length(T))
                    error('vectores de distinta longitud, cehquee G,T ');
                end

            %% Inicio calculo 
                i=1;
                while (i<=length(G))
                    Pmodel0(i)=a.get_Pout(G(i),T(i),0);
                    Pmodel1(i)=a.get_Pout(G(i),T(i),1);                              
                    i=i+1;
                end     

            %% plots de salida
                t=(1:length(G))*Horas_estudio/length(G); % escalo base de tiempo a HorasEstudio       
                figure('Name','curva de Potencia con modelo de potencia')
                plot(t,Pmodel0),title('Potencia de arreglo segun modelo potencia'),xlabel('t[Hs]'),ylabel('Pot[W]'),grid('minor');       

                figure('Name','curva de Potencia con modelo de 5 parametros')
                plot(t,Pmodel1),title('Potencia de arreglo segun modelo 5 parametros'),xlabel('t[Hs]'),ylabel('Pot[W]'),grid('minor');       
 
        end
     end
end