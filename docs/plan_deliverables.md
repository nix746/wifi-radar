# Źródło prawdy: co ma powstać

Ten dokument rozstrzyga **co** jest celem pracy i repozytorium. Kolejność zadań jest w [`plan_work_order.md`](plan_work_order.md). Struktura pracy odpowiada układowi zdefiniowanemu w [`milestone_1.md`](milestone_1.md). Dokument integruje wytyczne merytoryczne, redakcyjne i formalne (w tym wytyczne uczelni i wnioski z notatki redakcyjnej).

## 1. Praca

| Pole | Wartość |
| :--- | :--- |
| Typ | Praca **inżynierska** |
| Temat | Implementacja i testowanie efektywności detekcji wybranego algorytmu radaru pasywnego używającego sygnału Wi-Fi |
| Opiekun | prof. dr hab. inż. Tomasz Zieliński |
| Wydział i Instytut | Wydział Informatyki, Elektroniki i Telekomunikacji (WIEiT AGH), **Instytut Telekomunikacji i Cyberbezpieczeństwa** (uwzględniona aktualna nazwa) |
| Kierunek | Teleinformatyka |
| Objętość docelowa | **Ok. 35–50 stron** (zwięzła, konkretna inżynierska forma, bez sztucznego pompowania objętości) |
| Proporcje pracy | **Wyraźna dominacja części praktycznej** (Rozdziały 3 i 4) nad częścią teoretyczną (Rozdział 2) |
| Wzorzec układu | Prace z katedry / analogiczna inżynierska K. Szwej (*Radar OFDM z użyciem sygnału DVB-T2*), plus Sorbian (WAT) jako drugi punkt odniesienia rysunków i porównań |
| Wkład własny | Zastosowanie paradygmatu przetwarzania CIR (estymacja kanału, MTI, kompensacja DC, mapa Range–Doppler) na sygnale **Wi-Fi 802.11a oraz 802.11ax**, przekrojowa analiza wpływu parametrów warstwy fizycznej (szerokość pasma, aliasing Dopplera, rząd MCS, model kanału TGax) na detekcję oraz implementacja algorytmów **Binary STC oraz Coherent STC** z progiem CFAR (Braun) |

Kod w `src/` jest już nośnikiem metody. Praca ma **opisać i zbadać** ten łańcuch, a nie przebudowywać go od zera.

---

## 2. Układ rozdziałów

Układ obejmuje **cztery numerowane rozdziały główne** poprzedzone nienumerowanym Wstępem oraz zwieńczone nienumerowanymi Wnioskami końcowymi, Literaturą i Dodatkami (szczegółowy plan migracji plików w [`docs/plan_structure_migration.md`](plan_structure_migration.md)).

