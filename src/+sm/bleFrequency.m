function fc = bleFrequency(index)
validateattributes(index,{'numeric'},{'scalar','integer','>=',0,'<=',39});
if index==37, mhz=2402;
elseif index==38, mhz=2426;
elseif index==39, mhz=2480;
elseif index<=10, mhz=2404+2*index;
else, mhz=2406+2*index;
end
fc = mhz*1e6;
end
