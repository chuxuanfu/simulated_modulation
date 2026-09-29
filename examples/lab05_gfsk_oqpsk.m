function r = lab05_gfsk_oqpsk()
g=sm.generate(sm.defaultConfig('gfsk')); q=sm.generate(sm.defaultConfig('oqpsk'));
sm.plotWaveform(g,fullfile(sm.root(),'reports','lab05_gfsk.png'));
sm.plotWaveform(q,fullfile(sm.root(),'reports','lab05_oqpsk.png'));
r=struct('GFSKEnvelopeError',max(abs(abs(g.iq)-1)), ...
    'OQPSKInteriorEnvelopeError',max(abs(abs(q.iq(17:end-16))-1)));
assert(r.GFSKEnvelopeError<1e-12 && r.OQPSKInteriorEnvelopeError<1e-12); disp(r);
end
