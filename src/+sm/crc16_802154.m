function fcs = crc16_802154(bytes)
% CRC-16/KERMIT: poly 0x1021 reflected 0x8408, init 0, xorout 0.
% Standard check ASCII 123456789 -> 0x2189; on-air bytes 89 21.
r = uint16(0);
for byte = uint8(bytes(:)).'
    r = bitxor(r,uint16(byte));
    for k = 1:8
        low = bitand(r,uint16(1)); r = bitshift(r,-1);
        if low, r = bitxor(r,uint16(hex2dec('8408'))); end
    end
end
fcs = uint8([bitand(r,uint16(255));bitshift(r,-8)]);
end
