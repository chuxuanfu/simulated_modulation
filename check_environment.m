function report = check_environment()
root=setup();
features={
    'Core MATLAB','fft';
    'WLAN Toolbox','wlanWaveformGenerator';
    'Wi-Fi HE','wlanHESUConfig';
    'Wi-Fi EHT','wlanEHTMUConfig';
    'Bluetooth Toolbox','bleWaveformGenerator';
    'Classic Bluetooth','bluetoothWaveformGenerator';
    '802.15.4 / Thread PHY','lrwpanWaveformGenerator';
    'LTE Toolbox','lteRMCDLTool';
    '5G Toolbox','nrWaveformGenerator';
    'Signal Processing Toolbox','resample';
    'Simulink (optional)','new_system'};
rows=repmat(struct('Feature','','EntryPoint','','Present',false,'Path',''),size(features,1),1);
for k=1:size(features,1)
    rows(k).Feature=features{k,1}; rows(k).EntryPoint=features{k,2};
    rows(k).Path=which(features{k,2}); rows(k).Present=~isempty(rows(k).Path);
end
report=struct('CheckedLocal',datestr(now,30),'MATLABVersion',version,'Release',version('-release'), ...
    'Platform',computer,'InstalledProducts',ver,'Features',rows, ...
    'LicenseNote','Presence is not license checkout. Actual generation/tests determine usability.');
sm.writeJSON(fullfile(root,'reports','environment.json'),report);
disp(struct2table(rows));
fprintf('Recommended: R2024b or later. Project baseline: R2023b+, capability-dependent.\n');
fprintf('Missing optional features do not block core lessons. Run run_tests(''all'') for actual smoke tests.\n');
end
