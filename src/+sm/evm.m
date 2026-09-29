function r = evm(received,reference,fitComplexGain)
% Already aligned symbols required; fit only one complex scalar, no timing.
if nargin<3, fitComplexGain=false; end
received=received(:); reference=reference(:);
assert(numel(received)==numel(reference),'EVM vectors must have equal length.');
assert(sum(abs(reference).^2)>0,'Nonzero reference required.');
gain=1;
if fitComplexGain
    gain=(reference'*received)/(reference'*reference);
    assert(abs(gain)>eps,'Estimated gain is zero.'); received=received/gain;
end
r.RMSPercent=100*sqrt(sum(abs(received-reference).^2)/sum(abs(reference).^2));
r.FittedComplexGain=gain; r.GainFitApplied=logical(fitComplexGain);
end
