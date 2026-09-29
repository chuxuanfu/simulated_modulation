function m = metrics(x,fs)
validateattributes(x,{'numeric'},{'2d','nonempty','finite'});
power = mean(abs(x).^2,1); peak=max(abs(x),[],1);
m = struct('SampleRateHz',fs,'NumSamples',size(x,1),'NumChannels',size(x,2), ...
    'DurationSec',size(x,1)/fs,'RMS',sqrt(power),'PeakMagnitude',peak, ...
    'MeanI',mean(real(x),1),'MeanQ',mean(imag(x),1), ...
    'PAPR_dB',10*log10(max(peak.^2,realmin)./max(power,realmin)), ...
    'OBW99Hz',zeros(1,size(x,2)),'OBWLowerHz',zeros(1,size(x,2)), ...
    'OBWUpperHz',zeros(1,size(x,2)));
for ch=1:size(x,2)
    [f,p]=sm.psd(x(:,ch),fs);
    if sum(p)==0, continue; end
    c=cumsum(p)/sum(p); lo=find(c>=0.005,1); hi=find(c>=0.995,1);
    m.OBWLowerHz(ch)=f(lo); m.OBWUpperHz(ch)=f(hi);
    m.OBW99Hz(ch)=f(hi)-f(lo)+fs/numel(f);
end
m.MeasurementNote='Whole-record PAPR includes gaps; OBW is a Welch estimate, not a compliance measurement.';
end
