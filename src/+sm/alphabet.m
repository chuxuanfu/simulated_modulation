function [a,k] = alphabet(modulation)
modulation = upper(char(modulation));
switch modulation
    case 'BPSK', a = [1;-1]; k = 1;
    case 'QPSK', a = [1+1i;1-1i;-1+1i;-1-1i]/sqrt(2); k = 2;
    case {'16QAM','64QAM','256QAM'}
        M = str2double(strrep(modulation,'QAM','')); k = log2(M); m = sqrt(M);
        label = uint32((0:M-1).');
        gI = bitshift(label,-k/2); gQ = bitand(label,uint32(m-1));
        bI = gI; bQ = gQ;
        for shift = 1:k/2-1
            bI = bitxor(bI,bitshift(gI,-shift));
            bQ = bitxor(bQ,bitshift(gQ,-shift));
        end
        a = (2*double(bI)-(m-1) + 1i*(2*double(bQ)-(m-1)))/sqrt(2*(M-1)/3);
    case '8PSK'
        k = 3; g = uint32((0:7).'); b = bitxor(g,bitshift(g,-1)); b = bitxor(b,bitshift(g,-2));
        a = exp(1i*2*pi*double(b)/8);
    otherwise, error('sm:Modulation','Unsupported modulation %s.',modulation);
end
end
