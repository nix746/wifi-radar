# Źródło prawdy: co ma powstać

Ten dokument rozstrzyga **co** jest celem pracy i repozytorium. Kolejność zadań jest w [`plan_work_order.md`](plan_work_order.md).

## 1. Praca

| Pole | Wartość |
| :--- | :--- |
| Typ | Praca **inżynierska** |
| Temat | Implementacja i testowanie efektywności detekcji wybranego algorytmu radaru pasywnego używającego sygnału Wi-Fi |
| Opiekun | prof. dr hab. inż. Tomasz Zieliński |
| Wzorzec układu | Prace z katedry / analogiczna inżynierska K. Szwej (*Radar OFDM z użyciem sygnału DVB-T2*), plus Sorbian (WAT) jako drugi punkt odniesienia rysunków i porównań |
| Wkład własny | Zastosowanie paradygmatu przetwarzania CIR (estymacja kanału, MTI, kompensacja DC, mapa Range–Doppler) na sygnale **Wi-Fi 802.11a oraz 802.11ax**, przekrojowa analiza wpływu parametrów warstwy fizycznej (szerokość pasma, aliasing Dopplera, rząd MCS, model kanału TGax) na detekcję oraz implementacja algorytmu **Coherent CLEAN** (Braun) |

Kod w `src/` jest już nośnikiem metody. Praca ma **opisać i zbadać** ten łańcuch, a nie przebudowywać go od zera.

---

## 2. Układ rozdziałów (obowiązujący)

Sześć rozdziałów. Nie ma osobnego rozdziału „implementacja MATLAB”: środowisko i architektura wchodzą w **5.1**. Nie łączy się geometrii PBR z PHY 802.11 w jednym rozdziale.

| Nr | Plik LaTeX | Tytuł | Zawartość |
| :--- | :--- | :--- | :--- |
| 1 | `thesis/tex/10_introduction.tex` | Wstęp | Cel i zakres (802.11a vs 802.11ax, kanał syntetyczny vs TGax), motywacja (iluminator Wi-Fi, nowsze generacje OFDM), teza i pytania badawcze, układ pracy |
| 2 | `thesis/tex/20_pbr.tex` | Koncepcja bistatycznego radaru pasywnego | Geometria bistatyczna, zjawiska fizyczne (DPI, clutter stacjonarny, bilans mocy i równanie bistatyczne), model kanału, **paradygmat CIR i estymacja Zero-Forcing**, zalety i ograniczenia |
| 3 | `thesis/tex/30_wifi_phy.tex` | Sygnał Wi-Fi IEEE 802.11 | Rodzina 802.11 i ewolucja PHY (802.11a vs 802.11ax), struktura OFDM i CP, ramki Non-HT oraz HE-SU, siatka podnośnych i luka DC; **sprzężone relacje parametrów telekomunikacyjnych i radarowych (trade-offs)** |
| 4 | `thesis/tex/40_radar_dsp.tex` | Algorytmy przetwarzania radarowego | Synchronizacja pakietu (wlanPacketDetect, L-LTF); Zero-Forcing z dynamiczną maską podnośnych (52 vs 242), filtr MTI w czasie wolnym, adaptacyjna interpolacja DC, okno 2D Blackmana–Harrisa (-92 dB), periodogram 2D Range–Doppler, algorytm Coherent CLEAN z adaptacyjnym progiem szumu MAD |
| 5 | `thesis/tex/50_simulation_results.tex` | Badania symulacyjne | 5.1 Środowisko MATLAB i bilans mocy AP; 5.2 Rozdzielczość odległościowa a pasmo (20, 40, 80, 160 MHz); 5.3 Aliasing Dopplera i długość symbolu OFDM (802.11a vs ax); 5.4 Wpływ MCS i zjawisko wzmocnienia szumu w estymacji ZF; 5.5 Clutter wielodrogowy TGax (Modele A, C, E) i filtr MTI; 5.6 Skuteczność Coherent CLEAN w scenariuszach o dużej dynamice mocy (>30 dB) i adaptacyjny warunek stopu; 5.7 Analiza statystyczna Monte Carlo ($P_D$ oraz stabilność estymacji liczby obiektów) |
| 6 | `thesis/tex/99_conclusion.tex` | Wnioski | Podsumowanie wyników, ograniczenia metody CIR w Wi-Fi, perspektywy rozwoju (SDR/CSI, Multi-Frame CPI) |

