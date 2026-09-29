function r = lab07_wifi_receive()
% Packet timing is known. This is a PHY loopback, not an RF acquisition chain.
p=sm.defaultConfig('wifi_nonht'); p.NumPackets=1; p.IdleTimeSec=0;
w=sm.generate(p); c=w.details.PHYConfig;
ind=wlanFieldIndices(c); ltf=w.iq(ind.LLTF(1):ind.LLTF(2),:);
h=wlanLLTFChannelEstimate(wlanLLTFDemodulate(ltf,c),c);
y=w.iq(ind.NonHTData(1):ind.NonHTData(2),:);
[bits,eq]=wlanNonHTDataRecover(y,h,1e-10,c);
r=struct('BitErrors',sum(double(bits(:))~=double(w.details.Bits(:))),'NumBits',numel(bits));
assert(r.BitErrors==0,'Noiseless WLAN loopback failed.');
fig=figure('Visible','off','Color','w'); plot(real(eq(:)),imag(eq(:)),'.'); axis equal; title('Recovered non-HT data symbols');
sm.saveFigure(fig,'lab07_wifi'); disp(r);
end
