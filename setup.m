function root = setup()
% SETUP Add this project's paths for the current MATLAB session only.
root = fileparts(mfilename('fullpath'));
addpath(root,fullfile(root,'src'),fullfile(root,'examples'),fullfile(root,'tests'));
for name = {'generated','reports'}
    p = fullfile(root,name{1});
    if ~isfolder(p), mkdir(p); end
end
fprintf('Simulated Modulation: %s\nRun check_environment, then run_all(''core'').\n',root);
end
