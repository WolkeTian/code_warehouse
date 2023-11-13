function draw_radia_graph(graph_data, labels)% 准备数据
    theta = linspace(0, 2*pi, numel(labels)+1); % 设置角度
    data = [graph_data; graph_data(1)];
    % 创建雷达图
    color2 = [64/255, 151/255, 170/255];
    polarplot(theta, data, '-o','MarkerFaceColor', color2,'Color', color2, 'LineWidth', 2); % 使用 '-' 连接数据点，并用 'o' 表示数据点
    
    % 设置雷达图样式
    ax = gca;
    ax.ThetaAxisUnits = 'radians'; % 设置角度单位为弧度
    ax.ThetaZeroLocation = 'top'; % 将起点设置为顶部
    ax.ThetaTick = linspace(0, 2*pi, numel(labels)+1); % 设置刻度线的位置


    ax.RLim = [-1 5]; % 设置半径范围
    % 设置刻度标签位置 隐藏圆心点刻度标签
    rticklabels({'0', '2', '4'});
%     rticklabels({'', '0', '2', '4'});
    % 添加标签
    pax = gca;
    pax.ThetaTickLabel = labels; % 设置标签
    % 设置字体大小
    set(gca, 'FontSize', 20, 'FontName', 'Arial');  % 设置字体大小为12
end