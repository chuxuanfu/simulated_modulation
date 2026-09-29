function bits = symbolsToBits(s,modulation)
s = s(:);
[a,k] = sm.alphabet(modulation);
% Chunk the distance matrix to keep memory bounded for large captures.
labels = zeros(numel(s),1);
for first = 1:8192:numel(s)
    idx = first:min(first+8191,numel(s));
    [~,j] = min(abs(s(idx(:))-a.').^2,[],2); labels(idx) = j-1;
end
b = zeros(numel(s),k);
for j = 1:k, b(:,j) = bitget(uint32(labels),k-j+1); end
bits = reshape(b.',[],1);
end
