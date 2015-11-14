function p = pv_array(Irrad,Tempr,prated)
    %% Initialize
    clc;
    close all;
    p=0;
    
    totalPanels = (40*prated)/20000;
    
    totalCells = 172;
    
    Vcell  = 0:0.01:0.665; % voltage vector??

    Ppv = zeros(totalPanels,length(Vcell));
    
    Tempr(1:totalPanels) = Tempr;
    Irrad(1:totalPanels) = Irrad;
    
    cc=hsv(totalPanels);
    
    %% Panels Computation
    for i=1:totalPanels
        Pcell(i,:) = Vcell .*  solarcell( Vcell ,  Irrad(i) , Tempr(i));
        
        Ppv(i,:) = totalCells * Pcell(i,:);
        
        pmax(i) = max(Ppv(i,:));
        
        p=p+dc_ac_pv( pmax(i) );
    end
end