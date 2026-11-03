function params = get_wifi_params(standard, psdu_length, cbw, mcs)
% GET_WIFI_PARAMS Returns configuration and parameters for the selected Wi-Fi standard.
%
% Inputs:
%   standard    - '802.11a' or '802.11ax'
%   psdu_length - (Optional) Payload length in bytes. If omitted or empty,
%                 automatically scaled with bandwidth and MCS to maintain a
%                 constant frame duration (~3.87 ms, matching 4095 B at
%                 802.11ax CBW20 MCS 0).
%   cbw         - (Optional) Channel bandwidth: 'CBW20' (default), 'CBW40', 'CBW80', 'CBW160'
%   mcs         - (Optional) Modulation and coding scheme index (default: 0)
%
% Output:
%   params      - Struct containing configuration object, FFT size, CP length, masks, etc.

    if nargin < 2
        psdu_length = [];
    end
    if nargin < 3 || isempty(cbw)
        cbw = 'CBW20';
    end
    if nargin < 4 || isempty(mcs)
        mcs = 0;
    end

    params = struct();
    params.standard = standard;

    switch standard
        case '802.11a'
            % 1. Validate bandwidth and MCS for IEEE 802.11a (Non-HT)
            if ~strcmp(cbw, 'CBW20')
                warning('Standard 802.11a only supports 20 MHz bandwidth (CBW20). Overriding %s -> CBW20.', cbw);
                cbw = 'CBW20';
            end
            mcs_clamped = min(max(mcs, 0), 7); % 802.11a supports MCS 0-7

            % 2. Auto-scale payload for constant frame duration (~3.87 ms) if not specified
            if isempty(psdu_length)
                base_psdu_a   = 2890; % 2890 B at MCS 0 -> 3872.0 us (963 OFDM symbols)
                max_psdu_a    = 4095; % 12-bit L-SIG hardware limit in 802.11a
                rate_Multiple = [1, 1.5, 2, 3, 4, 6, 8, 9];
                psdu_length   = min(max_psdu_a, round(base_psdu_a * rate_Multiple(mcs_clamped + 1)));
            end

            % 3. Build WLAN Toolbox configuration
            cfg = wlanNonHTConfig();
            cfg.ChannelBandwidth = 'CBW20';
            cfg.MCS              = mcs_clamped;
            cfg.PSDULength       = psdu_length;

            % 4. Extract OFDM timing and subcarrier parameters
            ind = wlanFieldIndices(cfg);

            params.cfg           = cfg;
            params.psdu_length   = psdu_length;
            params.fs            = wlanSampleRate(cfg); % 20 MHz
            params.Nfft          = 64;
            params.Ncp           = 16;
            params.payload_start = ind.NonHTData(1);

            % 5. Active subcarrier mask and DC index in centered (fftshift) domain
            % Active subcarriers: -26..-1 and +1..+26 (DC at index 33 = 1 + Nfft/2)
            mask = zeros(params.Nfft, 1);
            mask(7:32)  = 1;
            mask(34:59) = 1;
            params.active_mask = mask;
            params.dc_indices  = 33;

        case '802.11ax'
            % 1. Validate MCS for IEEE 802.11ax (HE-SU supports MCS 0-11)
            mcs_clamped = min(max(mcs, 0), 11);

            % 2. Build WLAN Toolbox configuration and query OFDM grid info
            cfg = wlanHESUConfig();
            cfg.ChannelBandwidth = cbw;
            cfg.MCS              = mcs_clamped;
            cfg.GuardInterval    = 0.8; % 0.8 us cyclic prefix
            ofdminfo = wlanHEOFDMInfo('HE-Data', cfg);

            % 3. Auto-scale payload for constant frame duration (~3.87 ms, 280 OFDM symbols)
            if isempty(psdu_length)
                base_apep_ax  = 4095;    % Reference payload at CBW20, MCS 0 (234 data tones)
                max_apep_ax   = 6500631; % IEEE 802.11ax maximum APEP length
                n_sd          = numel(ofdminfo.DataIndices);
                rate_Multiple = [1, 2, 3, 4, 6, 8, 9, 10, 12, 40/3, 15, 50/3];
                psdu_length   = min(max_apep_ax, round(base_apep_ax * (n_sd / 234) * rate_Multiple(mcs_clamped + 1)));
            end
            cfg.APEPLength = psdu_length;

            % 4. Extract OFDM timing and subcarrier parameters
            ind = wlanFieldIndices(cfg);

            params.cfg           = cfg;
            params.psdu_length   = psdu_length;
            params.fs            = wlanSampleRate(cfg);
            params.Nfft          = ofdminfo.FFTLength;
            params.Ncp           = round(cfg.GuardInterval * 1e-6 * params.fs);
            params.payload_start = ind.HEData(1);

            % 5. Active subcarrier mask and DC indices in centered (fftshift) domain
            center     = 1 + params.Nfft / 2;
            active_idx = ofdminfo.ActiveFrequencyIndices;

            mask = zeros(params.Nfft, 1);
            mask(center + active_idx) = 1;
            params.active_mask = mask;

            full_span_idx = min(active_idx) : max(active_idx);
            dc_null_idx   = setdiff(full_span_idx, active_idx);
            params.dc_indices = center + dc_null_idx;

        otherwise
            error('Unsupported standard ''%s''. Choose ''802.11a'' or ''802.11ax''.', standard);
    end
end
