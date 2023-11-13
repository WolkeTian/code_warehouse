function [t, p, CI, delta_coeff, index_hub] = ttest_hubs(coeffs_s1, coeffs_s2, hub_nums)
    % coeffs: nodes * subs
    [~, index_hub] = sort(mean(coeffs_s1,2), 'descend');
    
    index_hub = index_hub(1:hub_nums);
    % 取出chub的PC系数
    coeff_hub_s1 = coeffs_s1(index_hub,:);
    coeff_hub_s2 = coeffs_s2(index_hub,:);
    % 指定数量的hub系数的差值(ses1-ses2);size转为sub*hubs
    delta_coeff = (coeff_hub_s1 - coeff_hub_s2)';
    % 配对t检验
    for hub = 1:hub_nums

        [~,p(hub), ci95, stats] = ttest(coeff_hub_s1(hub, :), coeff_hub_s2(hub, :)); 
        t(hub) = stats.tstat;
        CI(hub,:) = ci95;
    end
    % 对均值进行t检验,保存在最后一位
    [~,p(hub_nums+1), CI(hub_nums+1, :), stats] = ttest(mean(coeff_hub_s1,1)', mean(coeff_hub_s2, 1)'); 
    t(hub_nums+1) = stats.tstat;
    % 进行F检验; ranova

end