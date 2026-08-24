% TRANSMITTER
% Generates IEEE 802.11a/g compliant Non-HT OFDM baseband waveform.
%
% Output:
%   waveform.mat - Contains complex baseband time-domain waveform and metadata.

fprintf(">> Running Transmitter...\n");

%% 1. Wi-Fi Frame Configuration (IEEE 802.11a Non-HT)
psdu_length = 4095; % Payload length in bytes

cfgNonHT = wlanNonHTConfig();
cfgNonHT.ChannelBandwidth = 'CBW20'; % 20 MHz channel
cfgNonHT.MCS = 0;                   % 0: BPSK rate 1/2
cfgNonHT.PSDULength = psdu_length;

fs = wlanSampleRate(cfgNonHT);
tx_time = transmitTime(cfgNonHT);

fprintf('  Sampling Rate:    %.2f MHz\n', fs/1e6);
fprintf('  Packet Duration:  %.2f us\n', tx_time * 1e6);
fprintf('  Modulation:       MCS %d (BPSK 1/2)\n', cfgNonHT.MCS);
fprintf('  Payload Size:     %d bytes\n', psdu_length);

%% 2. Waveform Generation
payload_bits = randi([0 1], psdu_length * 8, 1);
waveform = wlanWaveformGenerator(payload_bits, cfgNonHT);

%% 3. Save Output
save("waveform.mat", "waveform", "cfgNonHT", "fs");
fprintf("  Waveform saved to 'waveform.mat' (%d samples).\n", length(waveform));

%% 4. Power Spectral Density (PSD)
[pxx, f] = pwelch(waveform, [], [], [], fs, 'centered');

figure('Name', 'Transmitter - Power Spectral Density', 'Color', 'white');
plot(f/1e6, 10*log10(pxx), 'LineWidth', 1.2);
title('Power Spectral Density Estimate (IEEE 802.11a Non-HT)');
xlabel('Frequency [MHz]');
ylabel('Power [dB/Hz]');
grid on;
xlim([-15 15]);
