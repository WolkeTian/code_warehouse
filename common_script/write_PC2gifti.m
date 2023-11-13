function write_PC2gifti(coeffs,name2write)
% write PC to fsaverage gifti files
% 准备文件
annots{1} = 'C:\Users\DELL\Desktop\postproc_fmriprep\atlases_surfaces\lh.Schaefer2018_200Parcels_17Networks_order.annot';
annots{2} = 'C:\Users\DELL\Desktop\postproc_fmriprep\atlases_surfaces\rh.Schaefer2018_200Parcels_17Networks_order.annot';
giifiles{1} = 'hemi-L_space-fsaverage_bold.gii';
giifiles{2} = 'hemi-R_space-fsaverage_bold.gii';
giinames{1} = ['lh_', name2write];
giinames{2} = ['rh_', name2write];

addpath('C:\Users\DELL\Desktop\postproc_fmriprep\freesurfer');
% 先左脑后右脑
for n = 1:2

    annotfile = annots{n};
    coeff2write = coeffs(100*n-99:100*n);
    % 读取gifti模板
    giiname = giifiles{n};
    giistruct = gifti(giiname);
    giidata = giistruct.cdata;
    % 先初始化为全0，且只有一个时间点
    giidata = zeros(size(giidata,1), 1);
    % 开始
    [~, L, ct]  = read_annotation(annotfile);
      
    label_index = ct.table(:,5);
    % 先去除第一个无效脑区
    label_index(1) = [];
    
    label_name = ct.struct_names;
    label_name(1) = [];

    % 第一个不是有效脑区
    for x = 1:numel(label_name)
    % 获取第x个label对应的顶点的时间序列
        giidata(L == label_index(x)) = coeffs(x);        
    end
    % 写入文件
    new_gii_struct = gifti(giidata);
    save(new_gii_struct, giinames{n});
    
end

rmpath('C:\Users\DELL\Desktop\postproc_fmriprep\freesurfer');

end