| Nr | Plik LaTeX (docelowy) | Tytuł | Budżet stron | Podrozdziały i zawartość merytoryczna |
| :---: | :--- | :--- | :---: | :--- |
| — | `thesis/tex/05_introduction.tex` *(z `10_introduction.tex`)* | **Wstęp** *(nienumerowany)* | 1–2 str. | Piszemy na samym końcu po zredagowaniu całości. To nie jest abstrakt (nie powiela słów kluczowych/streszczenia).<br>Akapity / `\subsection*` (bez numerowanych `\subsection` w klasie `article`): zakres pracy (802.11a vs 802.11ax, kanał TGax, uproszczenia modelowe), motywacja (iluminator Wi-Fi, pasywna detekcja), teza i pytania badawcze oraz przegląd układu pracy w formie bezosobowej. |
| **1** | `thesis/tex/10_wifi_signal.tex` | **1. Sygnał 802.11** | 2,5–3,0 str. | Wydzielona część teoretyczna o warstwie fizycznej Wi-Fi (dotychczas napisane i zweryfikowane 2.1–2.2):<br>**1.1. Warstwa fizyczna standardu IEEE 802.11** (standardy 802.11a Non-HT i 802.11ax HE-SU, tabela 20/40/80/160 MHz, siatka podnośnych, Rys. 1.1)<br>**1.2. Model matematyczny sygnału OFDM** (ortogonalność, synteza IFFT, prefiks cykliczny CP, splot kołowy, właściwości symboli $X[k,l]$) |
| **2** | `thesis/tex/20_passive_radar.tex` | **2. Radar pasywny** | 7,5–8,5 str. | Zwięzły stan wiedzy (*state-of-the-art*), bez dominacji nad praktyką. Szczegóły w [`docs/plan_chapter_2.md`](plan_chapter_2.md):<br>**2.1. Geometria pomiarowa i parametry radaru: konfiguracja współlokowana (monostatyczna)** (układ dwuantenowy Full-Duplex, model $h(\tau,t)$, bilans mocy, DPI, siatka $\Delta R, R_{\max}, \Delta v, v_{\max}$)<br>**2.2. Estymacja częstotliwościowej odpowiedzi kanału (CFR)** (paradygmat CFR vs CAF, estymator ZF i MF, zjawisko *noise enhancement* $\zeta_{\mathrm{ZF}}$)<br>**2.3. Tłumienie ech stałych i kompensacja luki DC** (filtr MTI w czasie wolnym, uogólniona interpolacja wielopunktowa DC)<br>**2.4. Wyznaczanie mapy odległość–prędkość (Range–Doppler)** (okno 2D Blackmana–Harrisa, IFFT/FFT, zero-padding 4x)<br>**2.5. Detekcja progowa CFAR i iteracyjna ekstrakcja celów** (estymacja szumu ML, próg CFAR $\eta$, 2D interp. paraboliczna, Binary STC i Coherent STC, PNFR) |
| **3** | `thesis/tex/30_radar_implementation.tex` | **3. Opis oprogramowania** | 10–12,5 str. | Część inżynierska wg [`docs/plan_chapter_3.md`](plan_chapter_3.md) — jednoznaczność, schemat blokowy i odwołania do Rozdz. 1–2:<br>**3.1. Środowisko symulacyjne MATLAB i wykorzystane pakiety narzędziowe** (MATLAB R2024b/R2025b, WLAN Toolbox, Communications Toolbox, Signal Processing Toolbox, wkład własny bez Radar Toolbox)<br>**3.2. Ogólna architektura oprogramowania i przepływ danych** (schemat blokowy zależności Rys. 3.1, podział `src/` vs `lib/`, zasada DRY, założenia układu współlokowanego)<br>**3.3. Implementacja nadajnika sygnału IEEE 802.11** (zwięźle: `step1_transmitter.m`, `get_wifi_params.m`, generator WLAN Toolbox i automatyczne skalowanie ramki)<br>**3.4. Implementacja modelu kanału propagacyjnego i celów ruchomych** (`step2_channel.m`, `configure_targets.m`, `get_carrier_frequency.m`, TGax A/B/C/E, opóźnienia ułamkowe, **jawne doprecyzowanie braku ray-tracingu 3D i modelu SIC jako świadomego uproszczenia**)<br>**3.5. Implementacja odbiornika radarowego** (podrozdziały `3.5.1` synchronizacja *leading-edge* + `demodulate.m`; `3.5.2` `estimate_channel.m` + `interpolate_dc_nulls.m` — Rys. 3.2; `3.5.3` `compute_range_doppler_map.m` + `calculate_physical_axes.m` — Rys. 3.3–3.4; `3.5.4` `step4_interpreter.m`, `get_detection_algorithm.m`, Binary/Coherent STC, `compute_pnfr.m` i testy `verify_regression.m`) |
| **4** | `thesis/tex/40_simulation_results.tex` | **4. Opis eksperymentów** | 12–16 str. | Rdzeń badawczy: ściśle zdefiniowane scenariusze, wyniki, opracowanie statystyczne Monte Carlo z miarami ufności.<br>**4.1. Scenariusze testowe** (założenia geometrii monostatycznej z dwiema odizolowanymi antenami Tx/Rx, brak modelu ray-tracingu jako uproszczenie modelu tła, parametryzacja w `get_wifi_params.m`, fizyka stałej mocy AP 100 mW EIRP i spadek SNR o 9 dB dla 160 MHz)<br>**4.2. Rozdzielczość odległościowa a szerokość pasma** (Eksperyment E1: 20, 40, 80, 160 MHz — Rys. 4.1)<br>**4.3. Długość symbolu OFDM a prędkość jednoznaczna** (Eksperyment E2: 802.11a vs 802.11ax, aliasing Dopplera — Rys. 4.2)<br>**4.4. Wpływ rzędu modulacji MCS i poziomu szumu na estymację ZF** (Eksperyment E3: wszystkie indeksy MCS 0–11, współczynnik $\zeta_{\text{ZF}}$, kontrast PNFR — Rys. 4.3)<br>**4.5. Tłumienie stacjonarnego clutteru** (Eksperyment E4: modele TGax A, C, E, wycinanie $f_D = 0$ przez filtr MTI — Rys. 4.4)<br>**4.6. Skuteczność algorytmów Binary STC i Coherent STC** (Eksperyment E5: dynamika 30 dB — Rys. 4.5; Eksperymenty SIM-6a/6b Monte Carlo: analiza $P_D(R)$ z 95% przedziałami Wilsona dla scenariusza wewnętrznego Model-B 80 MHz — Rys. 4.6 oraz zewnętrznego Model-E 40 MHz — Rys. 4.7) |
| — | `thesis/tex/50_conclusion.tex` | **Wnioski końcowe** *(nienumerowane)* | 2–3 str. | Piszemy na samym końcu. Podsumowanie wyników z odniesieniem do tezy i celu, bez numerowanych `\subsection`. Ograniczenia metody (kompromis $T_{\text{sym}}$ w 802.11ax, bilans mocy AP, uproszczenie braku ray-tracingu 3D i fizycznego modelu SIC) oraz kierunki rozwoju (multi-frame CPI, pomiary SDR/CSI). |
| — | `thesis/bibliography.bib` | **Literatura** | — | Eksport z Zotero + repozytorium GitHub jako ostatnia pozycja. |
| — | `thesis/tex/60_appendices.tex` | **Dodatki** | 3–6 str. | **Dodatek A:** Wybrane zwarte listingi kodu MATLAB (`minted`) i instrukcja uruchomienia.<br>**Dodatek B (opcjonalnie):** Rozszerzone tabele wyników statystycznych Monte Carlo. |

Front matter (strona tytułowa, program pracy) znajduje się w plikach `01_`–`03_`, z danymi ze zgłoszenia i etykietą „praca inżynierska”.

Pliki rozdziałów (`05_introduction.tex`, `10_wifi_signal.tex`, `20_passive_radar.tex`, `30_radar_implementation.tex`, `40_simulation_results.tex`, `50_conclusion.tex`, `60_appendices.tex`) znajdują się w `thesis/tex/` i są włączane przez `\include` w `thesis/main.tex`.

**Zasada Single Source of Truth dla tekstu i wzorów**: Wszelka treść merytoryczna, wzory, wyprowadzenia i tabele powstają **od razu bezpośrednio w plikach `.tex` w `thesis/tex/`**. Nie tworzymy równoległych brudnopisów teorii w Markdownie. Wcześniejsze notatki służą jedynie jako podręczna ściąga wyjściowa do zredagowania w LaTeX-u.

---

## 3. Bibliografia i zasady cytowania

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

