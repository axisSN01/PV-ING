%%calculo de penetracion y funcionamiento de la red con SFCR
%NOTA: store -> se pasan las barras por referencia
%       DAE -> se pasan las barras por valor
%arr=Arreglo(1362.09,2.44,6520,60,8,1,299.54,8.53,2000)% defino arreglo(Rp,Rs,P0,N,Ns,Np,Vca0,Icc0,Points)
%inve=Inversor(6520,'eficienciaPV4600.xls',176,255);
%SistemaName='UnifilarEdificioNuevoUnne_mdl';
%config='config.xls';
%datosRed= 'datos_red_para_modelo.xls';% todos de la misma longitud., G,T,V,Pd,Qd
%modelo=0; %0:modelo P; 1: modelo 5 par;
function [resultado, IsResultado]= AlgoritmoFlujoPot(arr,modelo,inve,config,red,SistemaName,MyPath) 
%%    Leo datos de red.
    %red=xlsread(datosRed); % leo todos los datos de un excel
    %armo parametros
    if nargin == 6
        MyPath=false;
    end
    
    G=red(:,1); 
    T=red(:,2);
    VTG=red(:,3);
    PTCASFCR=red(:,4); 
    QTCASFCR=red(:,5);    
    PTS5=red(:,6); 
    QTS5=red(:,7);
    PTS1=red(:,8); 
    QTS1=red(:,9);
    PTG=red(:,10); 
    QTG=red(:,11);
    
    BarraName={'TCA_SFCR'; 'TG'; 'TS1'; 'TS5'};
%% armo estructura resultado  
    resultado=struct('Tiempo_horas',[],'V_TCA_SFCR_V',[],'deltaVTCA_SFCR_grad',[],'Pgen_SF_Kw',[],...
                    'Qgen_SF_Kvar',[],'status_SF_bol',[],...
                    'V_TS5_V',[],'deltaVTS5_grad',[],'V_TS1_V',[],'deltaVTS1_grad',[],...
                    'V_TG_V',[],'deltaVTG_grad',[],'P_genTG_Kw',[],'Q_genTG_Kvar',[],...
                    'Ploss_tot_Kw',[],'Qloss_tot_Kvar',[]);
                
%%    Leo configuracion   
    %config=xlsread(config);
    Pbase=config(1);
    Vbase=config(2);
    HorasEstudio=config(3);    
    TSample=config(4);     
%     TSFIndex=config(3);     los indices de las barras son fijos
%     TS5Index=config(4);      porque la red es fija
%     TS1Index=config(5);       TODO: permitir unifilar variables
%     TGIndex=config(6);
    TCASFCRIndex=1;
    TS5Index=4;
    TS1Index=3;
    TGIndex=2;   

   %% asigno indices a SLACK y PQGen por default y REFERENCIA
    SFCRIndex=1;
    SLACKIndex=1; %ojo, es por referencia
    
%%     chequeo datos config
    %TODO
    
 %%  Inicializo PSAT    
    Vmin=((inve.Vmin)*1E-3)/Vbase;  % Vmin,Vmax en V
    Vmax=((inve.Vmax)*1E-3)/Vbase;   % Vb en Kv.
    initpsat;
    Settings.mva=Pbase; % en MVA
    Settings.iftol=1E-5; % error maximo.
    Settings.dyntol=1E-3;
    Settings.show=0; % no quiero ver display de iteraciones
    Settings.status=0; % no quiero ver display de iteraciones
    clpsat.readfile = 0;
    %resultado=struct ;
    try
        if MyPath
            runpsat(SistemaName,MyPath,'data');
        else
            runpsat(SistemaName,'data');
        end
    catch ME
        disp(ME.identifier);
        disp(ME.message);
        runpsat(SistemaName,'data');        
    end
    runpsat('pf');
%     Is_SFCR=0;
%     Is_PQSFCR=0;
    Is_PQTS5=0; % flags para control
    Is_PQTS1=0; % flags para control
    Is_PQTG=0; % flags para control
    i=1;
    

    
   %% asigno indices de cargas PQ y chequeo por referencia
    while (i<=PQ.n) && not(Is_PQTS5&& Is_PQTS1&& Is_PQTG) % pueden estar en la misma barra.
        if PQ.con(i,1)==TS5Index
            PQTS5Index=i; %se asigna por referencia.
            Is_PQTS5=1;
        end
        if PQ.con(i,1)==TS1Index
            PQTS1Index=i; %se asigna por referencia.  
            Is_PQTS1=1;
        end
        if PQ.con(i,1)==TGIndex
            PQTGIndex=i; %se asigna por referencia.  
            Is_PQTG=1;
        end
