function [R2, P, raw_values, predicted_values, corr_res] = multi_regress_hubs(Y, X)
% add ones column

New_X = [X, ones(size(X,1),1)];
% 移除nan项
rows_nan = find(isnan(Y));
Y(rows_nan,:)  = [];
New_X(rows_nan, :) = [];
% 拟合
[b,~,~,~,stats] = regress(Y, New_X);
% 输出结果
P = stats(3);
R2 = stats(1);
raw_values = Y;
predicted_values = New_X*b;
[corr_res.r, ~] = corr(Y, predicted_values);
% PT得到p值,1000次
ptimes = 1e3;
for i = 1:1e3
    Y_permed = Y(randperm(numel(Y)));
    [~,~,~,~,stats] = regress(Y_permed, New_X);
    R2_permed(i) = stats(1);
end
% 得到p值
corr_res.p = sum(R2 < R2_permed)/ptimes;



end
