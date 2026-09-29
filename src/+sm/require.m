function require(names,product)
% Function presence is a preflight, NOT proof of a license checkout.
for k = 1:numel(names)
    if isempty(which(names{k}))
        error('sm:MissingDependency','Missing %s. Install/license %s; run check_environment.',names{k},product);
    end
end
end