%         if PQ.con(i,1)==TCASFCRIndex
%             PQTCAIndex=i; %se asigna por referencia.  
%             Is_PQSFCR=1;
%         end         
        i=i+1;
        if (i>PQ.n) && not(Is_PQTS5&& Is_PQTS1&& Is_PQTG) % chequeo ultima iteracion y sino salgo.
            error('problema con indices de cargas PQ');
            resultado=0;
            IsResultado=0;
            return;
        end
    end

    %% Inicio calculo 
    i=1;
    k=length(G); % defino un iterador.
    h = waitbar(0,'1','Name','Espere por favor, calculando...',...
    'CreateCancelBtn',...
    'setappdata(gcbf,''canceling'',1)');
    setappdata(h,'canceling',0);      
    while (i<=k)
        if getappdata(h,'canceling')
            delete(h)       % DELETE the waitbar; don't try to CLOSE it. 
            break
        end
        % Report current estimate in the waitbar's message field
        waitbar(i/k,h,sprintf('muestras analizadas %d / %d ',i,k)); 
        
        %% actualizo estado de la red
        SW.store(SLACKIndex,4)=(VTG(i)*1E-3)/Vbase;  % actualizo voltage en slack 
%         %carga TCASFCR
%         PQ.store(PQTCAIndex,4)=(PTCASFCR(i)*1E-3)/Pbase;
%         PQ.store(PQTCAIndex,5)=(QTCASFCR(i)*1E-3)/Pbase;
        %carga TS5
        PQ.store(PQTS5Index,4)=(PTS5(i)*1E-3)/Pbase;
        PQ.store(PQTS5Index,5)=(QTS5(i)*1E-3)/Pbase;
        % carga TS1
        PQ.store(PQTS1Index,4)=(PTS1(i)*1E-3)/Pbase;
        PQ.store(PQTS1Index,5)=(QTS1(i)*1E-3)/Pbase;        
        % carga TG
        PQ.store(PQTGIndex,4)=(PTG(i)*1E-3)/Pbase;
        PQ.store(PQTGIndex,5)=(QTG(i)*1E-3)/Pbase;
        
        %% calculo flujo de prueba con SF conectado
        %%calculo Pg inyectada por SFCR
        P_arr=arr.get_Pout(G(i),T(i),modelo); % el arreglo no genera Q, y devuelve Watt
        PCA_inv=inve.get_PCA(P_arr);
        PCA=(PCA_inv*1E-6)/Pbase; % llevo a pu 
        %%calculo Qg inyectada por SFCR
        QCA_inv=inve.get_QCA(P_arr);
        QCA=(QCA_inv*1E-6)/Pbase; % llevo a pu 
        %% agrego todo a la red y chequeo nuevamente
        PdemandTCA=(PTCASFCR(i)*1E-3)/Pbase;% llevo a pu 
        QdemandTCA=(QTCASFCR(i)*1E-3)/Pbase;    % llevo a pu     
        PQgen.store(SFCRIndex,4)=(PCA-PdemandTCA);  % actualizo barra SF 
        PQgen.store(SFCRIndex,5)=(QCA-QdemandTCA);  % actualizo barra SF,principio de Pprog=Pg-Pd          
        runpsat('pf');
        [P_s,Q_s,P_r,Q_r,fr_bus,to_bus] = fm_flows('bus'); % obtengo flujos de potencia entre barras        
        flujoP1=strcat('P',BarraName{fr_bus(1)},'a',BarraName{to_bus(1)});
        flujoQ1=strcat('Q',BarraName{fr_bus(1)},'a',BarraName{to_bus(1)});
        flujoP2=strcat('P',BarraName{fr_bus(2)},'a',BarraName{to_bus(2)});
        flujoQ2=strcat('Q',BarraName{fr_bus(2)},'a',BarraName{to_bus(2)});
        flujoP3=strcat('P',BarraName{fr_bus(3)},'a',BarraName{to_bus(3)});
        flujoQ3=strcat('Q',BarraName{fr_bus(3)},'a',BarraName{to_bus(3)});
        %% chequeo tensiones, con el ultimo calculo de pf (con SF conectado)
        if DAE.y(TCASFCRIndex+Bus.n)>Vmin && DAE.y(TCASFCRIndex+Bus.n)<Vmax %primero van las fases y despues los modulos en DAE.y pasan pro valor
            
            [P_s,Q_s,P_r,Q_r,fr_bus,to_bus] = fm_flows('bus'); % obtengo flujos de potencia entre barras
            resultado.(flujoP1)(i)=P_s(1);
            resultado.(flujoQ1)(i)=Q_s(1);
            resultado.(flujoP2)(i)=P_s(2);
            resultado.(flujoQ2)(i)=Q_s(2);
            resultado.(flujoP3)(i)=P_s(3);
            resultado.(flujoQ3)(i)=Q_s(3);
            resultado.V_TCA_SFCR_V(i)=DAE.y(TCASFCRIndex+Bus.n);
            resultado.deltaVTCA_SFCR_grad(i)=DAE.y(TCASFCRIndex);
            resultado.Pgen_SF_Kw(i)=PCA_inv;
            resultado.Qgen_SF_Kvar(i)=QCA_inv;             
            resultado.status_SF_bol(i)=1;
            resultado.V_TS5_V(i)=DAE.y(TS5Index+Bus.n);
            resultado.deltaVTS5_grad(i)=DAE.y(TS5Index);            
            resultado.V_TS1_V(i)=DAE.y(TS1Index+Bus.n);
            resultado.deltaVTS1_grad(i)=DAE.y(TS1Index);
            resultado.V_TG_V(i)=DAE.y(TGIndex+Bus.n);
            resultado.deltaVTG_grad(i)=DAE.y(TGIndex);
            resultado.P_genTG_Kw(i)=Snapshot.Pg(TGIndex);
            resultado.Q_genTG_Kvar(i)=Snapshot.Qg(TGIndex);
            resultado.Ploss_tot_Kw(i)=Snapshot.Ploss;
            resultado.Qloss_tot_Kvar(i)=Snapshot.Qloss;
            i=i+1;            

        elseif DAE.y(TCASFCRIndex+Bus.n)<Vmin || DAE.y(TCASFCRIndex+Bus.n)>Vmax %indices pasan por valor
            % si las tensiones estan fuera de margen con SF conectado => lo
            % desconecto, recalculo pf y guardo.
            %% status_SF_bol tiene 3 valores: 
            %% 1: SFCRconectado, 
            %% 0:SFCR desconctado, 
            %% -1= SFCR desconectado, pero en zona de incertidumbre
            %% actualizo estado de la red
            SW.store(SLACKIndex,4)=(VTG(i)*1E-3)/Vbase;  % actualizo voltage en slack 
