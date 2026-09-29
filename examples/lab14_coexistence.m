function w = lab14_coexistence()
% 40 MS/s covers 20MHz Wi-Fi at DC, BLE at +12MHz, 802.15.4 at -12MHz.
a=sm.generate(sm.defaultConfig('wifi_nonht'));
b=sm.generate(sm.defaultConfig('ble'));
c=sm.generate(sm.defaultConfig('thread'));
w=sm.composite({a,b,c},40e6,[0 12e6 -12e6],[0 -10 -15]);
w.meta.CenterFrequencyHz=2.437e9; w.config.CenterFrequencyHz=2.437e9;
w.meta.Scope=[w.meta.Scope '; component RF placements are synthetic, not channel-plan compliant'];
folder=tempname(fullfile(sm.root(),'generated')); sm.exportBundle(w,folder,0.8);
sm.plotWaveform(w,fullfile(folder,'overview.png')); fprintf('%s\n',folder);
end
