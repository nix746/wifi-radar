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
| 4 | `thesis/tex/40_radar_dsp.tex` | Algorytmy przetwarzania radarowego | Synchronizacja pakietu (wlanPacketDetect); Zero-Forcing z dynamiczną maską podnośnych (52 vs 242), filtr MTI, adaptacyjna interpolacja DC, okno 2D Blackman–Harris, periodogram 2D Range–Doppler, algorytm Coherent CLEAN |
| 5 | `thesis/tex/50_simulation_results.tex` | Badania symulacyjne | 5.1 Środowisko MATLAB i parametryzacja; 5.2 Rozdzielczość odległościowa a pasmo (20, 40, 80 MHz); 5.3 Aliasing Dopplera i długość symbolu OFDM (802.11a vs ax); 5.4 Wpływ MCS i poziomu szumu na estymację ZF; 5.5 Clutter TGax (Model-B/D) i filtr MTI; 5.6 Skuteczność Coherent CLEAN w scenariuszu dużej dynamiki mocy |
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
> - **Nie wolno dotykać ani modyfikować tego pliku ręcznie** — ani bezpośrednio w edytorze kodu, ani przez agentów AI.
> - Wszelkie zmiany (dodawanie nowych pozycji, modyfikacje pól, poprawki autorów, tytułów, dat) muszą być wprowadzane **wyłącznie w aplikacji Zotero**, a następnie propagowane do repozytorium przez automatyczny eksport.
> - Ręczna zmiana w pliku `.bib` zostanie bezpowrotnie nadpisana przy kolejnej synchronizacji z Zotero.

> [!IMPORTANT]
> **Status demonstracji i toolboxów MathWorks**: Przykłady demonstracyjne z `_archive_original/` oraz pakiety narzędziowe (WLAN Toolbox, Communications Toolbox) **nie wchodzą do bibliografii jako artykuły naukowe**. Ich wykorzystanie opisuje się w tekście pracy w rozdziale **5.1** (z ewentualnym jednym ogólnym cytowaniem środowiska MATLAB, jeśli wymagane).

## 4. Architektura oprogramowania, scenariusze badawcze i rysunki do rozdziału 5

### 4.1. Architektura kodu i uzasadnienie wkładu własnego (podrozdział 5.1)

W rozdziale 5.1 wyraźnie rozgranicza się rolę toolboxów i wkładu własnego:
1. **WLAN Toolbox**: wykorzystany wyłącznie w `src/step1_transmitter.m` do syntezy sygnału nadawczego IEEE 802.11a i 802.11ax (`wlanWaveformGenerator`, `wlanNonHTConfig`, `wlanHESUConfig`). Gwarantuje to pełną zgodność ze standardem bez konieczności tworzenia koderów telekomunikacyjnych od podstaw.
2. **Communications Toolbox**: wykorzystany w `src/step2_channel.m` do wprowadzenia szumu addytywnego (`awgn`).
3. **Wkład własny w algorytmy DSP (rdzeń pracy)**: cała część odbiorcza i detekcyjna zaimplementowana w bazowym środowisku MATLAB bez „czarnych skrzynek” z Radar Toolboxa:
   - manualna demodulacja OFDM i usuwanie CP (`lib/demodulate.m`),
   - estymacja macierzy transmitancji kanału Zero-Forcing ($H = Y ./ X$),
   - filtracja MTI w dziedzinie symboli,
   - adaptacyjna interpolacja podnośnych DC przeciwdziałająca wyciekowi widmowemu,
   - okienkowanie 2D Blackman–Harris obliczone bezpośrednio z analitycznego szeregu cosinusów,
   - dwuwymiarowy periodogram zespolony Range–Doppler (`lib/compute_range_doppler_map.m`),
   - koherentne usuwanie listków bocznych algorytmem Coherent CLEAN (`lib/run_coherent_clean.m`).

### 4.2. Sprzężone relacje fizyczne (Trade-offs) do zbadania

