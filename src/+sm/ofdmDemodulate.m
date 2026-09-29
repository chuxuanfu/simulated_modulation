function s = ofdmDemodulate(x,nfft,ncp,active,spread)
if nargin<5, spread=false; end
assert(mod(numel(x),nfft+ncp)==0,'Capture must contain complete OFDM symbols.');
x = reshape(x,nfft+ncp,[]); x = x(ncp+1:end,:);
g = fftshift(fft(x,[],1)/sqrt(nfft),1);
s = g(active(:)+nfft/2+1,:);
if spread, s = ifft(s,[],1)*sqrt(numel(active)); end
end
