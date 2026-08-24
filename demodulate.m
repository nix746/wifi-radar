% demodulate.m
% Demodulates OFDM transmission

function [F_matrix, n_syms] = demodulate(signal, n_fft, n_cp)
    len_sym = n_fft + n_cp;
    n_syms = floor(length(signal) / len_sym);
    
    sig_trunc = signal(1 : n_syms*len_sym);
    mat_time = reshape(sig_trunc, len_sym, n_syms);
    
    % CP removal
    mat_payload = mat_time(n_cp+1 : end, :);
    
    % FFT along columns (Time -> Frequency)
    F_matrix = fft(mat_payload, n_fft, 1);
end
