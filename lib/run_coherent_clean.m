function [CPer_clean, targets_found] = run_coherent_clean(CPer_base, W_2D_unshifted, N_per, M_per, Nfft, n_symbols, num_targets)
    % RUN_COHERENT_CLEAN
    % Iterative Coherent Target Cancellation (CLEAN Algorithm).
    
    CPer_clean = CPer_base;
    targets_found = [];

    for i = 1 : num_targets
        % Find maximum amplitude in current residual periodogram
        [~, idx] = max(abs(CPer_clean(:)));
        [r_idx, d_idx] = ind2sub([N_per, M_per], idx);
        targets_found = [targets_found; r_idx, d_idx];
        
        complex_val = CPer_clean(r_idx, d_idx);
        
        % Reconstruct target point spread function in frequency/time domain
        P = zeros(N_per, M_per);
        P(r_idx, d_idx) = 1;
        H_full = fft(ifft(ifftshift(P, 2), M_per, 2), N_per, 1);
        
        % Apply 2D window matching the measurement pipeline
        H_crop_win = H_full(1:Nfft, 1:n_symbols) .* W_2D_unshifted;
        
        % Periodogram of the reconstructed single target
        CPer_target = fftshift(fft(ifft(H_crop_win, N_per, 1), M_per, 2), 2);
        CPer_target_norm = CPer_target / CPer_target(r_idx, d_idx);
        
        % Coherent subtraction of target and its sidelobes
        CPer_clean = CPer_clean - complex_val * CPer_target_norm;
    end
end
