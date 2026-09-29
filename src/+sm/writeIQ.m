function writeIQ(path,x,kind)
% Single complex channel. Interleaved I0,Q0,I1,Q1, little endian.
assert(isvector(x) && all(isfinite(x(:))),'Expected finite single-channel IQ.');
x=x(:); a=[real(x).';imag(x).'];
switch kind
    case 'cf32_le', data=single(a); precision='single';
    case 'ci16_le'
        assert(max(abs(a(:)))<=1,'Normalize before int16 conversion.');
        data=int16(round(a*32767)); precision='int16';
    otherwise, error('sm:IQFormat','Unsupported IQ format %s.',kind);
end
fid=fopen(path,'w','ieee-le'); assert(fid>=0,'Cannot open %s',path);
c=onCleanup(@() fclose(fid)); %#ok<NASGU>
written=fwrite(fid,data,precision); assert(written==numel(data),'Incomplete IQ write.');
end