Front matter (strona tytułowa, oświadczenie, program pracy) znajduje się w plikach `01_`–`03_`, z danymi ze zgłoszenia i etykietą „praca inżynierska”.

Pliki rozdziałów (`10_introduction.tex` … `99_conclusion.tex`) znajdują się w `thesis/tex/` i są włączane przez `\include` w `thesis/main.tex`.

**Zasada Single Source of Truth dla tekstu i wzorów**: Wszelka treść merytoryczna, wzory, wyprowadzenia i tabele powstają **od razu bezpośrednio w plikach `.tex` w `thesis/tex/`**. Nie tworzymy równoległych brudnopisów teorii w Markdownie. Wcześniejsze notatki (`theory_notes.md`) służą jedynie jako podręczna ściąga wyjściowa do zredagowania w LaTeX-u.

---

## 3. Bibliografia

Źródło prawdy metadanych: **kolekcja Zotero *Wi-Fi Radar***. Git trzyma wyłącznie bezpośredni eksport `.bib` oraz kopie robocze PDF.

| Warstwa | Gdzie | Rola |
| :--- | :--- | :--- |
| Metadane + PDF | Zotero | Rekord, stały klucz cytowania (Better BibTeX), DOI/URL, załączony plik |
| Eksport LaTeX | `thesis/bibliography.bib` | Bezpośredni eksport z Zotero — jedyne źródło literatury dla LaTeX-a |
| Kopie robocze PDF | `references/` | Materiały robocze (`compendiums/`, `shorts/`, `TW/`, `TZ/`) do importu do Zotero |

> [!CAUTION]
> **ZAKAZ RĘCZNEJ EDYCJI `thesis/bibliography.bib`**:
> Plik `thesis/bibliography.bib` jest generowany i synchronizowany **wyłącznie automatycznie z programu Zotero** (za pomocą wtyczki Better BibTeX / auto-export).
> - **Nie wolno modyfikować tego pliku ręcznie** — wszelkie nowe pozycje (w tym kluczowe prace Brauna: `braun2014ofdm`, `braun2020bistatic`, Bergera `berger2010signal` czy Sorbiana `sorbianWykorzystanieSieciWifi2025`) wprowadza się przez Zotero.
> - Ręczna zmiana w pliku `.bib` zostanie bezpowrotnie nadpisana przy kolejnej synchronizacji z Zotero.

> [!IMPORTANT]
> **Status demonstracji i toolboxów MathWorks**: Przykłady demonstracyjne z `_archive_original/` oraz pakiety narzędziowe (WLAN Toolbox, Communications Toolbox) **nie wchodzą do bibliografii jako artykuły naukowe**. Ich wykorzystanie opisuje się w tekście pracy w rozdziale **5.1**.

## 4. Architektura oprogramowania, scenariusze badawcze i rysunki do rozdziałów 4 i 5

### 4.1. Architektura kodu i uzasadnienie wkładu własnego (podrozdział 5.1)

W rozdziale 5.1 wyraźnie rozgranicza się rolę toolboxów i wkładu własnego:
1. **WLAN Toolbox**: wykorzystany w `src/step1_transmitter.m` do syntezy sygnału nadawczego IEEE 802.11a i 802.11ax (`wlanWaveformGenerator`, `wlanNonHTConfig`, `wlanHESUConfig`) oraz w `src/step2_channel.m` do symulacji standaryzowanych kanałów wielodrogowych IEEE 802.11ax (`wlanTGaxChannel`).
2. **Communications Toolbox**: wykorzystany w `src/step2_channel.m` do wprowadzania szumu termicznego AWGN.
3. **Wkład własny w algorytmy DSP (rdzeń pracy)**: cała część odbiorcza i interpretacyjna zaimplementowana w bazowym środowisku MATLAB bez „czarnych skrzynek” z Radar Toolboxa:
   - manualna demodulacja OFDM i usuwanie CP (`lib/demodulate.m`),
   - estymacja macierzy transmitancji kanału Zero-Forcing ($H = Y ./ X$),
   - filtracja MTI w dziedzinie symboli (czas wolny),
   - adaptacyjna interpolacja podnośnych DC przeciwdziałająca wyciekowi widmowemu,
   - okienkowanie 2D Blackmana–Harrisa (-92 dB) wyznaczane analitycznie,
   - dwuwymiarowy periodogram zespolony Range–Doppler (`lib/compute_range_doppler_map.m`),
   - koherentne usuwanie celów algorytmem Coherent CLEAN z adaptacyjnym progiem tła szumowego MAD (`lib/run_coherent_clean.m`),
   - kalibracja fizycznych osi odległości i prędkości (`lib/calculate_physical_axes.m`).

