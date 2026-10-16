function [delays, dopplers, taps, target_info] = configure_targets(targets, fs, fc)
% CONFIGURE_TARGETS Translates physical target descriptions into radar channel parameters.
% Implements Martin Braun's model (eq. 3.12 - 3.13): attenuation b_h ~ sqrt(RCS) / d^2.
%
% Inputs:
%   targets - Struct (array) with physical target parameters:
%               * range_m      : Distance to target [m] (required)
%               * velocity_mps : Target radial velocity [m/s] (default: 0)
%               * type         : Target type: 'human' (1 m^2), 'car' (10 m^2), 'pet' (0.1 m^2)
%               * rcs          : (Optional) Custom RCS [m^2]
%   fs, fc  - Sampling frequency [Hz], Carrier frequency [Hz]
%
% Outputs:
%   delays, dopplers, taps - Channel delay [samples], Doppler [Hz], and echo amplitudes
%   target_info            - Struct array with resolved physical and radar parameters

    c0 = 3e8;
    sample_res = c0 / (2 * fs); % Range resolution per sample (two-way)
    d_ref = 10.0;  sigma_ref = 1.0;  b_ref = 0.03; % Calibration reference (10 m, 1 m^2)

    N = length(targets);
    target_info = repmat(struct('type', '', 'rcs', 0, 'range_m', 0, ...
        'delay_samples', 0, 'velocity_mps', 0, 'doppler_hz', 0, 'gain', 0), 1, N);

    for k = 1:N
        tgt = targets(k);

        % 1. Intuicyjne parametry fizyczne
        range_m  = get_opt(tgt, 'range_m', get_opt(tgt, 'range', []));
        if isempty(range_m)
            error('Target %d must specify distance "range_m" in meters.', k);
        end
        vel_mps  = get_opt(tgt, 'velocity_mps', get_opt(tgt, 'velocity', 0));
        tgt_type = get_opt(tgt, 'type', 'human');
        rcs      = get_opt(tgt, 'rcs', default_rcs(tgt_type));

        % 2. Przeliczenie na parametry kanału radarowego
        del_spl = round(range_m / sample_res);
        dop_hz  = (2 * fc * vel_mps) / c0;
        gain    = get_opt(tgt, 'gain', b_ref * (d_ref / max(range_m, 1.0))^2 * sqrt(rcs / sigma_ref));

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
