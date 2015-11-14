function [ObjFun] = objFun(pmt,putil,statusMT)
    
    stp = 3600;
    cmt = 0.36; % ($/m^3)
    fmt = 0.0009; % (m^3/Wh)
    dt = 1; % time stp, the optimazation is updated every time stp (h)
    koc = 0.006*10^(-3); % ($/Wh)
    hot_startup = 30; %sec
    cold_startup = 200; %sec
    cooling_time = 520; %sec
    toff=0;% counting the times turned off
    scmt = ( ( hot_startup / stp ) + ( cold_startup / stp ) * (1 - exp ( - toff / (cooling_time/stp) )) ) * (1 - statusMT); %scmt   
    cutil = 0.1*10^(-3);
    ommt = koc *  pmt * dt;% ($)
    %% COST FUNCTION MT
    Fmt = cmt * fmt *  pmt * dt + ommt + scmt; % ($) COST FUNCTION MICROTURBINE
    %% UTILITY
    Futility = cutil * putil;
    %% OBJECTIVE FUNCTION
    ObjFun =  sum(Futility +  Fmt);
end