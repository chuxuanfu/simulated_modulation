function r = lab11_papr_dftspread()
p=sm.defaultConfig('ofdm'); p.Modulation='QPSK'; p.NumSymbols=500;
a=sm.generate(p); p.TransformPrecoding=true; b=sm.generate(p);
ma=sm.metrics(a.iq,a.fs); mb=sm.metrics(b.iq,b.fs);
fig=figure('Visible','off','Color','w');
for x={a.iq,b.iq}
    z=abs(x{1}).^2/mean(abs(x{1}).^2); z=sort(z);
    survival=(numel(z):-1:1).'/numel(z); semilogy(10*log10(z),survival); hold on;
end
grid on; xlabel('Instantaneous power / mean (dB)'); ylabel('Empirical CCDF'); legend('CP-OFDM','DFT-s-OFDM');
sm.saveFigure(fig,'lab11_papr');
r=struct('OFDM_PAPR_dB',ma.PAPR_dB,'DFTspread_PAPR_dB',mb.PAPR_dB, ...
    'Note','Sampled PAPR, no oversampling; one realization, not a universal bound.'); disp(r);
end
