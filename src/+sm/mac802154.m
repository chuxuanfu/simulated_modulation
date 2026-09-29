function bytes = mac802154(payload,pan,src,dst,sequence)
% Legacy unsecured 802.15.4 data frame, short addresses, PAN compression.
% No Thread/6LoWPAN/MLE/security semantics are claimed.
assert(numel(payload)<=116,'Payload <=116 bytes: 9-byte header + 2-byte FCS.');
for v = [pan src dst], validateattributes(v,{'numeric'},{'scalar','integer','>=',0,'<=',65535}); end
validateattributes(sequence,{'numeric'},{'scalar','integer','>=',0,'<=',255});
le = @(v) uint8([bitand(uint16(v),uint16(255));bitshift(uint16(v),-8)]);
header = [uint8([hex2dec('41');hex2dec('88');sequence]);le(pan);le(dst);le(src)];
b = [header;uint8(payload(:))]; bytes = [b;sm.crc16_802154(b)];
end
