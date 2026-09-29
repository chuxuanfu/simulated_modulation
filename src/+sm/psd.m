function [f,p] = psd(x,fs,nfft)
% Two-sided Welch PSD, amplitude^2/Hz; no Signal Processing Toolbox needed.
x = x(:); validateattributes(fs,{'numeric'},{'scalar','positive','finite'});
if nargin<3, nfft=min(4096,2^floor(log2(numel(x)))); end
assert(nfft>=2 && numel(x)>=nfft,'Need at least one complete FFT window.');
win = 0.5-0.5*cos(2*pi*(0:nfft-1).'/nfft); step=max(1,floor(nfft/2));
p = zeros(nfft,1); count=0;
for first = 1:step:numel(x)-nfft+1
    z = fft(x(first:first+nfft-1).*win,nfft);
    p = p+abs(z).^2/(fs*sum(win.^2)); count=count+1;
end
p = fftshift(p/count); f = (-floor(nfft/2):ceil(nfft/2)-1).'*fs/nfft;
end
