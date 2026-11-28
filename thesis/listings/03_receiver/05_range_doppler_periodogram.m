N_per  = pad_factor * 2^nextpow2(Nfft);
M_per  = pad_factor * 2^nextpow2(n_symbols);
H_win  = H_shifted .* W;
CPer_F = fftshift(N_per * ifft(fft(H_win, M_per, 2), N_per, 1), 2);
Per_F  = (1 / (N_act * n_symbols)) * abs(CPer_F).^2;
