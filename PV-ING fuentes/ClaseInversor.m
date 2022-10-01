%%calculo de penetracion y funcionamiento de la red con D-SFVG
%% Parametros inversor
classdef ClaseInversor
    properties
    Pnom=0;
    %%todos los parametros a agregar
    tablaN=[];
    Ppu=[];
    Vmin=0;
    Vmax=0;
    end
    methods
        function a= ClaseInversor(param, rendimiento)
            a.Pnom=param(1);
            a.tablaN=rendimiento; %xlsread(rendimiento); %rendimiento: restricciones, igual numero de filas, curva para 3 tensiones:400,300y200Vdc
            a.Ppu=a.tablaN(:,1); % si o si primer columna es Ppu.
            a.Vmin=param(2);
            a.Vmax=param(3);
        end %constructor
    end
     methods
        function   PCA_out= get_PCA(a,Pout,Vdc) %P=W, Vdc=Volts
            
            if nargin < 3
                Vdc=300; % Vdc parametro opcional, por default 300
            end
            
            if Vdc>=400.0
                Vindex=2;
            elseif  Vdc<400.0 && Vdc>=300.0
                Vindex=3;
            elseif Vdc<300.0
                Vindex=4;
            end
                                       
            P=Pout/a.Pnom;
            if P>=1.0
                PCA_out=0.97*Pout;
            else
                Pindex=find(a.Ppu>=P & a.Ppu<=(P+(1/length(a.Ppu))));            
                PCA_out= a.tablaN(Pindex,Vindex)*Pout;
            end
        end 
        
        function   QCA_out= get_QCA(a,Pout)% funcion no implementada en SFVGD_loop 
            QCA_out= 0.0; % TODO distorcion armonica y reactivos
        end
        
        
        function    get_CurvasN(a)
            figure('Name','curvas de eficiencia del Inversor')
            plot(a.Ppu,a.tablaN(:,2)),title('Rendimiento a distintas Vdc'),xlabel('P [pu]'),ylabel('n[pu]'),grid('minor');
            hold on ;
            plot(a.Ppu,a.tablaN(:,3)),title('Rendimiento a distintas Vdc'),xlabel('P [pu]'),ylabel('n[pu]'),grid('minor');
            hold on;
            plot(a.Ppu,a.tablaN(:,4)),title('Rendimiento a distintas Vdc'),xlabel('P [pu]'),ylabel('n[pu]'),grid('minor');
        end
        
        function Errores = get_ErrMedicion(a,DatosVdcPdcPcaMedidaXLS,Horas_estudio) % ej: get_ErrMedicion('datos_red.xls','Pdc_medidida.xls',24)
        %%
            %%inicializo todo
            args=xlsread(DatosVdcPdcPcaMedidaXLS); % leo todos los datos de un excel  
            %armo parametros
            Vdc=args(:,1);%en Volts
            Pdc=args(:,2); % en Watt
            Pca=args(:,3); % en Watt           
            
         %%   chequeo simple de datos
            if not(length(Vdc)==length(Pca) && length(Pdc)==length(Pca))
                error('vectores de distinta longitud');
            end
            
        %% Inicio calculo 
            i=1;
            rendimientoCalc=[];
            rendimientoReal=[];            
            while (i<=length(Vdc))
                PCAcalc=a.get_PCA(Pdc(i),Vdc(i));
                if Pdc(i)==0
                    rendimientoCalc(i)=0;
                    rendimientoReal(i)=0;                   
                else
                    rendimientoCalc(i)=PCAcalc/Pdc(i);
                    rendimientoReal(i)=Pca(i)/Pdc(i);
                end
                
                
                Errores.ErrAbs(i)=abs(PCAcalc-Pca(i));
                Errores.ErrAbsEfi(i)=abs(rendimientoCalc(i)-rendimientoReal(i));
                
                if rendimientoReal(i)==0
                    Errores.ErrRel(i)=0;
                else
                    Errores.ErrRel(i)=100.0*(Errores.ErrAbsEfi(i)/rendimientoReal(i));
                end
                i=i+1;
            end
            
            Errores.Media.ABS=median(Errores.ErrAbs);
            Errores.Media.Rel=median(Errores.ErrRel);  
        %% plots de salida
            t=(1:length(Vdc))*Horas_estudio/length(Vdc); % escalo base de tiempo a HorasEstudio       
            figure('Name','curva errores absolutos, rendimiento calculador y real)')
            plot(t,Errores.ErrAbs),title('ErrAbs de rendimiento'),xlabel('t[Hs]'),ylabel('Err[Abs]'),grid('minor');
            hold on;
            plot(t,ones(1,length(Vdc)).*Errores.Media.ABS);
                       
            figure('Name','curva errores realtivo de rendimiento')
            plot(t,Errores.ErrRel),title('ErrRelativo '),xlabel('t[Hs]'),ylabel('ErrRell1[%]'),grid('minor');       
            hold on;
            plot(t,ones(1,length(Vdc)).*Errores.Media.Rel);
            
        end               
        
     end
end