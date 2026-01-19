clear;

firstlevel_dir = 'E:\Projects\social_reward\fMRI_CSY\first_level\StroopSwitching\Congruence'
% 对应的con_num

search_path = fullfile(firstlevel_dir, 'sub*', 'con_0002.nii');
%对应的MNI坐标
mni_coord = [-30 +00 +10];
%% 1. extract
confiles = dir(search_path);

% 2. 准备存储结果
results = zeros(length(confiles), 1);

for i = 1:length(confiles)
    % 获取当前文件的完整路径
    fname = fullfile(confiles(i).folder, confiles(i).name);
    
    % 使用 SPM 函数读取 header 信息
    V = spm_vol(fname);
    
    % 将 MNI 坐标转换为体素坐标 (Voxel Coordinate)
    % inv(V.mat) 是从空间坐标转回矩阵索引的变换矩阵
    voxel_coord = inv(V.mat) * [mni_coord, 1]';
    voxel_coord = voxel_coord(1:3)'; 
    
    % 提取该点的数值
    % spm_sample_vol 支持线性插值（建议使用 0 表示最近邻，或 1 表示线性插值）
    results(i) = spm_sample_vol(V, voxel_coord(1), voxel_coord(2), voxel_coord(3), 1);
    
    fprintf('Subject %d: Value = %.4f\n', i, results(i));
end
% 分组
load group_info
beta_g1 = results(high);
beta_g2 = results(low);

% % 3. 保存结果到 Table 方便查看
% subject_names = {con1s.folder}'; % 提取路径中的被试信息
% T = table(subject_names, results, 'VariableNames', {'Path', 'ContrastValue'});
