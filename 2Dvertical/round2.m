function z = round2(x,y)
%ROUND2 rounds number to nearest multiple of arbitrary precision.
%   >> round2(pi,5)
%   ans =
%         5 
%
% See also ROUND.

%% defensive programming
error(nargchk(2,2,nargin))
error(nargoutchk(0,1,nargout))
if numel(y)>1
  error('Y must be scalar')
end

z = round(x/y)*y;
if z < x
    z = z +5;
end
end
