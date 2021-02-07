function Report = NII_getlabel(nii_map, threshold)
% reference map: spm12 Neuromorphometrics, resolution: 1.5mm
if ( ~exist('threshold', 'var') || isempty(threshold) )
    threshold = 2; % default threshold set to 2
end

% prepare
label_map = fullfile(spm('Dir'), 'tpm', 'labels_Neuromorphometrics.nii');
label_xml = fullfile(spm('Dir'), 'tpm', 'labels_Neuromorphometrics.xml');

xml_struct = xml2struct(label_xml);
xml_data = [xml_struct(2).Children(4).Children(4:2:end)];

% initial varaible to store index and label
label_indexs = zeros(numel(xml_data), 1);
label_names = cell(numel(xml_data), 1);

for i = 1:numel(xml_data)
    % get index
    label_indexs(i) = str2double(xml_data(i).Children(1).Children.Data);
    % get label name
    label_names(i) = {xml_data(i).Children(2).Children.Data};
end



% reslice ica map to smp12 label nifti resolution
resize_img(nii_map,[1.5, 1.5, 1.5], nan(2,3));

% read label nifti 
% label_niistruct = spm_vol_nifti(label_map);
% label_niimat = label_niistruct.private.dat(); % load 3d mat data
label_data = niftiread(label_map);

% load resliced ica_map
[fpath, fname] = fileparts(nii_map);
rnii_map = fullfile(fpath, ['r', fname, '.nii']);

% rica_niistruct = spm_vol_nifti(rnii_map);
% rica_niimat = lica_niistruct.private.dat(); % load 3d mat data
rnii_data = niftiread(rnii_map);

% delete resliced nii map
delete(rnii_map);

% threshold to binary
upper_thresh = label_data(rnii_data > threshold);
% only left with label & < threshold
upper_thresh = upper_thresh(upper_thresh ~= 0);
% statistics
uni_inds = unique(upper_thresh);
uni_voxel_nums = zeros(numel(uni_inds), 1); % to store numbers of voxels
uni_labels = cell(numel(uni_inds), 1); % to store name of lable
for i = 1:numel(uni_inds)
    % cal voxel number in 1.5 resolution
    uni_voxel_nums(i) = sum(upper_thresh == uni_inds(i) );
    % find corresponding label
    uni_labels(i) = label_names(label_indexs == uni_inds(i));
end
%resort by voxel numbers, descend
[VoxelSize, I] = sort(uni_voxel_nums, 'descend');
anatLabel = uni_labels(I);
% Report.thresh = threshold;

Report = table(VoxelSize, anatLabel);

% -----------------------End of code-------------------------------%
end
