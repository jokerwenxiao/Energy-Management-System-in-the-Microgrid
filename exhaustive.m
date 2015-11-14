function [array,minopt,opt,soccc,putil] = exhaustive(pwt,ppv,pload,soc,status,prated,pmin)

    Pmt = 0 : prated/4 : prated;
    limit=1000;
    V=Pmt;
    N=24;
    nv = length(V) ;
    
    for q=1:nv^N
        for w=1:N
            if q>limit; break; end
            M(q,w)= 0 ; % declaration
        end
        if q>limit; break; end
    end

    for ii=1:N
        cc = 1 ;
        for jj=1:(nv^(ii-1))
            for kk=1:nv
                for mm=1:(nv^(N-ii))
                    if (status(ii)==1) || (status(ii)==0 && V(kk)==0)
                        M(cc,ii) = V(kk) ;
                    else
                        M(cc,ii) = inf ;    
                    end
                    cc = cc + 1 ;
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
    
    [M2,soccc] = exhaustive2(pwt,ppv,pload,soc,status,limit,prated,pmin);
    
    vect=zeros(size(M,1)*size(M2,1),2*size(M2,2));
    
    in=0;
    
    for r=1:size(M,1)
        for t=1:size(M2,1)
            in=in+1;
            vect(in,:) = [M2(t,:) M(r,:)];
        end
    end

    for f = 1:size(vect,1)
        putil = pload - (ppv + pwt + vect(f,1:size(vect,2)/2) + vect(f,size(vect,2)/2+1:size(vect,2)));
        opt(f) = objFun(vect(f,1:size(vect,2)/2),putil,status);
        [minopt(f) ind]= min(opt);
    end
    
    array(1:size(vect,2)/2) = vect(ind,1:size(vect,2)/2);
    array(size(vect,2)/2 + 1:size(vect,2)) = vect(ind,size(vect,2)/2 + 1:size(vect,2));
end