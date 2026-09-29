function r = lab06_impairments()
p=sm.defaultConfig('basic'); p.Modulation='16QAM'; w=sm.generate(p);
settings={struct('AddNoise',true,'SNRdB',20),struct('CFOHz',5000), ...
    struct('IQGainImbalanceDB',2,'IQPhaseErrorDeg',10),struct('ClipMagnitude',0.25)};
names={'AWGN','CFO','IQ imbalance','Clipping'}; results=cell(1,4);
fig=figure('Visible','off','Color','w');
for k=1:4
    [y,info]=sm.impair(w.iq,w.fs,settings{k});
    z=conv(y,w.details.Pulse); delay=numel(w.details.Pulse)-1;
    s=z(delay+1+(0:p.NumSymbols-1)*p.SamplesPerSymbol); s=s(:);
    results{k}=struct('Name',names{k},'EVM',sm.evm(s,w.details.Symbols,false),'Impairment',info);
    subplot(2,2,k); plot(real(s),imag(s),'.'); axis equal; title(names{k});
end
sm.saveFigure(fig,'lab06_impairments'); r=results; disp(r);
end
