% cima 0p8 data with 12 rotations 
% (view 5-9 need flip)
% process the PA data only
% for AP data, the header will be re-used for each of the diffusion
% directions
% Qiang Liu qliu30@mgh.harvrad.edu

clear; close all; clc;
step=3;

data_dir    = '/scratch/home/ql087/data_bwh/Cima_data/2026_06_09_mgh_phantom/nii/pa/nii/';
out_nii_dir = '/scratch/home/ql087/data_bwh/Cima_data/2026_06_09_mgh_phantom/nii/pa/nii/NII/';

if (step==2)

    % copy views 1-4 and 10-12 to NII/ as view_*.nii
    for i=[1:4, 10:12]
        f_in  = find_view_nii(data_dir, i);
        f_out = fullfile(out_nii_dir, ['view_', num2str(i), '.nii']);

        nii = MRIread(f_in);
        MRIwrite(nii, f_out);
        fprintf('copied view %d -> %s\n', i, f_out);
    end

    % permute + header update for views 5-9
    for i=5:9
        f_in  = find_view_nii(data_dir, i);
        f_out = fullfile(out_nii_dir, ['view_', num2str(i), '.nii']);

        nii_orig = MRIread(f_in);
        data = nii_orig.vol;
        data = permute(data, [2 1 3]);
        data = flip(data, 1);

        vox2ras = nii_orig.vox2ras;
        vox2ras_new = vox2ras(:, [2 1 3 4]);
        vox2ras_new(:,2) = vox2ras_new(:,2) * -1;
        ras = vox2ras * [0 0 0 1]';
        center_new = ras - vox2ras_new(:,1:3) * [0 273 0]';
        vox2ras_new(:,4) = center_new;

        nii = nii_orig;
        nii.vol = data;
        nii.vox2ras  = vox2ras_new;
        nii.vox2ras0 = vox2ras_new;

        MRIwrite(nii, f_out);
        fprintf('processed view %d -> %s\n', i, f_out);
    end
end

if (step==3)

    in_nii_dir = out_nii_dir;
    out_dir    = '/scratch/home/ql087/data_bwh/Cima_data/2026_06_09_mgh_phantom/nii/pa/nii/NII/NII_reset/';

    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
        fprintf('Created output folder: %s\n', out_dir);
    end

    for i=1:12
        f_in  = fullfile(in_nii_dir, ['view_', num2str(i), '.nii']);
        f_out = fullfile(out_dir, ['view_', num2str(i), '.nii']);

        nii_orig = MRIread(f_in);
        nii = nii_orig;

        nii.c_r = 0;
        nii.c_a = 0;
        nii.c_s = 0;

        nii.niftihdr.sform_code = 1;
        nii.niftihdr.qform_code = 0;

        MRIwrite(nii, f_out);
        fprintf('reset view %d -> %s\n', i, f_out);
    end
end


function f_in = find_view_nii(data_dir, view_num)
    f_pattern = fullfile(data_dir, ['*_view_', num2str(view_num), '_pa_*.nii']);
    d = dir(f_pattern);
    if isempty(d)
        error('No file found for view %d: %s', view_num, f_pattern);
    end
    if numel(d) > 1
        warning('Multiple files for view %d; using %s', view_num, d(1).name);
    end
    f_in = fullfile(d(1).folder, d(1).name);
end
