%ems.m
clear all;
close all;
clc;
%% INPUTS
pso_flag = 1;
swarm_size = 50;
perms = 81;
% row=53
%% VARS
for row = 1 : perms
    num = xlsread('Data');
    BATTpmax = num(row,1);
    BATTpmin = num(row,2);
    PVpmax = num(row,3);
    WTpmax = num(row,4);
    MTpmax = num(row,5);

    %% INIALIZE TIME STEPS AND AC BUS
    stp = 3600;
    pertime = 24;
    totalTime = pertime*1; % total hours simulation
    totalUnits = 5;
    p_bus = zeros(totalUnits,totalTime);
    index_GenMT = 1;
    index_GenPV = 2;
    index_GenWT = 3;
    index_GenBTR = 4;
    index_Load = 5;
    index_Util = 6;
    zeros24(1:pertime) = 0.5;

    %% MICROURBINE PARAMETERS FOR EMS
    pMTmax = 20*10^3;
    cmt = 0.3571; % ($/m^3)
    fmt = 0.0085; % (m^3/Wh)
    dt = 1; % time stp, the optimazation is updated every time stp (h)
    koc = 0.0587; % ($/Wh)
    hot_startup = 30; %sec
    cold_startup = 200; %sec
    cooling_time = 520; %sec
    mut = 600;% minimum up time (sec)
    mdt = 300;% minimum down time (sec)
    ton=0;% counting the times turned on
    toff=0;% counting the times turned off
    statusMT=ones(1,pertime);

    %% WIND TURBINE PARAMETERS FOR EMS
    Cwt = 0.0001;% $0.1/Wh
    statusWT=ones(1,totalTime);

    %% BATTTERY PARAMETERS FOR EMS
    soc = zeros(1,totalTime);
    soc(1,:) = 0.5; %initialize battery's sate of charge to 50%
    statusBTR=ones(1,totalTime);
    minchargpwr = 1000;
    maxchargpwr = 16000;
    effBTR = 0.9;
    %% PV array PARAMETERS FOR EMS
    Cpv = 0.2;% $0.2/kWh

    %% LOAD PARAMETERS FOR EMS
    powerDemandmin = 150*10^3;
    powerDemandmax = 300*10^3;

    %% UTILITY
    cutil = 1.05;
    counterDisp=0;
    util = zeros(1,totalTime);
    stp_time =0;
    irrad = zeros(totalTime);
    tempr = zeros(totalTime);
    vwind = zeros(totalTime);
    p_min=zeros(3,pertime);
    gb_mt=zeros(1,pertime);
    gb_batt=zeros(1,pertime);
    gb_util=zeros(1,pertime);

    for i=1:totalTime
        %% LOAD DEMAND
        stp_time=stp_time+1;

        if(stp_time<=pertime)
            if (stp_time==1 || stp_time==8 || stp_time==9 || stp_time==16 || stp_time==17 || stp_time==24)
                p_bus(index_Load,i) = 30000;
            elseif (stp_time==11 || stp_time==12 || stp_time==15 || stp_time==18 || stp_time==19 || stp_time==23)
                p_bus(index_Load,i) = 60000;
            elseif (stp_time==10)
                p_bus(index_Load,i) = 90000;
            elseif (stp_time==21 || stp_time==22)
                p_bus(index_Load,i) = 150000;
            elseif (stp_time==14 || stp_time==20)
                p_bus(index_Load,i) = 210000;
            elseif (stp_time==13)
                p_bus(index_Load,i) = 300000;
            else
                p_bus(index_Load,i) = 3000;
            end
        else
            if (mod(stp_time,pertime)==1 || mod(stp_time,pertime)==8 || mod(stp_time,pertime)==9 || mod(stp_time,pertime)==16 || mod(stp_time,pertime)==17 || mod(stp_time,pertime)==24)
                p_bus(index_Load,i) = 30000;
            elseif (mod(stp_time,pertime)==11 || mod(stp_time,pertime)==12 || mod(stp_time,pertime)==15 || mod(stp_time,pertime)==18 || mod(stp_time,pertime)==19 || mod(stp_time,pertime)==23)
                p_bus(index_Load,i) = 60000;
            elseif (mod(stp_time,pertime)==10)
                p_bus(index_Load,i) = 90000;
            elseif (mod(stp_time,pertime)==21 || mod(stp_time,pertime)==22)
                p_bus(index_Load,i) = 150000;
            elseif (mod(stp_time,pertime)==14 || mod(stp_time,pertime)==20)
                p_bus(index_Load,i) = 210000;
            elseif (mod(stp_time,pertime)==13)
                p_bus(index_Load,i) = 300000;
            else
                p_bus(index_Load,i) = 3000;
            end
        end

        %% CONSTRAINTS MT
        if( ton >= mut/stp )
            statusMT(i) = 0;
        end

        if( toff >= mdt/stp )
            statusMT(i) = 1;
        end

        if( statusMT(i) == 0 )
            ton=0;
            toff=toff+1;
            if(i<length(statusMT))
                statusMT(i+1)=0;
            end
        else
            toff = 0;
            ton = ton+1;
            if(i<length(statusMT))
                statusMT(i+1)=1;
            end
        end

        %% POWER GENERATORS (RES) 
