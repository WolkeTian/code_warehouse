% mriqc_out path
parentpath = 'E:\Projects\离线工作记忆\Data\mriqc_out';
% 设定阈值
motion_threshold = 2;

%% load file
tsvfiles = dir(fullfile(parentpath, 'sub-*', 'func', 'sub-*task-rest_timeseries.tsv'));
% 读取被试编号
subids = struct2cell(tsvfiles);
subids = subids(1,:)';
assert(numel(subids) == numel(tsvfiles));
% load tsv for each subject
maxmotions = zeros(numel(tsvfiles), 1);
for i = 1:numel(tsvfiles)
    subitsv = fullfile(tsvfiles(i).folder, tsvfiles(i).name);
    data = readtable(subitsv, 'FileType', 'text', 'Delimiter', '\t');
    % 提取6列头动数据
    motiondata = data{:, 1:6};
    maxmotions(i, 1) = max(max(motiondata .* [1,1,1,180/pi,180/pi,180/pi]));
end
histogram(maxmotions);

disp('大于绝对头动阈值的')
disp(subids(maxmotions>motion_threshold));
%% mean FD > 0.2mm
tsvtable = fullfile(parentpath, 'group_bold.tsv');
groupdata = readtable(tsvtable, 'FileType', 'text', 'Delimiter', '\t');

meanFD = groupdata.fd_mean;

disp('平均fd>0.2的')
disp(subids(meanFD>0.2));
%% 超过30%的时间点FD>0.2mm
FDnum = groupdata.fd_num;
TRs = groupdata.size_t;
FD_perc = FDnum./TRs;

disp('fd超标数量>30%的')
disp(subids(FD_perc>0.3));

%% 合计
unique_exclude = unique([subids(maxmotions>motion_threshold); subids(meanFD>0.2); subids(FD_perc>0.3)]);
disp(['综合排除', num2str(numel(unique_exclude)), '人']);
disp(unique_exclude);