### Kluczowe zasady dotyczące literatury (z notatki redakcyjnej):
1. **Bezwzględny wymóg cytowania każdej pozycji**: Każda pozycja umieszczona w bibliografii **musi być jawnie zacytowana (`\cite{...}`) w tekście pracy**. Nie dopuszcza się „wiszących” pozycji bibliograficznych.
2. **Częste i odważne cytowanie**: Cytujemy przy pierwszym przytoczeniu danego pojęcia, algorytmu, standardu lub parametru. Jeśli coś opisujemy szczegółowo własnymi słowami, podajemy źródło; jeśli temat jest poboczny, odsyłamy czytelnika cytowaniem.
3. **Zakaz przepisywania 1:1**: Żaden fragment literatury ani podręcznika nie może być skopiowany dosłownie. Wszystkie twierdzenia i opisy redagujemy własnymi słowami (parafraza inżynierska).
4. **Ostatnia pozycja bibliografii — repozytorium GitHub**: Ostatnią pozycją w bibliografii musi być jawny link do repozytorium GitHub z kodem źródłowym, skryptami i tekstem pracy (jako źródło otwarte).
5. **Status toolboxów i dem MathWorks**: Demonstratory z `_archive_original/` oraz pakiety narzędziowe (WLAN Toolbox, Communications Toolbox) **nie wchodzą do bibliografii jako artykuły naukowe**. Ich wykorzystanie opisuje się w tekście pracy w rozdziale **3.1**.

---

## 4. Architektura oprogramowania, scenariusze badawcze i rysunki do rozdziałów 3 i 4

### 4.1. Architektura kodu, założenia systemu i uzasadnienie wkładu własnego (podrozdział 3.1–3.2)

#### Założenia architektury fizycznej i modelu propagacyjnego (obowiązujące w Rozdz. 2.3, 3.1–3.3 i 4.1):
1. **Geometria monostatyczna z dwiema osobnymi antenami (Full-Duplex):** System pracuje w układzie współlokowanym, w którym jedna antena nadaje ciągłą ramkę Wi-Fi OFDM, a druga, fizycznie oddzielona antena odbiera sygnał powrotny. Pomijalna odległość między antenami ($d_{\mathrm{Tx-Rx}} \ll R$) zachowuje dwudrożną geometrię monostatyczną ($R_{\mathrm{Tx}} + R_{\mathrm{Rx}} \approx 2R$), a jednoczesna znajomość sygnału nadanego eliminuje szum kanału referencyjnego.
2. **Założenie izolacji antenowej i tłumienia samoprzekłóceń (SIC):** Przyjmuje się skuteczną izolację pasywną między anteną nadawczą i odbiorczą (wspomaganą przez analogowe tłumienie samoprzekłóceń przed przetwornikiem ADC). W konsekwencji tor odbiorczy nie ulega przesterowaniu, a sygnał w domenie cyfrowej jest wynikiem odbić powrotnych z otoczenia (statyczny clutter wielodrogowy i echa celów ruchomych) wraz z resztkowym przesłuchem bezpośrednim (DPI).
3. **Uproszczenie kanału propagacyjnego — brak modelu ray-tracingu 3D:** Odbicia od celów ruchomych odwzorowano ściśle według dwudrożnej fizyki radiolokacji ($\tau = 2R/c_0$, $f_D = 2v f_c/c_0$, amplituda $b_h \propto \sqrt{\sigma}/R^2$, czyli moc $\propto 1/R^4$). Natomiast tło wielodrogowe (odbicia od ścian i obiektów statycznych) oraz resztkowy przesłuch przybliżono standaryzowanym modelem komunikacyjnym `wlanTGaxChannel` (tryb LOS, `LargeScaleFadingEffect = 'None'`, domyślne `TransmitReceiveDistance = 3 m < d_BP`). **Brak geometrycznego symulatora śledzenia promieni (*ray-tracingu* 3D) stanowi świadome uproszczenie modelu symulacyjnego**, które należy wprost opisać w podrozdziałach 3.2, 4.1 oraz 5.2.
4. **Synchronizacja czasowa z MATLAB WLAN Toolbox (detekcja pierwszego czoła):** W `src/step3_receiver.m` synchronizacja ramki realizowana jest wyłącznie funkcjami WLAN Toolbox: wstępna detekcja pakietu `wlanPacketDetect` (na L-STF) oraz precyzyjna estymacja czasu symbolu `wlanSymbolTimingEstimate` (na oknie preambuły L-LTF), uzupełniona o detekcję pierwszego czoła (*leading-edge / first-arrival path*, próg $0{,}20 \cdot M_{\max}$ w oknie wstecznym $\le N_{\mathrm{CP}}$ na metryce korelacyjnej `M` zwracanej przez `wlanSymbolTimingEstimate`). Zastępuje to proste wyszukiwanie bezwzględnego maksimum korelacji, zapobiegając blokowaniu synchronizacji na opóźnionych klastrach wielodrogowych w dużych przestrzeniach (`Model-E`).

