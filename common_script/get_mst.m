function meanweight = get_mst(conn_matrix)
% 权重值设为负值，即按最大生成树思想执行
% 最大生成树保证所有连接至少一条边
% 求解最大生成树, 'Method','sparse'启用kruskal算法
conn_neg = conn_matrix.*-1;
G_obj = graph(conn_neg);
T = minspantree(G_obj, 'Method','sparse');
% 检查是否生成成功
if size(T.Edges,1) ~= (size(conn_matrix,1) - 1)
    disp('最大生成树生成失败');
end
meanweight = mean(T.Edges.Weight).*-1;
% 除以全脑平均FC
meanweight = meanweight / (mean(conn_matrix(conn_matrix > 0)));

end