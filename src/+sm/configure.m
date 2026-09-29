function p = configure(protocol,overrides)
% Strict merge catches misspelled fields rather than silently ignoring them.
p = sm.defaultConfig(protocol);
if nargin < 2, return; end
assert(isstruct(overrides) && isscalar(overrides),'Overrides must be a scalar struct.');
f = fieldnames(overrides);
for k = 1:numel(f)
    assert(isfield(p,f{k}),'Unknown parameter: %s',f{k});
    assert(~strcmp(f{k},'Protocol'),'Choose protocol using first argument.');
    p.(f{k}) = overrides.(f{k});
end
end
