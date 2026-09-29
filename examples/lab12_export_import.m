function r = lab12_export_import()
p=sm.defaultConfig('basic'); p.Modulation='QPSK'; w=sm.generate(p);
folder=tempname(fullfile(sm.root(),'generated')); m=sm.exportBundle(w,folder,0.8);
z=sm.readIQ(fullfile(folder,'channel_01.sigmf-data'),'cf32_le');
r=struct('Folder',folder,'SampleRateHz',m.SampleRateHz,'ExportGain',m.ExportGain, ...
    'RestoredOriginalMaxError',max(abs(z/m.ExportGain-w.iq)));
assert(r.RestoredOriginalMaxError<1e-6); disp(r);
end
