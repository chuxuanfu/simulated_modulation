function r = lab13_dsss_fhss_chirp()
% Educational mechanisms only: not IEEE spreading, Bluetooth hopping or LoRa.
state=rng; cleanup=onCleanup(@() rng(state)); %#ok<NASGU>
rng(113); fs=8e6; sps=8; N=256; data=1-2*randi([0 1],N,1);
code=1-2*randi([0 1],31,1); chips=reshape(code*data.',[],1);
dsss=repelem(chips,sps); recovered=mean(reshape(chips,31,[]).*code,1).';
assert(max(abs(recovered-data))<eps,'DSSS despreading failed.');
base=exp(1i*2*pi*cumsum(repelem(data,sps))/sps*0.25);
hoplen=256; hopHz=[-2e6 0 2e6 -1e6];
freq=repelem(hopHz(:),hoplen); freq=repmat(freq,ceil(numel(base)/numel(freq)),1); freq=freq(1:numel(base));
fhss=base.*exp(1i*2*pi*cumsum(freq)/fs);
t=(0:4095).'/fs; T=numel(t)/fs; B=2e6;
chirpSignal=exp(1i*2*pi*(-B/2*t+B/(2*T)*t.^2));
p=struct('Protocol','educational_spreading','Seed',113,'CenterFrequencyHz',0);
items={dsss,fhss,chirpSignal}; names={'DSSS','FHSS','CHIRP'};
for k=1:3
    w=sm.pack(items{k},fs,p,['Educational ' names{k} '; no protocol compliance']);
    sm.plotWaveform(w,fullfile(sm.root(),'reports',['lab13_' names{k} '.png']));
end
r=struct('DespreadingMaxError',max(abs(recovered-data)),'ProcessingGainIdealDB',10*log10(31)); disp(r);
end
