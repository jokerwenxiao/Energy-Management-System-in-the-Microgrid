function [soc pout] = batt( pbnew, pbold, pbmax)
	
    nb = 0.9;
    dT = 1/60; 
    Vb = 12; % constant voltage
    Ahinit = (pbmax*25)/20000; % 25Ah -> SOC = 100%
    pb_avail_max = (Vb*Ahinit) / (nb*dT) ;  

    pbold(pbold==inf) = 0;
        
    if(pbnew>=0)
        if(pbnew+sum(pbold)>pb_avail_max)
            Ahold = ((nb * dT) / Vb) * pbold;

            Ahnew = Ahinit - sum(Ahold);

            pbnew = Ahnew / ( (nb * dT) / Vb );

            pout = nb * pbnew;

            sumAhold = sum(Ahold);

            soc = ( Ahinit - sumAhold - Ahnew) / Ahinit;
        else
            pout = nb * pbnew;

            Ahold = ((nb * dT) / Vb) * pbold;

            Ahnew = ((nb * dT) / Vb) * pbnew;

            sumAhold = sum(Ahold);

            soc = ( Ahinit - sumAhold - Ahnew) / Ahinit;
        end
    else
        if(abs(pbnew) < sum(pbold))
            pout = nb * pbnew;

            Ahold = ((nb * dT) / Vb) * pbold;

            Ahnew = ((nb * dT) / Vb) * pout;

            sumAhold = sum(Ahold);

            soc = ( Ahinit - sumAhold - Ahnew) / Ahinit ;
        else
            pout = -sum(pbold);

            Ahold = ((nb * dT) / Vb) * pbold;

            Ahnew = ((nb * dT) / Vb) * pout;

            sumAhold = sum(Ahold);

            soc = ( Ahinit - sumAhold - Ahnew) / Ahinit; 
        end
    end
end