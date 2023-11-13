function swness = get_smallworldness(network)
% 100次重连 ~4.4s
rand_graph = randmio_und(network,100);
shortest_path = distance_wei(rand_graph); % 获取最短距离矩阵
% 排除0或者inf
shortest_path(shortest_path == 0 | shortest_path == inf) = [];
LR = mean(shortest_path); % 计算随机网络的平均最短路径
CR = mean(clustering_coef_wu(rand_graph)); % 获取平均聚类系数

% 真实系数
shortest_path = distance_wei(network);
shortest_path(shortest_path == 0 | shortest_path == inf) = [];
L = mean(shortest_path);
C = mean(clustering_coef_wu(network));
% 计算
Ls = L / LR;
Cs =  C / CR;
swness = Cs / Ls;
end
