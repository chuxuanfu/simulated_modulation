function w = generate(p)
% Deterministic generation without permanently changing caller RNG state.
assert(isstruct(p) && isscalar(p) && isfield(p,'Protocol'),'Use sm.defaultConfig first.');
expected=fieldnames(sm.defaultConfig(p.Protocol));
assert(all(ismember(fieldnames(p),expected)),'Unknown configuration field; check spelling.');
assert(all(ismember(expected,fieldnames(p))),'Missing configuration field; use sm.defaultConfig.');
validateattributes(p.Seed,{'numeric'},{'scalar','integer','>=',0,'<=',2^32-1});
validateattributes(p.CenterFrequencyHz,{'numeric'},{'scalar','nonnegative','finite'});
state = rng; restore = onCleanup(@() rng(state)); %#ok<NASGU>
rng(p.Seed,'twister');
switch p.Protocol
    case 'basic'
        [~,k] = sm.alphabet(p.Modulation);
        validateattributes(p.NumSymbols,{'numeric'},{'scalar','integer','positive'});
        validateattributes(p.SymbolRateHz,{'numeric'},{'scalar','positive','finite'});
        bits = randi([0 1],p.NumSymbols*k,1);
        symbols = sm.bitsToSymbols(bits,p.Modulation);
        h = sm.rrc(p.Rolloff,p.FilterSpanSymbols,p.SamplesPerSymbol);
        iq = sm.pulseShape(symbols,h,p.SamplesPerSymbol);
        d = struct('Bits',bits,'Symbols',symbols,'Pulse',h, ...
            'TxGroupDelaySamples',(numel(h)-1)/2);
        w = sm.pack(iq,p.SymbolRateHz*p.SamplesPerSymbol,p,'Educational single-carrier; no protocol framing',d);
    case 'gfsk'
        validateattributes(p.NumBits,{'numeric'},{'scalar','integer','positive'});
        validateattributes(p.BitRateHz,{'numeric'},{'scalar','positive','finite'});
        bits = randi([0 1],p.NumBits,1);
        [iq,f] = sm.gfsk(bits,p.BitRateHz,p.SamplesPerSymbol,p.BT,p.ModulationIndex);
        w = sm.pack(iq,p.BitRateHz*p.SamplesPerSymbol,p,'Educational GFSK; not a Bluetooth packet',struct('Bits',bits,'InstantaneousFrequencyHz',f));
    case 'oqpsk'
        validateattributes(p.NumChips,{'numeric'},{'scalar','integer','positive','even'});
        validateattributes(p.ChipRateHz,{'numeric'},{'scalar','positive','finite'});
        chips = randi([0 1],p.NumChips,1);
        iq = sm.oqpsk(chips,p.SamplesPerChip);
        w = sm.pack(iq,p.ChipRateHz*p.SamplesPerChip,p,'Educational half-sine OQPSK; no IEEE spreading or framing',struct('Chips',chips));
    case 'ofdm'
        [~,k] = sm.alphabet(p.Modulation); K = numel(p.ActiveSubcarriers);
        validateattributes(p.NumSymbols,{'numeric'},{'scalar','integer','positive'});
        validateattributes(p.SubcarrierSpacingHz,{'numeric'},{'scalar','positive','finite'});
        bits = randi([0 1],K*p.NumSymbols*k,1);
        s = reshape(sm.bitsToSymbols(bits,p.Modulation),K,[]);
        [iq,g] = sm.ofdmModulate(s,p.Nfft,p.Ncp,p.ActiveSubcarriers,p.TransformPrecoding);
        w = sm.pack(iq,p.Nfft*p.SubcarrierSpacingHz,p,'Educational OFDM; no pilots, coding, synchronization or protocol framing',struct('Bits',bits,'Symbols',s,'Grid',g));
    case {'wifi_nonht','wifi_ht','wifi_vht','wifi_he','wifi_eht'}
        w = sm.generateWLAN(p);
    case 'ble', w = sm.generateBLE(p);
    case 'bt_classic', w = sm.generateBT(p);
    case 'thread', w = sm.generateThread(p);
    case {'lte_dl','lte_ul'}, w = sm.generateLTE(p);
    case {'nr_dl','nr_ul'}, w = sm.generateNR(p);
    otherwise, error('sm:UnknownProtocol','Unknown protocol %s.',p.Protocol);
end
end