### 4.2. Sprzężone relacje fizyczne (Trade-offs) i ograniczenia środowiskowe

W badaniach uwzględnia się fundamentalne zależności sprzężone parametrów sygnału Wi-Fi i parametrów radarowych:
1. **Fizyka mocy punktu dostępowego (AP) i szerokość pasma $B$**: W rzeczywistych punktach dostępowych całkowita moc nadawcza jest ograniczona przepisami prawnymi (np. $P_{\text{tx}} = 100\ \text{mW}$ EIRP). Przejście z 20 MHz do 160 MHz rozprasza tę samą moc na 8x większą liczbę podnośnych. Dodatkowo moc szumu termicznego w odbiorniku $P_N = k_B \cdot T \cdot B \cdot F$ rośnie o $10 \log_{10}(160/20) = 9.03\ \text{dB}$. Zysk rozdzielczości odległościowej ($\Delta R = c / 2B$: 7.5 m dla 20 MHz vs 0.94 m dla 160 MHz) okupiony jest więc 9 dB spadkiem wejściowego SNR.
2. **Długość symbolu OFDM $T_{\mathrm{sym}}$ (802.11a vs ax)**: 4-krotnie dłuższy symbol w ax ($13.6\ \mu\text{s}$ vs $4.0\ \mu\text{s}$) zwiększa odporność na wielodrogowość, lecz 4-krotnie obniża prędkość jednoznaczną $v_{\mathrm{unamb}}$ ($\pm 16.7\ \text{m/s}$ w ax vs $\pm 56.8\ \text{m/s}$ w a).
3. **Brama anomalii prędkości**: W scenariuszach wnętrzowych/biurowych wykrycia o $|v| > 100\ \text{km/h}$ ($27.78\ \text{m/s}$) traktowane są jako niefizyczne anomalie i odrzucane.
4. **Rząd modulacji MCS i zjawisko Noise Enhancement**: Wyższe rzędy modulacji (16-QAM, 64-QAM, 1024-QAM) niosą zmienną energię symboli. Dzielenie przez małe wartości w Zero-Forcing podbija wariancję tła szumowego ($\zeta_{\text{ZF}} = \text{mean}(1/|\tilde{X}|^2) > 0\ \text{dB}$), co obniża kontrast celu (PNFR).
5. **Clutter wielodrogowy i filtr MTI**: Zgodnie z równaniem bistatycznym bezpośredni przesłuch DPI oraz odbicia stacjonarne są silniejsze od echa ruchomego celu o $30\text{--}50\ \text{dB}$; filtr MTI w czasie wolnym wycina składową stałą ($f_D = 0$).
6. **Luka DC**: Zerowanie podnośnych stałoprądowych wokół częstotliwości środkowej wywołuje oscylacje sinc wzdłuż osi odległości; interpolacja liniowa likwiduje ten wyciek widmowy.

### 4.3. Reprezentatywna triada modeli kanału TGax

Zamiast testowania wszystkich modeli kanałowych wybrano triadę o zróżnicowanym profilu opóźnień:
- **Model-A**: $\tau_{\text{rms}} = 0\ \text{ns}$ (warunki komory bezechowej / idealny tor odniesienia; kalibracja algorytmów bez zniekształceń wielodrogowych).
- **Model-C**: $\tau_{\text{rms}} = 30\ \text{ns}$ (typowe środowisko mieszkalne i biurowe o umiarkowanym profilu opóźnień i gęstym clutterze stacjonarnym).
- **Model-E**: $\tau_{\text{rms}} = 100\ \text{ns}$ (duża otwarta przestrzeń przemysłowa lub hala magazynowa; długie echa wielodrogowe o wysokiej dynamice mocy).

### 4.4. Matryca eksperymentów badawczych

