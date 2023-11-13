function draw_square_chart(connmat)
imagesc(connmat);
% 取消显示横纵轴刻度线
%set(gca,'xtick',[],'xticklabel',[]); set(gca,'ytick',[],'yticklabel',[]);
axis off;
colormap("jet");
% 设置坐标轴为紧贴图像 保证长宽一致
axis image;

end