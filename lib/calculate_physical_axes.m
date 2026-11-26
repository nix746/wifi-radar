function [axis_range, axis_velocity] = calculate_physical_axes(fs, fc, Nfft, Ncp, N_per, M_per, c, k_pri)
% CALCULATE_PHYSICAL_AXES Computes range and velocity axes for the radar map
%
% Inputs:
%   fs    - Sampling frequency (Hz)
%   fc    - Carrier frequency (Hz)
%   Nfft  - FFT size (Number of subcarriers)
%   Ncp   - Cyclic prefix length (samples)
%   N_per - Number of points in range axis (Periodogram rows)
%   M_per - Number of points in velocity axis (Periodogram columns)
%   c     - (Optional) Speed of light (m/s, default: 3e8)
%   k_pri - (Optional) Slow-time PRI subsampling factor in OFDM symbols (default: 1)
%
% Outputs:
%   axis_range    - 1D array of range bins (m)
%   axis_velocity - 1D array of velocity/Doppler bins (m/s)

if nargin < 7 || isempty(c)
    c = 3e8;
end
if nargin < 8 || isempty(k_pri)
    k_pri = 1;
end

% Braun (2014), eq. (3.32)-(3.33): exact DFT/IDFT frequency-to-physical mapping
delta_f = fs / Nfft;
T_O     = k_pri * (Nfft + Ncp) / fs;

n_idx = 0 : (N_per - 1);
m_idx = floor(-M_per / 2) : (ceil(M_per / 2) - 1);

axis_range    = (n_idx * c) / (2 * delta_f * N_per);
axis_velocity = (m_idx * c) / (2 * fc * T_O * M_per);
end
