matpaths = 'E:\fMRI1500\Conn\conn_f1113\results\preprocessing\ROI_Sub*Cond*001.mat';
matdir = dir(matpaths);

ROIs_Timecourses_power = zeros(numel(matdir), 264, 240);
ROIs_Timecourses_dosen = zeros(numel(matdir), 160, 240);
% load
for i = 1:numel(matdir)
    load(fullfile(matdir(i).folder, matdir(i).name));
    power_data = permute(cell2mat(data(4:267)), [2,1]);
    dosen_data = permute(cell2mat(data(268:267+160)), [2,1]);
    % write
    ROIs_Timecourses_power(i, :, :) = power_data;
    ROIs_Timecourses_dosen(i, :, :) = dosen_data;
end
