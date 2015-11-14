function [DV,putil,soc_] = init_swarms(pwt, ppv, pload, soc, status, BATTpmax, BATTpmin, MTpmax,swarm_size)

    range_max_pbatt = BATTpmax;
    chrpwr_min = BATTpmin;
    range_max_mt = MTpmax;

    range_min_pbatt = 0;    
    range_min_mt = 0;
    pwt_tmp = pwt;
    ppv_tmp = ppv;
    pload_tmp = pload;
    soc_tmp = soc;
    status_tmp = status;

    DV = zeros(swarm_size, 2*length(pwt_tmp));
    
    for i=1:swarm_size
        pwt(i,:) = pwt_tmp';
        ppv(i,:) = ppv_tmp';
        pload(i,:) = pload_tmp';
        status(i,:) = status_tmp';
        soc(i,:) = soc_tmp';

        r = rand(swarm_size,2*length(pwt_tmp));

        for j=1:length(pwt_tmp)
            if(soc(i,j)<=0.2)
                DV(i,j) = (chrpwr_min + ( soc(i,j).* range_min_pbatt - chrpwr_min  ).*r(i,j))';
            else
                DV(i,j) = (range_min_pbatt + ( soc(i,j).* range_max_pbatt - range_min_pbatt ).*r(i,j))';
            end
            
            if(j~=length(pwt_tmp))
                [soc(i,j+1) DV(i,j)] = battery(DV(i,j),DV(i,1:j-1),BATTpmax);
            end
            
            [DV(i,length(pwt_tmp)+j) ~] = microturbine((range_min_mt + ( range_max_mt - range_min_mt  ).*r(i,length(pwt_tmp)+j))',status(i,j), MTpmax);
        end
    end
    soc_=soc;

    putil = pload - (ppv + pwt + DV(:,(length(pwt_tmp)+1):2*length(pwt_tmp)) + DV(:,1:length(pwt_tmp)));
%     putil(putil<0) = 0; % uncomment to just buy not sell
%     putil(putil>=0) = 0; % uncomment the current and the above line to
%     just not buy not sell
end