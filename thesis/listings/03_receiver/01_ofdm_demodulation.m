sym_len = n_fft + n_cp;
n_syms  = floor(length(signal) / sym_len);

sig_truncated       = signal(1 : n_syms * sym_len);
matrix_time_with_cp = reshape(sig_truncated, sym_len, n_syms);
matrix_time_no_cp   = matrix_time_with_cp(n_cp + 1 : end, :);
F_matrix            = fft(matrix_time_no_cp, n_fft, 1);
