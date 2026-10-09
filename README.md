# Wi-Fi Passive Radar

Symulator pasywnego radaru bistatycznego (PBR) wykorzystujący sygnały standardów **IEEE 802.11a** oraz **IEEE 802.11ax (Wi-Fi 6)** w środowisku MATLAB.

Projekt realizuje pełny łańcuch przetwarzania sygnałowego: syntezę ramek transmisyjnych, symulację kanału wielodrogowego z celami ruchomymi (model syntetyczny oraz TGax Model-B), estymację transmitancji kanału (Zero-Forcing), filtrację MTI, dwuwymiarowy periodogram Range-Doppler oraz usuwanie listków bocznych algorytmem Coherent CLEAN.

---

## Główne Cechy i Parametry

- **Obsługiwane standardy**:
  - **802.11a (Legacy)**: $N_{\text{fft}} = 64$, 52 podnośne aktywne, $T_{\text{sym}} = 4.0\ \mu\text{s}$, prędkość jednoznaczna $v_{\text{unamb}} \approx 68.2\ \text{m/s}$.
  - **802.11ax (Wi-Fi 6 HE-SU)**: $N_{\text{fft}} = 256$, 242 podnośne aktywne, $T_{\text{sym}} = 13.6\ \mu\text{s}$, prędkość jednoznaczna $v_{\text{unamb}} \approx 16.7\ \text{m/s}$.
- **Modele kanału**:
  - **Ideal Channel**: Dyskretna linia opóźniająca z celami ruchomymi i przesłuchem bezpośrednim (DPI).
  - **TGax Multipath**: Model wewnątrzbudynkowy `wlanTGaxChannel` (Model-B) z realistycznym profilem clutteru i opóźnieniem filtru.
- **Moduły DSP**:
  - Synchronizacja pakietu (`wlanPacketDetect`, `wlanSymbolTimingEstimate`).
  - Ręczna demodulacja OFDM i estymacja kanału Zero-Forcing ($H = Y / X$).
  - Filtracja MTI w dziedzinie wolnego czasu (usuwanie DPI i obiektów stacjonarnych).
  - Adaptacyjna interpolacja luki nośnych stałoprądowych (DC).
  - Okienkowanie Blackman-Harris 2D oraz periodogram Range-Doppler.
  - Detekcja celów i tłumienie listków bocznych algorytmem Coherent CLEAN.

---

## Porównanie Parametrów Fizycznych i Radarowych

| Parametr | IEEE 802.11a | IEEE 802.11ax (HE-SU) | Wpływ na radar pasywny |
| :--- | :---: | :---: | :--- |
| **Pasmo ($B$)** | 20 MHz | 20 MHz | Jednakowe dla obu standardów |
| **Częstotliwość próbkowania ($f_s$)** | 20 MHz | 20 MHz | Krok dyskretnego czasu $T_s = 50\ \text{ns}$ |
| **Rozmiar FFT ($N_{\text{fft}}$)** | 64 | 256 | 4-krotnie gęstsze próbkowanie pasma w 802.11ax |
| **Odstęp między podnośnymi ($\Delta f$)** | 312.5 kHz | 78.125 kHz | $\Delta f = 1 / T_{\text{fft}}$ |
| **Czas trwania symbolu ($T_{\text{sym}}$)** | $4.0\ \mu\text{s}$ | $13.6\ \mu\text{s}$ | Wpływa bezpośrednio na jednoznaczność prędkości |
| **Podnośne aktywne** | 52 | 242 | Większa gęstość informacji o transmitancji kanału |
| **Luka DC** | 1 nośna | 3 nośne ([-1, 0, 1]) | Wymaga wielopunktowej interpolacji w 802.11ax |
| **Rozdzielczość odległości ($\Delta R$)** | **7.5 m** | **7.5 m** | $\Delta R = c / (2B)$ |
| **Prędkość jednoznaczna ($v_{\text{unamb}}$)** | **$\approx 68.2\ \text{m/s}$** | **$\approx 16.7\ \text{m/s}$** | $v_{\text{unamb}} = \lambda / (2 T_{\text{sym}})$ |

---

## Architektura Przetwarzania

```text
+-----------------------+      +---------------------------+
|  step1_transmitter    | ---> |       step2_channel       |
|  (802.11a / 802.11ax) |      | (Ideal / TGax Multipath)  |
+-----------------------+      +---------------------------+
                                             |
                                             v
+-----------------------+      +---------------------------+
|  step4_interpreter    | <--- |      step3_receiver       |
| (Coherent CLEAN, 2D)  |      | (PktSync, ZF, MTI, DC, Win)|
+-----------------------+      +---------------------------+
```

1. **`src/step1_transmitter.m`**: Generacja ramki transmisyjnej (`wlanWaveformGenerator`).
2. **`src/step2_channel.m`**: Nałożenie celów radarowych, przesłuchu DPI, modelu kanału (Ideal / TGax) i szumu AWGN.
3. **`src/step3_receiver.m`**: Synchronizacja czasowa, demodulacja, estymacja ZF, filtracja MTI, interpolacja DC i periodogram Range-Doppler.
4. **`src/step4_interpreter.m`**: Detekcja celów, eliminacja listków bocznych Coherent CLEAN i zapis wykresów.

---

## Szybki Start

Wymagania: **MATLAB** (R2021a+) wraz z **WLAN Toolbox**.

Uruchomienie pełnego zestawu symulacji (4 konfiguracje):

```matlab
% W konsoli MATLAB:
cd('scripts');
run_full_simulation;
```

Kombinacje scenariuszy:
1. `802.11a` + `Ideal Channel`
2. `802.11ax` + `Ideal Channel`
3. `802.11a` + `TGax Multipath`
4. `802.11ax` + `TGax Multipath`

Wykresy wynikowe zapisywane są automatycznie w katalogu `results/figures/run_YYYY-MM-DD_HH-MM-SS/`.

---

## Struktura Repozytorium

```text
WiFi-Radar/
├── init_paths.m          # Konfiguracja ścieżek MATLAB-a
├── src/                  # 4 etapy przetwarzania (transmitter -> channel -> receiver -> interpreter)
├── lib/                  # Biblioteki DSP (demodulacja, estymacja ZF, MTI, CLEAN)
│   └── visualizations/   # Generatory wykresów (spektrum, konstelacja, mapy 2D/3D)
├── scripts/              # Skrypt uruchomieniowy run_full_simulation.m
├── tests/                # Testy regresyjne (verify_regression.m)
├── results/figures/      # Wygenerowane wyniki i mapy radarowe
├── docs/                 # Notatki merytoryczne i dokumentacja
└── thesis/               # Pliki pracy dyplomowej (LaTeX)
```

---

## Autorzy

- **Tymon Woźniak** (`nix746`, `tym.wozniak@gmail.com`)
- Podziękowania dla **Patryka Pajerskiego** za wstępną implementację nadajnika 802.11a i synchronizacji Schmidl-Cox.