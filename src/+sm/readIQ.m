function x = readIQ(path,kind)
% ci16_le returns normalized double; divide by 32767 (not 32768).
switch kind
    case 'cf32_le', precision='single=>double'; scale=1; bytes=4;
    case 'ci16_le', precision='int16=>double'; scale=32767; bytes=2;
    otherwise, error('sm:IQFormat','Unsupported IQ format.');
end
s=dir(path); assert(~isempty(s) && mod(s.bytes,2*bytes)==0,'Missing or truncated IQ file.');
fid=fopen(path,'r','ieee-le'); assert(fid>=0,'Cannot open %s',path);
c=onCleanup(@() fclose(fid)); %#ok<NASGU>
a=fread(fid,Inf,precision); assert(mod(numel(a),2)==0,'Truncated IQ pair.');
x=(a(1:2:end)+1i*a(2:2:end))/scale;
end
