function [s,alphabet] = bitsToSymbols(bits,modulation)
% Educational Gray-labelled mapper. NOT a replacement for protocol mappers.
bits = double(bits(:)); assert(all(bits==0 | bits==1),'Expected binary bits.');
[alphabet,k] = sm.alphabet(modulation);
assert(mod(numel(bits),k)==0,'Bit length must be divisible by log2(M).');
v = reshape(bits,k,[]).';
labels = v*(2.^(k-1:-1:0)).';
s = alphabet(labels+1);
end
