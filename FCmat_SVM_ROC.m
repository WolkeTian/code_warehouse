clear;close;
% 供方阵使用
NumROI  = 90; % 矩阵ROI数目
NumCon = 51; %连接数目，进入作为特征值的规定数量

%length(file1) sad组数量，length(file2)，hc组数量
num_sad = 200; num_hc = 250; % to test


% 是否选择连接mask
conn_msk = ones(NumROI); % 否的话生成全1矩阵

Ind_01    = find(triu(ones(NumROI),1)); % 上三角的索引
Ind_02    = find(conn_msk(Ind_01) ~= 0); % （Ind_01中）mask后的索引

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 读取功能连接数据
DATA_sad = zeros(length(file1), length(Ind_02)); % 被试数*连接数
% DATA_sad(i,:) = corROI4(Ind_01(Ind_02)); % 读取

DATA_hc = zeros(length(file2), length(Ind_02));
DATA_hc(i,:) = corROI4(Ind_01(Ind_02));

% 两组特征合并
DATA = [DATA_sad;DATA_hc];
label  = [ones(size(DATA_sad,1),1); -1*ones(size(DATA_hc,1),1)];% 病人为1，对照为-1

%% svm分类
h = waitbar(0,'please wait..');
for i = 1:size(DATA,1) %每个被试循环
    waitbar(i/size(DATA,1),h,[num2str(i),'/',num2str(size(DATA,1))])
    new_DATA = DATA;
    new_label  = label;
    test_data   = DATA(i,:);new_DATA(i,:) = []; train_data = new_DATA; %留一法交叉验证，该被试作为测试数据
    test_label   = label(i,:);new_label(i,:) = [];train_label = new_label;
    
    % F_score feature selection
    % F检验筛选特征值
    % training data in the sad group
    data_sad    = train_data(train_label==1,:); %训练集中的病人数据
    % training data in the hc group
    data_hc      = train_data(train_label==-1,:);
    x_sad         = mean(data_sad);
    x_hc           = mean(data_hc);
    x_data        = mean(train_data);
    for k = 1:size(train_data,2)
        for j = 1:size(train_data,1)
            if j<=size(data_sad,1)
                AA_sad(j) = (train_data(j,k)-x_sad(k))^2;
                sum_sad(k) = sum(AA_sad);
            else
                BB_hc(j-size(data_sad,1)) = (train_data(j,k)-x_hc(k))^2;
                sum_hc(k) = sum(BB_hc);
            end
        end
        % 储存F值
        F(i,k) = ((x_sad(k)-x_data(k))^2+(x_hc(k)-x_data(k))^2)/((sum_sad(k)/(size(data_sad,1)-1))+(sum_hc(k)/(size(data_hc,1)-1)));
    end
    clear AA_sad sum_sad BB_hc sum_hc x_sad x_hc x_data
    
    %       % t-score for feature selection
    %     [~,~,~,stat] = ttest2(train_data(train_label==1,:),train_data(train_label==-1,:));
    %     F(i,:)               = abs(stat.tstat); % 储存t值（绝对值）
    %     clear stat
    
    %     % correlation for feature selection
    %     r = r = corr(train_data, train_label,'type','Spearman');
    %     F(i,:) = abs(r);
    
    [B,IX] = sort(F(i,:),'descend'); %B, 从大到校的T值/F值，IX，B在F中的相应序号.
    % 根据测试，T和F检验结果基本一致（因为进入最后的只是由大小关系决定）
    order(i,:) = IX;
    strength(i,:) = B; %强度和大小排位存储在order和strength中，第几行就是第几个被试
    
    % parameter selection 选择最优参数
    [bestacc,bestc] = SVMcgForClass_NoDisplay_linear(train_label,train_data(:,order(i,1:NumCon)),-5,5,5,0.2);
    cmd = ['-t 0', '-c ',num2str(bestc)]; % 参数， c使用自动寻找到的参数
    
    %训练模型 只有前NumCon大的连接才会进入作为特征值
    model = svmtrain(train_label,train_data(:,order(i,1:NumCon)), cmd);
    w(i,:)   = model.SVs'*model.sv_coef; %支持向量的权重
    [predicted_label accuracy deci] = svmpredict(test_label,test_data(:,order(i,1:NumCon)),model);
    acc(i) = accuracy(1); %第n个被试的acc值和预测值
    deci_value(i) = deci;
    clear k j model cmd
end
close(h)
acc_final = mean(acc); % 平均acc表现（每一层交叉的均值）

% %AUC 画AUC曲线
[X,Y,T,AUC] = perfcurve(label,deci_value,1);
disp(['AUC= ', num2str(AUC)]);
figure;plot(X,Y);hold on;plot(X,X,'-');
xlabel('False positive rate'); ylabel('True positive rate'); % 得到敏感度和特异性

for i=1:length(X)
    Cut_off(i,1) = (1-X(i))*Y(i);
