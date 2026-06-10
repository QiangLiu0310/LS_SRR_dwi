% SRR for AP DWI data
% use the header information from PA
% Qiang Liu qliu30@mgh.harvard.edu

clear; close all; clc;

%% define output directories

data_dir   = '/Cima_data/2026_06_09_mgh_phantom/nii/pa/nii/NII/NII_reset/';
data_dir1 = '/Cima_data/2026_06_09_mgh_phantom/nii/ap/nii/'; 
nii_fn_cell = cell(1,12);  
for i = 1:12
    nii_fn_cell{i} = fullfile(data_dir, ['view_', num2str(i), '.nii']);
end

clear tmp i
nii_fn_cell1 = cell(1,12);  

for i = 1:12
    f_pattern = fullfile(data_dir1, ['*_view_', num2str(i), '_*.nii']);
    d = dir(f_pattern);
    if isempty(d)
        error('No AP file found for view %d: %s', i, f_pattern);
    end
    nii_fn_cell1{i} = fullfile(d(1).folder, d(1).name);
end

%% save in structure s
bdelta = 1; % b-tensor shape
s = cell(1, numel(nii_fn_cell));
for i = 1:numel(nii_fn_cell)
    s{i} = mdm_s_from_nii(nii_fn_cell{i}, bdelta);
end

s_ap = cell(1, numel(nii_fn_cell));
for i = 1:numel(nii_fn_cell)
    s_ap{i} = mdm_s_from_nii(nii_fn_cell1{i}, bdelta);
end

%% reconstruct
out_srr_dir = 'SRR_ap_cima';

opt_srr.lambda = 0.05; % regularization 
out_srr_fn = sprintf('srr_ap_cima_la%.5g.nii.gz', opt_srr.lambda);

s_out = srr_s_recon_QL_4(s, s_ap, out_srr_dir, out_srr_fn, opt_srr);