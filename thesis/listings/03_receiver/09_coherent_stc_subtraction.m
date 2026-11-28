e_r = exp(-1j * 2 * pi * k_vec * n_sub / N_Per);
e_d = exp( 1j * 2 * pi * l_vec * m_sub / M_Per);
if mti_applied
    e_d = e_d - mean(e_d);
end
v_r = N_Per * ifft(e_r .* w_r, N_Per, 1);
v_d = fftshift(fft(e_d .* w_d.', M_Per, 2), 2);
denom_pk = v_r(rn) * v_d(dm);
CPer_F = CPer_F - ((CPer_F(rn, dm) / denom_pk) * v_r) * v_d;
Per_F  = (1 / (N * M)) * (real(CPer_F).^2 + imag(CPer_F).^2);
