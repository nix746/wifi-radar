# Źródło prawdy: co ma powstać

Ten dokument rozstrzyga **co** jest celem pracy i repozytorium. Kolejność zadań jest w [`plan_work_order.md`](plan_work_order.md).

## 1. Praca

| Pole | Wartość |
| :--- | :--- |
| Typ | Praca **inżynierska** |
| Temat | Implementacja i testowanie efektywności detekcji wybranego algorytmu radaru pasywnego używającego sygnału Wi-Fi |
| Opiekun | prof. dr hab. inż. Tomasz Zieliński |
| Wzorzec układu | Prace z katedry / analogiczna inżynierska K. Szwej (*Radar OFDM z użyciem sygnału DVB-T2*), plus Sorbian (WAT) jako drugi punkt odniesienia rysunków i porównań |
| Wkład własny | Zastosowanie paradygmatu przetwarzania CIR (estymacja kanału, MTI, kompensacja DC, mapa Range–Doppler) na sygnale **Wi-Fi 802.11a**, pogłębiona analiza statystyczna wpływu parametrów warstwy fizycznej (MCS, PSDU) na detekcję oraz implementacja algorytmu **Coherent CLEAN** (Braun) |

Kod w `src/` jest już nośnikiem metody. Praca ma **opisać i zbadać** ten łańcuch, a nie przebudowywać go od zera.

---

## 2. Układ rozdziałów (obowiązujący)

Sześć rozdziałów. Nie ma osobnego rozdziału „implementacja MATLAB”: środowisko i architektura wchodzą w **5.1**. Nie łączy się geometrii PBR z PHY 802.11 w jednym rozdziale.

| Nr | Plik LaTeX | Tytuł | Zawartość |
| :--- | :--- | :--- | :--- |
| 1 | `thesis/tex/10_introduction.tex` | Wstęp | Cel i zakres (rozszerzenie o 802.11ax i kanał TGax), motywacja (iluminator Wi-Fi, nowsze generacje OFDM), teza / pytania badawcze, układ pracy |
| 2 | `thesis/tex/20_pbr.tex` | Koncepcja bistatycznego radaru pasywnego | Geometria bistatyczna, zjawiska fizyczne (DPI, clutter stacjonarny, kanał syntetyczny vs TGax Model-B), etapy przetwarzania, **model detekcji oparty o Zero-Forcing (CIR)**, zalety i ograniczenia |
| 3 | `thesis/tex/30_wifi_phy.tex` | Sygnał Wi-Fi IEEE 802.11 | Rodzina 802.11 i ewolucja PHY (802.11a vs 802.11ax), OFDM i CP, ramki Non-HT oraz HE-SU, tabela porównawcza parametrów radarowych ($B=20\,\mathrm{MHz}$, $\Delta R=7.5\,\mathrm{m}$, $v_{\mathrm{unamb}}\approx 68\,\mathrm{m/s}$ vs $16.7\,\mathrm{m/s}$), siatka podnośnych i luka DC (1 vs 3 podnośne); analiza transmisji pakietowej |
| 4 | `thesis/tex/40_radar_dsp.tex` | Algorytmy przetwarzania radarowego | Synchronizacja pakietu (Schmidl--Cox vs detekcja wlanPacketDetect); Zero-Forcing z dynamiczną maską podnośnych (52 vs 242), filtr MTI, adaptacyjna interpolacja DC, okno 2D Blackman–Harris, periodogram 2D, Coherent CLEAN |
| 5 | `thesis/tex/50_simulation_results.tex` | Badania symulacyjne | 5.1 środowisko MATLAB (architektura modularna, kanał syntetyczny vs realistyczny TGax Model-B, macierz 4 scenariuszy); 5.2 Porównanie standardów 802.11a i 802.11ax (analiza aliasingu Dopplera); 5.3 Wpływ clutteru wielodrogowego TGax na skuteczność MTI; 5.4 Krzywe $SNR_{\mathrm{out}}(SNR_{\mathrm{in}})$ (Monte Carlo); 5.5 Skuteczność Coherent CLEAN w scenariuszach wielocelowych |
| 6 | `thesis/tex/99_conclusion.tex` | Wnioski | Podsumowanie, ograniczenia (aliasing Dopplera w ax, pasmo 20 MHz), dalsze prace (SDR/CSI, szersze pasma 802.11ax, Multi-Frame CPI) |

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

> [!IMPORTANT]
> **Status demonstracji i toolboxów MathWorks**: Przykłady demonstracyjne z `_archive_original/` oraz pakiety narzędziowe (WLAN Toolbox, Communications Toolbox) **nie wchodzą do bibliografii jako artykuły naukowe**. Ich wykorzystanie opisuje się w tekście pracy w rozdziale **5.1** (z ewentualnym jednym ogólnym cytowaniem środowiska MATLAB, jeśli wymagane).

