function draw_heatmap(data, rowLabels, colLabels, colorMap)
% 绘制热度图
% 输入：
%   - data: 数据矩阵
%   - rowLabels: 行标签
%   - colLabels: 列标签
%   - colorMap: 颜色映射

% 创建热度图
figure();

width=600;%宽度，像素数
height=600;%高度

h = heatmap(data);

% 设置行和列标签
h.YDisplayLabels = rowLabels;
h.XDisplayLabels = colLabels;

% 设置颜色映射
colormap(colorMap);

% % 获取 Axes 对象
% ax = gca;
% 
% % 设置图像长宽比为1：1
% ax.Position(3) = ax.Position(4);

% 添加标题
%title('热度图');



end