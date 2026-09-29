function report = run_tests(mode)
if nargin<1, mode='core'; end
assert(ismember(mode,{'core','all'}),'Mode must be core or all.');
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root,fullfile(root,'src'),fullfile(root,'examples'));
if ~isfolder(fullfile(root,'reports')), mkdir(fullfile(root,'reports')); end
suite={
    'known mappings and Gray adjacency',@test_mapping,{};
    'RRC matched-filter timing',@test_rrc,{};
    'OFDM / DFT-spread inversion',@test_ofdm,{};
    'GFSK and OQPSK envelope',@test_envelopes,{};
    'IEEE 802.15.4 CRC known vector',@test_crc,{};
    'determinism and caller RNG isolation',@test_rng,{};
    'CFO sign and complex noise power',@test_impair,{};
    'FFT sign and PSD normalization',@test_psd,{};
    'float/int16 byte layout and roundtrip',@test_io,{};
    'strict configuration rejection',@test_invalid,{};
    'cross-language known IQ fixtures',@test_fixture,{};
    'BLE channel frequency map',@test_ble_channels,{}};
if strcmp(mode,'all')
    protocols={'wifi_nonht','wifi_ht','wifi_vht','wifi_he','wifi_eht','ble','bt_classic','thread','lte_dl','lte_ul','nr_dl','nr_ul'};
    deps={'wlanNonHTConfig','wlanHTConfig','wlanVHTConfig','wlanHESUConfig','wlanEHTMUConfig','bleWaveformGenerator', ...
        'bluetoothWaveformGenerator','lrwpanWaveformGenerator','lteRMCDLTool','lteRMCULTool','nrWaveformGenerator','nrWaveformGenerator'};
    for k=1:numel(protocols)
        name=protocols{k}; suite(end+1,:)={['generate ' name],@() test_protocol(name),{deps{k}}}; %#ok<AGROW>
    end
    suite(end+1,:)={'Wi-Fi noiseless receiver',@lab07_wifi_receive,{'wlanNonHTDataRecover'}};
    suite(end+1,:)={'BLE PHY + advertising CRC receiver',@lab08_ble_receive,{'bleIdealReceiver','bleLLAdvertisingChannelPDUDecode'}};
    suite(end+1,:)={'802.15.4 PPDU time + FCS',@lab09_thread_frame,{'lrwpanWaveformGenerator'}};
    suite(end+1,:)={'NR grid + codeword loopback',@lab10_nr_resource_grid,{'nrPDSCHDecode'}};
    suite(end+1,:)={'BLE four PHY modes',@test_ble_modes,{'bleIdealReceiver'}};
    suite(end+1,:)={'Bluetooth BR and EDR modes',@test_bt_modes,{'bluetoothWaveformGenerator'}};
    suite(end+1,:)={'NR uplink transform precoding',@test_nr_dft,{'nrWaveformGenerator'}};
    suite(end+1,:)={'WLAN HE OFDMA allocation',@lab15_wlan_ofdma,{'wlanHEMUConfig'}};
    suite(end+1,:)={'WLAN two transmit antennas',@test_mimo,{'wlanVHTConfig'}};
    suite(end+1,:)={'Resample tone frequency and duration',@test_resample,{'resample'}};
end
rows=repmat(struct('Name','','Status','','Seconds',0,'Message',''),size(suite,1),1);
for k=1:size(suite,1)
    rows(k).Name=suite{k,1}; req=suite{k,3}; missing=req(cellfun(@(x) isempty(which(x)),req));
    if ~isempty(missing)
        rows(k).Status='SKIP'; rows(k).Message=['Missing: ' strjoin(missing,', ')];
    else
        started=tic;
        try
            suite{k,2}(); rows(k).Status='PASS';
        catch err
            rows(k).Status='FAIL'; rows(k).Message=getReport(err,'extended','hyperlinks','off');
        end
        rows(k).Seconds=toc(started);
    end
    fprintf('[%s] %s\n',rows(k).Status,rows(k).Name);
    if strcmp(rows(k).Status,'FAIL'), fprintf('%s\n',rows(k).Message); end
