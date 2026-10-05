% MTI Filter: Eliminate static reflection at direct path (0 Hz)
H_shifted = fftshift(H, 1);
H_shifted = H_shifted - mean(H_shifted, 2);

% DC carrier repair: Interpolate DC gap to prevent spectral leakage
H_shifted(33, :) = (H_shifted(32, :) + H_shifted(34, :)) / 2;
