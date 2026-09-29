function w = generateWLAN(p)
sm.require({'wlanWaveformGenerator','wlanSampleRate'},'WLAN Toolbox');
validateattributes(p.PayloadBytes,{'numeric'},{'scalar','integer','positive'});
validateattributes(p.NumPackets,{'numeric'},{'scalar','integer','positive'});
validateattributes(p.IdleTimeSec,{'numeric'},{'scalar','nonnegative','finite'});
validateattributes(p.OversamplingFactor,{'numeric'},{'scalar','integer','positive'});
bw = sprintf('CBW%d',p.BandwidthMHz);
switch p.Protocol
    case 'wifi_nonht'
        c = wlanNonHTConfig('ChannelBandwidth',bw,'MCS',p.MCS,'PSDULength',p.PayloadBytes);
        assert(p.NumTransmitAntennas==1 && p.NumSpaceTimeStreams==1,'This non-HT preset is SISO.');
        L = c.PSDULength;
    case 'wifi_ht'
        c = wlanHTConfig('ChannelBandwidth',bw,'MCS',p.MCS,'PSDULength',p.PayloadBytes, ...
            'NumTransmitAntennas',p.NumTransmitAntennas,'NumSpaceTimeStreams',p.NumSpaceTimeStreams);
        L = c.PSDULength;
    case 'wifi_vht'
        c = wlanVHTConfig('ChannelBandwidth',bw,'MCS',p.MCS,'APEPLength',p.PayloadBytes, ...
            'NumTransmitAntennas',p.NumTransmitAntennas,'NumSpaceTimeStreams',p.NumSpaceTimeStreams);
        L = c.PSDULength;
    case 'wifi_he'
        sm.require({'wlanHESUConfig'},'WLAN Toolbox with HE support');
        c = wlanHESUConfig('ChannelBandwidth',bw,'MCS',p.MCS,'APEPLength',p.PayloadBytes, ...
            'NumTransmitAntennas',p.NumTransmitAntennas,'NumSpaceTimeStreams',p.NumSpaceTimeStreams);
        L = getPSDULength(c);
    case 'wifi_eht'
        sm.require({'wlanEHTMUConfig'},'WLAN Toolbox R2022b or later');
        c = wlanEHTMUConfig(bw);
        c.NumTransmitAntennas = p.NumTransmitAntennas;
        c.User{1}.MCS = p.MCS; c.User{1}.APEPLength = p.PayloadBytes;
        c.User{1}.NumSpaceTimeStreams = p.NumSpaceTimeStreams;
        L = psduLength(c);
end
assert(isscalar(L),'This adapter handles one user; see advanced WLAN example.');
bits = randi([0 1],8*L*p.NumPackets,1);
iq = wlanWaveformGenerator(bits,c,'NumPackets',p.NumPackets,'IdleTime',p.IdleTimeSec, ...
    'OversamplingFactor',p.OversamplingFactor);
fs = wlanSampleRate(c)*p.OversamplingFactor;
d = struct('PHYConfig',c,'Bits',bits,'PSDULengthBytes',L);
w = sm.pack(iq,fs,p,'Toolbox WLAN PPDU with random PSDU; not an associated Wi-Fi session or valid MAC payload',d);
end
