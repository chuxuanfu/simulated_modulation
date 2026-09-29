function w = generateLTE(p)
validateattributes(p.NumSubframes,{'numeric'},{'scalar','integer','positive'});
bits = randi([0 1],30000,1);
if strcmp(p.Protocol,'lte_dl')
    sm.require({'lteRMCDL','lteRMCDLTool'},'LTE Toolbox');
    c = lteRMCDL(p.RC); c.TotSubframes = p.NumSubframes;
    [iq,grid,out] = lteRMCDLTool(c,bits);
else
    sm.require({'lteRMCUL','lteRMCULTool'},'LTE Toolbox');
    c = lteRMCUL(p.RC); c.TotSubframes = p.NumSubframes;
    [iq,grid,out] = lteRMCULTool(c,bits);
end
w = sm.pack(iq,out.SamplingRate,p,'LTE reference measurement channel waveform; no connected UE/session', ...
    struct('InputBits',bits,'ResourceGrid',grid,'LTEConfig',out));
end
