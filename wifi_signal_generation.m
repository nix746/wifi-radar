% wifi_signal_generation.m
% Wi-Fi - Signal Waveform Generation (802.11a/g)

clearvars; close all; clc;

% 1. LOAD PARAMETERS
wifi_params; 

% 2. WAVEFORM GENERATION
fprintf("Generating Wi-Fi Signal...\n");

% Generate random payload bits
txBits = randi([0 1], cfg.PSDULength * 8, 1);   

% Generate the complex baseband waveform (Time Domain)
txWaveform = wlanWaveformGenerator(txBits, cfg); 

% Get the sampling rate
fs = wlanSampleRate(cfg);

% 3. DISPLAY INFO
fprintf("--- Wi-Fi Signal Parameters ---\n");
fprintf('Sample Rate:       %.2f MHz\n', fs/1e6);
fprintf('Packet Duration:   %.2f us\n', (length(txWaveform)/fs)*1e6);
fprintf('Modulation:        MCS %d\n', cfg.MCS);
fprintf('Payload Length:    %d bytes\n', cfg.PSDULength);

% 4. SAVING TO FILE 
receivedSignal = txWaveform; 

metadata.sampleRate = fs;
metadata.centerFreq = 0;        
metadata.duration = length(txWaveform)/fs;
metadata.timestamp = datetime('now');
metadata.gain = 'Simulated (0 dB)';
metadata.MCS = cfg.MCS;  
metadata.isSimulation = true;

filename = sprintf('WiFi_MCS%d_BW20.mat', cfg.MCS);

save(filename, 'receivedSignal', 'metadata');

% 5. PLOTTING
figure('Name', 'Wi-Fi Signal Analysis', 'Color', 'white', 'Position', [100, 100, 800, 800]);

% --- Plot 1: Time Domain (I & Q Separately) ---
subplot(2, 1, 1);
t_axis = (0:length(txWaveform)-1)/fs * 1e6;
plot(t_axis, real(txWaveform)); 
hold on;
plot(t_axis, imag(txWaveform)); 
hold off;
title('1. Time Domain: I (Real) & Q (Imag)');
xlabel('Time [\mus]'); ylabel('Amplitude');
legend('In-Phase (I)', 'Quadrature (Q)', 'Location', 'northeast');
grid on; axis tight;

% --- Plot 2: Power Spectral Density (PSD) ---
subplot(2, 1, 2);
[pxx, f] = pwelch(txWaveform, [], [], [], fs, 'centered');
plot(f/1e6, 10*log10(pxx), 'LineWidth', 1.5);
title('2. Frequency Spectrum (PSD)');
xlabel('Frequency [MHz]'); ylabel('Power [dB/Hz]');
grid on; 

% --- Plot 3: Constellation Diagram ---
idealSymbols = wlanReferenceSymbols(cfg);
cdInput = comm.ConstellationDiagram();

cdInput(idealSymbols(:));
