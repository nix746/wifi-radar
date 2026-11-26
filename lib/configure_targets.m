function [delays, dopplers, taps, target_info] = configure_targets( ...
    targets, fs, fc, channel_model, p_rx_dBm, p_tx_W, gain_ant)
% CONFIGURE_TARGETS Translates physical target descriptions into radar channel parameters.
% Implements the physical monostatic radar equation (Braun 2014, eqs. 3.12-3.13, 3.34;
% Sturm & Wiesbeck 2011) combined with the IEEE 802.11 TGn/TGax dual-slope path loss
% model (Erceg et al., IEEE 802.11-03/940r4):
%   * Model-A (d_bp = Inf) or R <= d_bp (LoS) : P_tgt = P_Tx*G^2*lambda^2*sigma / ((4*pi)^3*R^4)
%   * R > d_bp (NLOS, Model-B..F)            : additional (d_bp / R)^(2*(n_nlos - n_los)) attenuation
%
% Inputs:
%   targets       - Struct (array) with physical target parameters:
%                     * range_m      : Distance to target [m] (required)
%                     * velocity_mps : Target radial velocity [m/s] (default: 0)
%                     * type         : Target type: 'human' (1 m^2), 'car' (10 m^2), 'pet' (0.1 m^2)
%                     * rcs          : (Optional) Custom RCS [m^2]
%   fs, fc        - Sampling frequency [Hz], Carrier frequency [Hz]
%   channel_model - (Optional) TGax model ('Model-A'..'Model-F', default: 'Model-A')
%   p_rx_dBm      - (Optional) Direct-path + clutter reference power [dBm] (default: -50.0)
%   p_tx_W        - (Optional) Transmitter EIRP [W] (default: 0.1 W = 20 dBm)
%   gain_ant      - (Optional) Monostatic antenna gain [linear] (default: 1.0 = 0 dBi)
%
% Outputs:
%   delays, dopplers, taps - Channel delay [samples], Doppler [Hz], and complex echo taps
%   target_info            - Struct array with resolved physical and radar parameters

if nargin < 4 || isempty(channel_model)
    channel_model = 'Model-A';
end
if nargin < 5 || isempty(p_rx_dBm)
    p_rx_dBm = -50.0;
end
if nargin < 6 || isempty(p_tx_W)
    p_tx_W = 0.1;
end
if nargin < 7 || isempty(gain_ant)
    gain_ant = 1.0;
end

c0         = 3e8;
sample_res = c0 / (2 * fs); % Two-way range resolution per sample
lambda     = c0 / fc;
p_rx_W     = 10^((p_rx_dBm - 30) / 10);
tgax_p     = get_tgax_propagation_params(channel_model);

N = length(targets);
target_info = repmat(struct('type', '', 'rcs', 0, 'range_m', 0, ...
    'delay_samples', 0, 'velocity_mps', 0, 'doppler_hz', 0, 'gain', 0, 'tap', 0), 1, N);

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

    r_eff        = max(range_m, 1.0);
    p_target_los = p_tx_W * (gain_ant^2) * (lambda^2) * rcs / ((4 * pi)^3 * r_eff^4);
    amp          = sqrt(p_target_los / p_rx_W);
    if r_eff > tgax_p.d_bp
        amp = amp * (tgax_p.d_bp / r_eff)^(tgax_p.n_nlos - tgax_p.n_los);
    end
    tau_s = 2 * range_m / c0;
    tap   = amp * exp(-1j * 2 * pi * fc * tau_s);

    target_info(k) = struct('type', tgt_type, 'rcs', rcs, 'range_m', range_m, ...
        'delay_samples', del_spl, 'velocity_mps', vel_mps, 'doppler_hz', dop_hz, ...
        'gain', amp, 'tap', tap);
end

delays   = [target_info.delay_samples];
dopplers = [target_info.doppler_hz];
taps     = [target_info.tap];
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
