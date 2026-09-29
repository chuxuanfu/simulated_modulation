function r = lab03_ber_awgn()
% Symbol-domain AWGN: Es=1; N0=1/(k*EbN0); no oversampling correction here.
state=rng; cleanup=onCleanup(@() rng(state)); %#ok<NASGU>
rng(103); modes={'BPSK','QPSK','16QAM'}; eb=0:2:12; N=200000;
ber=zeros(numel(modes),numel(eb)); upper=zeros(size(ber));
for m=1:numel(modes)
    [~,k]=sm.alphabet(modes{m}); bits=randi([0 1],N*k,1); s=sm.bitsToSymbols(bits,modes{m});
    for j=1:numel(eb)
        n0=1/(k*10^(eb(j)/10)); y=s+sqrt(n0/2)*(randn(size(s))+1i*randn(size(s)));
        errors=sum(sm.symbolsToBits(y,modes{m})~=bits);
        ber(m,j)=errors/numel(bits);
        if errors==0, upper(m,j)=3/numel(bits); else, upper(m,j)=NaN; end
    end
end
theory=0.5*erfc(sqrt(10.^(eb/10)));
% At Eb/N0=0 dB, both binary and quadrature Gray PSK should match theory.
assert(all(abs(ber(1:2,1)-theory(1))<0.003),'Noise variance/bit mapping regression.');
fig=figure('Visible','off','Color','w');
handles=gobjects(1,numel(modes)+1);
for m=1:numel(modes)
    measured=ber(m,:); measured(measured==0)=NaN;
    handles(m)=semilogy(eb,measured,'o-'); hold on;
    zero=(ber(m,:)==0);
    semilogy(eb(zero),upper(m,zero),'v','Color',handles(m).Color,'HandleVisibility','off');
end
handles(end)=semilogy(eb,theory,'k--'); ylim([1e-6 0.3]); grid on;
xlabel('Eb/N0 (dB), uncoded information bits'); ylabel('BER'); legend(handles,[modes {'BPSK/QPSK theory'}]);
title('Downward triangles: zero-error 95% upper bounds');
sm.saveFigure(fig,'lab03_ber');
r=struct('Modes',{modes},'EbN0dB',eb,'BER',ber,'ZeroError95PercentUpperBound',upper);
save(fullfile(sm.root(),'reports','lab03_ber.mat'),'r'); disp(ber);
end
