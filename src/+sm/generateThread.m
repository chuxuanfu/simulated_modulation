function w = generateThread(p)
sm.require({'lrwpanOQPSKConfig','lrwpanWaveformGenerator'},'Communications Toolbox R2023a or later');
validateattributes(p.Channel,{'numeric'},{'scalar','integer','>=',11,'<=',26});
validateattributes(p.NumPackets,{'numeric'},{'scalar','integer','positive'});
validateattributes(p.PayloadBytes,{'numeric'},{'scalar','integer','>=',0,'<=',116});
validateattributes(p.IdleTimeSec,{'numeric'},{'scalar','nonnegative','finite'});
fc = (2405+5*(p.Channel-11))*1e6;
assert(abs(p.CenterFrequencyHz-fc)<1,'CenterFrequencyHz must equal (2405+5*(Channel-11))*1e6.');
payload = uint8(randi([0 255],p.PayloadBytes,1));
psdu = sm.mac802154(payload,p.PANID,p.SourceAddress,p.DestinationAddress,0);
c = lrwpanOQPSKConfig('Band',2450,'SamplesPerChip',p.SamplesPerChip,'PSDULength',numel(psdu));
% Read object rate: its chip-pulse convention differs from serial-chip SPS.
fs = c.SampleRate;
bits = sm.bytesToBits(psdu);
packet = lrwpanWaveformGenerator(bits,c);
gap = zeros(round(p.IdleTimeSec*fs),1);
iq = repmat([packet;gap],p.NumPackets,1);
d = struct('PHYConfig',c,'PSDUBytes',psdu,'Bits',bits,'PHYPacket',packet, ...
    'PacketSamples',numel(packet),'GapSamples',numel(gap),'ExpectedPPDUBitTimeSec',8*(6+numel(psdu))/250e3);
w = sm.pack(iq,fs,p,'2.4GHz IEEE 802.15.4 OQPSK with unsecured MAC+FCS; Thread PHY substrate only, no Thread stack',d);
end
