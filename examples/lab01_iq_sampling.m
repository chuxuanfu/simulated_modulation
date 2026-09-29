function r = lab01_iq_sampling()
% Positive complex exponential must appear at POSITIVE baseband frequency.
fs=1e6; N=4096; f0=125e3; t=(0:N-1).'/fs; x=exp(1i*2*pi*f0*t);
[f,p]=sm.psd(x,fs,1024); [~,j]=max(p);
assert(abs(f(j)-f0)<fs/1024,'I/Q sign or FFT shift error.');
xAlias=exp(1i*2*pi*(f0+fs)*t);
assert(max(abs(x-xAlias))<1e-8,'Aliasing identity failed.');
fig=figure('Visible','off','Color','w');
subplot(2,1,1); plot(t(1:64)*1e6,[real(x(1:64)) imag(x(1:64))]); legend('I','Q'); xlabel('us');
subplot(2,1,2); plot(f/1e3,10*log10(max(p,realmin))); xlabel('kHz'); ylabel('PSD dB'); grid on;
sm.saveFigure(fig,'lab01_iq');
r=struct('PeakHz',f(j),'AliasingMaxError',max(abs(x-xAlias))); disp(r);
end
