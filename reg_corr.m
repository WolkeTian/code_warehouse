function residual = reg_corr(Y,X)
%从Y中回归掉X的影响，得出残差Y~
%   自动添加intercept项
X = [X,ones(size(X,1),1)];
residual = Y - X*(X\Y);
end

