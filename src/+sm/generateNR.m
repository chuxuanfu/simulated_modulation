function w = generateNR(p)
sm.require({'nrWaveformGenerator','nrSCSCarrierConfig','nrWavegenBWPConfig'},'5G Toolbox');
validateattributes(p.NumSubframes,{'numeric'},{'scalar','integer','positive'});
validateattributes(p.NSizeGrid,{'numeric'},{'scalar','integer','positive','<=',275});
validateattributes(p.TargetCodeRate,{'numeric'},{'scalar','>',0,'<',1});
assert(all(p.PRBSet>=0 & p.PRBSet<p.NSizeGrid & p.PRBSet==fix(p.PRBSet)) && ~isempty(p.PRBSet),'Invalid PRB allocation.');
assert(numel(unique(p.PRBSet))==numel(p.PRBSet),'Duplicate PRBs.');
scs = p.SubcarrierSpacingKHz;
assert(ismember(scs,[15 30 60]),'This FR1 preset supports 15/30/60 kHz.');
carrier = nrSCSCarrierConfig('SubcarrierSpacing',scs,'NSizeGrid',p.NSizeGrid,'NStartGrid',0);
bwp = nrWavegenBWPConfig('BandwidthPartID',1,'SubcarrierSpacing',scs,'NSizeBWP',p.NSizeGrid,'NStartBWP',0);
period = 10*scs/15; % slots in a 10 ms frame
if strcmp(p.Protocol,'nr_dl')
    assert(~p.TransformPrecoding,'Transform precoding is an uplink option.');
    c = nrDLCarrierConfig;
    c.SSBurst.Enable = false; c.PDCCH = {}; c.CORESET = {}; c.SearchSpaces = {}; c.CSIRS = {};
    d = nrWavegenPDSCHConfig('BandwidthPartID',1,'Modulation',p.Modulation, ...
        'PRBSet',p.PRBSet,'TargetCodeRate',p.TargetCodeRate, ...
        'SymbolAllocation',[0 14],'SlotAllocation',0:period-1,'Period',period,'NumLayers',1);
    d.DataSource = randi([0 1],10000,1); c.PDSCH = {d};
    scope = 'NR FR1 PDSCH+DMRS test waveform; SSB/PDCCH disabled, NOT a campable cell';
else
    c = nrULCarrierConfig; c.PUCCH = {}; c.SRS = {};
    d = nrWavegenPUSCHConfig('BandwidthPartID',1,'Modulation',p.Modulation, ...
        'PRBSet',p.PRBSet,'TargetCodeRate',p.TargetCodeRate, ...
        'SymbolAllocation',[0 14],'SlotAllocation',0:period-1,'Period',period, ...
        'NumLayers',1,'TransformPrecoding',p.TransformPrecoding);
    if p.TransformPrecoding
        assert(all(diff(p.PRBSet)==1),'Use contiguous PRBs for DFT-s-OFDM.');
        factors=factor(numel(p.PRBSet));
        assert(all(ismember(factors,[2 3 5])) || numel(p.PRBSet)==1, ...
            'DFT-s-OFDM allocation needs a supported transform size; use 48 PRB (0:47), not 51.');
        d.DMRS.DMRSTypeAPosition = 2;
    end
    d.DataSource = randi([0 1],10000,1); c.PUSCH = {d};
    scope = 'NR FR1 PUSCH+DMRS test waveform; no random access, scheduler or connected UE';
end
c.FrequencyRange = 'FR1'; c.ChannelBandwidth = p.BandwidthMHz;
c.NCellID = p.NCellID; c.NumSubframes = p.NumSubframes;
c.SCSCarriers = {carrier}; c.BandwidthParts = {bwp};
[iq,info] = nrWaveformGenerator(c);
fs = info.ResourceGrids(1).Info.SampleRate;
w = sm.pack(iq,fs,p,scope,struct('NRConfig',c,'WaveformInfo',info));
end
