function conn_binary = cost_threshold(conn_matrix, threshold)
% 将n*n的功能连接矩阵设置阈值为0.15
% conn_matrix: n*n的功能连接矩阵，对角线所有值为0
% threshold: 阈值，默认为0.15
% conn_matrix: 处理后的功能连接矩阵

if nargin < 2
    threshold = 0.15;
    disp('默认阈值为0.15')
end


% 生成全1矩阵, 用于后续取出上三角元素
temp_matrix = ones(size(conn_matrix));
temp_matrix = triu(temp_matrix,1);
triu_log_index = find(temp_matrix == 1);
% 将矩阵转换为上三角向量
elements = conn_matrix(triu_log_index);

% 获取上三角矩阵中数量
edge_nums = numel(elements);

% 计算保留的元素数量
keep_num = round(edge_nums * threshold);

% 对元素进行排序并保留前keep_num个
sorted_elements = sort(elements, 'descend');
threshold_value = sorted_elements(keep_num);

% 根据阈值保留矩阵中的元素
conn_matrix = conn_matrix.*(conn_matrix >= threshold_value);

% 除以平均值以normalize, 保证每个矩阵得到的不仅仅边数一致，权重和也一直
% 避免overall FC差异导致的网络组织差异(doi.org/10.1016/j.neuroimage.2017.02.005)
weights_mean = mean(nonzeros(conn_matrix));

conn_costed = conn_matrix./weights_mean;


conn_binary = logical(conn_costed);
% G_obj = graph(conn_binary);
% % 用conncomp判断图是否连通
% C = conncomp(G_obj);
% if max(C) ~= 1
%     disp(['图不是连通的,cost为 ', num2str(threshold)]);
% end

% 权重值设为负值，即按最大生成树思想执行
% % 最大生成树保证所有连接至少一条边
% % 求解最大生成树, 'Method','sparse'启用kruskal算法
% T = minspantree(G_obj, 'Method','sparse');
% if size(T.Edges,1) ~= (size(conn_matrix,1) - 1)
%     disp(['最大生成树生成失败, cost为 ', num2str(threshold)])
% end

end
