# Wi-Fi Passive Radar (IEEE 802.11a OFDM)

Implementacja pasywnego radaru opartego na sygnałach Wi-Fi w standardzie IEEE 802.11a (OFDM, 5.5 GHz) w środowisku MATLAB. Projekt realizuje pełny łańcuch przetwarzania sygnałów: od generacji ramki i symulacji kanału wielodrożnego z przesunięciem Dopplera, przez demodulację i dwuwymiarowy periodogram Range-Doppler, aż po filtrację MTI oraz koherentne usuwanie celów algorytmem CLEAN.

---

## Architektura i Łańcuch Przetwarzania

```
+------------------+      +--------------------+      +-----------------------+      +----------------------+
|   Transmitter    | ---> |  Multipath Channel | ---> |   Receiver Pipeline   | ---> |  CLEAN Interpreter   |
| (IEEE 802.11a TX)|      |  (Delay + Doppler) |      | (Demod, ZF, MTI, Win) |      |  (Target Detection)  |
+------------------+      +--------------------+      +-----------------------+      +----------------------+
```

1. **`src/transmitter.m`**: Generacja ramki IEEE 802.11a Non-HT (20 MHz, $N_{\text{fft}}=64$, $N_{\text{cp}}=16$).
2. **`src/channel.m`**: Model kanału z konfigurowalnymi opóźnieniami wielodrożnymi, przesunięciami Dopplera oraz szumem AWGN.
3. **`src/receiver_pipeline.m`**:
   - Usunięcie preambuły ($20\ \mu\text{s} = 400\ \text{próbek}$),
   - Ręczna demodulacja OFDM i estymacja kanału metodą Zero-Forcing ($H = Y / X$),
   - Maska 52 podnośnych aktywnych IEEE 802.11a,
   - Filtr MTI (usunięcie przesłuchu bezpośredniego / składowej stałej),
   - Łatanie luki częstotliwości stałoprądowej DC (indeks 33) przez interpolację liniową,
   - Okienkowanie 2D Blackman-Harris ($92\ \text{dB}$ tłumienia listków bocznych),
   - Obliczenie zespolonego periodogramu Range-Doppler i zapis `radar_data.mat`.
4. **`src/clean_interpreter.m`**:
   - Iteracyjny algorytm Coherent Successive Target Cancellation (CLEAN),
   - Skalowanie osi fizycznych: odległość [m] i prędkość radialna [m/s],
   - Wizualizacja mapy Range-Doppler przed i po usunięciu celów oraz eksport wykresów.
5. **`src/receiver_correlation.m`**: Alternatywny odbiornik korelacyjny w dziedzinie czasu (filtr dopasowany).

---

## Struktura Repozytorium

```text
WiFi-Radar/
├── .gitignore                     # Konfiguracja ignorowania plików tymczasowych i danych symulacji
├── README.md                      # Główny opis projektu i instrukcja uruchomienia
│
├── src/                           # Główny kod źródłowy algorytmów
│   ├── transmitter.m              # Moduł nadajnika Wi-Fi 802.11a
│   ├── channel.m                  # Symulator kanału radarowego z Dopplerem
│   ├── receiver_pipeline.m        # Odbiornik: demodulacja, ZF, MTI, okno 2D, periodogram
│   ├── clean_interpreter.m        # Detektor celów i algorytm Coherent CLEAN
│   └── receiver_correlation.m     # Alternatywny odbiornik korelacyjny (Time-Domain Matched Filter)
│
├── lib/                           # Biblioteka funkcji pomocniczych
│   ├── demodulate.m               # Ręczna demodulacja OFDM (CP + FFT)
│   └── find_packet_start.m        # Synchronizacja ramki algorytmem Schmidl-Cox
│
├── scripts/                       # Skrypty automatyzacji i testów
│   └── run_full_simulation.m      # Uruchomienie pełnego łańcucha od nadajnika do wykresów
│
├── results/                       # Wygenerowane wyniki i wykresy
│   └── figures/                   # Zapisane wykresy Range-Doppler (.png)
│
└── docs/                          # Dokumentacja naukowa
    ├── theory_notes.md            # Wyprowadzenia matematyczne, parametry 802.11a i algorytm CLEAN
    └── references.md              # Spis literatury i materiałów źródłowych
```

---

## Szybki Start

Aby uruchomić pełną symulację w MATLAB-ie:

```matlab
% W konsoli MATLAB-a:
cd('scripts')
run_full_simulation
```

Skrypt automatycznie wygeneruje sygnał, przeprowadzi transmisję przez kanał z celami ruchomymi, przetworzy macierz kanału i wyświetli porównanie mapy Range-Doppler przed i po zastosowaniu algorytmu CLEAN, zapisując wynikowy wykres do katalogu `results/figures/`.

---

## Autorzy i Podziękowania

- **Główny rozwój i implementacja**: Tymoteusz Woźniak (`nix746`, `tym.wozniak@gmail.com`)
- **Wkład początkowy (Baseline)**: Podziękowania dla **Patryka** za opracowanie wstępnej wersji modułu generacji sygnału 802.11a oraz synchronizacji ramki metodą Schmidl-Cox.

---

## Literatura

1. Martin Braun, *"OFDM Radar Algorithms in Mobile Communication Networks"*, Rozprawa doktorska, KIT, 2014.
2. IEEE Standard 802.11a-1999: *High-speed Physical Layer in the 5 GHz Band*.