Badania w Rozdziale 5 podzielono na eksperymenty deterministyczne E1–E5 oraz weryfikację statystyczną Monte Carlo:

| Nr | Eksperyment | Cel badawczy | Warunki i parametry | Obserwowane zjawisko |
| :---: | :--- | :--- | :--- | :--- |
| **E1** | **Rozdzielczość pasma** | Wpływ pasma na separację bliskich celów | $B = 20, 40, 80, 160\,\mathrm{MHz}$ (802.11ax, MCS 0, Model-C) | Dwa cele oddalone o $3.75\,\mathrm{m}$: zlanie w $20\,\mathrm{MHz}$ ($\Delta R=7.5\ \text{m}$), styk w $40\,\mathrm{MHz}$, pełna separacja w $80$ i $160\,\mathrm{MHz}$ |
| **E2** | **Aliasing Dopplera** | Długość symbolu OFDM a prędkość jednoznaczna | 802.11a ($T_{\mathrm{sym}}=4.0\,\mu\text{s}$) vs 802.11ax ($T_{\mathrm{sym}}=13.6\,\mu\text{s}$), Model-A | Szybki pojazd ($v=20\,\mathrm{m/s}$): poprawna detekcja w 'a' vs fałszywa prędkość (aliasing do $-13.4\ \text{m/s}$) w 'ax' |
| **E3** | **Modulacja i szum** | Wzmocnienie szumu $\zeta_{\text{ZF}}$ i kontrast PNFR | MCS 0 (BPSK), MCS 3 (16-QAM), MCS 7 (64-QAM), MCS 11 (1024-QAM), ładunek 4095 B | Wzrost $\zeta_{\text{ZF}}$ z 0 dB do $>4.2\ \text{dB}$ oraz spadek zysku integracji o $12\ \text{dB}$ dla wyższych MCS |
| **E4** | **Clutter TGax i MTI** | Tłumienie stacjonarnego echa wielodrogowego | Modele TGax: Model-A, Model-C, Model-E | Wycięcie składowej stałej $f_D = 0$ o ponad $48\ \text{dB}$ przez filtr MTI; rola interpolacji luki DC |
| **E5** | **Dynamika i Coherent CLEAN** | Odkrywanie słabych celów i adaptacyjny warunek stopu | Cel silny ($0\,\mathrm{dB}$, pojazd), cel słaby ($-30\,\mathrm{dB}$, pieszy), Model-C | Odkrycie słabego celu w listkach bocznych; automatyczne przerwanie po 2 iteracjach dzięki progowi MAD (brak *over-cleaning*) |
| **MC** | **Analiza Monte Carlo** | Statystyczna niezawodność detekcji i zliczania celów | $N_{\text{prób}} = 30$, SNR = $0\text{--}30\ \text{dB}$ (krok 5 dB), Model-C, $N_{\text{true}} = 2$ | Krzywe $P_D(\text{SNR})$ dla obu celów oraz odsetek prawidłowego zliczenia $P(N_{\text{det}} == 2)$ i fałszywych alarmów ($0\%$) |

### 4.5. Struktura skryptów figur i katalog rysunków

Wszystkie skrypty generujące rysunki zorganizowane są w podkatalogach według rozdziałów pracy jako samodzielne, modularne funkcje w języku angielskim:
- `scripts/figures/ch4_dsp/` — skrypty dla rozdziału 4,
- `scripts/figures/ch5_sim/` — skrypty dla rozdziału 5 (E1–E5 i Monte Carlo),
- `scripts/figures/run_all_figures.m` — nadrzędny master runner wykonujący wszystkie skrypty po kolei.

Katalogi wyjściowe figur:
- `thesis/img/ch4_dsp/` (rysunki rozdziału 4),
- `thesis/img/ch5_sim/` (rysunki rozdziału 5).

