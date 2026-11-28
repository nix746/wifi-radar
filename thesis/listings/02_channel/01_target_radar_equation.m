del_spl = range_m / sample_res;
dop_hz  = (2 * fc * vel_mps) / c0;

r_eff        = max(range_m, 1.0);
p_target_los = p_tx_W * (gain_ant^2) * (lambda^2) * rcs / ((4 * pi)^3 * r_eff^4);
amp          = sqrt(p_target_los / p_rx_W);
if r_eff > tgax_p.d_bp
    amp = amp * (tgax_p.d_bp / r_eff)^(tgax_p.n_nlos - tgax_p.n_los);
end
tau_s = 2 * range_m / c0;
tap   = amp * exp(-1j * 2 * pi * fc * tau_s);
