L_active = idx(end) - idx(1) + 1;
w_d_act  = blackmanharris(L_active);
w_d_act  = w_d_act * sqrt(L_active) / norm(w_d_act);
win_f    = zeros(Nfft, 1);
win_f(idx(1):idx(end)) = w_d_act;

win_t = blackmanharris(n_symbols).';
win_t = win_t * sqrt(n_symbols) / norm(win_t);
W     = win_f .* win_t;
