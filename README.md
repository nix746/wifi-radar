# Wi-Fi Passive Radar

Symulator pasywnego radaru bistatycznego (PBR) wykorzystujący sygnały standardów **IEEE 802.11a** oraz **IEEE 802.11ax (Wi-Fi 6)** w środowisku MATLAB.

Projekt realizuje pełny łańcuch przetwarzania sygnałowego: syntezę ramek transmisyjnych, symulację kanału wielodrogowego TGax z celami ruchomymi, estymację odpowiedzi częstotliwościowej kanału przez dzielenie podnośnych, usuwanie echa stałego przez odejmowanie średniej czasowej, interpolację luki DC, dwuwymiarowy periodogram Range–Doppler oraz sekwencyjną detekcję i ekstrakcję celów algorytmami **Binary STC** i **Coherent STC** z progiem CFAR $\eta$ (wg M. Brauna, 2014).

---

## Szybki Start

Wymagania: **MATLAB** (R2021a+) wraz z **WLAN Toolbox** oraz **Communications Toolbox** (`awgn`).

Uruchomienie bezpośrednio z katalogu głównego projektu (po `init_paths` lub przez `run(...)`) albo z podfolderów `scripts/`:

- **Wygenerowanie i wyświetlenie wszystkich rysunków z pracy dyplomowej** (9 osobnych okien + eksport PNG 300 DPI do `thesis/img/`):
  ```matlab
  run('scripts/figures/run_all_figures.m')
  % lub po init_paths():
  run_all_figures
  ```
- **Pokazówka losowych celów i porównanie detekcji Binary STC vs Coherent STC**:
  ```matlab
  run('scripts/run_random_demo.m')
  % lub po init_paths():
  run_random_demo
  ```
- **Testy regresyjne i jednostkowe** (Golden Master + testy Binary/Coherent STC):
  ```matlab
  run('tests/verify_regression.m')
  ```

---

## Główne Cechy i Parametry

- **Obsługiwane standardy**:
  - **802.11a (Legacy)**: $N_{\text{fft}} = 64$, 52 podnośne aktywne, $T_{\text{sym}} = 4{,}0\ \mu\text{s}$, prędkość jednoznaczna $v_{\text{unamb}} \approx \pm 68{,}2\ \text{m/s}$ (przy $f_c = 5{,}5\ \text{GHz}$: $\pm 56{,}8\ \text{m/s}$ dla okresu $T_{\text{sym}}$ z CP $0{,}8\ \mu\text{s}$).
  - **802.11ax (Wi-Fi 6 HE-SU)**: $N_{\text{fft}} = 256\text{–}2048$ (`CBW20`–`CBW160`), $T_{\text{sym}} = 13{,}6\ \mu\text{s}$, prędkość jednoznaczna $v_{\text{unamb}} \approx \pm 16{,}7\ \text{m/s}$ (przy $f_c = 5{,}5\ \text{GHz}$).
- **Modele kanału**:
  - **TGax (`wlanTGaxChannel`)**: profile wewnątrzbudynkowe `Model-A` (brak wielodrogi, $\tau_{\text{rms}} = 0\ \text{ns}$), `Model-B` ($\tau_{\text{rms}} = 15\ \text{ns}$), `Model-C` ($\tau_{\text{rms}} = 30\ \text{ns}$), `Model-E` ($\tau_{\text{rms}} = 100\ \text{ns}$) z realistycznym przesłuchem bezpośrednim (DPI), opóźnieniem filtru i szumem AWGN.
- **Moduły DSP**:
  - Synchronizacja pakietu z WLAN Toolbox (`wlanPacketDetect` + detekcja pierwszego czoła *leading-edge* na metryce korelacyjnej L-LTF z `wlanSymbolTimingEstimate`).
  - Ręczna demodulacja OFDM i estymacja odpowiedzi częstotliwościowej kanału przez dzielenie element po elemencie podnośnych odebranych przez podnośne wzorcowe ($H = Y / X$).
  - Usuwanie echa stałego w dziedzinie czasu wolnego przez odejmowanie średniej czasowej (eliminacja DPI i obiektów stacjonarnych).
  - Adaptacyjna interpolacja luki podnośnych stałoprądowych (DC).
  - Okienkowanie Blackmana–Harrisa 2D oraz periodogram Range–Doppler (`compute_range_doppler_map`).
  - Sekwencyjna ekstrakcja celów **Binary STC** (maskowanie binarne) oraz **Coherent STC** (koherentne odejmowanie repliki celu) z globalnym progiem **CFAR $\eta$**, estymacją mocy szumu ML poza $N_{\max}$, 2D interpolacją paraboliczną oraz oceną kontrastu **PNFR**.

---

## Architektura Przetwarzania

```text
+-----------------------+      +---------------------------+
|  step1_transmitter    | ---> |       step2_channel       |
|  (802.11a / 802.11ax) |      |  (TGax Model A/B/C/E +    |
+-----------------------+      |   Moving Radar Targets)   |
                               +---------------------------+
                                             |
                                             v
+-----------------------+      +---------------------------+
|  step4_interpreter    | <--- |      step3_receiver       |
| (Binary/Coherent STC, |      | (PktSync, Y/X, -Mean, DC) |
|  CFAR, PNFR)          |      +---------------------------+
+-----------------------+
```

1. **`src/step1_transmitter.m`**: Generacja ramki transmisyjnej (`wlanWaveformGenerator`).
2. **`src/step2_channel.m`**: Nałożenie celów radarowych, kanału wielodrogowego TGax (z DPI) i szumu AWGN.
3. **`src/step3_receiver.m`**: Synchronizacja czasowa, demodulacja, estymacja kanału przez dzielenie podnośnych, usuwanie echa stałego (odejmowanie średniej czasowej), interpolacja DC i periodogram Range–Doppler.
4. **`src/step4_interpreter.m`**: Detekcja celów algorytmami Binary/Coherent STC oraz wyznaczenie kontrastu PNFR.

---

## Struktura Repozytorium

```text
WiFi-Radar/
├── init_paths.m          # Konfiguracja ścieżek MATLAB-a
├── src/                  # 4 etapy przetwarzania (transmitter -> channel -> receiver -> interpreter)
├── lib/                  # Biblioteki DSP (demodulacja, estymacja kanału, usuwanie echa stałego, Binary/Coherent STC, PNFR)
├── scripts/              # Skrypty uruchomieniowe (run_random_demo.m)
│   └── figures/          # Skrypty generujące rysunki (run_all_figures.m oraz ch2–ch4)
├── tests/                # Testy regresyjne i jednostkowe (verify_regression.m)
├── docs/                 # Notatki merytoryczne i plany eksperymentów
└── thesis/               # Pliki pracy dyplomowej (LaTeX) i wyeksportowane rysunki (thesis/img/)
```

---

## Autorzy

- **Tymon Woźniak** (`nix746`, `tym.wozniak@gmail.com`)
- Podziękowania dla **Patryka Pajerskiego** za wstępną implementację nadajnika 802.11a i synchronizacji Schmidl-Cox.
