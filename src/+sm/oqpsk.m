function x = oqpsk(chips,samplesPerSerialChip)
% Serial chips at Rc. Each branch pulse spans 2/Rc; Q delayed by 1/Rc.
c = 1-2*double(chips(:)); assert(mod(numel(c),2)==0,'Even number of chips required.');
s = samplesPerSerialChip;
validateattributes(s,{'numeric'},{'scalar','integer','>=',2});
h = sin(pi*(0:2*s).'/ (2*s));
i = sm.pulseShape(c(1:2:end),h,2*s);
q = sm.pulseShape(c(2:2:end),h,2*s);
x = [i;zeros(s,1)] + 1i*[zeros(s,1);q];
end
