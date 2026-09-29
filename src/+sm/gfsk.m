function [x,freqHz] = gfsk(bits,rb,sps,bt,hIndex)
% Offline centered Gaussian filter, finite 4-symbol span; educational GFSK.
validateattributes(bt,{'numeric'},{'scalar','positive','finite'});
validateattributes(hIndex,{'numeric'},{'scalar','positive','finite'});
validateattributes(sps,{'numeric'},{'scalar','integer','>=',2});
t = (-2*sps:2*sps).'/sps;
g = exp(-2*(pi*bt*t).^2/log(2)); g = g/sum(g);
nrz = repelem(2*double(bits(:))-1,sps);
freqHz = hIndex*rb/2*conv(nrz,g,'same');
x = exp(1i*2*pi*cumsum(freqHz)/(rb*sps));
end
