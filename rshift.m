function y=rshift(x,dir)
% Usage: y=rshift(x,dir)
% rotate x vector to right (down) by 1 if dir = 0 (default)
% or rotate x to left (up) by 1 if dir = 1
% (C) 2001 by Yu Hen Hu
% created: 12/1/2001

if nargin<2, dir=0; end

[m,n]=size(x);

if m > 1,
   if n == 1, 
      col=1; 
   elseif n > 1,
      error('x must be a vector! break');
   end % x is a column vector
elseif m == 1, 
   if n == 1, 
      y=x; return
   elseif n > 1,
      col=0; % x is a row vector
   end
end

if dir==1,  % rotate left or up
   if col==0, % row vector, rotate left
      y = [x(2:n) x(1)];
   elseif col==1,
      y = [x(2:n); x(1)]; % rotate up
   end
elseif dir==0, % default rotate right or down 
   if col==0, 
      y = [x(n) x(1:n-1)];
   elseif col==1 % column vector
      y = [x(n); x(1:n-1)];
   end
end

   