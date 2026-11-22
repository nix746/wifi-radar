function [axis_range, axis_velocity] = calculate_physical_axes(fs, fc, Nfft, Ncp, N_per, M_per, c)
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
%
% Outputs:
%   axis_range    - 1D array of range bins (m)
%   axis_velocity - 1D array of velocity/Doppler bins (m/s)

if nargin < 7 || isempty(c)
    c = 3e8;
end

% Braun (2014), eq. (3.32)-(3.33): exact DFT/IDFT frequency-to-physical mapping
delta_f = fs / Nfft;
T_O     = (Nfft + Ncp) / fs;

n_idx = 0 : (N_per - 1);
m_idx = floor(-M_per / 2) : (ceil(M_per / 2) - 1);

axis_range    = (n_idx * c) / (2 * delta_f * N_per);
axis_velocity = (m_idx * c) / (2 * fc * T_O * M_per);
end