> [!IMPORTANT]
> **Zasada językowa i standardy czytelności dla wizualizacji**:
> Wszystkie generowane wykresy przeznaczone do pracy dyplomowej **muszą posiadać podpisy, tytuły, osie z jednostkami w nawiasach kwadratowych `[...]`, legendy i paski kolorów w 100% w języku polskim**. Nazwy plików figur w `thesis/img/` również są w języku polskim. Kod źródłowy MATLAB i komentarze pozostają w języku angielskim.
>
> Każdy eksperyment badawczy realizowany jest w osobnym kroku i podlega dwuetapowej weryfikacji:
> 1. **Poprawność fizyczna i numeryczna**: zgodność osi z teorią (brak anomalii prędkości $> 100\ \text{km/h}$, stała moc AP $P_{\text{tx}}$ i wzrost szumu $P_N$ o $9\ \text{dB}$ dla 160 MHz, poprawne tłumienie MTI i próg MAD).
> 2. **Czytelność i estetyka do druku**: grube linie ($\ge 1.5\ \text{pt}$), duże czcionki ($\ge 10\text{--}11\ \text{pt}$), siatka `grid on`, wysoka rozdzielczość, brak nachodzących na siebie etykiet.

**Katalog 11 rysunków i dedykowanych eksperymentów do pracy**:

| Nr w pracy | Plik graficzny | Skrypt testowy / generator | Eksperyment i zawartość merytoryczna |
| :---: | :--- | :--- | :--- |
| **Rys. 4.1** | `thesis/img/ch4_dsp/rys_4_1_konstelacja_rx.png` | `scripts/figures/ch4_dsp/gen_fig_4_1_constellation_rx.m` | **DSP-1**: Konstelacja sygnału RX przed i po korekcji transmitancji kanału (ZF) |
| **Rys. 4.2** | `thesis/img/ch4_dsp/rys_4_2_macierz_transmitancji_h.png` | `scripts/figures/ch4_dsp/gen_fig_4_2_channel_matrix_h.m` | **DSP-2**: Estymowana macierz transmitancji $\hat{H}(k, l)$ w dziedzinie częstotliwość--czas wolny |
| **Rys. 4.3** | `thesis/img/ch4_dsp/rys_4_3_periodogram_3d.png` | `scripts/figures/ch4_dsp/gen_fig_4_3_range_doppler_3d.m` | **DSP-3**: Trójwymiarowa powierzchnia periodogramu Range--Doppler $P_{\text{Per}}(R, v)$ z pikami celów |
| **Rys. 5.1** | `thesis/img/ch5_sim/rys_5_1_mapa_range_doppler_2d.png` | `scripts/figures/ch5_sim/gen_fig_5_1_range_doppler_2d.m` | **SIM-0**: Bazowa mapa 2D Range--Doppler w paśmie 40 MHz (Model-A) ilustrująca architekturę łańcucha |
| **Rys. 5.2** | `thesis/img/ch5_sim/rys_5_2_przekroj_odleglosci_pasma.png` | `scripts/figures/ch5_sim/gen_fig_5_2_bandwidth_cut.m` | **SIM-1 (E1)**: Przekrój odległościowy dla pasm 20, 40, 80, 160 MHz w teście separacji celów ($\Delta R = 3.75\ \text{m}$) a stała moc AP |
| **Rys. 5.3** | `thesis/img/ch5_sim/rys_5_3_aliasing_dopplera_porownanie.png` | `scripts/figures/ch5_sim/gen_fig_5_3_doppler_aliasing.m` | **SIM-2 (E2)**: Przekrój prędkości Dopplera dla 802.11a i 802.11ax dla szybkiego celu $v = 20\ \text{m/s}$ (aliasing w ax) |
| **Rys. 5.4** | `thesis/img/ch5_sim/rys_5_4_wzmocnienie_szumu_mcs.png` | `scripts/figures/ch5_sim/gen_fig_5_4_noise_enhancement.m` | **SIM-3 (E3)**: Współczynnik wzmocnienia szumu $\zeta_{\text{ZF}}$ i kontrast celu PNFR w funkcji rzędu MCS (0, 3, 7, 11) |
| **Rys. 5.5** | `thesis/img/ch5_sim/rys_5_5_tlumienie_clutteru_mti.png` | `scripts/figures/ch5_sim/gen_fig_5_5_tgax_mti_cut.m` | **SIM-4 (E4)**: Przekrój profilu Dopplera przed i po filtracji MTI w kanałach TGax (Modele A, C, E) |
| **Rys. 5.6** | `thesis/img/ch5_sim/rys_5_6_clean_prog_adaptacyjny.png` | `scripts/figures/ch5_sim/gen_fig_5_6_clean_cut.m` | **SIM-5 (E5)**: Przekrój odległościowy przed i po dekonwolucji CLEAN z zaznaczonym progiem adaptacyjnym MAD (odkrycie pieszego) |
| **Rys. 5.7** | `thesis/img/ch5_sim/rys_5_7_statystyka_pd_vs_snr.png` | `scripts/figures/ch5_sim/gen_fig_5_7_stat_pd_vs_snr.m` | **SIM-6 (MC)**: Prawdopodobieństwo prawidłowej detekcji $P_D$ w funkcji SNR dla silnego i słabego celu |
| **Rys. 5.8** | `thesis/img/ch5_sim/rys_5_8_statystyka_dokladnosc_zliczenia.png` | `scripts/figures/ch5_sim/gen_fig_5_8_stat_accuracy_vs_snr.m` | **SIM-6 (MC)**: Skuteczność prawidłowego zliczania celów $P(N_{\text{det}} == 2)$ i odsetek fałszywych alarmów |

