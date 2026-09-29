function y = pulseShape(symbols,h,sps)
u = zeros((numel(symbols)-1)*sps+1,1);
u(1:sps:end) = symbols(:); y = conv(u,h(:),'full');
end