%             %carga TCASFCR
%             PQ.store(PQTCAIndex,4)=(PTCASFCR(i)*1E-3)/Pbase;
%             PQ.store(PQTCAIndex,5)=(QTCASFCR(i)*1E-3)/Pbase;
            %carga TS5
            PQ.store(PQTS5Index,4)=(PTS5(i)*1E-3)/Pbase;
            PQ.store(PQTS5Index,5)=(QTS5(i)*1E-3)/Pbase;
            % carga TS1
            PQ.store(PQTS1Index,4)=(PTS1(i)*1E-3)/Pbase;
            PQ.store(PQTS1Index,5)=(QTS1(i)*1E-3)/Pbase;        
            % carga TG
            PQ.store(PQTGIndex,4)=(PTG(i)*1E-3)/Pbase;
            PQ.store(PQTGIndex,5)=(QTG(i)*1E-3)/Pbase;
            % generacion FV
            PdemandTCA=(PTCASFCR(i)*1E-3)/Pbase;
            QdemandTCA=(QTCASFCR(i)*1E-3)/Pbase;        
            PQgen.store(SFCRIndex,4)=(0.0-PdemandTCA);  % actualizo barra SF 
            PQgen.store(SFCRIndex,5)=(0.0-QdemandTCA);  % actualizo barra SF,principio de Pprog=Pg-Pd   
            runpsat('pf');
            %% obtengo flujos de potencia entre barras            
            [P_s,Q_s,P_r,Q_r,fr_bus,to_bus] = fm_flows('bus'); % obtengo flujos de potencia entre barras
            resultado.(flujoP1)(i)=P_s(1);
            resultado.(flujoQ1)(i)=Q_s(1);
            resultado.(flujoP2)(i)=P_s(2);
            resultado.(flujoQ2)(i)=Q_s(2);
            resultado.(flujoP3)(i)=P_s(3);
            resultado.(flujoQ3)(i)=Q_s(3); 

            resultado.V_TCA_SFCR_V(i)=DAE.y(TCASFCRIndex+Bus.n);
            resultado.deltaVTCA_SFCR_grad(i)=DAE.y(TCASFCRIndex);
            resultado.Pgen_SF_Kw(i)=0.0;
            resultado.Qgen_SF_Kvar(i)=0.0;             
            resultado.V_TS5_V(i)=DAE.y(TS5Index+Bus.n);
            resultado.deltaVTS5_grad(i)=DAE.y(TS5Index);             
            resultado.V_TS1_V(i)=DAE.y(TS1Index+Bus.n);
            resultado.deltaVTS1_grad(i)=DAE.y(TS1Index);
            resultado.V_TG_V(i)=DAE.y(TGIndex+Bus.n);
            resultado.deltaVTG_grad(i)=DAE.y(TGIndex);
            resultado.P_genTG_Kw(i)=Snapshot.Pg(TGIndex);
            resultado.Q_genTG_Kvar(i)=Snapshot.Qg(TGIndex);
            resultado.Ploss_tot_Kw(i)=Snapshot.Ploss;
            resultado.Qloss_tot_Kvar(i)=Snapshot.Qloss;  
            
            if DAE.y(TCASFCRIndex+Bus.n)>Vmin && DAE.y(TCASFCRIndex+Bus.n)<Vmax %primero van las fases y despues los modulos en DAE.y pasan pro valor            
                resultado.status_SF_bol(i)=-1;               % si la tension en la barra vuelve a estar en los limites permisibles ,pero sin SFCR
            else resultado.status_SF_bol(i)=0;          % si la tension en la barra sigue estando fuera de los limites permisibles sin SFCR.
            end  
                
            i=i+1;            
            
        else
            resultado.V_TCA_SFCR_V(i)='Err';
            resultado.deltaVTCA_SFCR_grad(i)='Err';
            resultado.Pgen_SF_Kw(i)='Err';
            resultado.Qgen_SF_Kvar(i)='Err';             
            resultado.status_SF_bol(i)='Err';
            resultado.V_TS5_V(i)='Err';
            resultado.deltaVTS5_grad(i)='Err';            
            resultado.V_TS1_V(i)='Err';
            resultado.deltaVTS1_grad(i)='Err';
            resultado.V_TG_V(i)='Err';
            resultado.deltaVTG_grad(i)='Err';
            resultado.P_genTG_Kw(i)='Err';
            resultado.Q_genTG_Kvar(i)='Err';
            resultado.Ploss_tot_Kw(i)='Err';
            resultado.Qloss_tot_Kvar(i)='Err';
            resultado.(flujoP1)(i)='Err';
            resultado.(flujoQ1)(i)='Err';
            resultado.(flujoP2)(i)='Err';
            resultado.(flujoQ2)(i)='Err';
            resultado.(flujoP3)(i)='Err';
            resultado.(flujoQ3)(i)='Err';            
            'ERROR, en recalculo'
            i=i+1;
        end
    end
    %% Cambio unidades en datos de resultado
            resultado.Tiempo_horas=((1:length(G))*HorasEstudio/length(G))';
            resultado.V_TCA_SFCR_V=(resultado.V_TCA_SFCR_V*Vbase*1E3)'; %de pu a V
            resultado.deltaVTCA_SFCR_grad=(resultado.deltaVTCA_SFCR_grad*(180/pi))'; %de rad a grad
            resultado.Pgen_SF_Kw=(resultado.Pgen_SF_Kw*1E-3)'; % de W a kW
            resultado.Qgen_SF_Kvar=(resultado.Qgen_SF_Kvar*1E-3)'; % de Var a kVAr            
            resultado.status_SF_bol=(resultado.status_SF_bol)';
            resultado.V_TS5_V=(resultado.V_TS5_V*Vbase*1E3)'; %de pu a V;
            resultado.deltaVTS5_grad=(resultado.deltaVTS5_grad*(180/pi))'; %de rad a grad;            
            resultado.V_TS1_V=(resultado.V_TS1_V*Vbase*1E3)'; %de pu a V;
            resultado.deltaVTS1_grad=(resultado.deltaVTS1_grad*(180/pi))'; %de rad a grad;
            resultado.V_TG_V=(resultado.V_TG_V*Vbase*1E3)'; %de pu a V;;
            resultado.deltaVTG_grad=(resultado.deltaVTG_grad*(180/pi))'; %de rad a grad;
            resultado.P_genTG_Kw=(resultado.P_genTG_Kw*Pbase*1E3)'; % de pu a Kw
            resultado.Q_genTG_Kvar=(resultado.Q_genTG_Kvar*Pbase*1E3)'; % de pu a Kw;
            resultado.Ploss_tot_Kw=(resultado.Ploss_tot_Kw*Pbase*1E3)'; % de pu a Kw;
            resultado.Qloss_tot_Kvar=(resultado.Qloss_tot_Kvar*Pbase*1E3)'; % de pu a Kw;
            resultado.(flujoP1)=(resultado.(flujoP1)*Pbase*1E3)';
            resultado.(flujoQ1)=(resultado.(flujoQ1)*Pbase*1E3)';
            resultado.(flujoP2)=(resultado.(flujoP2)*Pbase*1E3)';
            resultado.(flujoQ2)=(resultado.(flujoQ2)*Pbase*1E3)';
            resultado.(flujoP3)=(resultado.(flujoP3)*Pbase*1E3)';
            resultado.(flujoQ3)=(resultado.(flujoQ3)*Pbase*1E3)';            
            IsResultado=true;

       delete(h)       % DELETE the waitbar; don't try to CLOSE it.         
  
end
