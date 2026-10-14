function [cbw, mcs, summary] = adaptive_wifi_params(snr_dB, standard, band)
% ADAPTIVE_WIFI_PARAMS Heuristic link and sensing adaptation for Wi-Fi Radar.
% Balances communication throughput and radar sensing resolution.
%
% Inputs:
%   snr_dB   - Channel Signal-to-Noise Ratio in dB
%   standard - '802.11a' or '802.11ax' (default: '802.11ax')
%   band     - Carrier band ('2.4GHz', '5GHz', '6GHz', default: '5GHz')
%
% Outputs:
%   cbw     - Adapted channel bandwidth ('CBW20', 'CBW40', 'CBW80', 'CBW160')
%   mcs     - Adapted modulation and coding scheme index
%   summary - Descriptive string summarizing the adaptation decision

    if nargin < 2 || isempty(standard)
        standard = '802.11ax';
    end
    if nargin < 3 || isempty(band)
        band = '5GHz';
    end

    [~, band_str] = get_carrier_frequency(band);

    switch standard
        case '802.11a'
            % 802.11a is strictly 20 MHz (CBW20)
            cbw = 'CBW20';
            if snr_dB < 10
                mcs = 0; % BPSK 1/2 (6 Mbps)
                summary = 'Low SNR (<10 dB): 802.11a CBW20, robust MCS 0 (BPSK)';
            elseif snr_dB < 16
                mcs = 2; % QPSK 3/4 (18 Mbps)
                summary = 'Medium SNR (10-16 dB): 802.11a CBW20, moderate MCS 2 (QPSK)';
            elseif snr_dB < 22
                mcs = 4; % 16-QAM 3/4 (36 Mbps)
                summary = 'Good SNR (16-22 dB): 802.11a CBW20, high MCS 4 (16-QAM)';
            else
                mcs = 7; % 64-QAM 3/4 (54 Mbps)
                summary = 'High SNR (>22 dB): 802.11a CBW20, max MCS 7 (64-QAM)';
            end

        case '802.11ax'
            % Constraint: 2.4 GHz physical limitation restricts Wi-Fi to 20 MHz
            is_2_4 = strcmp(band_str, '2.4GHz');

            if is_2_4
                cbw = 'CBW20';
                if snr_dB < 12
                    mcs = 0; % BPSK 1/2
                    summary = '2.4 GHz Band (Forced CBW20), Low SNR (<12 dB): MCS 0 (BPSK)';
                elseif snr_dB < 18
                    mcs = 3; % 16-QAM 1/2
                    summary = '2.4 GHz Band (Forced CBW20), Moderate SNR (12-18 dB): MCS 3 (16-QAM)';
                elseif snr_dB < 25
                    mcs = 5; % 64-QAM 2/3
                    summary = '2.4 GHz Band (Forced CBW20), Good SNR (18-25 dB): MCS 5 (64-QAM)';
                else
                    mcs = 9; % 256-QAM 5/6
                    summary = '2.4 GHz Band (Forced CBW20), High SNR (>25 dB): MCS 9 (256-QAM)';
                end
            else
                % 5 GHz or 6 GHz allows 20, 40, 80, and 160 MHz
                if snr_dB < 12
                    cbw = 'CBW20';
                    mcs = 0; % BPSK 1/2 (Priority: Maximum detection sensitivity & range)
                    summary = 'Low SNR (<12 dB): Narrow CBW20, robust MCS 0 (delta_r = 7.5m, max sensitivity)';
                elseif snr_dB < 18
                    cbw = 'CBW40';
                    mcs = 3; % 16-QAM 1/2
                    summary = 'Moderate SNR (12-18 dB): Balanced CBW40, MCS 3 (delta_r = 3.75m)';
                elseif snr_dB < 25
                    cbw = 'CBW80';
                    mcs = 7; % 64-QAM 5/6
                    summary = 'Good SNR (18-25 dB): Wide CBW80, MCS 7 (delta_r = 1.88m, high throughput)';
                else
                    cbw = 'CBW160';
                    mcs = 9; % 256-QAM 5/6 (Ultra-wide band for sub-meter resolution)
                    summary = 'High SNR (>25 dB): Ultra-wide CBW160, MCS 9 (delta_r = 0.94m sub-meter radar)';
                end
            end

        otherwise
            error('Unsupported standard ''%s''. Choose ''802.11a'' or ''802.11ax''.', standard);
    end
end
