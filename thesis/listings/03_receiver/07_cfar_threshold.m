N_max      = ceil((Ncp / Nfft) * N_Per);
n_guard    = ceil(N_win_null);
row_start  = min(N_Per - 1, N_max + n_guard + 1);
row_end    = max(row_start, N_Per - n_guard);
sigma2_hat = mean(Per_F(row_start : row_end, :), 'all');

p_FA_bin = -expm1(log1p(-p_FA) / (N * M));
eta      = -sigma2_hat * log(p_FA_bin);