#### Podział ról: toolboxy a wkład własny (podrozdział 3.1):
1. **WLAN Toolbox**: wykorzystany w `src/step1_transmitter.m` do syntezy sygnału nadawczego IEEE 802.11a i 802.11ax (`wlanWaveformGenerator`, `wlanNonHTConfig`, `wlanHESUConfig`, `wlanHEOFDMInfo`, `wlanFieldIndices`, `wlanSampleRate`, `transmitTime`), w `src/step2_channel.m` do symulacji standaryzowanych kanałów wielodrogowych IEEE 802.11ax (`wlanTGaxChannel`) oraz w `src/step3_receiver.m` do detekcji pakietu i estymacji metryki korelacyjnej L-LTF (`wlanPacketDetect`, `wlanSymbolTimingEstimate`).
2. **Communications Toolbox**: wykorzystany w `src/step2_channel.m` do wprowadzania szumu termicznego AWGN (`awgn`).
3. **Signal Processing Toolbox**: wykorzystany w `lib/compute_range_doppler_map.m` do generowania wektorów wag 4-wyrazowego okna Blackmana–Harrisa (`blackmanharris`).
4. **Wkład własny w algorytmy DSP (rdzeń pracy)**: cała część odbiorcza i interpretacyjna zaimplementowana w bazowym środowisku MATLAB bez „czarnych skrzynek” z Radar Toolboxa:
   - rafinacja pierwszego czoła (*leading-edge*) na metryce korelacyjnej L-LTF w `src/step3_receiver.m`,
   - manualna demodulacja OFDM i usuwanie CP (`lib/demodulate.m`),
   - estymacja macierzy transmitancji kanału Zero-Forcing ($H = Y ./ X$),
   - filtracja MTI w dziedzinie symboli (czas wolny),
   - adaptacyjna interpolacja podnośnych DC przeciwdziałająca wyciekowi widmowemu,
   - normalizacja energetyczna i złożenie separowalnego okna 2D Blackmana–Harrisa (-92 dB),
   - dwuwymiarowy periodogram zespolony Range–Doppler (`lib/compute_range_doppler_map.m`),
   - sekwencyjna ekstrakcja celów algorytmami **Binary STC** (`lib/binary_successive_target_cancellation.m`) oraz **Coherent STC** (`lib/coherent_successive_target_cancellation.m`) z progiem **CFAR $\eta$**, estymacją mocy szumu ML poza $N_{\max}$, dwuwymiarową interpolacją paraboliczną i estymacją RCS oraz centralnym rejestrem algorytmów (`lib/get_detection_algorithm.m`),
   - kalibracja fizycznych osi odległości i prędkości (`lib/calculate_physical_axes.m`).

### 4.2. Sprzężone relacje fizyczne (Trade-offs) i ograniczenia środowiskowe

W badaniach uwzględnia się fundamentalne zależności sprzężone parametrów sygnału Wi-Fi i parametrów radarowych:
1. **Fizyka mocy punktu dostępowego (AP) i szerokość pasma $B$**: W rzeczywistych punktach dostępowych całkowita moc nadawcza jest ograniczona przepisami prawnymi (np. $P_{\text{tx}} = 100\ \text{mW}$ EIRP). Przejście z 20 MHz do 160 MHz rozprasza tę samą moc na 8x większą liczbę podnośnych. Dodatkowo moc szumu termicznego w odbiorniku $P_N = k_B \cdot T \cdot B \cdot F$ rośnie o $10 \log_{10}(160/20) = 9{,}03\ \text{dB}$. Zysk rozdzielczości odległościowej ($\Delta R = c / 2B$: 7.5 m dla 20 MHz vs 0.94 m dla 160 MHz) okupiony jest więc 9 dB spadkiem wejściowego SNR.
2. **Długość symbolu OFDM $T_{\mathrm{sym}}$ (802.11a vs ax)**: 4-krotnie dłuższy symbol w ax ($13{,}6\ \mu\text{s}$ vs $4{,}0\ \mu\text{s}$) zwiększa odporność na wielodrogowość, lecz 4-krotnie obniża prędkość jednoznaczną $v_{\mathrm{unamb}}$ ($\pm 16{,}7\ \text{m/s}$ w ax vs $\pm 56{,}8\ \text{m/s}$ w a).
3. **Brama anomalii prędkości**: W scenariuszach wnętrzowych/biurowych wykrycia o $|v| > 100\ \text{km/h}$ ($27{,}78\ \text{m/s}$) traktowane są jako niefizyczne anomalie i odrzucane.
4. **Rząd modulacji MCS i zjawisko Noise Enhancement**: Wyższe rzędy modulacji (16-QAM, 64-QAM, 1024-QAM) niosą zmienną energię symboli. Dzielenie przez małe wartości w Zero-Forcing podbija wariancję tła szumowego ($\zeta_{\text{ZF}} = \text{mean}(1/|\tilde{X}|^2) > 0\ \text{dB}$), co obniża kontrast celu (PNFR).
5. **Clutter wielodrogowy i filtr MTI**: Zgodnie z równaniem bistatycznym bezpośredni przesłuch DPI oraz odbicia stacjonarne są silniejsze od echa ruchomego celu o $30\text{--}50\ \text{dB}$; filtr MTI w czasie wolnym wycina składową stałą ($f_D = 0$).
6. **Luka DC**: Zerowanie podnośnych stałoprądowych wokół częstotliwości środkowej wywołuje oscylacje sinc wzdłuż osi odległości; interpolacja liniowa likwiduje ten wyciek widmowy.

### 4.3. Reprezentatywna triada modeli kanału TGax

Zamiast testowania wszystkich modeli kanałowych wybrano triadę o zróżnicowanym profilu opóźnień:
- **Model-A**: $\tau_{\text{rms}} = 0\ \text{ns}$ (warunki komory bezechowej / idealny tor odniesienia; kalibracja algorytmów bez zniekształceń wielodrogowych).
- **Model-C**: $\tau_{\text{rms}} = 30\ \text{ns}$ (typowe środowisko mieszkalne i biurowe o umiarkowanym profilu opóźnień i gęstym clutterze stacjonarnym).
- **Model-E**: $\tau_{\text{rms}} = 100\ \text{ns}$ (duża otwarta przestrzeń przemysłowa lub hala magazynowa; długie echa wielodrogowe o wysokiej dynamice mocy).

### 4.4. Matryca eksperymentów badawczych w Rozdziale 4

Badania w Rozdziale 4 podzielono na eksperymenty deterministyczne E1–E5 oraz weryfikację statystyczną Monte Carlo:

