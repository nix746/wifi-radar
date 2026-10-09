function params = get_wifi_params(standard, psdu_length)
% GET_WIFI_PARAMS Returns configuration and parameters for the selected Wi-Fi standard.
%
% Inputs:
%   standard    - '802.11a' or '802.11ax'
%   psdu_length - Payload length in bytes (default 4095)
%
% Output:
%   params      - Struct containing configuration object, FFT size, CP length, masks, etc.

    if nargin < 2
        psdu_length = 4095;
    end

    params = struct();
    params.standard = standard;
    
    switch standard
        case '802.11a'
            % IEEE 802.11a/g (Non-HT)
            cfg = wlanNonHTConfig();
            cfg.ChannelBandwidth = 'CBW20';
            cfg.MCS = 0; % BPSK 1/2
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
            cfg.ChannelBandwidth = 'CBW20';
            cfg.MCS = 0; % BPSK 1/2
            cfg.GuardInterval = 0.8; % 0.8 us CP
            cfg.APEPLength = psdu_length;
            
            params.cfg = cfg;
            params.fs = wlanSampleRate(cfg); % 20 MHz
            params.Nfft = 256;
            
            % Calculate CP length in samples
            % For 20 MHz fs and 0.8 us GI, CP is 16 samples
            params.Ncp = round(cfg.GuardInterval * 1e-6 * params.fs); 
            
            % Preamble parameters
            ind = wlanFieldIndices(cfg);
            params.payload_start = ind.HEData(1);
            
            % Active subcarrier mask for 802.11ax 20 MHz (242 tones)
            % Tones: [-122:-2, 2:122]
            % FFT center in MATLAB is at index 129 (1 + Nfft/2)
            mask = zeros(params.Nfft, 1);
            center = 129;
            mask(center-122 : center-2) = 1;
            mask(center+2 : center+122) = 1;
            params.active_mask = mask;
            
            % DC indices (indices around DC that are nulled out)
            % Typically -1, 0, 1 for 802.11ax
            params.dc_indices = [center-1, center, center+1];
            
        otherwise
            error('Unsupported standard. Choose ''802.11a'' or ''802.11ax''.');
    end
end
