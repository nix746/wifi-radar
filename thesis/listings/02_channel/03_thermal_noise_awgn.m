p_n_dBm          = 10 * log10(k_B * T_0 * bw_hz * 1e3) + nf_dB;
effective_snr_dB = p_rx_dBm - p_n_dBm;

signal        = clutter_signal + target_signal;
ref_power_dBW = 10 * log10(max(mean(abs(waveform).^2), eps));
signal        = awgn(signal, effective_snr_dB, ref_power_dBW);
