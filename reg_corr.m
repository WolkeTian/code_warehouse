function residual = reg_corr(Y,X)
%��Y�лع��X��Ӱ�죬�ó��в�Y~
%   �Զ����intercept��
X = [X,ones(size(X,1),1)];
residual = Y - X*(X\Y);
end

