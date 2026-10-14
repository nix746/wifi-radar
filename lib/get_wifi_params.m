function params = get_wifi_params(standard, psdu_length, cbw, mcs)
% GET_WIFI_PARAMS Returns configuration and parameters for the selected Wi-Fi standard.
%
% Inputs:
%   standard    - '802.11a' or '802.11ax'
%   psdu_length - Payload length in bytes (default 4095)
%   cbw         - Channel bandwidth: 'CBW20' (default), 'CBW40', 'CBW80', 'CBW160'
%   mcs         - Modulation and coding scheme index (default: 0)
%
% Output:
%   params      - Struct containing configuration object, FFT size, CP length, masks, etc.

    if nargin < 2 || isempty(psdu_length)
        psdu_length = 4095;
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
            % IEEE 802.11a/g (Non-HT)
            if ~strcmp(cbw, 'CBW20')
                warning('Standard 802.11a only supports 20 MHz bandwidth (CBW20). Overriding %s -> CBW20.', cbw);
                cbw = 'CBW20';
            end
            cfg = wlanNonHTConfig();
            cfg.ChannelBandwidth = 'CBW20';
            cfg.MCS = min(mcs, 7); % 802.11a supports MCS 0-7
            cfg.PSDULength = psdu_length;
            
            params.cfg = cfg;
            params.fs = wlanSampleRate(cfg); % 20 MHz
            params.Nfft = 64;
            params.Ncp = 16;
            
            % Preamble parameters
            ind = wlanFieldIndices(cfg);
            params.payload_start = ind.NonHTData(1); % Index where data starts
            
            % Active subcarrier mask (52 data/pilot subcarriers)
            % Subcarriers -26 to -1 and 1 to 26
            % FFT center in MATLAB is at index 33 (1 + Nfft/2)
            mask = zeros(params.Nfft, 1);
            mask(7:32)  = 1; % Lower subcarriers
            mask(34:59) = 1; % Upper subcarriers
            params.active_mask = mask;
            
            % DC index for interpolation
            params.dc_indices = 33; 
            
        case '802.11ax'
            % IEEE 802.11ax (High Efficiency - Single User)
            cfg = wlanHESUConfig();
            cfg.ChannelBandwidth = cbw;
            cfg.MCS = mcs;
            cfg.GuardInterval = 0.8; % 0.8 us CP
            cfg.APEPLength = psdu_length;
            
            params.cfg = cfg;
            params.fs = wlanSampleRate(cfg);
            
            % Query standard OFDM information for the given bandwidth
            ofdminfo = wlanHEOFDMInfo('HE-Data', cfg);
            params.Nfft = ofdminfo.FFTLength;
            
            % Calculate CP length in samples
            params.Ncp = round(cfg.GuardInterval * 1e-6 * params.fs); 
            
            % Preamble parameters
            ind = wlanFieldIndices(cfg);
            params.payload_start = ind.HEData(1);
            
            % Active subcarrier mask in centered (fftshift) domain
            center = 1 + params.Nfft / 2;
            mask = zeros(params.Nfft, 1);
            mask(center + ofdminfo.ActiveFrequencyIndices) = 1;
            params.active_mask = mask;
            
            % DC indices for interpolation (center nulls around DC)
            zero_band_nulls = setdiff(min(ofdminfo.ActiveFrequencyIndices):max(ofdminfo.ActiveFrequencyIndices), ofdminfo.ActiveFrequencyIndices);
            dc_nulls = zero_band_nulls(abs(zero_band_nulls) <= 15);
            params.dc_indices = center + dc_nulls;
            
        otherwise
            error('Unsupported standard. Choose ''802.11a'' or ''802.11ax''.');
    end
end
