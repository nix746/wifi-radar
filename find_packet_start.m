function [start_index, metric] = find_packet_start(signal, threshold)
% FIND_PACKET_START Wykrywa początek pakietu 802.11 używając algorytmu Schmidl-Cox.
%
% WEJŚCIE:
%   signal    - wektor zespolony z odebranym sygnałem
%   threshold - (opcjonalne) próg detekcji (domyślnie 0.75)
%
% WYJŚCIE:
%   start_index - numer próbki, gdzie zaczyna się pakiet (lub [] jeśli nie znaleziono)
%   metric      - obliczona metryka (do celów diagnostycznych/wykresów)

    % Ustawienia domyślne dla WiFi (kanał 20MHz)
    L = 16; % Opóźnienie autokorelacji dla L-STF
    
    if nargin < 2
        threshold = 0.75; % Domyślny próg detekcji
    end

    signal = signal(:); % Upewnij się, że to wektor kolumnowy
    N = length(signal);
    
    % --- 1. Algorytm Schmidl-Cox (Wersja zoptymalizowana) ---
    
    % y*(n) * y(n+L)
    delayed_term = conj(signal(1:end-L)) .* signal(L+1:end);
    
    % Energia: |y(n+L)|^2
    energy_term = abs(signal(L+1:end)).^2;
    
    % Suma w oknie przesuwnym (filter jest szybszy niż pętla for)
    window_sum = ones(L, 1);
    
    P_raw = filter(window_sum, 1, delayed_term);
    R_raw = filter(window_sum, 1, energy_term);
    
    % Wyrównanie wektorów (po filtracji przesuwamy o L, żeby indeksy pasowały)
    P = zeros(N, 1);
    R = zeros(N, 1);
    P(L+1:end) = P_raw;
    R(L+1:end) = R_raw;
    
    % Obliczenie metryki: M = |P|^2 / R^2
    metric = (abs(P).^2) ./ (R.^2 + eps);
    
    % --- 2. Logika decyzyjna (Szukanie indeksu) ---
    
    % Szukamy pierwszego momentu, gdy metryka przekroczy próg.
    idx = find(metric > threshold, 1, 'first');
    
    if isempty(idx)
        start_index = []; 
    else
        % POPRAWKA:
        % Odejmujemy L, ponieważ wcześniej przesunęliśmy wektor P i R o L.
        % Dodatkowo zabezpieczamy się funkcją max(), żeby nie wyjść poza zakres (gdyby idx < L).
        start_index = max(1, idx - L);
    end
end
