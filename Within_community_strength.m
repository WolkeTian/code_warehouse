function Z = Within_community_strength(W,Ci)
% Within-community strength measures how well-connected node i is to 
% other nodes in the community relative to other nodes in the community.
K_nodes = zeros(length(Ci),1); % 每个节点的k（与社团内节点的连接和）
for i = 1:length(Ci)
    mod_ind = Ci(i);
    within = find(Ci == mod_ind);
    within(within == i) = []; % 去除自身
    weights = W(i,within); % 去除社群内的权重
    k = sum(weights);
    K_nodes(i) = k;
end
% 计算第i个社团的k均值和标准差
for i = 1:max(Ci)
    K_nodes(Ci == i);
    k_ava = mean(K_nodes(Ci == i));
    k_std = std(K_nodes(Ci == i));
    k_avas(i) = k_ava;
    k_stds(i) = k_std;
end

% 计算第i个节点的Within_community_strength
within_stres = zeros(length(Ci),1);
for i = 1:length(Ci)
    mod_ind = Ci(i);
    k = K_nodes(i);
    k_ava = k_avas(mod_ind);
    k_std = k_stds(mod_ind);
    within_stre = (k - k_ava)/k_std;
    within_stres(i) = within_stre;
end

Z = within_stres;
Z(isnan(Z))=0;
end

