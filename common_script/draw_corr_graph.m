function draw_corr_graph(x, y)
    % 排序
    [x,I] = sort(x);
    y = y(I);
    % 设置黄金分割比例
    golden_ratio = 1.618;
    width = 800;  % 宽度（单位：像素）
    height = width / golden_ratio;  % 高度根据黄金分割比例计算
    % 创建图形
    figure('Units', 'pixels', 'Position', [100, 100, width, height]);
    
    % 定义颜色
    color1 = [255/255, 148/255, 131/255]; %橙色
    color2 = [64/255, 151/255, 170/255]; %蓝色
        
    % 计算线性拟合
    [p,S] = polyfit(x, y, 1);
    y_fit = polyval(p, x);

    % 计算置信区间
    [y_pred, delta] = polyconf(p, x, S,'alpha', 0.05, 'predopt', 'curve'); 
    % 插值处理置信区间上下限，使其平滑
   
    x_interp = linspace(min(x), max(x), 1000);
     % 增加unique()避免报错:采样点必须唯一
    y_pred_interp = interp1(unique(x), unique(y_pred), x_interp, 'pchip');
    delta_interp = interp1(unique(x), unique(delta), x_interp, 'pchip');

    xconf = [x_interp';fliplr(x_interp)'] ;%fliplr: 左右翻转数组;
    yconf = [y_pred_interp'+delta_interp';fliplr(y_pred_interp)'-delta_interp'];%delta就是条带宽度，换成矩阵就会有不同的宽度
    
    % 第一个'r'是置信区间边缘的颜色，后续已改为none不显示
    % 'Facealpha', 0.4透明度
    fill(xconf,yconf,'k', 'FaceColor',[1 0.8 0.8], 'Facealpha', 0.4,'EdgeColor','none');
    hold on;

    % 绘制相关散点图
    scatter(x, y, 'filled', 'MarkerFaceColor', color2);

    % 绘制拟合直线
    plot(x_interp,y_pred_interp, 'r', 'LineWidth', 2,'color', color1);
    % 隐藏右侧框线
    box off;
    hold off;
    % 调整坐标范围,计算留白距离
    x_margin = 0.04 * (max(x) - min(x));
    y_margin = 0.2 * (max(y) - min(y));
    
    % 调整坐标范围（加上留白距离）
    xlim([min(x) - x_margin, max(x) + x_margin]);
    ylim([min(y) - y_margin, max(y) + y_margin+0.005]);

    % 在y=0处延申一根虚线
%     x_range = max(x) - min(x);
%     line(xlim, [0, 0], 'Color', 'k', 'LineStyle', '--');

    % xlabel('X轴');
    % ylabel('Y轴');
    % title('相关散点图');
    % legend('散点', '拟合直线');
    % 添加r和p值信息
%     [r,p] = corr(x, y);
%     text(max(x) - x_margin, max(y) - y_margin, sprintf('r = %.4f\np = %.4f', r, p), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
 % 设置坐标轴字体大小和字体类型
    ax = gca;
    ax.FontSize = 34;
    ax.FontName = 'Arial';

end