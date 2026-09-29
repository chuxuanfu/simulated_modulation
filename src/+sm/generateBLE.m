function w = generateBLE(p)
sm.require({'bleWaveformGenerator'},'Bluetooth Toolbox');
validateattributes(p.NumPackets,{'numeric'},{'scalar','integer','positive'});
validateattributes(p.IdleTimeSec,{'numeric'},{'scalar','nonnegative','finite'});
assert(ismember(p.Mode,{'LE1M','LE2M','LE500K','LE125K'}),'Unsupported BLE mode.');
fc = sm.bleFrequency(p.ChannelIndex);
assert(abs(p.CenterFrequencyHz-fc)<1,'CenterFrequencyHz must match sm.bleFrequency(ChannelIndex).');
if strcmp(p.PayloadKind,'advertising')
    assert(strcmp(p.Mode,'LE1M') && ismember(p.ChannelIndex,37:39), ...
        'Legacy advertising requires LE1M on channels 37/38/39. Use PayloadKind=phy-test for other modes.');
    sm.require({'bleLLAdvertisingChannelPDU','bleLLAdvertisingChannelPDUConfig'},'Bluetooth Toolbox');
    c = bleLLAdvertisingChannelPDUConfig;
    c.AdvertiserAddress = p.AdvertiserAddress;
    c.AdvertisingData = p.AdvertisingData;
    % This link-layer generator includes CRC; do NOT append a second CRC.
    bits = bleLLAdvertisingChannelPDU(c);
    scope = 'Legacy LE advertising PDU+CRC through toolbox PHY; no scanner/connection state machine';
else
    assert(strcmp(p.PayloadKind,'phy-test'),'PayloadKind must be advertising or phy-test.');
    validateattributes(p.TestMessageBits,{'numeric'},{'scalar','integer','>=',40,'<=',2088});
    assert(mod(p.TestMessageBits,8)==0,'Use whole octets.');
    bits = randi([0 1],p.TestMessageBits,1); c = struct;
    scope = 'BLE PHY test: random PDU+CRC-position bits, NOT a CRC-valid/link-layer-valid packet';
end
fs = p.SamplesPerSymbol*1e6*(1+strcmp(p.Mode,'LE2M'));
packet = bleWaveformGenerator(bits,'Mode',p.Mode,'ChannelIndex',p.ChannelIndex, ...
    'SamplesPerSymbol',p.SamplesPerSymbol);
gap = zeros(round(p.IdleTimeSec*fs),1);
iq = repmat([packet;gap],p.NumPackets,1);
d = struct('Bits',bits,'PHYPacket',packet,'LLConfig',c,'PacketSamples',size(packet,1),'GapSamples',numel(gap));
w = sm.pack(iq,fs,p,scope,d);
end