## 4. Architektura oprogramowania i rysunki do rozdziału 5

### 4.1. Architektura kodu i uzasadnienie wkładu własnego (podrozdział 5.1)

W rozdziale 5.1 wyraźnie rozgranicza się rolę toolboxów i wkładu własnego:
1. **WLAN Toolbox**: wykorzystany wyłącznie w `src/transmitter.m` do syntezy sygnału nadawczego IEEE 802.11a (`wlanWaveformGenerator`, `wlanNonHTConfig`). Gwarantuje to pełną zgodność z normą bez konieczności tworzenia telekomunikacyjnego kodera/modulatora od podstaw.
2. **Communications Toolbox**: wykorzystany w `src/channel.m` do wprowadzenia szumu addytywnego (`awgn`).
3. **Wkład własny w algorytmy DSP (rdzeń pracy)**: cała część odbiorcza i detekcyjna zaimplementowana w bazowym środowisku MATLAB bez „czarnych skrzynek” z Radar Toolboxa:
   - manualna demodulacja OFDM i usuwanie CP (`demodulate.m`),
   - estymacja macierzy transmitancji kanału Zero-Forcing ($H = Y ./ X$),
   - filtracja MTI w dziedzinie symboli,
   - interpolacja podnośnej DC przeciwdziałająca wyciekowi widmowemu,
   - okienkowanie 2D Blackman–Harris obliczone bezpośrednio z analitycznego szeregu cosinusów,
   - dwuwymiarowy periodogram zespolony Range–Doppler,
   - koherentne usuwanie listków bocznych algorytmem Coherent CLEAN (`clean_interpreter.m`).

### 4.2. Skrypty badawcze i katalog figur

Istniejący łańcuch zostaje: `transmitter` → `channel` → `receiver_pipeline` → `clean_interpreter`. Bez przebudowy modułów (CAF usunięty na rzecz dogłębnych badań statystycznych).

Prace badawcze realizowane są w dwóch krokach (zgodnie z `plan_work_order.md`):
1. **Silnik eksperymentalny i metryki (Tor B.1)**: analityczny estymator $SNR_{\mathrm{out}}$ (moc w binie celu vs wariancja tła) oraz pętla uśredniania statystycznego Monte Carlo po $N$ niezależnych ramkach (z wariantami MCS i długości PSDU).
2. **Generacja i eksport katalogu figur (Tor B.2)**: wykonanie obliczeń i zapis sformatowanych figur do `thesis/img/`.

Do dopisania są **dwa skrypty badawcze**:

| Skrypt | Po co |
| :--- | :--- |
| `scripts/evaluate_wifi_parameters.m` | Zastępuje stare porównania z CAF; silnik Monte Carlo badający wpływ parametrów PHY (MCS, PSDU) na skuteczność detekcji dla wybranego SNR |
| `scripts/evaluate_snr_curves.m` | Krzywe $SNR_{\mathrm{out}}=f(SNR_{\mathrm{in}})$ (uśrednianie Monte Carlo po $N$ niezależnych ramkach/szumie), demonstracja zdolności detekcyjnych toru CIR przy zadanym zaszumieniu |

Zapis figur:
- roboczy: `results/figures/`
- do składu: `thesis/img/` (PNG i/lub PDF), nazwy stabilne, gotowe do `\includegraphics`

**Katalog rysunków do rozdziału 5**:
1. Mapa Range–Doppler 2D/3D przed MTI vs po MTI (zobrazowanie kompensacji przesłuchu bezpośredniego i luki DC).
2. Mapa Range–Doppler przed CLEAN vs po CLEAN (scena wielocelowa z maskowaniem słabych celów).
3. Przekrój 1D w osi prędkości (albo odległości) przez wykryty cel po ekstrakcji CLEAN.
4. Wykres krzywych $SNR_{\mathrm{out}} = f(SNR_{\mathrm{in}})$ uśredniony statystycznie (metoda Monte Carlo).
5. Wykres wpływu długości ramki PSDU (np. krótka kontrolna vs max) na poprawę zysku SNR.
6. Wykres wpływu schematów modulacji (odporne BPSK vs gęste 64-QAM) na pik celów i szum tła.
7. Analiza skrajnego wariantu zaszumienia i ekstremalnego tłumienia echa celu w stosunku do DPI.

### 4.3. Czystość kodu, listingi do pracy i weryfikacja regresyjna

