% 2D Blackman-Harris Windowing
W_2D_shifted = win_f_shifted .* win_t;
H_ready = ifftshift(H_shifted .* W_2D_shifted, 1);

% Complex Range-Doppler Periodogram Generation
% N_per: Range FFT size, M_per: Doppler FFT size
CPer_base = fftshift(fft(ifft(H_ready, N_per, 1), M_per, 2), 2);
