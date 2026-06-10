clear

%% define output directories
% run preprocess first

change_nii_QL_v9

data_dir   = '/scratch/home/ql087/data_bwh/Cima_data/2026_06_09_mgh_phantom/nii/pa/nii/NII/NII_reset/';
nii_fn_cell = cell(1,12);  
for i = 1:12
    nii_fn_cell{i} = fullfile(data_dir, ['view_', num2str(i), '.nii']);
end

%% save in structure s
bdelta = 1; % b-tensor shape
s = cell(1, numel(nii_fn_cell));
for i = 1:numel(nii_fn_cell)
    s{i} = mdm_s_from_nii(nii_fn_cell{i}, bdelta);
end

%% reconstruct
out_srr_dir = ['SRR_pa_cima_b0'];

opt_srr.lambda = 0.05; % regularization 
out_srr_fn = sprintf('srr_pa_cima_la%.5g.nii.gz', opt_srr.lambda);
s_out = srr_s_recon(s, out_srr_dir, out_srr_fn, opt_srr);