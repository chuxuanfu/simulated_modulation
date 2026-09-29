function r = lab02_constellation_rrc()
p=sm.defaultConfig('basic'); p.Modulation='16QAM'; w=sm.generate(p);
z=conv(w.iq,w.details.Pulse,'full'); delay=numel(w.details.Pulse)-1;
indices=delay+1+(0:p.NumSymbols-1)*p.SamplesPerSymbol;
s=z(indices); s=s(:); bits=sm.symbolsToBits(s,p.Modulation);
e=sm.evm(s,w.details.Symbols,false);
r=struct('BER',mean(bits~=w.details.Bits),'RMS_EVM_Percent',e.RMSPercent,'CombinedFilterDelaySamples',delay);
assert(r.BER==0,'Noiseless matched-filter BER must be zero.');
fig=figure('Visible','off','Color','w');
subplot(1,2,1); plot(real(w.iq(1:4000)),imag(w.iq(1:4000)),'.'); axis equal; title('All time samples');
subplot(1,2,2); plot(real(s),imag(s),'.'); axis equal; title('Matched filter + symbol timing');
sm.saveFigure(fig,'lab02_rrc'); disp(r);
end
