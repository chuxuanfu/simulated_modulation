function w = lab15_wlan_ofdma()
sm.require({'wlanHEMUConfig','wlanWaveformGenerator'},'WLAN Toolbox');
state=rng; cleanup=onCleanup(@() rng(state)); %#ok<NASGU>
rng(115); c=wlanHEMUConfig(0); % 20 MHz, nine 26-tone RUs, one user each
for k=1:numel(c.User), c.User{k}.MCS=0; c.User{k}.APEPLength=100; end
L=getPSDULength(c); bits=cell(1,numel(L));
for k=1:numel(L), bits{k}=randi([0 1],8*L(k),1); end
x=wlanWaveformGenerator(bits,c); fs=wlanSampleRate(c);
p=struct('Protocol','wifi_he_ofdma','Seed',115,'CenterFrequencyHz',2.412e9);
w=sm.pack(x,fs,p,'HE MU OFDMA, random per-user PSDUs; no valid MAC traffic',struct('PHYConfig',c,'Bits',{bits}));
folder=tempname(fullfile(sm.root(),'generated')); sm.exportBundle(w,folder,0.8);
sm.plotWaveform(w,fullfile(folder,'overview.png')); fprintf('%s\n',folder);
end
