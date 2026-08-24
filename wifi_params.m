% wifi_params.m
% Wi-Fi - initialization of Wi-Fi signal parameters for 802.11a/g.

% PARAMETER INITIALIZATION
cfg = wlanNonHTConfig;              % packet configuration
cfg.MCS = 0;                        % 0 - BPSK; 1 - QPSK; 3 - 16QAM
cfg.ChannelBandwidth = 'CBW20';     % channel bandwidth
cfg.PSDULength = 4095;              % number of bytes in payload