W celu ułatwienia cytowania kodu w pracy (pakiet `minted` w rozdz. 4 i 5.1) oraz umożliwienia szybkiego wykonywania pętli Monte Carlo (Tor B) przyjmuje się zasady:
1. **Wyodrębnienie czystych funkcji DSP do `lib/` (bez dyskowego I/O i bez rysowania figur)**:
   - `lib/demodulate.m` — manualna demodulacja OFDM i usuwanie CP (istniejąca funkcja),
   - `lib/estimate_channel_zf.m` — estymacja Zero-Forcing, maska aktywnych podnośnych, filtracja MTI i interpolacja luki DC,
   - `lib/compute_range_doppler_map.m` — analityczne okno 2D Blackmana–Harrisa oraz periodogram 2D (IFFT wzdłuż podnośnych, FFT wzdłuż symboli),
   - `lib/run_coherent_clean.m` — pętla koherentnego usuwania listków bocznych celów (Braun).
2. **Skrypty w `src/` jako fasady uruchomieniowe (100% kompatybilności wstecznej)**:
   - Skrypty `transmitter.m`, `channel.m`, `receiver_pipeline.m`, `clean_interpreter.m` zachowują swoje nazwy, lokalizacje i format plików `.mat`.
   - `scripts/run_full_simulation.m` wykonuje się w niezmieniony sposób.
3. **Zabezpieczenie wzorcem odniesienia („Golden Master”) i testy regresyjne**:
   - Przed refaktoryzacją utrwala się wzorzec referencyjny ze stałym ziarnem generatora losowego (`golden_*.mat`).
   - Tworzy się automatyczny skrypt testowy `tests/verify_regression.m`, sprawdzający tożsamość numeryczną wszystkich etapów (`max(abs(diff)) < 1e-12`).
   - Żadna modyfikacja czytelnościowa nie może zmienić wyników numerycznych.
4. **Zwarte listingi do tekstu pracy (`thesis/listings/`)**:
   - Odpowiadające 1:1 podrozdziałom rozdziału 4 (zwięzłe, 8–20 linii, pozbawione szumu I/O/GUI):
     - `listings/lst_zero_forcing.m` (rozdz. 4.2),
     - `listings/lst_mti_dc.m` (rozdz. 4.3–4.4),
     - `listings/lst_range_doppler.m` (rozdz. 4.5–4.6),
     - `listings/lst_coherent_clean.m` (rozdz. 4.7).
   - Zmienne w kodzie są zbieżne z notacją matematyczną w tekście ($Y, X, H, \mathbf{W}_{\mathrm{2D}}, \Delta R, v_{\mathrm{unamb}}$).
   - W `thesis/tex/00_preambule.tex` konfiguruje się styl `\setminted[matlab]{...}`.

---

## 5. Stan szablonu LaTeX do domknięcia

- `thesis/main.tex` — autor, tytuł, wydział, kierunek, opiekun, recenzent, `\include` wszystkich rozdziałów
- `thesis/tex/01_titlePage.tex` — etykieta **Praca inżynierska**
- `thesis/tex/03_MasterThesisOutline.tex` — program pracy inżynierskiej ze zgłoszenia
- Spis rysunków / tabel w `main.tex`

---

## 6. Poza zakresem
 
 Celowo **nie** wchodzi do tej pracy:
 - Pomiary rzeczywiste SDR / CSI z karty Wi-Fi (ewentualna wzmianka w podsumowaniu jako perspektywa rozwoju).
 - Implementacja w kodzie przetwarzania ciągów wielu ramek w czasie (Multi-Frame CPI z przerwami IFS i osobną detekcją preambuł) — omówiona w pracy wyłącznie **teoretycznie** (rozdz. 3/4) oraz jako **kierunek rozwoju** (rozdz. 6); w kodzie symulacji skupiamy się na pełnej ramce pojedynczej i uśrednianiu Monte Carlo.
 - Przebudowa `src/` pod inną architekturę (np. obiektową OOP, frameworki lub zmianę paradygmatu przetwarzania) — zachowujemy łańcuch CIR/CLEAN i skrypty w `src/`, dopuszczalna i zalecana jest jedynie lekka refaktoryzacja czytelnościowa funkcji DSP do `lib/` oraz testy regresyjne.
 - Ręczne inwentarze literatury oraz równoległe brudnopisy teorii w Markdownie — jedynym źródłem prawdy dla literatury jest Zotero/`thesis/bibliography.bib`, a dla teorii pliki `.tex`.
 - Umieszczanie skryptów demonstracyjnych MathWorks w spisie literatury.
 - Obszerne teoretyczne wywody o synchronizacji telekomunikacyjnej (Schmidl–Cox) — wystarczy zwięzły akapit uzasadniający a priori odcięcie preambuły w symulacji.
 - Osobny rozdział implementacyjny (architektura i środowisko wchodzą do 5.1).
