function [CPer_base, W_2D_unshifted, N_per, M_per] = compute_range_doppler_map(H_shifted, Nfft, n_symbols)
    % COMPUTE_RANGE_DOPPLER_MAP
    % Applies 2D Blackman-Harris window and computes the complex Range-Doppler periodogram.
    
    L_win = 53; % Span of active carriers including DC
    n_idx = (0 : L_win - 1)';
    a0 = 0.35875; a1 = 0.48829; a2 = 0.14128; a3 = 0.01168;

    bh_window = a0 - a1*cos(2*pi*n_idx/(L_win-1)) + a2*cos(4*pi*n_idx/(L_win-1)) - a3*cos(6*pi*n_idx/(L_win-1));

    win_f_shifted = zeros(Nfft, 1);
    win_f_shifted(7:59) = bh_window;

    win_t = a0 - a1*cos(2*pi*(0:n_symbols-1)/(n_symbols-1)) + ...
                 a2*cos(4*pi*(0:n_symbols-1)/(n_symbols-1)) - ...
                 a3*cos(6*pi*(0:n_symbols-1)/(n_symbols-1));

    W_2D_shifted = win_f_shifted .* win_t;
    W_2D_unshifted = ifftshift(W_2D_shifted, 1); % Preserved for CLEAN point spread function reconstruction

    H_ready = ifftshift(H_shifted .* W_2D_shifted, 1);

    N_per = 256;                  % Range FFT size (Zero padding)
    M_per = 2^nextpow2(n_symbols); % Doppler FFT size (Optimal power of 2)

    CPer_base = fftshift(fft(ifft(H_ready, N_per, 1), M_per, 2), 2);
end
