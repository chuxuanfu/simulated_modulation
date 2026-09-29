function h = rrc(beta,span,sps)
% Unit-energy root-raised-cosine pulse; delay = span*sps/2 samples.
validateattributes(beta,{'numeric'},{'scalar','>',0,'<=',1});
validateattributes(span,{'numeric'},{'scalar','integer','positive'});
validateattributes(sps,{'numeric'},{'scalar','integer','>=',2});
assert(mod(span*sps,2)==0,'span*sps must be even.');
t = (-span*sps/2:span*sps/2).'/sps;
h = zeros(size(t));
for k = 1:numel(t)
    x = t(k);
    if abs(x)<1e-12
        h(k) = 1+beta*(4/pi-1);
    elseif abs(abs(x)-1/(4*beta))<1e-10
        h(k) = beta/sqrt(2)*((1+2/pi)*sin(pi/(4*beta))+(1-2/pi)*cos(pi/(4*beta)));
    else
        h(k) = (sin(pi*x*(1-beta))+4*beta*x*cos(pi*x*(1+beta)))/(pi*x*(1-(4*beta*x)^2));
    end
end
h = h/sqrt(sum(abs(h).^2));
end