W badaniach uwzględnia się fundamentalne zależności sprzężone parametrów sygnału Wi-Fi i parametrów radarowych:
1. **Szerokość pasma $B$**: Wzrost pasma poprawia rozdzielczość odległościową ($\Delta R = c / 2B$), lecz zwiększa moc wejściowego szumu termicznego ($P_n = k_B T B F$, spadek wejściowego SNR), co jest kompensowane zyskiem IFFT po większej liczbie podnośnych $N_{\mathrm{sub}}$.
2. **Długość symbolu OFDM $T_{\mathrm{sym}}$ (802.11a vs ax)**: 4-krotnie dłuższy symbol w ax zapewnia odporność na wielodrogowość (dłuższy CP), lecz 4-krotnie obniża prędkość jednoznaczną $v_{\mathrm{unamb}}$, powodując aliasing Dopplera przy obiektach drogowych.
3. **Rząd modulacji MCS**: Wyższe rzędy modulacji (64-QAM, 256-QAM) niosą zróżnicowaną energię symboli; dzielenie przez małe wartości w Zero-Forcing wywołuje zjawisko *noise enhancement* (lokalne podbicie wariancji tła szumowego).
4. **Bilans mocy i dynamika celów**: Zgodnie z równaniem bistatycznym moc DPI spada z $R^{-2}$, a echo celu z $R^{-4}$; duża dysproporcja mocy wymaga filtru MTI oraz usuwania listków bocznych przez Coherent CLEAN.
5. **Luka DC**: Nullowanie podnośnych DC powoduje wyciek widmowy w osi odległości (silniejszy w ax z 3 pustymi podnośnymi), wymagający kompensacji interpolacyjnej.

### 4.3. Matryca 5 scenariuszy badawczych (zastępuje Monte Carlo)

Zamiast czasochłonnego i mało informatywnego uśredniania statystycznego Monte Carlo, badania opierają się na **5 dedykowanych scenariuszach fizycznych**:

| Nr | Eksperyment | Cel badawczy | Zmienne niezależne | Obserwowane zjawisko |
| :---: | :--- | :--- | :--- | :--- |
| **E1** | **Rozdzielczość pasma** | Wpływ pasma na separację bliskich celów | $B = 20, 40, 80\,\mathrm{MHz}$ (802.11ax, MCS 0) | Dwa cele oddalone o $3\,\mathrm{m}$: zlanie w $20\,\mathrm{MHz}$ vs idealne rozdzielenie w $80\,\mathrm{MHz}$ |
| **E2** | **Aliasing Dopplera** | Długość symbolu OFDM a prędkość jednoznaczna | 802.11a ($T_{\mathrm{sym}}=4\,\mu\mathrm{s}$) vs 802.11ax ($T_{\mathrm{sym}}=13.6\,\mu\mathrm{s}$) | Cel szybki ($v=25\,\mathrm{m/s}$): poprawna detekcja w 'a' vs fałszywa prędkość (aliasing) w 'ax' |
| **E3** | **Modulacja i szum** | Efekt *noise enhancement* w Zero-Forcing | MCS 0 (BPSK) vs MCS 3 (16-QAM) vs MCS 7 (64-QAM) oraz poziomy SNR ($+25, +10, -5\,\mathrm{dB}$) | Podbicie tła szumowego i spadek kontrastu przy wyższych rzędach MCS; granica zysku integracji |
| **E4** | **Clutter TGax i MTI** | Tłumienie stacjonarnego echa wielodrogowego | Idealny AWGN vs TGax Model-B vs TGax Model-D | Wycinanie stacjonarnego profilu kanału przez MTI; rola interpolacji luki DC |
| **E5** | **Dynamika i CLEAN** | Odkrywanie słabych celów w listkach bocznych | Cel silny ($0\,\mathrm{dB}$) + cel zamaskowany ($-30\,\mathrm{dB}$) | Odkrycie słabego celu schowanego pod listkami bocznymi po koherentnej eliminacji |

### 4.4. Skrypty eksperymentów i katalog figur do rozdziału 5

Struktura skryptów badawczych w `scripts/`:
- `scripts/exp1_bandwidth_resolution.m` — scenariusz E1 (profil 1D odległości dla 3 pasm),
- `scripts/exp2_doppler_aliasing.m` — scenariusz E2 (mapy 2D Range–Doppler dla 'a' i 'ax'),
- `scripts/exp3_modulation_noise.m` — scenariusz E3 (przekroje tła szumowego dla MCS 0/3/7 i poziomów SNR),
- `scripts/exp4_tgax_clutter.m` — scenariusz E4 (mapy przed/po MTI w kanale TGax Model-B i D),
- `scripts/exp5_coherent_clean.m` — scenariusz E5 (mapy przed/po CLEAN oraz profil prędkości dla skrajnej dynamiki celów),
- `scripts/run_all_experiments.m` — master runner wykonujący wszystkie eksperymenty i eksportujący figury.

