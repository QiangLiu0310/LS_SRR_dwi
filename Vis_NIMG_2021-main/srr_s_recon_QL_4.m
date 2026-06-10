function s_out = srr_s_recon_QL_4(s, s1, o_dir, o_fn, opt)

nii_fn_out = [o_dir filesep o_fn];

if (nargin < 4); opt.present = 1; end
opt = srr_opt(opt);

% get hr header from first lr image
h_lr = mdm_nii_read_header(s{1}.nii_fn);
h_hr = srr_hr_header_from_lr(h_lr);

h_lr_ap = mdm_nii_read_header(s1{1}.nii_fn);
h_hr_ap = srr_hr_header_from_lr(h_lr_ap);

% create h2l operator
h2l = srr_h2l_from_s(s, h_hr, opt);


n_ims = length(s);
aspect = h_lr.pixdim(4)/h_lr.pixdim(2);
n_elem = h_lr.dim(2)*h_lr.dim(4);

hr_size4d = floor(h_hr_ap.dim(2:5)');
hr_size3d = hr_size4d([1 2 3]);
hr_size2d  = hr_size4d([1 3]);


% read in nii
for n = 1:n_ims
    [I{n}, ~] = mdm_nii_read(s1{n}.nii_fn);

end

% Qiang 
for n=5:9
    I{n}=rot90(I{n},-1);
end

if opt.meas_ind == -1
    meas_ind = 1:h_hr_ap.dim(5);
else
    meas_ind = opt.meas_ind;
end

if opt.slice_ind == -1
    slice_ind = 1:h_hr_ap.dim(3);
else
    slice_ind = opt.slice_ind;
end


% reconstruct per volume and coronal 'slice'
hr_out = zeros(hr_size4d);
for i = meas_ind
    
    fprintf('Reconstructing volume %d out of %d\n', i, length(meas_ind));
    
    tmp = zeros(hr_size3d);
    for j = slice_ind
        lr_c = zeros(n_elem * n_ims, 1);
        for n = 1:n_ims 
            lr_c((n-1)*n_elem+1 : n*n_elem) = double(squeeze(I{n}(:,j,:,i)));
        end 
        
        tmp(:,j,:) = srr_recon(h2l, lr_c(:), hr_size2d, aspect, n_ims, opt.lambda);
    end
    
    hr_out(:,:,:,i) = tmp;
    
end
   
% write output nifti
mdm_nii_write(single(hr_out), nii_fn_out, h_hr);

% save merged h2l
h2l_fn_out = srr_h2l_fn_from_nii_fn(nii_fn_out);
n_ims = length(s);
save(h2l_fn_out, 'h2l', 'n_ims')

s_out = mdm_s_from_nii(nii_fn_out);


% save lr image on hr grid
if opt.savelonh == 1  
    for n = 1:n_ims
         [I, ~] = mdm_nii_read(s{n}.nii_fn);
         lonh = zeros(hr_size3d);
         h2lstruct = load(srr_h2l_fn_from_nii_fn(s{n}.nii_fn));
         h2l_single = h2lstruct.h2l;
         for i = meas_ind
            tmp2 = zeros(hr_size3d);
            for j = slice_ind
                lr_im = squeeze(double(I(:,j,:,i)));
                lr_c = h2l_single'*lr_im(:);
                tmp2(:,j,:) = reshape(lr_c, hr_size2d);
            end
            lonh(:,:,:,i) = tmp2;
         end 
         niilr_name = [o_dir filesep sprintf('lonh_rot%d.nii.gz', n)];
         mdm_nii_write(single(lonh), niilr_name, h_hr);
    end
end 




