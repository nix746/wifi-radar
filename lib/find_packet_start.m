function [start_index, metric] = find_packet_start(signal, threshold)
% FIND_PACKET_START Detects 802.11 packet start using the Schmidl-Cox autocorrelation metric.
%
% Original baseline implementation: Patryk Pajerski
% Refactoring & optimization: Tymon Woźniak
%
% Inputs:
%   signal    - Complex received time-domain baseband signal
%   threshold - Detection threshold for normalized metric (default: 0.75)
%
% Outputs:
%   start_index - Sample index indicating the packet start (or [] if undetected)
%   metric      - Normalized autocorrelation metric array

    L = 16; % Auto-correlation delay for 802.11a L-STF periodic short training symbols
    
    if nargin < 2
        threshold = 0.75;
    end

    signal = signal(:);
    N = length(signal);
    
    if N <= L
        start_index = [];
        metric = [];
        return;
    end

    % Cross-term: y*(n) * y(n+L)
    delayed_term = conj(signal(1:end-L)) .* signal(L+1:end);
    
    % Energy term: |y(n+L)|^2
    energy_term = abs(signal(L+1:end)).^2;
    
    % Moving average sum over window length L
    window_sum = ones(L, 1);
    P_raw = filter(window_sum, 1, delayed_term);
    R_raw = filter(window_sum, 1, energy_term);
    
    % Vector alignment
    P = zeros(N, 1);
    R = zeros(N, 1);
    P(L+1:end) = P_raw;
    R(L+1:end) = R_raw;
    
    % Schmidl-Cox metric: M(d) = |P(d)|^2 / (R(d)^2 + eps)
    metric = (abs(P).^2) ./ (R.^2 + eps);
    
    % Peak search
    idx = find(metric > threshold, 1, 'first');
    
    if isempty(idx)
        start_index = [];
    else
        start_index = max(1, idx - L);
    end
end