end
[~,maxind] = max(Cut_off);
disp(['Specificity= ', num2str(1-X(maxind))]);
disp(['Sensitivty= ', num2str(Y(maxind))]);

fprintf('Permutation test ......\n');
Nsloop = 5000;
auc_rand = zeros(Nsloop,1);
for i=1:Nsloop
    label_rand = randperm(length(label));
    deci_value_rand = deci_value(label_rand);
    [~,~,~,auc_rand(i)] = perfcurve(label,deci_value_rand,1);
    clear label_rand
end
p_auc = mean(auc_rand >= AUC);
disp(['Pvalue= ', num2str(p_auc)]); % 置换检验，和随机AUC对比，得到AUC得分p值

%% find consensus feature 找寻一致（每层都出现）的特征
for i=1:size(order,1)
    A = zeros(NumROI);
    A(Ind_01(Ind_02((order(i,1:NumCon))))) = w(i,:);
    A = A+A';
    cons_feature(:,:,i) = A; % ROIs*ROIs*被试数，包含每一层（被试）的权重。堆成矩阵
    clear A
end
cons_feature_mask = double(sum(cons_feature ~= 0,3)==size(DATA,1)); % 得到每层都被选中的连接的位置

cons_feature_mean = mean(cons_feature,3).*double(cons_feature_mask~=0);  % 得到一致出现的连接的权重均值
cons_feature_label = []; k=1;
for i=1:NumROI-1
    for j=i+1:NumROI % i,j关系表明在矩阵上三角
        if cons_feature_mean(i,j) ~= 0
            % 得到n行3列变量，n代表一致连接的数量，第三列为权重值
            cons_feature_label(k,:) = [i j cons_feature_mean(i,j)]; k=k+1;
        end
    end
end

% permutation test 得到acc置换检验的p值
permut                = 100; % 随机置换次数
acc_final_rand     = zeros(permut,1);
h = waitbar(0,'please wait..');
for i=1:permut
    waitbar(i/permut,h,['permutation:',num2str(i),'/',num2str(permut)]);
    % 随机置换label
    randlabel = randperm(length(label));
    label_r  = label(randlabel);
    for j=1:size(DATA,1)
        new_DATA = DATA;
        new_label  = label_r;
        test_data   = new_DATA(j,:);  new_DATA(j,:) = []; train_data = new_DATA;
        test_label  = new_label(j,:);    new_label(j,:)  = [];  train_label = new_label;
        
        % F_score feature selection
        data_sad    = train_data(train_label==1,:);
        data_hc      = train_data(train_label==-1,:);
        x_sad         = mean(data_sad);
        x_hc           = mean(data_hc);
        x_data        = mean(train_data);
        F = zeros(1,size(train_data,2));
        for k = 1:size(train_data,2)
            for m = 1:size(train_data,1)
                if m<=size(data_sad,1)
                    AA_sad(m) = (train_data(m,k)-x_sad(k))^2;
                    sum_sad(k) = sum(AA_sad);
                else
                    BB_hc(m-size(data_sad,1)) = (train_data(m,k)-x_hc(k))^2;
                    sum_hc(k) = sum(BB_hc);
                end
            end
            F(1,k) = ((x_sad(k)-x_data(k))^2+(x_hc(k)-x_data(k))^2)/((sum_sad(k)/(size(data_sad,1)-1))+(sum_hc(k)/(size(data_hc,1)-1)));
        end
        clear AA_sad sum_sad BB_hc sum_hc x_sad x_hc x_data
        
        %       % t-score for feature selection
        %     [~,~,~,stat] = ttest2(train_data(train_label==1,:),train_data(train_label==-1,:));
        %     F               = abs(stat.tstat);
        %     clear stat
        
        %     % correlation for feature selection
        %     r   = corr(train_data, train_label,'type','Spearman');
        %     F  = abs(r);
        
        [B,IX] = sort(F,'descend');
        order = IX;
        strength = B;
        
        % parameter selection
        [bestacc,bestc] = SVMcgForClass_NoDisplay_linear(train_label,train_data(:,order(1:NumCon)),-5,5,5,0.2);
        cmd = ['-t 0', '-c ',num2str(bestc)];
        
        model = svmtrain(train_label,train_data(:,order(1:NumCon)), cmd);
        [predicted_label accuracy deci] = svmpredict(test_label,test_data(:,order(1:NumCon)),model);
        acc_r(i) = accuracy(1);
        clear B IX order strength  cmd bestacc bestc F
    end
    acc_final_rand(i) = mean(acc_r);
    clear randlabel  acc_r label_r
end
close(h);
acc_pvalue     = mean(abs(acc_final_rand) >= abs(acc_final)); % 得到acc置换检验的p值

save('FC_svm_roc_result.mat','acc_final','acc_pvalue','AUC','p_auc','cons_feature_mean','cons_feature_mask','cons_feature_label');


