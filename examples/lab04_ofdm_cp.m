function r = lab04_ofdm_cp()
p=sm.defaultConfig('ofdm'); w=sm.generate(p); x=w.iq;
short=[1;zeros(7,1);0.35*exp(1i*0.5)]; long=[1;zeros(47,1);0.35*exp(1i*0.5)];
hs={short,long}; ev=zeros(1,2);
fig=figure('Visible','off','Color','w');
for k=1:2
    y=filter(hs{k},1,x); z=sm.ofdmDemodulate(y,p.Nfft,p.Ncp,p.ActiveSubcarriers,false);
    H=fftshift(fft(hs{k},p.Nfft)); H=H(p.ActiveSubcarriers+p.Nfft/2+1);
    z=z./H(:); % Perfect channel known. CP alone does NOT equalize the channel.
    ref=w.details.Symbols(:,2:end); recovered=z(:,2:end);
    e=sm.evm(recovered(:),ref(:),false); ev(k)=e.RMSPercent;
    subplot(1,2,k); plot(real(recovered(:)),imag(recovered(:)),'.'); axis equal; title(sprintf('Max delay %d, EVM %.3g%%',numel(hs{k})-1,ev(k)));
end
assert(ev(1)<1e-9 && ev(2)>1,'CP sufficiency test failed.');
sm.saveFigure(fig,'lab04_cp'); r=struct('CPsamples',p.Ncp,'EVMPercent',ev); disp(r);
end
