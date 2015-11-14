function [ pout emission ] = microturbine(p,status,prated)
    %% Pout and Emission
    emissionSO2 = 720/10^6; % kg/Wh
    emissionCO2 = 0.0036/10^6;
    emissionNOx = 0.1/10^6;
    
    if(status==1)
        pout(p>prated) = prated;
        pout(p<=prated && p>=0)=p;
    else
        pout = 0;
    end

    emission = (emissionSO2 + emissionCO2 + emissionNOx) * pout;
end