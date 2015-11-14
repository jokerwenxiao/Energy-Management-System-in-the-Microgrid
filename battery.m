function [soc pout] = battery( pbnew, pbold, pbmax)

    nb=0.9;     %efficiency
	dT=1;       %1 hour
	Vb=12;      %inital Voltage
	Ahinit=25;  %inital Ampere-hours
    
    K = pbmax/(Vb*Ahinit*dT/nb);% total batteries
	
    Ahinit= Ahinit*K;
	
    Ah_cur_con = (pbnew/pbmax)*Ahinit;
    
    Ah_con = (sum(pbold)/pbmax)*Ahinit;
    
	Ah_remain = (Ahinit)-Ah_con;
    
    soc = (Ah_remain-Ah_cur_con)/(Ahinit);
    	
	pout(soc>=0) = (Vb*(Ah_cur_con));
    
    pout(soc>1) = -(Vb*(Ah_con));
    
    pout(soc<0) = 0;
    
    soc(soc<0) = (Ah_remain)/(Ahinit);
    
    soc(soc>1) = 1;
end