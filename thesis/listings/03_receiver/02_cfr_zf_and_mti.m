epsilon = 1e-9;
act_mask_unshifted = ifftshift(params.active_mask);
H = F_rx ./ (F_tx + epsilon);
H = H .* act_mask_unshifted;

X_act   = F_tx(logical(act_mask_unshifted), :);
pwr_x   = abs(X_act(:)).^2;
zeta_dB = 10 * log10(mean(pwr_x) * mean(1 ./ (pwr_x + epsilon^2)));

H_raw_shifted       = fftshift(H, 1);
H_no_static_shifted = H_raw_shifted - mean(H_raw_shifted, 2);
H_shifted           = interpolate_dc_nulls(H_no_static_shifted, params.dc_indices);