| Nr | Eksperyment | Cel badawczy | Warunki i parametry | Obserwowane zjawisko |
| :---: | :--- | :--- | :--- | :--- |
| **E1** | **Rozdzielczość pasma** | Wpływ pasma na separację bliskich celów | $B = 20, 40, 80, 160\,\mathrm{MHz}$ (802.11ax, MCS 0, Model-C) | Dwa cele oddalone o $3{,}75\,\mathrm{m}$: zlanie w $20\,\mathrm{MHz}$ ($\Delta R=7{,}5\ \text{m}$), styk w $40\,\mathrm{MHz}$, pełna separacja w $80$ i $160\,\mathrm{MHz}$ |
| **E2** | **Aliasing Dopplera** | Długość symbolu OFDM a prędkość jednoznaczna | 802.11a ($T_{\mathrm{sym}}=4{,}0\,\mu\text{s}$) vs 802.11ax ($T_{\mathrm{sym}}=13{,}6\,\mu\text{s}$), Model-A | Szybki pojazd ($v=20\,\mathrm{m/s}$): poprawna detekcja w 'a' vs fałszywa prędkość (aliasing do $-13{,}4\ \text{m/s}$) w 'ax' |
| **E3** | **Modulacja i szum** | Wzmocnienie szumu $\zeta_{\text{ZF}}$ i kontrast PNFR | Wszystkie indeksy MCS 0–11 (BPSK do 1024-QAM), CBW40, Model-C, stały czas ramki ($M = 280$ symboli) | Wzrost $\zeta_{\text{ZF}}$ z $0{,}00\ \text{dB}$ do $6{,}15\ \text{dB}$ oraz spadek kontrastu celu PNFR z $47{,}96\ \text{dB}$ (MCS 0) do $42{,}27\ \text{dB}$ (MCS 11; $41{,}61\ \text{dB}$ dla MCS 10) |
| **E4** | **Clutter TGax i MTI** | Tłumienie stacjonarnego echa wielodrogowego | Modele TGax: Model-A, Model-C, Model-E (CBW80, cel $10{,}0\ \text{m}, +8{,}0\ \text{m/s}$) | Wycięcie składowej stałej ($v=0$) przy $R=10\ \text{m}$ o $28{,}1\ \text{dB}$ (Model-C) i $24{,}2\ \text{dB}$ (Model-E), tłumienie DPI $>70\ \text{dB}$ oraz poprawna lokalizacja celu na $10{,}0\ \text{m}$ dzięki synchronizacji *leading-edge* |
| **E5** | **Dynamika i Binary vs Coherent STC** | Odsłanianie słabych celów i porównanie metod Brauna | CBW20, Model-C, $\text{SNR} = 38\ \text{dB}$, pojazd ($15{,}0\ \text{m}, 0\ \text{dB}$) + pieszy ($30{,}0\ \text{m}, -30\ \text{dB}$) | Binary STC maskuje pieszego w strefie $B = 0$ ($[0; 46{,}9]\ \text{m}$); Coherent STC po odjęciu pojazdu odsłania pieszego ($-31{,}5\ \text{dB} > \eta = -39{,}7\ \text{dB}$) |
| **MC** | **Analiza Monte Carlo** | Statystyczna niezawodność detekcji i zliczania celów | $N_{\text{prób}} = 30$, SNR = $0\text{--}30\ \text{dB}$ (krok 5 dB), Model-C, $N_{\text{true}} = 2$ | Krzywe $P_D(\text{SNR})$ dla obu celów, średnia i przedział ufności oraz odsetek prawidłowego zliczenia $P(N_{\text{det}} == 2)$ |

### 4.5. Struktura skryptów figur i katalog rysunków

Wszystkie skrypty generujące rysunki zorganizowane są w podkatalogach według rozdziałów pracy jako samodzielne, modularne funkcje w języku angielskim:
- `scripts/figures/ch3_impl/` — skrypty dla rozdziału 3 (ilustracje implementacji łańcucha radaru),
- `scripts/figures/ch4_sim/` — skrypty dla rozdziału 4 (badania symulacyjne E1–E5 i Monte Carlo),
- `scripts/figures/run_all_figures.m` — nadrzędny master runner wykonujący wszystkie skrypty po kolei.

Katalogi wyjściowe figur:
- `thesis/img/ch3_impl/` (rysunki rozdziału 3),
- `thesis/img/ch4_sim/` (rysunki rozdziału 4).

#### Twarde zasady implementacji skryptów figur (wzorzec z commita `dd69b70`):
1. **Zasada DRY — zakaz duplikacji kodu potoku radaru**:
   - Skrypty w `scripts/figures/` **bezwzględnie nie mogą powielać ani reimplementować logiki bloków przetwarzania sygnału** (np. synchronizacji, demodulacji OFDM, usuwania CP, estymacji odpowiedzi częstotliwościowej kanału przez dzielenie podnośnych, usuwania echa stałego przez odejmowanie średniej czasowej, okienkowania, transformacji FFT/IFFT czy pętli Binary/Coherent STC).
   - Skrypt generatora **ma bezpośrednio uruchamiać autorski kod projektu**: fasady `step1_transmitter`, `step2_channel`, `step3_receiver`, `step4_interpreter` oraz wyspecjalizowane funkcje z `lib/`.
   - **Ekstrakcja stanów pośrednich przez rozszerzenie struktur wyjściowych**: Jeżeli eksperyment wymaga dostępu do danych pośrednich (np. macierzy $\hat{H}$ przed i po odjęciu średniej czasowej), rozszerza się sygnaturę/strukturę zwracaną przez odpowiedni moduł produkcyjny (np. dodanie pól `H_raw`, `H_no_static`, `H_shifted` do struktury `radar_data` w `step3_receiver.m` lub zwrócenie dodatkowych argumentów w `estimate_channel.m`), zamiast przepisywać wnętrze funkcji w skrypcie rysunku.

