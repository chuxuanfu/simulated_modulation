function r = lab10_nr_resource_grid()
% Uncoded codeword mapping -> resource grid -> OFDM -> demapping/descrambling.
sm.require({'nrPDSCH','nrPDSCHDecode','nrOFDMModulate'},'5G Toolbox');
state=rng; cleanup=onCleanup(@() rng(state)); %#ok<NASGU>
rng(110); c=nrCarrierConfig('NSizeGrid',24,'SubcarrierSpacing',30,'NCellID',1);
p=nrPDSCHConfig('PRBSet',0:23,'Modulation','16QAM','NumLayers',1);
[ind,info]=nrPDSCHIndices(c,p); bits=randi([0 1],info.G,1);
s=nrPDSCH(c,p,bits); g=nrResourceGrid(c,1); g(ind)=s;
g(nrPDSCHDMRSIndices(c,p))=nrPDSCHDMRS(c,p);
[x,ofdm]=nrOFDMModulate(c,g,'Windowing',0);
y=nrOFDMDemodulate(c,x); recovered=y(ind);
llr=nrPDSCHDecode(c,p,recovered); bhat=double(llr{1}<0);
e=sm.evm(recovered,s,false);
r=struct('CodewordBitErrors',sum(bhat~=bits),'EVMPercent',e.RMSPercent,'SampleRateHz',ofdm.SampleRate);
assert(r.CodewordBitErrors==0 && r.EVMPercent<1e-8,'NR mapping loopback failed.');
fig=figure('Visible','off','Color','w'); imagesc(abs(g)); axis xy;
xlabel('OFDM symbol'); ylabel('Subcarrier'); title('PDSCH + DM-RS resource grid'); colorbar;
sm.saveFigure(fig,'lab10_nr_grid'); disp(r);
end
