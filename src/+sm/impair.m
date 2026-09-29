function [y,info] = impair(x,fs,o)
% Deliberate processing order: FIR -> IQ -> CFO/phase -> noise -> clipping.
% Noise SNR is relative to full-record, post-channel mean power PER channel.
def=struct('Seed',123,'Taps',1,'IQGainImbalanceDB',0,'IQPhaseErrorDeg',0, ...
    'CFOHz',0,'PhaseDeg',0,'PhaseNoiseStepStdDeg',0, ...
    'AddNoise',false,'SNRdB',30,'ClipMagnitude',0);
if nargin<3, o=struct; end
f=fieldnames(o);
for k=1:numel(f)
    assert(isfield(def,f{k}),'Unknown impairment %s.',f{k}); def.(f{k})=o.(f{k});
end
o=def; validateattributes(fs,{'numeric'},{'scalar','positive','finite'});
validateattributes(x,{'numeric'},{'2d','nonempty','finite'});
for name={'IQGainImbalanceDB','IQPhaseErrorDeg','CFOHz','PhaseDeg','SNRdB'}
    validateattributes(o.(name{1}),{'numeric'},{'scalar','real','finite'});
end
validateattributes(o.PhaseNoiseStepStdDeg,{'numeric'},{'scalar','nonnegative','finite'});
validateattributes(o.Seed,{'numeric'},{'scalar','integer','>=',0,'<=',2^32-1});
assert(abs(o.CFOHz)<fs/2,'CFO must be inside sampled band; still check signal edge aliasing.');
validateattributes(o.Taps,{'numeric'},{'vector','nonempty','finite'});
validateattributes(o.ClipMagnitude,{'numeric'},{'scalar','nonnegative','finite'});
state=rng; cleanup=onCleanup(@() rng(state)); %#ok<NASGU>
rng(o.Seed,'twister'); y=filter(o.Taps,1,x); % FIR tail truncated, recorded below
q=imag(y)*10^(o.IQGainImbalanceDB/20); a=o.IQPhaseErrorDeg*pi/180;
y=real(y)+q*sin(a)+1i*q*cos(a);
t=(0:size(y,1)-1).'/fs;
phi=o.PhaseDeg*pi/180+2*pi*o.CFOHz*t;
if o.PhaseNoiseStepStdDeg>0
    phi=phi+cumsum(randn(size(t)))*o.PhaseNoiseStepStdDeg*pi/180;
end
y=y.*exp(1i*phi);
noisePower=zeros(1,size(y,2));
if o.AddNoise
    noisePower=mean(abs(y).^2,1)/10^(o.SNRdB/10);
    y=y+(randn(size(y))+1i*randn(size(y))).*sqrt(noisePower/2);
end
clipped=zeros(1,size(y,2));
if o.ClipMagnitude>0
    clipped=mean(abs(y)>o.ClipMagnitude,1);
    y=y.*min(1,o.ClipMagnitude./max(abs(y),realmin));
end
info=struct('Settings',o,'NoiseVariancePerComplexSample',noisePower, ...
    'ClippedFraction',clipped,'FIRTailTruncatedSamples',numel(o.Taps)-1, ...
    'Note','Toy phase random walk; not a calibrated oscillator phase-noise mask.');
end
