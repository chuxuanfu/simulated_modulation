function b = bytesToBits(bytes)
% LSB first within each octet; octets remain in supplied order.
bytes = uint8(bytes(:)); a = zeros(numel(bytes),8);
for k = 1:8, a(:,k) = bitget(bytes,k); end
b = reshape(a.',[],1);
end