2. **Czystość kodu generatora**:
   - Skrypt figury pełni wyłącznie rolę **zwięzłego sterownika testowo-wizualizacyjnego**: przygotowanie parametrów wejściowych $\to$ wywołanie modułów $\to$ pobranie danych wyjściowych ze struktur $\to$ czyste wykreślenie i eksport grafiki przez `exportgraphics(fig, out_file, 'Resolution', 300)`.

**Katalog kluczowych rysunków do pracy**:

| Nr w pracy | Plik graficzny / Źródło | Skrypt testowy / generator | Eksperyment i zawartość merytoryczna |
| :---: | :--- | :--- | :--- |
| **Rys. 1.1** | `thesis/img/ch2_theory/rys_2_1_alokacja_podnosnych.png` | `scripts/figures/ch2_theory/gen_fig_2_1_subcarrier_allocation.m` | Alokacja podnośnych w polu danych (802.11a vs 802.11ax, 20 MHz, luka DC) |
| **Rys. 3.1** | Schemat wektorowy TikZ (`30_radar_implementation.tex`) | — | Schemat blokowy architektury oprogramowania i zależności między funkcjami (`src/`, `lib/`, toolboxes) |
| **Rys. 3.2** | `thesis/img/ch3_impl/rys_3_1_macierz_transmitancji_h.png` | `scripts/figures/ch3_impl/gen_fig_3_1_channel_matrix_h.m` | **IMPL-1**: Estymowana macierz transmitancji $\hat{H}(k, l)$ w dziedzinie czas--częstotliwość przed i po odjęciu średniej czasowej oraz z interpolacją luki DC (802.11ax, CBW80) |
| **Rys. 3.3** | `thesis/img/ch3_impl/rys_3_2_mapa_range_doppler.png` | `scripts/figures/ch3_impl/gen_fig_3_2_range_doppler.m` | **IMPL-2**: Periodogram Range--Doppler: bazowy oraz po usunięciu echa stałego, interpolacji DC i oknowaniu 2D w 3D (cała mapa) i 2D (zbliżenie na strefę celów z detekcją Coherent STC, 802.11ax, CBW80) |
| **Rys. 3.4** | `thesis/img/ch3_impl/rys_3_3_etapy_przetwarzania.png` | `scripts/figures/ch3_impl/gen_fig_3_3_processing_stages.m` | **IMPL-3**: Dekompozycja 4 etapów przetwarzania w odbiorniku i interpreterze (Periodogram bazowy $\to$ Odjęcie średniej czasowej $\to$ Okno 2D BH + interpolacja DC $\to$ Ekstrakcja Coherent STC, 802.11ax, CBW80) |
| **Rys. 4.1** | `thesis/img/ch4_sim/rys_4_1_przekroj_odleglosci_pasma.png` | `scripts/figures/ch4_sim/gen_fig_4_1_bandwidth_cut.m` | **SIM-1 (E1)**: Granica rozdzielczości odległościowej dla pasm 20, 40, 80, 160 MHz ($\Delta R = 3{,}75\ \text{m}$) a stała moc AP |
| **Rys. 4.2** | `thesis/img/ch4_sim/rys_4_2_aliasing_dopplera.png` | `scripts/figures/ch4_sim/gen_fig_4_2_doppler_aliasing.m` | **SIM-2 (E2)**: Granica prędkości jednoznacznej -- porównanie 802.11a i 802.11ax dla szybkiego celu $v = 20\ \text{m/s}$ (aliasing w ax) |
| **Rys. 4.3** | `thesis/img/ch4_sim/rys_4_3_wzmocnienie_szumu_mcs.png` | `scripts/figures/ch4_sim/gen_fig_4_3_noise_enhancement.m` | **SIM-3 (E3)**: Granica modulacji -- współczynnik wzmocnienia szumu $\zeta$ przy dzieleniu podnośnych i kontrast PNFR w funkcji rzędu MCS (0–11) |
| **Rys. 4.4** | `thesis/img/ch4_sim/rys_4_4_usuwanie_echa_stalego.png` | `scripts/figures/ch4_sim/gen_fig_4_4_tgax_static_removal.m` | **SIM-4 (E4)**: Wpływ otoczenia wielodrogowego -- tłumienie clutteru TGax (Modele A, C, E) przez odejmowanie średniej w czasie wolnym |
| **Rys. 4.5** | `thesis/img/ch4_sim/rys_4_5_porownanie_stc.png` | `scripts/figures/ch4_sim/gen_fig_4_5_stc_comparison.m` | **SIM-5 (E5)**: Granica dynamiki mocy -- porównanie Binary STC (maskowanie binarne) i Coherent STC (odejmowanie koherentne) z progiem CFAR $\eta$ (odkrycie pieszego $-30\ \text{dB}$) |
| **Rys. 4.6** | `thesis/img/ch4_sim/rys_4_6_statystyka_indoor.png` | `scripts/figures/ch4_sim/gen_fig_4_6_stat_indoor.m` | **SIM-6a (MC)**: Scenariusz wewnętrzny (802.11ax CBW80, MCS 4, Model-B): prawdopodobieństwo detekcji $P_D(R)$ z 95% przedziałami Wilsona |
| **Rys. 4.7** | `thesis/img/ch4_sim/rys_4_7_statystyka_outdoor.png` | `scripts/figures/ch4_sim/gen_fig_4_7_stat_outdoor.m` | **SIM-6b (MC)**: Scenariusz zewnętrzny/otwarty (802.11ax CBW40, MCS 4, Model-E): prawdopodobieństwo detekcji $P_D(R)$ z 95% przedziałami Wilsona |

### 4.6. Czystość kodu, listingi do pracy i weryfikacja regresyjna

