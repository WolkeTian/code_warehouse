function Results = NII_getlabel(nii_map, threshold)
% reference map: spm12 Neuromorphometrics, resolution: 1.5mm
if ( ~exist('threshold', 'var') || isempty(threshold) )
    threshold = 2; % default threshold set to 2
end
disp(['threshold is ', num2str(threshold)]);
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


% read label nifti 
% label_niistruct = spm_vol_nifti(label_map);
% label_niimat = label_niistruct.private.dat(); % load 3d mat data
label_data = niftiread(label_map);
label_info = niftiinfo(label_map);
label_dims = label_info.PixelDimensions;

% reslice ica map to smp12 label nifti resolution
disp('Resize nii file to match label file ing...');
resize_img(nii_map,label_dims, nan(2,3));

% load resliced ica_map
[fpath, fname] = fileparts(nii_map);
rnii_map = fullfile(fpath, ['r', fname, '.nii']);

% rica_niistruct = spm_vol_nifti(rnii_map);
% rica_niimat = lica_niistruct.private.dat(); % load 3d mat data
rnii_data = niftiread(rnii_map);

% delete resliced nii map
delete(rnii_map);


if numel(size(rnii_data)) == 3 % if only one volume
    [Results{1}, Results{2}] = getlabel_fromVolume(rnii_data, threshold, label_data, label_indexs, label_names);
elseif numel(size(rnii_data)) == 4 % if multiple volumes
    for n = 1:size(rnii_data, 4)
        % loop for every volume
        [Results{1, n}, Results{2, n}] = getlabel_fromVolume(squeeze(rnii_data(:,:,:,n)), threshold, label_data, label_indexs, label_names);
    end
end
    

% -----------------------End of code-------------------------------%
end

% -----------------------------------------------------------------------
% nested function, get report from one volume
function [Report, maxRegion] = getlabel_fromVolume(rnii_data, threshold, label_data, label_indexs, label_names)
% threshold to binary
    upper_thresh = label_data(rnii_data > threshold);
    % only left with label & > threshold
    upper_thresh = upper_thresh(upper_thresh ~= 0);
    % statistics
    uni_inds = unique(upper_thresh); % indexs of label upper threshold
    uni_voxel_nums = zeros(numel(uni_inds), 1); % to store numbers of voxels
    uni_voxel_mass = zeros(numel(uni_inds), 1); % to store mass of voxels (size * statistics value);
    uni_labels = cell(numel(uni_inds), 1); % to store name of lable
    for i = 1:numel(uni_inds)
        % cal voxel sizes in 1.5 resolution
        uni_voxel_nums(i) = sum(upper_thresh == uni_inds(i) );
        % cal voxel masses in 1.5 resolution
        uni_voxel_mass(i) = sum(rnii_data(rnii_data > threshold & label_data  == uni_inds(i)));
        % find corresponding label
        uni_labels(i) = label_names(label_indexs == uni_inds(i));
    end
    %resort by voxel numbers, descend
    [VoxelSize, Ind] = sort(uni_voxel_nums, 'descend');
    anatLabel = uni_labels(Ind);
    VoxelMass = uni_voxel_mass(Ind);
    % Report.thresh = threshold;

    Report = table(VoxelSize, VoxelMass, anatLabel);
    if isempty(anatLabel) % if no upper threshold voxel with label
        maxRegion =NaN;
    else
        maxRegion = anatLabel(1);
    end
end