### 4.6. Czystość kodu, listingi do pracy i weryfikacja regresyjna

1. **Funkcje DSP w `lib/` (czyste funkcje numeryczne)**:
   - `lib/demodulate.m` — demodulacja OFDM i usuwanie CP,
   - `lib/estimate_channel_zf.m` — estymacja Zero-Forcing, maska podnośnych, MTI i interpolacja luki DC,
   - `lib/compute_range_doppler_map.m` — analityczne okno 2D Blackmana–Harrisa oraz periodogram 2D,
   - `lib/run_coherent_clean.m` — pętla Coherent CLEAN (Braun) ze wsparciem stałej liczby iteracji `num_targets` oraz adaptacyjnego progu szumu MAD ($\sigma_{\text{szum}} = \text{median}(|C_{\text{Per}}|)/0.6745$, $T_{\text{stop}} = \sigma_{\text{szum}} \cdot 10^{\text{margin}/20}$),
   - `lib/calculate_physical_axes.m` — skalowanie fizycznych osi odległości i prędkości.
2. **Skrypty w `src/` jako fasady uruchomieniowe (100% kompatybilności wstecznej)**:
   - Skrypty `step1_transmitter.m`, `step2_channel.m`, `step3_receiver.m`, `step4_interpreter.m` zachowują stabilną zgodność.
   - `scripts/run_full_simulation.m` nadal wykonuje bazowy łańcuch.
3. **Zabezpieczenie wzorcem odniesienia („Golden Master”) i testy regresyjne**:
   - Skrypt `tests/verify_regression.m` gwarantuje tożsamość numeryczną bazowych funkcji (`max(abs(diff)) < 1e-12`).
4. **Zwarte listingi do tekstu pracy (`thesis/listings/`)**:
   - `listings/lst_zero_forcing.m` (rozdz. 4.2),
   - `listings/lst_mti_dc.m` (rozdz. 4.3–4.4),
   - `listings/lst_range_doppler.m` (rozdz. 4.5–4.6),
   - `listings/lst_coherent_clean.m` (rozdz. 4.7).

---

## 5. Stan szablonu LaTeX do domknięcia

- `thesis/main.tex` — autor, tytuł, wydział, kierunek, opiekun, recenzent, `\include` wszystkich rozdziałów
- `thesis/tex/01_titlePage.tex` — etykieta **Praca inżynierska**
- `thesis/tex/03_MasterThesisOutline.tex` — program pracy inżynierskiej ze zgłoszenia
- Spis rysunków / tabel w `main.tex`

---

## 6. Poza zakresem

Celowo **nie** wchodzi do tej pracy:
- Pomiary rzeczywiste SDR / CSI z fizycznej karty Wi-Fi (omówione w podsumowaniu jako perspektywa rozwoju).
- Ciągłe śledzenie obiektów w czasie (Multi-Frame CPI / Tracking) — omówione teoretycznie w rozdz. 3/4 i 6; w badaniach skupiamy się na pełnej ramce pojedynczej i jej parametrach.
- Przebudowa `src/` pod inną architekturę (np. obiektową OOP).
- Ręczne inwentarze literatury oraz brudnopisy w Markdownie — jedynym źródłem prawdy dla literatury jest Zotero/`.bib`, a dla tekstu pliki `.tex`.
- Umieszczanie skryptów demonstracyjnych MathWorks w bibliografii.