end
report=struct('Mode',mode,'MATLABVersion',version,'CheckedLocal',datestr(now,30), ...
    'Passed',sum(strcmp({rows.Status},'PASS')),'Failed',sum(strcmp({rows.Status},'FAIL')), ...
    'Skipped',sum(strcmp({rows.Status},'SKIP')),'Results',rows);
sm.writeJSON(fullfile(root,'reports',['tests_' mode '.json']),report);
fprintf('PASS=%d FAIL=%d SKIP=%d. SKIP is not a pass.\n',report.Passed,report.Failed,report.Skipped);
if nargout==0, assert(report.Failed==0,'Tests failed; read reports/tests_%s.json.',mode); end
end

function test_mapping()
assert(isequal(sm.bitsToSymbols([0;1],'BPSK'),[1;-1]));
assert(max(abs(sm.bitsToSymbols([0;0;0;1;1;0;1;1],'QPSK')-[1+1i;1-1i;-1+1i;-1-1i]/sqrt(2)))<eps);
for name={'BPSK','QPSK','8PSK','16QAM','64QAM','256QAM'}
    [a,k]=sm.alphabet(name{1}); M=numel(a); labels=(0:M-1).'; b=zeros(M,k);
    for j=1:k, b(:,j)=bitget(uint32(labels),k-j+1); end
    bits=reshape(b.',[],1); assert(isequal(sm.symbolsToBits(a,name{1}),bits));
    assert(abs(mean(abs(a).^2)-1)<1e-12);
    if contains(name{1},'QAM')
        D=abs(a-a.'); D(D<eps)=Inf; nearest=min(D(:)); [i,j]=find(abs(D-nearest)<1e-10);
        assert(all(sum(b(i,:)~=b(j,:),2)==1),'Nearest QAM neighbours must differ by one bit.');
    end
end
end
function test_rrc()
p=sm.defaultConfig('basic'); p.Modulation='16QAM'; w=sm.generate(p); h=w.details.Pulse;
z=conv(w.iq,h); s=z(numel(h)+(0:p.NumSymbols-1)*p.SamplesPerSymbol);
assert(mean(sm.symbolsToBits(s,p.Modulation)~=w.details.Bits)==0);
e=sm.evm(s,w.details.Symbols,false); assert(e.RMSPercent<1);
end
function test_ofdm()
p=sm.defaultConfig('ofdm');
for mode=[false true]
    p.TransformPrecoding=mode; w=sm.generate(p);
    z=sm.ofdmDemodulate(w.iq,p.Nfft,p.Ncp,p.ActiveSubcarriers,mode);
    assert(max(abs(z(:)-w.details.Symbols(:)))<1e-12);
end
end
function test_envelopes()
p=sm.defaultConfig('gfsk'); w=sm.generate(p); assert(max(abs(abs(w.iq)-1))<1e-12);
p=sm.defaultConfig('oqpsk'); w=sm.generate(p); x=w.iq(2*p.SamplesPerChip+1:end-2*p.SamplesPerChip);
assert(max(abs(abs(x)-1))<1e-12);
end
function test_crc()
f=sm.crc16_802154(uint8('123456789')); assert(isequal(f,uint8([hex2dec('89');hex2dec('21')])));
b=sm.mac802154(uint8(1:32),hex2dec('1234'),1,2,0);
assert(numel(b)==43 && isequal(b(1:3),uint8([65;136;0])));
assert(isequal(sm.crc16_802154(b),uint8([0;0])));
end
function test_rng()
state=rng; p=sm.defaultConfig('basic'); a=sm.generate(p); assert(isequal(state,rng));
b=sm.generate(p); assert(isequal(a.iq,b.iq)); p.Seed=43; c=sm.generate(p); assert(~isequal(a.iq,c.iq));
end
function test_impair()
x=ones(100000,1); fs=1e6;
y=sm.impair(x,fs,struct('CFOHz',12345)); f=angle(y(2:end).*conj(y(1:end-1)))*fs/(2*pi);
assert(max(abs(f-12345))<1e-5);
y=sm.impair(x,fs,struct('AddNoise',true,'SNRdB',20)); assert(abs(mean(abs(y-x).^2)-0.01)<0.0002);
end
function test_psd()
fs=1e6; x=exp(1i*2*pi*125e3*(0:8191).'/fs); [f,p]=sm.psd(x,fs,1024);
[~,idx]=max(p); assert(f(idx)==125e3); assert(abs(sum(p)*fs/1024-1)<1e-10);
end
function test_io()
folder=tempname; mkdir(folder); cleanup=onCleanup(@() rmdir(folder,'s')); %#ok<NASGU>
x=[0.125+0.25i;-0.5+0.75i;0.8-0.1i];
for fmt={'cf32_le','ci16_le'}
    path=fullfile(folder,fmt{1}); sm.writeIQ(path,x,fmt{1}); y=sm.readIQ(path,fmt{1});
    assert(max(abs(x-y))<sqrt(2)/32767);
end
fid=fopen(fullfile(folder,'cf32_le'),'r','ieee-le'); a=fread(fid,6,'single=>double'); fclose(fid);
assert(max(abs(a-[0.125;0.25;-0.5;0.75;0.8;-0.1]))<1e-7);
end
function test_invalid()
caught=false; try, sm.configure('basic',struct('Typo',1)); catch, caught=true; end; assert(caught);
caught=false; try, sm.ofdmModulate(ones(2,1),64,16,[1 1]); catch, caught=true; end; assert(caught);
end
function test_ble_channels()
assert(sm.bleFrequency(37)==2402e6 && sm.bleFrequency(38)==2426e6 && sm.bleFrequency(39)==2480e6);
assert(sm.bleFrequency(0)==2404e6 && sm.bleFrequency(10)==2424e6 && sm.bleFrequency(11)==2428e6 && sm.bleFrequency(36)==2478e6);
end
function test_protocol(name)
p=sm.defaultConfig(name); w=sm.generate(p);
assert(all(isfinite(w.iq(:))) && any(abs(w.iq(:))>0));
assert(w.fs>0 && size(w.iq,1)==w.meta.NumSamples);
if startsWith(name,'nr_') || startsWith(name,'lte_')
    assert(abs(size(w.iq,1)/w.fs-p.NumSubframes*1e-3)<10/w.fs,'Unexpected cellular duration.');
end
end
function test_ble_modes()
for mode={'LE1M','LE2M','LE500K','LE125K'}
    p=sm.defaultConfig('ble'); p.Mode=mode{1}; p.PayloadKind='phy-test';
    p.ChannelIndex=0; p.CenterFrequencyHz=sm.bleFrequency(0); w=sm.generate(p);
    b=bleIdealReceiver(w.details.PHYPacket,'Mode',p.Mode,'SamplesPerSymbol',p.SamplesPerSymbol,'ChannelIndex',p.ChannelIndex);
    assert(isequal(double(b(:)),double(w.details.Bits(:))));
end
end
function test_bt_modes()
for mode={'BR','EDR2M','EDR3M'}
    p=sm.defaultConfig('bt_classic'); p.Mode=mode{1}; w=sm.generate(p);
    assert(w.fs==8e6 && any(abs(w.iq)>0));
end
end
function test_nr_dft()
p=sm.defaultConfig('nr_ul'); p.TransformPrecoding=true; p.PRBSet=0:47;
w=sm.generate(p); assert(any(abs(w.iq)>0));
end
function test_mimo()
p=sm.defaultConfig('wifi_vht'); p.NumTransmitAntennas=2; p.NumSpaceTimeStreams=2;
w=sm.generate(p); assert(size(w.iq,2)==2);
end
function test_resample()
p=struct('Protocol','tone','Seed',0,'CenterFrequencyHz',0); fs=1e6;
x=exp(1i*2*pi*100e3*(0:9999).'/fs); w=sm.pack(x,fs,p,'Test tone');
z=sm.resampleWaveform(w,1.5e6); assert(size(z.iq,1)==15000);
y=z.iq(100:end-100); freq=mean(angle(y(2:end).*conj(y(1:end-1))))*z.fs/(2*pi);
assert(abs(freq-100e3)<10);
end

function test_fixture()
folder=fullfile(sm.root(),'resources','fixtures');
x=[0.125+0.25i;-0.5+0.75i;0.8-0.1i];
a=sm.readIQ(fullfile(folder,'known_iq.cf32'),'cf32_le');
b=sm.readIQ(fullfile(folder,'known_iq.ci16'),'ci16_le');
assert(max(abs(a-x))<1e-7 && max(abs(b-x))<sqrt(2)/32767);
end
