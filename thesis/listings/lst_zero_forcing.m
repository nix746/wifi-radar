% Demodulation of receive and reference signals
Y = demodulate(y_cut, Nfft, Ncp);
X = demodulate(x_cut, Nfft, Ncp);

% Zero-Forcing channel estimation
epsilon = 1e-9;
H = Y ./ (X + epsilon);

% Apply active subcarrier mask
H = H .* mask_active;
