CPer_clean = CPer_base;

for i = 1 : num_targets
    % Find highest peak in residual periodogram
    [~, idx] = max(abs(CPer_clean(:)));
    [r_idx, d_idx] = ind2sub([N_per, M_per], idx);
    complex_val = CPer_clean(r_idx, d_idx);
    
    % Reconstruct target point spread function
    P = zeros(N_per, M_per);
    P(r_idx, d_idx) = 1;
    H_full = fft(ifft(ifftshift(P, 2), M_per, 2), N_per, 1);
    
    % Apply matching 2D window and compute periodogram
    H_crop_win = H_full(1:Nfft, 1:n_symbols) .* W_2D_unshifted;
    CPer_target = fftshift(fft(ifft(H_crop_win, N_per, 1), M_per, 2), 2);
    
    % Coherent cancellation
    CPer_target_norm = CPer_target / CPer_target(r_idx, d_idx);
    CPer_clean = CPer_clean - complex_val * CPer_target_norm;
end
