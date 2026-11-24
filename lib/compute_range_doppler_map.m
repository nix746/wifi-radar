function [CPer_F, W, N_per, M_per, Per_F, N_act] = compute_range_doppler_map(H_shifted, Nfft, n_symbols, active_mask, pad_factor, use_window)
% COMPUTE_RANGE_DOPPLER_MAP Generates 2D Range-Doppler periodogram (Braun 2014).
%
% Applies 2D Blackman-Harris windowing (normalized to unit mean energy across
% active subcarriers and OFDM symbols) and computes the complex and real-valued
% Range-Doppler periodograms per Braun (2014), eq. (3.30)-(3.31) and (3.69)-(3.70).
%
% Inputs:
%   H_shifted   - Centered channel transfer matrix [Nfft x n_symbols]
%   Nfft        - Baseband FFT size (number of subcarriers)
%   n_symbols   - Number of OFDM symbols in frame
%   active_mask - (Optional) Logical/binary mask of active subcarriers
%   pad_factor  - (Optional) Universal zero-padding factor (default: 4)
%   use_window  - (Optional) Logical flag: true for 2D Blackman-Harris (default),
%                 false for rectangular window (unwindowed raw periodogram)
%
% Outputs:
%   CPer_F      - Complex 2D Range-Doppler periodogram [N_per x M_per]
%   W           - 2D window matrix [Nfft x n_symbols]
%   N_per       - Range IFFT length (after zero-padding)
%   M_per       - Doppler FFT length (after zero-padding)
%   Per_F       - Real-valued power periodogram (1/(N_act*M)) * |CPer_F|^2
%   N_act       - Number of active subcarriers (N in Braun's notation)

    if nargin < 5 || isempty(pad_factor)
        pad_factor = 4;
    end
    if nargin < 6 || isempty(use_window)
        use_window = true;
    end

    % Determine active subcarrier span and count N_act
    if nargin < 4 || isempty(active_mask)
        idx   = find(any(H_shifted, 2));
        N_act = numel(idx);
    else
        idx   = find(active_mask);
        N_act = nnz(active_mask);
    end
    if isempty(idx)
        idx   = 1:Nfft;
        N_act = Nfft;
    elseif N_act == 0
        N_act = numel(idx);
    end

    % 2D window normalized to unit mean energy per Braun (2014), eq. (3.70) & Fig. 3.11a
    if use_window
        L_active = idx(end) - idx(1) + 1;
        w_d_act  = blackmanharris(L_active);
        if norm(w_d_act) > 0
            w_d_act = w_d_act * sqrt(L_active) / norm(w_d_act);
        end
        win_f = zeros(Nfft, 1);
        win_f(idx(1):idx(end)) = w_d_act;

        win_t = blackmanharris(n_symbols).';
        if norm(win_t) > 0
            win_t = win_t * sqrt(n_symbols) / norm(win_t);
        end
        W = win_f .* win_t;
    else
        W = ones(Nfft, n_symbols);
    end

    % Range-Doppler periodogram per Braun (2014), eq. (3.31) & (3.69)
    % Multiply by N_per to compensate MATLAB ifft's 1/N_per normalization.
    N_per  = pad_factor * 2^nextpow2(Nfft);
    M_per  = pad_factor * 2^nextpow2(n_symbols);
    H_win  = H_shifted .* W;
    CPer_F = fftshift(N_per * ifft(fft(H_win, M_per, 2), N_per, 1), 2);
    Per_F  = (1 / (N_act * n_symbols)) * abs(CPer_F).^2;
end
