function manifest = exportBundle(w,folder,peakTarget)
% One common gain across antennas preserves relative channel amplitudes.
if nargin<3, peakTarget=0.8; end
validateattributes(peakTarget,{'numeric'},{'scalar','>',0,'<=',1});
if ~isfolder(folder), mkdir(folder); end
assert(~isfile(fullfile(folder,'waveform.mat')),'Refusing to overwrite an existing waveform.mat.');
peak=max(abs(w.iq(:))); assert(peak>0,'Cannot export an all-zero waveform.');
exportGain=peakTarget/peak; iqExport=w.iq*exportGain; %#ok<NASGU>
save(fullfile(folder,'waveform.mat'),'w','iqExport','exportGain','-v7.3');
manifest=w.meta; manifest.GenerationConfig=w.config; manifest.Metrics=sm.metrics(w.iq,w.fs);
manifest.ExportGain=exportGain; manifest.ExportPeakTarget=peakTarget;
manifest.Int16Divisor=32767; manifest.RFPowerDBm='Uncalibrated: set and measure on instrument';
manifest.RawLayout='one file per channel; I0,Q0,I1,Q1; little endian; no header';
files=cell(1,size(w.iq,2));
for ch=1:size(w.iq,2)
    stem=sprintf('channel_%02d',ch);
    fp=[stem '.sigmf-data']; ip=[stem '.ci16'];
    sm.writeIQ(fullfile(folder,fp),iqExport(:,ch),'cf32_le');
    sm.writeIQ(fullfile(folder,ip),iqExport(:,ch),'ci16_le');
    a=sm.readIQ(fullfile(folder,fp),'cf32_le'); b=sm.readIQ(fullfile(folder,ip),'ci16_le');
    err32=max(abs(a-iqExport(:,ch))); err16=max(abs(b-iqExport(:,ch)));
    assert(err32<1e-6 && err16<=sqrt(2)/32767,'Export round-trip failed.');
    g=struct('core_datatype','cf32_le','core_sample_rate',w.fs,'core_version','1.2.0', ...
        'core_description',[w.meta.Protocol '; ' w.meta.Scope]);
    capture=struct('core_sample_start',0,'core_frequency',w.meta.CenterFrequencyHz);
    sig=struct('global',g,'captures',{{capture}},'annotations',{{}});
    txt=jsonencode(sig,'PrettyPrint',true); txt=strrep(txt,'"core_','"core:');
    fid=fopen(fullfile(folder,[stem '.sigmf-meta']),'w','n','UTF-8'); assert(fid>=0,'Cannot write SigMF metadata.');
    fprintf(fid,'%s\n',txt); fclose(fid);
    files{ch}=struct('Channel',ch,'FloatFile',fp,'Int16File',ip,'FloatRoundTripMaxError',err32,'Int16RoundTripMaxError',err16);
end
manifest.Files=files; sm.writeJSON(fullfile(folder,'manifest.json'),manifest);
end
