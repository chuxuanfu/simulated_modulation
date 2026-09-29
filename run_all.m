function summary = run_all(mode)
% core: no optional toolboxes. all: protocol tests and waveform bundles too.
if nargin<1, mode='core'; end
assert(ismember(mode,{'core','all'}),'Mode must be core or all.');
root=setup(); check_environment(); tests=run_tests(mode);
assert(tests.Failed==0,'Tests failed. Inspect reports/tests_%s.json before generating a batch.',mode);
labs={@lab01_iq_sampling,@lab02_constellation_rrc,@lab03_ber_awgn,@lab04_ofdm_cp, ...
    @lab05_gfsk_oqpsk,@lab06_impairments,@lab11_papr_dftspread,@lab12_export_import,@lab13_dsss_fhss_chirp};
for k=1:numel(labs), labs{k}(); end
names={'basic','gfsk','oqpsk','ofdm'};
if strcmp(mode,'all')
    names=[names {'wifi_nonht','wifi_ht','wifi_vht','wifi_he','wifi_eht', ...
        'ble','bt_classic','thread','lte_dl','lte_ul','nr_dl','nr_ul'}];
end
rows=repmat(struct('Protocol','','Status','','Message',''),numel(names),1);
for k=1:numel(names)
    rows(k).Protocol=names{k};
    try
        generate_waveform(sm.defaultConfig(names{k})); rows(k).Status='PASS';
    catch err
        if strcmp(err.identifier,'sm:MissingDependency'), rows(k).Status='SKIP';
        else, rows(k).Status='FAIL'; end
        rows(k).Message=getReport(err,'extended','hyperlinks','off'); fprintf('%s\n',rows(k).Message);
    end
end
summary=struct('Mode',mode,'Tests',tests,'Generation',rows);
sm.writeJSON(fullfile(root,'reports',['run_' mode '.json']),summary);
assert(~any(strcmp({rows.Status},'FAIL')),'Some generators failed; see reports/run_%s.json.',mode);
fprintf('Finished. %d waveform bundles; %d skipped. Reports: %s\n',sum(strcmp({rows.Status},'PASS')),sum(strcmp({rows.Status},'SKIP')),fullfile(root,'reports'));
end
