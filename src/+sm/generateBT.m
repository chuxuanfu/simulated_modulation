function w = generateBT(p)
sm.require({'bluetoothWaveformConfig','bluetoothWaveformGenerator'},'Bluetooth Toolbox');
validateattributes(p.NumPackets,{'numeric'},{'scalar','integer','positive'});
c = bluetoothWaveformConfig('Mode',p.Mode,'PacketType',p.PacketType, ...
    'PayloadLength',p.PayloadBytes,'SamplesPerSymbol',p.SamplesPerSymbol);
L = getPayloadLength(c); bits = randi([0 1],8*L*p.NumPackets,1);
iq = bluetoothWaveformGenerator(bits,c);
% BR, EDR2M and EDR3M all use 1 Msymbol/s; EDR changes bits per symbol.
w = sm.pack(iq,p.SamplesPerSymbol*1e6,p,'Bluetooth BR/EDR toolbox PHY packets; no piconet or hopping scheduler', ...
    struct('PHYConfig',c,'Bits',bits,'PayloadLengthBytes',L));
end
