for k = 1 : length(taps)
    delay  = delays(k) + intrinsic_delay;
    d_int  = floor(delay);
    d_frac = delay - d_int;
    delayed = [zeros(d_int, 1); waveform(1 : N - d_int)];
    if d_frac > 1e-6
        k_freq = [0 : floor(N/2)-1, -ceil(N/2) : -1].';
        delayed = ifft(fft(delayed) .* exp(-1j * 2 * pi * k_freq * d_frac / N));
    end
    target_signal = target_signal + taps(k) * delayed .* exp(1j * 2 * pi * dopplers(k) * t_eff);
end