1. **Funkcje DSP w `lib/` (czyste funkcje numeryczne)**:
   - `lib/demodulate.m` — demodulacja OFDM i usuwanie CP,
   - `lib/estimate_channel.m` — estymacja odpowiedzi częstotliwościowej kanału przez dzielenie podnośnych, maska podnośnych, usuwanie echa stałego (odejmowanie średniej czasowej) i interpolacja luki DC,
   - `lib/compute_range_doppler_map.m` — analityczne okno 2D Blackmana–Harrisa oraz periodogram 2D,
   - `lib/get_detection_algorithm.m` — centralny rejestr algorytmów detekcji (`'binary'`, `'coherent'`) rozwiązujący identyfikatory, opisy i uchwyty funkcji uruchomieniowych oraz wizualizacyjnych,
   - `lib/binary_successive_target_cancellation.m` — kanoniczna implementacja Binary STC Brauna (estymacja szumu ML poza $N_{\max}$, próg CFAR $\eta = -\hat{\sigma}^2 \ln(1 - (1 - p_{\mathrm{FA}})^{1/(NM)})$, 2D interpolacja paraboliczna piku, estymacja RCS i maskowanie binarne elipsą *null-to-null*),
   - `lib/coherent_successive_target_cancellation.m` — kanoniczna implementacja Coherent STC Brauna (próg CFAR $\eta$, kontrola rezyduów wewnątrz elipsy $-3\ \text{dB}$, 2D interpolacja paraboliczna, synteza i koherentne odjęcie zespolonej repliki pojedynczego celu z oknem $\mathbf{W}$),
   - `lib/calculate_physical_axes.m` — skalowanie fizycznych osi odległości i prędkości.
2. **Skrypty w `src/` jako fasady uruchomieniowe (100% kompatybilności wstecznej)**:
   - Skrypty `step1_transmitter.m`, `step2_channel.m`, `step3_receiver.m`, `step4_interpreter.m` zachowują stabilną zgodność.
   - `scripts/run_full_simulation.m` nadal wykonuje bazowy łańcuch.
3. **Zabezpieczenie wzorcem odniesienia („Golden Master”) i testy regresyjne**:
   - Skrypt `tests/verify_regression.m` gwarantuje tożsamość numeryczną bazowych funkcji (`max(abs(diff)) < 1e-12`).
4. **Zwarte listingi przeniesione do Dodatku A (`thesis/tex/60_appendices.tex`)** *(zamiast długich bloków kodu w treści Rozdziału 3)*:
   - Listing A.1: model kanału TGax, opóźnienia ułamkowe i symulacja celów (`step2_channel.m`, `configure_targets.m`),
   - Listing A.2: synchronizacja *leading-edge*, estymacja Zero-Forcing, MTI i interpolacja DC (`step3_receiver.m`, `estimate_channel.m`, `interpolate_dc_nulls.m`),
   - Listing A.3: periodogram 2D, okno Blackmana–Harrisa i osie fizyczne (`compute_range_doppler_map.m`, `calculate_physical_axes.m`),
   - Listing A.4: algorytm Coherent STC z progiem CFAR $\eta$ i Krokiem 4 (`coherent_successive_target_cancellation.m`).

---

## 5. Wytyczne redakcyjne, stylistyka i wymogi formalne (z notatki redakcyjnej)

Poniższe reguły są bezwzględnie wiążące podczas pisania i redagowania tekstu pracy w LaTeX:

### 5.1. Stylistyka tekstu i język inżynierski
1. **Pisać „prosto z mostu”**: Unikać lania wody, ozdobników i rozwlekłych uogólnień typowych dla asystentów LLM. Każde zdanie ma wnosić konkretną informację techniczną, matematyczną lub fizyczną.
2. **Forma gramatyczna**: Opis prac własnych, implementacji i badań prowadzimy w **formie bezosobowej czasu przeszłego** (np. *„zaimplementowano”*, *„przeprowadzono”*, *„zbadano”*, *„wyznaczono”*, *„zastosowano”*), unikając formy pierwszoosobowej (*„zrobiłem”*, *„napisałem”*).
3. **Konkretne miary i odniesienia**: Aby rzetelnie ocenić wydajność toru radarowego, wszelkie parametry i wyniki odnosi się do pokrewnej literatury naukowej (Braun, Szwej, Sorbian).

### 5.2. Bezwzględna zasada odwołań do obiektów w tekście
1. **Wszystkie obiekty muszą być przywołane**: Każdy wykres, schemat, rysunek i tabela znajdująca się w pracy **musi posiadać bezpośrednie odwołanie w tekście (`\ref{...}`) oraz komentarz interpretacyjny**.
2. W pracy inżynierskiej niedopuszczalna jest obecność „wiszących” rysunków lub tabel, do których autor nie odnosi się w treści rozdziału.

### 5.3. Standardy czytelności wizualizacji (wykresy do druku)
1. **Wykresy mają być bezwzględnie CZYTELNE i eleganckie**:
   - Grube linie wykresów ($\ge 1.5\ \text{pt}$),
   - Wyraźne, duże czcionki podpisów osi i legend ($\ge 10\text{--}11\ \text{pt}$),
   - Siatka pomocnicza (`grid on`) z subtelnym kontrastem,
   - **Zamknięta pełna ramka osi dla wykresów 2D (`box on`)**: każdy wykres dwuwymiarowy (liniowy, stem, mapa 2D, przekrój) **musi mieć włączoną pełną ramkę osi (`box on;` / `set(gca, 'Box', 'on')`)**, dorysowującą krawędź górną („sufit”) oraz krawędź prawą („prawą ścianę”). Zapobiega to wrażeniu niedokończonych, otwartych wykresów,
   - Brak nakładających się etykiet i napisów.
