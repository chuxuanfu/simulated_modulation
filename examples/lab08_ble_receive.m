function r = lab08_ble_receive()
p=sm.defaultConfig('ble'); w=sm.generate(p);
[bits,aa]=bleIdealReceiver(w.details.PHYPacket,'Mode',p.Mode, ...
    'ChannelIndex',p.ChannelIndex,'SamplesPerSymbol',p.SamplesPerSymbol);
assert(numel(bits)==numel(w.details.Bits),'Unexpected receiver bit length.');
errors=sum(double(bits(:))~=double(w.details.Bits(:)));
assert(errors==0,'Noiseless BLE loopback failed.');
[status,decoded]=bleLLAdvertisingChannelPDUDecode(bits);
assert(strcmp(char(status),'Success'),'Advertising PDU/CRC decode failed.');
r=struct('BitErrors',errors,'AccessAddressBits',aa,'LLStatus',char(status),'LLConfig',decoded); disp(r);
end
