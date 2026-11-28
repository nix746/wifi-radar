delta_f = fs / Nfft;
T_O     = k_pri * (Nfft + Ncp) / fs;

n_idx = 0 : (N_per - 1);
m_idx = floor(-M_per / 2) : (ceil(M_per / 2) - 1);

axis_range    = (n_idx * c) / (2 * delta_f * N_per);
axis_velocity = (m_idx * c) / (2 * fc * T_O * M_per);
