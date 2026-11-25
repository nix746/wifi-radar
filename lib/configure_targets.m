function [delays, dopplers, taps, target_info] = configure_targets(targets, fs, fc, channel_model)
% CONFIGURE_TARGETS Translates physical target descriptions into radar channel parameters.
% Implements Martin Braun's radar attenuation model (eq. 3.12 - 3.13) combined with the
% IEEE 802.11 TGn/TGax dual-slope path loss model (Erceg et al., IEEE 802.11-03/940r4):
%   * R <= d_bp (LoS)  : b_h ~ sqrt(RCS) / R^2           (two-way power ~ R^-4)
%   * R >  d_bp (NLOS) : b_h ~ sqrt(RCS) / R^2 * (d_bp/R)^1.5  (two-way power ~ R^-7)
%
% Inputs:
%   targets       - Struct (array) with physical target parameters:
%                     * range_m      : Distance to target [m] (required)
%                     * velocity_mps : Target radial velocity [m/s] (default: 0)
%                     * type         : Target type: 'human' (1 m^2), 'car' (10 m^2), 'pet' (0.1 m^2)
%                     * rcs          : (Optional) Custom RCS [m^2]
%   fs, fc        - Sampling frequency [Hz], Carrier frequency [Hz]
%   channel_model - (Optional) TGax model ('Model-A'..'Model-F', default: 'Model-A')
%
% Outputs:
%   delays, dopplers, taps - Channel delay [samples], Doppler [Hz], and echo amplitudes
%   target_info            - Struct array with resolved physical and radar parameters

    if nargin < 4 || isempty(channel_model)
        channel_model = 'Model-A';
    end

    c0 = 3e8;
    sample_res = c0 / (2 * fs); % Two-way range resolution per sample
    d_ref = 10.0; sigma_ref = 1.0; b_ref = 0.03; % Calibration reference (10 m, 1 m^2)
    tgax_p = get_tgax_propagation_params(channel_model);

    N = length(targets);
    target_info = repmat(struct('type', '', 'rcs', 0, 'range_m', 0, ...
        'delay_samples', 0, 'velocity_mps', 0, 'doppler_hz', 0, 'gain', 0), 1, N);

    for k = 1:N
        tgt = targets(k);

        range_m  = get_opt(tgt, 'range_m', get_opt(tgt, 'range', []));
        if isempty(range_m)
            error('Target %d must specify distance "range_m" in meters.', k);
        end
        vel_mps  = get_opt(tgt, 'velocity_mps', get_opt(tgt, 'velocity', 0));
        tgt_type = get_opt(tgt, 'type', 'human');
        rcs      = get_opt(tgt, 'rcs', default_rcs(tgt_type));

        del_spl = range_m / sample_res;
        dop_hz  = (2 * fc * vel_mps) / c0;

        r_eff = max(range_m, 1.0);
        gain  = b_ref * (d_ref / r_eff)^2 * sqrt(rcs / sigma_ref);
        if r_eff > tgax_p.d_bp
            gain = gain * (tgax_p.d_bp / r_eff)^(tgax_p.n_nlos - tgax_p.n_los);
        end

        target_info(k) = struct('type', tgt_type, 'rcs', rcs, 'range_m', range_m, ...
            'delay_samples', del_spl, 'velocity_mps', vel_mps, 'doppler_hz', dop_hz, 'gain', gain);
    end

    delays   = [target_info.delay_samples];
    dopplers = [target_info.doppler_hz];
    taps     = [target_info.gain];
end

function val = get_opt(s, field, default_val)
    if isfield(s, field) && ~isempty(s.(field))
        val = s.(field);
    else
        val = default_val;
    end
end

function rcs = default_rcs(type)
    switch lower(type)
        case {'car', 'vehicle'},    rcs = 10.0;
        case {'pet', 'dog', 'cat'}, rcs = 0.1;
        case {'drone', 'uav'},      rcs = 0.05;
        otherwise,                  rcs = 1.0; % 'human', default
    end
end