Zapis figur:
- roboczy: `results/figures/`
- do składu: `thesis/img/` (PNG / PDF, stabilne nazwy gotowe do `\includegraphics`)

**Katalog rysunków do rozdziału 5**:
1. `fig_exp1_bandwidth_cut.png` — profil 1D odległości nakładający krzywe dla $B = 20, 40, 80\,\mathrm{MHz}$ (separacja celów).
2. `fig_exp2_doppler_80211a.png` — mapa 2D Range–Doppler dla 802.11a (poprawna detekcja szybkiego celu).
3. `fig_exp2_doppler_80211ax.png` — mapa 2D Range–Doppler dla 802.11ax (zjawisko aliasingu Dopplera / fałszywy cel).
4. `fig_exp3_noise_enhancement.png` — porównanie podłogi szumowej po Zero-Forcing dla BPSK vs 16-QAM vs 64-QAM.
5. `fig_exp3_snr_threshold.png` — przekrój detekcji przy skrajnym zaszumieniu ($\mathrm{SNR}_{\mathrm{in}} = -5\,\mathrm{dB}$) ilustrujący zysk przetwarzania.
6. `fig_exp4_tgax_before_mti.png` — mapa Range–Doppler w kanale TGax Model-B przed MTI (zamaskowanie przez clutter).
7. `fig_exp4_tgax_after_mti.png` — mapa Range–Doppler po MTI i interpolacji DC (czysta detekcja ruchomego celu).
8. `fig_exp5_clean_before_after.png` — zestawienie map 2D przed i po Coherent CLEAN (odkrycie słabego celu o dynamice $-30\,\mathrm{dB}$).
9. `fig_exp5_clean_velocity_cut.png` — przekrój 1D w osi prędkości obrazujący wycięcie listków bocznych silnego celu.

### 4.5. Czystość kodu, listingi do pracy i weryfikacja regresyjna

W celu ułatwienia cytowania kodu w pracy (pakiet `minted` w rozdz. 4 i 5.1) oraz zagwarantowania stabilności algorytmów:
1. **Funkcje DSP w `lib/` (czyste funkcje numeryczne bez dyskowego I/O)**:
   - `lib/demodulate.m` — demodulacja OFDM i usuwanie CP,
   - `lib/estimate_channel_zf.m` — estymacja Zero-Forcing, maska podnośnych, MTI i interpolacja luki DC,
   - `lib/compute_range_doppler_map.m` — analityczne okno 2D Blackmana–Harrisa oraz periodogram 2D,
   - `lib/run_coherent_clean.m` — pętla Coherent CLEAN (Braun),
   - `lib/calculate_physical_axes.m` — skalowanie fizycznych osi odległości i prędkości.
2. **Skrypty w `src/` jako fasady uruchomieniowe (100% kompatybilności wstecznej)**:
   - Skrypty `step1_transmitter.m`, `step2_channel.m`, `step3_receiver.m`, `step4_interpreter.m` zachowują kompatybilność.
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
- Pomiary rzeczywiste SDR / CSI z karty Wi-Fi (omówione w podsumowaniu jako perspektywa rozwoju).
- Pętle uśredniania statystycznego Monte Carlo (zastąpione deterministyczną matrycą 5 scenariuszy fizycznych).
- Ciągłe śledzenie obiektów w czasie (Multi-Frame CPI / Tracking) — omówione teoretycznie w rozdz. 3/4 i 6; w badaniach skupiamy się na pełnej ramce pojedynczej i jej parametrach.
- Przebudowa `src/` pod inną architekturę (np. obiektową OOP).
- Ręczne inwentarze literatury oraz brudnopisy w Markdownie — jedynym źródłem prawdy dla literatury jest Zotero/`.bib`, a dla tekstu pliki `.tex`.
- Umieszczanie skryptów demonstracyjnych MathWorks w bibliografii.
