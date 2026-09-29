function p = defaultConfig(protocol)
% All frequencies Hz, times seconds, byte counts octets unless stated.
p = struct('Protocol',lower(char(protocol)),'Seed',42,'CenterFrequencyHz',0);
switch p.Protocol
    case 'basic'
        p.Modulation = 'QPSK'; p.NumSymbols = 4096;
        p.SymbolRateHz = 1e6; p.SamplesPerSymbol = 8;
        p.Rolloff = 0.35; p.FilterSpanSymbols = 12;
    case 'gfsk'
        p.NumBits = 4096; p.BitRateHz = 1e6;
        p.SamplesPerSymbol = 8; p.BT = 0.5; p.ModulationIndex = 0.5;
    case 'oqpsk'
        p.NumChips = 8192; p.ChipRateHz = 2e6; p.SamplesPerChip = 8;
    case 'ofdm'
        p.Modulation = '16QAM'; p.Nfft = 256; p.Ncp = 32;
        p.ActiveSubcarriers = [-100:-1 1:100];
        p.NumSymbols = 100; p.SubcarrierSpacingHz = 15e3;
        p.TransformPrecoding = false;
    case {'wifi_nonht','wifi_ht','wifi_vht','wifi_he','wifi_eht'}
        p.BandwidthMHz = 20; p.MCS = 0; p.PayloadBytes = 256;
        p.NumPackets = 3; p.IdleTimeSec = 100e-6;
        p.NumTransmitAntennas = 1; p.NumSpaceTimeStreams = 1;
        p.OversamplingFactor = 1; p.CenterFrequencyHz = 2.412e9;
        if ismember(p.Protocol,{'wifi_vht','wifi_eht'}), p.CenterFrequencyHz = 5.18e9; end
    case 'ble'
        p.Mode = 'LE1M'; p.ChannelIndex = 37; p.SamplesPerSymbol = 8;
        p.NumPackets = 3; p.IdleTimeSec = 150e-6;
        p.PayloadKind = 'advertising'; p.TestMessageBits = 256;
        p.AdvertiserAddress = 'C123456789AB';
        p.AdvertisingData = '020106090953696D4C61623031'; % Flags + complete name SimLab01
        p.CenterFrequencyHz = 2.402e9;
    case 'bt_classic'
        p.Mode = 'BR'; p.PacketType = 'DH1'; p.PayloadBytes = 20;
        p.SamplesPerSymbol = 8; p.NumPackets = 3;
        p.CenterFrequencyHz = 2.402e9;
    case 'thread'
        p.Channel = 15; p.SamplesPerChip = 8; p.PayloadBytes = 32;
        p.NumPackets = 3; p.IdleTimeSec = 200e-6;
        p.PANID = hex2dec('1234'); p.SourceAddress = hex2dec('0001');
        p.DestinationAddress = hex2dec('0002');
        p.CenterFrequencyHz = 2.425e9;
    case {'lte_dl','lte_ul'}
        p.RC = 'R.0'; p.NumSubframes = 10;
        p.CenterFrequencyHz = 2.14e9;
        if strcmp(p.Protocol,'lte_ul'), p.RC = 'A1-3'; p.CenterFrequencyHz = 1.95e9; end
    case {'nr_dl','nr_ul'}
        p.BandwidthMHz = 20; p.SubcarrierSpacingKHz = 30;
        p.NSizeGrid = 51; p.PRBSet = 0:50; p.NumSubframes = 2;
        p.Modulation = '16QAM'; p.TargetCodeRate = 0.5;
        p.NCellID = 1; p.TransformPrecoding = false;
        p.CenterFrequencyHz = 3.5e9;
    otherwise
        error('sm:UnknownProtocol','Unknown protocol: %s',p.Protocol);
end
end
