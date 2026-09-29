function w = generate_waveform(config,outputFolder)
% GENERATE_WAVEFORM Generate, measure, export and plot a reproducible bundle.
% p=sm.defaultConfig('wifi_he'); w=generate_waveform(p);
root = fileparts(mfilename('fullpath')); addpath(fullfile(root,'src'));
if nargin<1, config=sm.defaultConfig('basic'); end
if ischar(config) || isstring(config)
    text = fileread(config); config = jsondecode(text);
    defaults = sm.defaultConfig(config.Protocol);
    fields = fieldnames(config);
    assert(all(ismember(fields,fieldnames(defaults))),'Unknown JSON configuration field.');
    for k=1:numel(fields), defaults.(fields{k})=config.(fields{k}); end
    config=defaults;
end
if nargin<2
    parent=fullfile(root,'generated'); if ~isfolder(parent), mkdir(parent); end
    [~,tag]=fileparts(tempname(parent));
    outputFolder=fullfile(parent,[config.Protocol '_' datestr(now,'yyyymmdd_HHMMSS') '_' tag]);
end
assert(~isfolder(outputFolder) || isempty(dir(fullfile(outputFolder,'*.mat'))), ...
    'Output folder already contains a MAT file; choose a new folder.');
w = sm.generate(config); w.metrics = sm.metrics(w.iq,w.fs);
sm.exportBundle(w,outputFolder,0.8);
sm.plotWaveform(w,fullfile(outputFolder,'overview.png'));
fprintf('Generated %s: %.6g MS/s, %.3f ms, %d channels\n%s\n', ...
    config.Protocol,w.fs/1e6,size(w.iq,1)/w.fs*1e3,size(w.iq,2),outputFolder);
fprintf('Scope: %s\n',w.meta.Scope);
end
