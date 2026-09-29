function out = composite(waves,fs,offsetsHz,powersDB)
% Offline coexistence mixture; relative whole-record power per component.
assert(iscell(waves) && numel(waves)==numel(offsetsHz) && numel(waves)==numel(powersDB),'Input sizes mismatch.');
xs=cell(size(waves)); descriptions=cell(size(waves));
for k=1:numel(waves)
    w=waves{k}; assert(size(w.iq,2)==1,'Use SISO components.');
    m=sm.metrics(w.iq,w.fs);
    % Estimate guard from 99% occupied edges plus 10%; inspect skirts separately.
    edge=max(abs([m.OBWLowerHz m.OBWUpperHz]));
    assert(abs(offsetsHz(k))+1.1*edge<fs/2,'Component %d approaches/exceeds Nyquist.',k);
    if abs(w.fs-fs)>1e-6, w=sm.resampleWaveform(w,fs); end
    a=w.iq; rmsValue=sqrt(mean(abs(a).^2)); assert(rmsValue>0,'Zero-power component.');
    a=a/rmsValue*10^(powersDB(k)/20);
    xs{k}=a;
    descriptions{k}=struct('Protocol',w.meta.Protocol,'OffsetHz',offsetsHz(k),'RelativePowerDB',powersDB(k),'NumSamples',numel(a), ...
        'SourceConfig',waves{k}.config,'SourceScope',waves{k}.meta.Scope,'SourceSampleRateHz',waves{k}.fs);
end
N=max(cellfun(@numel,xs)); y=zeros(N,1);
for k=1:numel(xs)
    % Repeat finite captures to common length. Loop-boundary artifacts are possible.
    a=xs{k}; repeated=a(mod((0:N-1).',numel(a))+1);
    y=y+repeated.*exp(1i*2*pi*offsetsHz(k)*(0:N-1).'/fs);
end
p=struct('Protocol','composite','Seed',0,'CenterFrequencyHz',0);
out=sm.pack(y,fs,p,'Offline mixture; relative powers include idle time; periodic repetition may create boundary transients',struct('Components',{descriptions}));
end