%         irrad(i) = 0.4;
%         tempr(i) = 25 ;
%         vwind(i) = 23;
        irrad(i) = rand();
        tempr(i) = 25 + (75-25).*rand();
        vwind(i) = 10 + (28-10).*rand();
        p_bus(index_GenWT,i) = windturbine(vwind(i),statusWT(i),WTpmax);
        if(mod(stp_time,pertime)<=19 && mod(stp_time,pertime)>=7)
            p_bus(index_GenPV,i) = pv_array(irrad(i),tempr(i),PVpmax);
        end

        if(mod(stp_time,pertime)==0)
            if(pso_flag==1)
                soc_tmp=soc;
                %% INITIALIZE POPULATION
                [ DV, putil, soc_ ] = init_swarms(p_bus(index_GenWT,i-pertime+1:i),p_bus(index_GenPV,i-pertime+1:i),p_bus(index_Load,i-pertime+1:i),soc(i-pertime+1:i),statusMT(i-pertime+1:i), BATTpmax, BATTpmin, MTpmax,swarm_size);
                %% PSO
                [final_global_best,ind, gbest, val, swarm, bestval, gb_mt, gb_batt, gb_util, soc] = pso(DV, putil, p_bus(index_Load,i-pertime+1:i), p_bus(index_GenPV,i-pertime+1:i), p_bus(index_GenWT,i-pertime+1:i), soc_, statusMT(i-pertime+1:i),BATTpmax, BATTpmin, MTpmax,swarm_size);
                p_bus(index_GenMT,i-pertime+1:i) = gb_mt(1:pertime);
                p_bus(index_GenBTR,i-pertime+1:i) = gb_batt(1:pertime);
                p_bus(index_Util,i-pertime+1:i) = gb_util(1:pertime);

                soc_tmp(i-pertime+1:i) = soc;
                soc = soc_tmp;

                h=figure;
                set(gcf,'Visible','off');
                plot(gbest)
                xlabel('Generations')
                ylabel('Cost($)')
                grid on
                title('PSO')

                baseFileName =  sprintf('%d_%d_%d_%d.jpg', BATTpmax, PVpmax, WTpmax, MTpmax);
                saveas(h, baseFileName );            
            else
                %% EXHAUSTIVE SEARCH   

                [array,minopt,opt,soc,putil] = exhaustive(p_bus(index_GenWT,i-pertime+1:i),p_bus(index_GenPV,i-pertime+1:i),p_bus(index_Load,i-pertime+1:i),soc(i-pertime+1:i),statusMT(i-pertime+1:i),BATTpmax,BATTpmin);
                p_bus(index_GenMT,i-pertime+1:i) = array(pertime+1 : 2*pertime);
                p_bus(index_GenBTR,i-pertime+1:i) = array(1:pertime);
                p_bus(index_Util,i-pertime+1:i) = putil(1:pertime);

                figure()
                plot(minopt)
                xlabel('Permutations')
                ylabel('Cost($)')
                grid on
                title('EXHAUSTIVE not for all permutations')
            end
        end
    end
    baseFileName =  sprintf('%d_%d_%d_%d_DATA.xls', BATTpmax, PVpmax, WTpmax, MTpmax);
    FileName = sprintf('%d_%d_%d_%d_DATA', BATTpmax, PVpmax, WTpmax, MTpmax);
    xlswrite(baseFileName,p_bus)
    
    range = sprintf('F%d',row+1);
    xlswrite('Data',roundsd(final_global_best,3),'ArrayEMS',range);
    if(mod(row,10)==0)  
        plot_from_excel(FileName);
    end
end