function out = resampleWaveform(w,newFs)
sm.require({'resample'},'Signal Processing Toolbox');
validateattributes(newFs,{'numeric'},{'scalar','positive','finite'});
[p,q]=rat(newFs/w.fs,1e-10);
assert(max(p,q)<=10000,'Resampling ratio too large; choose a rational instrument sample rate.');
achieved=w.fs*p/q;
assert(abs(achieved-newFs)<=max(1e-3,newFs*1e-9),'Requested sample rate not represented accurately.');
y=resample(w.iq,p,q); out=w; out.iq=y; out.fs=achieved;
out.meta.SampleRateHz=achieved; out.meta.NumSamples=size(y,1); out.meta.DurationSec=size(y,1)/achieved;
out.details.Resampling=struct('OriginalSampleRateHz',w.fs,'P',p,'Q',q, ...
    'Note','Anti-alias filter applied. Downsampling can remove occupied spectrum; inspect PSD/EVM.');
if isfield(out,'metrics'), out=rmfield(out,'metrics'); end
end
