function M = combn(V,N)

% error(nargchk(2,2,nargin)) ;
% 
% if isempty(V) || N == 0,
%     M = [] ;
%     IND = [] ;
% elseif fix(N) ~= N || N < 1 || numel(N) ~= 1 ;
%     error('combn:negativeN','Second argument should be a positive integer') ;
% elseif N==1,
%     % return column vectors
%     M = V(:) ; 
%     IND = (1:numel(V)).' ;
% else
%     % speed depends on the number of output arguments
%     if nargout<2,
%         M = local_allcomb(V,N) ;
%     else
%         % indices requested
%         IND = local_allcomb(1:numel(V),N) ;
%         M = V(IND) ;
%     end
% end
% 
% function Y = local_allcomb(X,N)
% % See ALLCOMB, available on the File Exchange
% if N>1
%     % create a list of all possible combinations of N elements
%     [Y{N:-1:1}] = ndgrid(X) ;
%     % concatenate into one matrix, reshape into 2D and flip columns
%     Y = reshape(cat(N+1,Y{:}),[],N) ;
% else
%     % no combinations have to be made
%     Y = X(:) ;
% end



%%% Previous algorithms



%% Combinations using for-loops

nv = length(V) ;

M = V(:) ; 

for q=1:nv^N
    
    for w=1:N
    
        M(q,w)= 0 ; % declaration
    
    end
    
end

for ii=1:N  
    
    cc = 1 ;
    
    for jj=1:(nv^(ii-1))
    
        for kk=1:nv
        
            for mm=1:(nv^(N-ii)),
            
                M(cc,ii) = V(kk) ;
                cc = cc + 1 ;
            
            end
            
        end
        
    end
    
end 



%% Version 3.2
%     % COMBN is very fast using a single matrix multiplication, without any
%       explicit for-loops. 
%     nV = numel(V) ;
%     % use a math trick
%     A = [0:nV^N-1]+(1/2) ;
%     B = [nV.^(1-N:0)] ;
%     IND = rem(floor((A(:) * B(:)')),nV) + 1 ;
%     M = V(IND) ;       

%% Version 2.0 
%     for i = N:-1:1
%         X = repmat(1:nV,nV^(N-i),nV^(i-1));
%         IND(:,i) = X(:);
%     end
%     M = V(IND) ;

%% Version 1.0
%     nV = numel(V) ;
%     % don waste space, if only one output is requested
%     [IND{1:N}] = ndgrid(1:nV) ;
%     IND = fliplr(reshape(cat(ndims(IND{1}),IND{:}),[],N)) ;
%     M = V(IND) ;