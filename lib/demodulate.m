function [F_matrix, n_syms] = demodulate(signal, n_fft, n_cp)
% DEMODULATE Manual OFDM Demodulation (CP removal and FFT along subcarriers)
%
% Syntax:
%   [F_matrix, n_syms] = demodulate(signal, n_fft, n_cp)
%
% Inputs:
%   signal - Received time-domain complex signal vector
%   n_fft  - FFT size (number of subcarriers, default: 64 for 802.11a)
%   n_cp   - Cyclic Prefix length in samples (default: 16 for 802.11a)
%
% Outputs:
%   F_matrix - Demodulated subcarrier matrix of size [n_fft x n_syms]
%   n_syms   - Number of complete OFDM symbols processed

    if nargin < 2, n_fft = 64; end
    if nargin < 3, n_cp = 16; end

    signal = signal(:);
    sym_len = n_fft + n_cp;
    n_syms = floor(length(signal) / sym_len);

    if n_syms < 1
        error('Input signal is shorter than a single OFDM symbol (%d samples).', sym_len);
    end

    % Truncate signal to an integer number of symbols
    sig_truncated = signal(1 : n_syms * sym_len);

    % Reshape to matrix: columns represent consecutive OFDM symbols in time
    matrix_time_with_cp = reshape(sig_truncated, sym_len, n_syms);

    % Remove Cyclic Prefix: keep samples from (n_cp + 1) to the end of each symbol
    matrix_time_no_cp = matrix_time_with_cp(n_cp + 1 : end, :);

    % FFT along fast-time dimension (columns: time -> subcarriers)
    F_matrix = fft(matrix_time_no_cp, n_fft, 1);
end