2. **Obowiązkowy nadrzędny tytuł główny (`sgtitle` / `title`)**:
   - Każdy wykres złożony z wielu podpaneli (`subplot`) **musi posiadać tytuł nadrzędny** wywołany za pomocą:  
     `sgtitle('Główny tytuł wykresu', 'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none')`.
   - Każdy wykres jednopanelowy musi posiadać zwięzły tytuł:  
     `title('Tytuł wykresu', 'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none')`.
   - Flaga `'Interpreter', 'none'` zapobiega niepożądanemu interpretowaniu znaków podkreślenia `_` jako indeksów dolnych.
3. **Zasada minimalizmu i zakaz przeładowania tekstem na wykresie**:
   - Wykresy w pracy dyplomowej są wizualizacją zjawisk fizycznych i wyników przetwarzania sygnałów, a nie miejscem na notatki.
   - **Bezwzględny zakaz umieszczania na wykresach bloków tekstu**, ramek opisowych (`annotation('textbox')`) czy wielolinijkowych komentarzy.
   - **Krótkie, techniczne tytuły podpaneli**: zwięzłe etykiety wariantów (np. `title('a) Przed MTI')`, `title('b) Po MTI')`, `title('a) Standard 802.11a')`, `title('b) Standard 802.11ax')`).
   - Podpisy osi i etykiety paska kolorów: krótkie i precyzyjne z jednostką w nawiasie kwadratowym (np. `Numer symbolu OFDM (czas wolny)`, `Indeks podnośnej k (częstotliwość)`, `Moc transmitancji [dB]`, `Prędkość radialna [m/s]`, `Odległość bistatyczna [m]`).
   - **Wszelkie objaśnienia, dyskusje, parametry scenariusza i interpretacje wyników należą do tekstu rozdziału w LaTeX oraz podpisu pod rysunkiem (`\caption{...}`)**, a nie do grafiki!
4. **100% język polski**: Tytuły, podpisy osi wraz z jednostkami w nawiasach kwadratowych `[...]`, etykiety pasków barwnych (`colorbar`) i legendy muszą być całkowicie w języku polskim.
5. **Eksport w wysokiej rozdzielczości**: Grafiki zapisywane wyłącznie funkcją `exportgraphics(fig, out_file, 'Resolution', 300)`.

### 5.4. Wytyczne uczelni dot. AI, stylometria i JSA
1. **Dozwolona rola narzędzi AI**: Zgodnie z wytycznymi uczelni narzędzia AI/LLM mogą być używane wyłącznie jako wsparcie techniczno-odtwórcze (*chores*: asysta w składzie LaTeX-a, sprawdzanie interpunkcji, drobne skrypty pomocnicze). Narzędzia AI **nie mogą być źródłem koncepcji merytorycznej (*concept*), tez ani wniosków badawczych**.
2. **Świadomość stylometrii i JSA**: Jednolity System Antyplagiatowy (JSA) analizuje jednorodność stylu tekstu. Tekst pracy musi być zredagowany spójnym, jednolitym, autorskim językiem inżynierskim. Zdania powinny być zwięzłe i przyczynowo skutkowe, czyli powiązane ze sobą.

### 5.5. Opracowanie statystyczne w części badawczej
1. W Rozdziale 4 wyniki nie mogą ograniczać się do pojedynczych przypadków deterministycznych.
2. Scenariusz Monte Carlo musi zawierać rzetelne opracowanie statystyczne: wyznaczenie prawdopodobieństwa detekcji $P_D(\text{SNR})$, średnich wartości i przedziałów ufności dla zróżnicowanych celów.

### 5.6. Kwestie formalne jednostki i szablonu
1. **Szablon WIEiT**: Bezwzględnie stosować szablon wydziałowy WIEiT AGH (unikać ogólnych, niezgodnych wzorców uczelnianych z Overleafa).
2. **Nazwa jednostki**: Należy stosować aktualną nazwę instytutu — **Instytut Telekomunikacji i Cyberbezpieczeństwa** (pamiętać o uwzględnieniu Cyberbezpieczeństwa).

---

## 6. Stan szablonu LaTeX do domknięcia

- `thesis/main.tex` — autor, tytuł, wydział (**WIEiT**), instytut (**Instytut Telekomunikacji i Cyberbezpieczeństwa**), kierunek (**Teleinformatyka**), opiekun, Wstęp (nienumerowany, `05_introduction`), 4 rozdziały numerowane (`10_wifi_signal`, `20_passive_radar`, `30_radar_implementation`, `40_simulation_results`), Wnioski końcowe (nienumerowane, `50_conclusion`), Literatura oraz Dodatki (`60_appendices`)
- `thesis/tex/01_titlePage.tex` — etykieta **Praca inżynierska**, aktualna nazwa jednostki
- `thesis/tex/03_MasterThesisOutline.tex` — program pracy inżynierskiej ze zgłoszenia
- `thesis/tex/00_preambule.tex` — pakiet `tikz` (schemat blokowy w Rozdz. 3) oraz polskie etykiety pakietu `appendix` (`Dodatki`)
- Ostatnia pozycja w `thesis/bibliography.bib` / bibliografii — link do repozytorium GitHub z pracą
- Spis rysunków / tabel w `main.tex`

---

## 7. Poza zakresem

Celowo **nie** wchodzi do tej pracy:
- Pomiary rzeczywiste SDR / CSI z fizycznej karty Wi-Fi (omówione w podsumowaniu jako perspektywa rozwoju).
- Ciągłe śledzenie obiektów w czasie (Multi-Frame CPI / Tracking) — omówione teoretycznie w rozdz. 2 i 5; w badaniach skupiamy się na pełnej ramce pojedynczej i jej parametrach.
- Przebudowa `src/` pod inną architekturę (np. obiektową OOP).
- Ręczne inwentarze literatury oraz brudnopisy w Markdownie — jedynym źródłem prawdy dla literatury jest Zotero/`.bib`, a dla tekstu pliki `.tex`.
- Umieszczanie skryptów demonstracyjnych MathWorks w bibliografii jako artykułów naukowych.
