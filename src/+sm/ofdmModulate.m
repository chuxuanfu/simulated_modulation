function [x,grid] = ofdmModulate(symbols,nfft,ncp,active,spread)
if nargin<5, spread=false; end
validateattributes(nfft,{'numeric'},{'scalar','integer','positive','even'});
validateattributes(ncp,{'numeric'},{'scalar','integer','>=',0,'<=',nfft});
active = active(:); assert(numel(unique(active))==numel(active),'Duplicate carriers.');
assert(all(active>=-nfft/2 & active<nfft/2 & active==fix(active)),'Invalid carrier index.');
assert(size(symbols,1)==numel(active),'One row per active subcarrier required.');
if spread, symbols = fft(symbols,[],1)/sqrt(numel(active)); end
grid = zeros(nfft,size(symbols,2)); grid(active+nfft/2+1,:) = symbols;
x = ifft(ifftshift(grid,1),[],1)*sqrt(nfft);
x = [x(end-ncp+1:end,:);x]; x = x(:);
end
