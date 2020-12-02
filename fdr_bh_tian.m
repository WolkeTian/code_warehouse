function fdrQ = fdr_bh_tian(pvalues)
    pvalues_1dim = pvalues(:); % 转成一维
    
    [p_sorted, index] = sort(pvalues_1dim, 'descend'); % 从大到小排序
    fdrQ = zeros(size(pvalues_1dim));
    for i = 1:numel(pvalues_1dim)
        if i == 1
            fdrQ(i) = p_sorted(i); % 最大的p值不变
        else
            % 接下来依次计算p值
            fdrQ(i) = min(fdrQ(i-1), p_sorted(i) * numel(pvalues_1dim) / (numel(pvalues_1dim) - i + 1));
        end
    end
    results = zeros(size(pvalues_1dim));
    results(index) = fdrQ; % 恢复原来的排序
    fdrQ = reshape(results, size(pvalues)); % 恢复原来的维度   
    
end
    