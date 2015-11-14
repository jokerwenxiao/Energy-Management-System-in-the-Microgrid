function [M,soc] = exhaustive2(pwt,ppv,pload,soc,status,limit,prated,pmin)

    Pbatt = pmin : prated/4 : prated;
    V=Pbatt;
    N=length(pwt);
    nv = length(V) ;
    maxPofSOC=prated;
    
    for q=1:nv^N
        for w=1:N
            if (q>limit); break; end
            M(q,w)= 0 ; % declaration
        end
        if (q>limit); break; end
    end

    for ii=1:N
        cc = 1 ;
        for jj=1:(nv^(ii-1))
            for kk=1:nv
                for mm=1:(nv^(N-ii))

                    if ii==N
                        if ( (soc(cc,N-1)<=0.2) && (V(kk)<0) ) || ( (soc(cc,N-1)>0.2) && (V(kk)>=0) )

                            [soc(cc,N) M(cc,ii)] = battery(V(kk),[maxPofSOC/2 M(cc,1:N-1)],prated);

                            if(soc(cc,N)>=soc(cc,1))
                                [soc(cc,N) M(cc,ii)] = battery(V(kk),[maxPofSOC/2 M(cc,1:N-1)],prated);
%                                 M(cc,ii) = V(kk)*0.9;
                                cc=cc+1;
                            else
                                M(cc,ii) = inf;
                                soc(cc,N)=inf;
                                cc=cc+1;
                            end
                        else
                            M(cc,ii) = inf;
                            soc(cc,N)=inf;
                            cc=cc+1;
                        end
                    else
                        if ii~=1
                            if ( (soc(cc,ii-1)<=0.2) && (V(kk)<0) ) || ( (soc(cc,ii-1)>0.2) && (V(kk)<=0) )
                                [soc(cc,ii) M(cc,ii)] = battery(V(kk),[maxPofSOC/2 M(cc,1:ii-1)],prated);
%                                 M(cc,ii) = V(kk)*0.9;
                            else
                                M(cc,ii) = inf;
                                soc(cc,N)=inf;
                                cc=cc+1;
                            end
                        else
                            [soc(cc,ii) M(cc,ii)] = battery(V(kk),[maxPofSOC/2 0],prated);
                            M(cc,ii) = V(kk)*0.9;
                        end

                        cc = cc + 1 ;
                    end
                    if(cc>limit); break; end
                end
                if(cc>limit); break; end
            end
            if(cc>limit); break; end
        end
    end

    vec = (M==inf);
    
    vec = sum(vec');
    
    ind_vec = find(vec==0);
    
    Mnew = zeros(length(ind_vec), N);
    
    for t=1:length(ind_vec)
        Mnew(t,:)=M(ind_vec(t),:);
    end
    
    M=Mnew;
    
    vec = (soc==inf);
    
    vec = sum(vec');
    
    ind_vec = find(vec==0);
    
    Mnew = zeros(length(ind_vec), N);
    
    for t=1:length(ind_vec)
        Mnew(t,:)=soc(ind_vec(t),:);
    end
    
    soc=Mnew;
    
    
end

    