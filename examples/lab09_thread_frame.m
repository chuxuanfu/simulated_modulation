function r = lab09_thread_frame()
p=sm.defaultConfig('thread'); w=sm.generate(p); b=w.details.PSDUBytes;
assert(isequal(sm.crc16_802154(b(1:end-2)),b(end-1:end)),'FCS construction mismatch.');
assert(isequal(sm.crc16_802154(b),uint8([0;0])),'CRC residue must be zero.');
measured=numel(w.details.PHYPacket)/w.fs; expected=w.details.ExpectedPPDUBitTimeSec;
% Half-sine shaping can add a short tail beyond the PPDU bit time.
assert(abs(measured-expected)<10e-6,'Unexpected PPDU duration: check sample-rate convention.');
r=struct('PSDUBytes',numel(b),'ExpectedBitTimeSec',expected,'WaveformTimeSec',measured, ...
    'FCSHex',dec2hex(b(end-1:end),2),'Scope','Valid unsecured 802.15.4 MAC framing; no Thread network payload');
sm.plotWaveform(w,fullfile(sm.root(),'reports','lab09_thread.png')); disp(r);
end
