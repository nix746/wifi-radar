function [CPer_base, W_2D, N_per, M_per] = compute_range_doppler_map(H_shifted, Nfft, n_symbols, active_mask, pad_factor, use_window)
% COMPUTE_RANGE_DOPPLER_MAP Generates 2D Range-Doppler periodogram.
%
% Applies 2D Blackman-Harris windowing (across active subcarriers and OFDM symbols)
% and computes the Range-Doppler map via zero-padded IFFT (Range) and FFT (Doppler).
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
%   CPer_base   - Complex 2D Range-Doppler periodogram [N_per x M_per]
%   W_2D        - 2D window matrix [Nfft x n_symbols]
%   N_per       - Range IFFT length (after zero-padding)
%   M_per       - Doppler FFT length (after zero-padding)

if nargin < 5 || isempty(pad_factor)
    pad_factor = 4;
end
if nargin < 6 || isempty(use_window)
    use_window = true;
end

% 1. Determine active subcarrier span in frequency domain
if nargin < 4 || isempty(active_mask)
    idx = find(any(H_shifted, 2));
else
    idx = find(active_mask);
end
if isempty(idx), idx = 1:Nfft; end

% 2. 2D Window construction (Blackman-Harris or Rectangular)
if use_window
    L_active = idx(end) - idx(1) + 1;
    win_f = zeros(Nfft, 1);
    win_f(idx(1):idx(end)) = blackmanharris(L_active);
    win_t = blackmanharris(n_symbols)';
    W_2D = win_f .* win_t;
else
    W_2D = ones(Nfft, n_symbols);
end

% 3. Range-Doppler periodogram (Range IFFT, Doppler FFT with universal zero-padding)
N_per = pad_factor * 2^nextpow2(Nfft);
M_per = pad_factor * 2^nextpow2(n_symbols);

H_windowed = H_shifted .* W_2D;
CPer_base  = fftshift(fft(ifft(H_windowed, N_per, 1), M_per, 2), 2);
end
