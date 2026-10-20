function [CPer_base, W_2D_unshifted, N_per, M_per] = compute_range_doppler_map(H_shifted, Nfft, n_symbols, active_mask)
% COMPUTE_RANGE_DOPPLER_MAP Generates 2D Range-Doppler periodogram.
%
% Applies 2D Blackman-Harris windowing (across active subcarriers and OFDM symbols)
% and computes the Range-Doppler map via IFFT (Range) and FFT (Doppler).

    % 1. Determine active subcarrier span in frequency domain
    if nargin < 4 || isempty(active_mask)
        idx = find(any(H_shifted, 2));
    else
        idx = find(active_mask);
    end
    if isempty(idx), idx = 1:Nfft; end

    % 2. 2D Blackman-Harris windowing
    L_active = idx(end) - idx(1) + 1;
    win_f = zeros(Nfft, 1);
    win_f(idx(1):idx(end)) = blackmanharris(L_active);
    win_t = blackmanharris(n_symbols)';

    W_2D_shifted = win_f .* win_t;
    W_2D_unshifted = ifftshift(W_2D_shifted, 1);

    % 3. Range-Doppler periodogram (Range IFFT, Doppler FFT)
    N_per = max(256, 2^nextpow2(Nfft));
    M_per = 2^nextpow2(n_symbols);

    H_ready = ifftshift(H_shifted .* W_2D_shifted, 1);
    CPer_base = fftshift(fft(ifft(H_ready, N_per, 1), M_per, 2), 2);
end
