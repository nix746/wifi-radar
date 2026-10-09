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
%   c     - Speed of light (m/s)
%
% Outputs:
%   axis_range    - 1D array of range bins (m)
%   axis_velocity - 1D array of velocity/Doppler bins (m/s)

    % Range Axis [m]
    delta_r = c / (2 * fs);
    max_range = delta_r * Nfft;
    axis_range = linspace(0, max_range, N_per);
    
    % Velocity / Doppler Axis [m/s]
    T_sym_total = (Nfft + Ncp) / fs;
    v_unamb = c / (2 * fc * T_sym_total);
    axis_velocity = linspace(-v_unamb/2, v_unamb/2, M_per);
end
