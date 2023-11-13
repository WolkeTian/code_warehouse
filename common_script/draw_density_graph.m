function draw_density_graph(vector1, vector2)
    [h,p,ci,stats] = ttest(vector2, vector1); 
    % tstat: 0.2433; ci: -0.0101    0.0128; p 0.8094;
    
    %% 绘图
    [fs1, xis1] = ksdensity(vector1); [fs2, xis2] = ksdensity(vector2);
    
    % 找到两组数据的密度图峰值处
    [~, idx1] = max(fs1);
    [~, idx2] = max(fs2);
    % 定义颜色方案
    color1 = [255/255, 148/255, 131/255]; %橙色
    color2 = [64/255, 151/255, 170/255]; %蓝色
    
    
    figure
    hold on
    h1 = fill([xis1 fliplr(xis1)], [zeros(size(fs1)) fliplr(fs1)], color1,'EdgeColor', 'none', 'FaceAlpha', 0.7);
    % 'FaceAlpha', 0.5 透明度
    h2 = fill([xis2 fliplr(xis2)], [zeros(size(fs2)) fliplr(fs2)], color2,'EdgeColor', 'none', 'FaceAlpha', 0.7);
    
    xlabel('PCnorm of connector hubs', 'FontSize', 20); ylabel('Frequency', 'FontSize', 20);
    
%     title('Autodetected Community', 'FontSize', 24);
    % 添加*
    if p < 0.001
        sig_sign = '***';
    elseif p < 0.01
        sig_sign = '**';
    elseif p < 0.05
        sig_sign = '*';
    else
        sig_sign = 'ns';
    end
    
    % 添加*
   text(mean([xis1(idx1) xis2(idx2)]), max([fs1 fs2])*1.2, sig_sign, 'FontSize', 24, 'HorizontalAlignment', 'center');
    % 绘制连接两个峰值的横线
    line([xis1(idx1) xis2(idx2)], [max([fs1,fs2])*1.12 max([fs2,fs1])*1.12], 'LineWidth', 2, 'Color', 'black');
    ylim([0, max([fs1,fs2])*1.3]);
    set(gca, 'FontSize', 16);
    legend([h1, h2], {'NS', 'SD'}, 'FontSize', 18,'Location', 'NorthEast');
    % 修改背景色、坐标轴和标签的颜色
    set(gcf, 'color', 'w');
    
    set(get(gca, 'xlabel'), 'FontName', 'Arial', 'FontSize', 20);
    set(get(gca, 'ylabel'), 'FontName', 'Arial', 'FontSize', 20);
    %set(get(gca, 'title'), 'FontName', 'Arial', 'FontSize', 24, 'Color', color1);
    set(legend, 'FontName', 'Arial', 'FontSize', 18, 'TextColor', 'black', 'EdgeColor', 'none', 'Color', 'none');
end