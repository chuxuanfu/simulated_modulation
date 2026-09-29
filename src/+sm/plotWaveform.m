function fig = plotWaveform(w,filename)
% Scatter is time samples, intentionally NOT called a demodulated constellation.
x=w.iq(:,1); fs=w.fs; n=numel(x); viewN=min(n,2000);
fig=figure('Visible','off','Color','w','Position',[100 100 1300 950]);
cleanup=onCleanup(@() close(fig)); %#ok<NASGU>
subplot(3,2,1); t=(0:viewN-1).'/fs*1e6;
plot(t,[real(x(1:viewN)) imag(x(1:viewN))]); xlabel('Time (us)'); ylabel('Amplitude'); legend('I','Q'); title(w.meta.Protocol,'Interpreter','none'); grid on;
subplot(3,2,2); stride=max(1,ceil(n/10000)); idx=1:stride:n;
plot((idx-1)/fs*1e3,abs(x(idx))); xlabel('Time (ms)'); ylabel('|IQ|'); title('Envelope (display decimated)'); grid on;
subplot(3,2,3); [f,p]=sm.psd(x,fs); plot(f/1e6,10*log10(max(p,realmin))); xlabel('Baseband frequency (MHz)'); ylabel('PSD (amplitude^2/Hz, dB)'); grid on;
subplot(3,2,4); plot(real(x(idx)),imag(x(idx)),'.','MarkerSize',3); axis equal; grid on;
xlabel('I'); ylabel('Q'); title('Time-sample scatter; NOT recovered symbols');
subplot(3,2,5); count=min(n,10000); z=x(1:count); inst=angle(z(2:end).*conj(z(1:end-1)))*fs/(2*pi);
mask=min(abs(z(2:end)),abs(z(1:end-1)))>max(abs(z))*0.05; inst(~mask)=NaN;
plot((1:count-1)/fs*1e6,inst/1e6); xlabel('Time (us)'); ylabel('Instantaneous frequency (MHz)'); grid on;
subplot(3,2,6); nf=min(256,2^floor(log2(n))); hop=max(1,floor(nf/2));
starts=1:hop:n-nf+1; starts=starts(1:max(1,ceil(numel(starts)/500)):end);
win=0.5-0.5*cos(2*pi*(0:nf-1).'/nf); sp=zeros(nf,numel(starts));
for k=1:numel(starts), sp(:,k)=abs(fftshift(fft(x(starts(k):starts(k)+nf-1).*win))).^2; end
imagesc((starts-1)/fs*1e3,(-nf/2:nf/2-1)*fs/nf/1e6,10*log10(max(sp,realmin))); axis xy;
xlabel('Time (ms)'); ylabel('Baseband frequency (MHz)'); title('Spectrogram (relative power)'); colorbar;
if nargin>1, exportgraphics(fig,filename,'Resolution',150); end
end
