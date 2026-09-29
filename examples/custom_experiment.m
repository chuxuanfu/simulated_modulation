function w = custom_experiment()
% Copy this function to customize one controlled experimental change at a time.
p=sm.configure('wifi_he',struct('BandwidthMHz',20,'MCS',4,'PayloadBytes',1024, ...
    'NumPackets',5,'CenterFrequencyHz',2.412e9));
clean=sm.generate(p); w=clean;
[w.iq,channelInfo]=sm.impair(clean.iq,clean.fs,struct('AddNoise',true,'SNRdB',25,'CFOHz',5000));
w.details.Impairments=channelInfo;
w.meta.Scope=[w.meta.Scope '; AWGN + CFO impaired'];
folder=tempname(fullfile(sm.root(),'generated'));
sm.exportBundle(w,folder,0.8); sm.plotWaveform(w,fullfile(folder,'overview.png'));
fprintf('Saved %s\n',folder);
end
