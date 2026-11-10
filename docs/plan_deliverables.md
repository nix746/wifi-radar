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
| Wkład własny | Zastosowanie paradygmatu przetwarzania CIR (estymacja kanału, MTI, kompensacja DC, mapa Range–Doppler) na sygnale **Wi-Fi 802.11a oraz 802.11ax**, przekrojowa analiza wpływu parametrów warstwy fizycznej (szerokość pasma, aliasing Dopplera, rząd MCS, model kanału TGax) na detekcję oraz implementacja algorytmu **Coherent CLEAN** (Braun) |

Kod w `src/` jest już nośnikiem metody. Praca ma **opisać i zbadać** ten łańcuch, a nie przebudowywać go od zera.

---

## 2. Układ rozdziałów

Układ obejmuje **pięć rozdziałów**, łącząc teorię sygnału i radaru pasywnego w Rozdziale 2, opisując całą implementację łańcucha w Rozdziale 3 oraz poświęcając Rozdział 4 w całości badaniom symulacyjnym.

| Nr | Plik LaTeX | Tytuł | Budżet stron | Podrozdziały i zawartość merytoryczna |
| :---: | :--- | :--- | :---: | :--- |
| **1** | `thesis/tex/10_introduction.tex` | Wstęp | 1–2 str. | Piszemy na samym końcu po zredagowaniu całości. To nie jest abstrakt (nie powiela słów kluczowych/streszczenia).<br>**1.1. Zakres pracy** (802.11a vs 802.11ax, kanał syntetyczny vs TGax, ograniczenia implementacyjne)<br>**1.2. Motywacja** (iluminator Wi-Fi, nowsze generacje OFDM, pasywna detekcja)<br>**1.3. Teza i pytania badawcze** (precyzyjnie określony cel pracy w osobnym akapicie; kompromisy rozdzielczości, prędkości jednoznacznej i tłumienia clutteru)<br>**1.4. Układ pracy** (przegląd zawartości poszczególnych rozdziałów, forma bezosobowa: „zrobiono, przeprowadzono”) |
| **2** | `thesis/tex/20_passive_radar.tex` | Radar Pasywny | 10–12 str. | Zwięzły stan wiedzy (*state-of-the-art*), bez lania wody i bez dominacji nad praktyką. Porównanie z pracami pokrewnymi (Szwej, Sorbian, Braun). Opis narzędzi/toolboxów przeniesiony do Rozdz. 3.<br>**2.1. Sygnał Wi-Fi 802.11** (standardy, formaty ramek Non-HT i HE-SU, siatka podnośnych)<br>**2.2. Modulacja OFDM** (ortogonalność, prefiks cykliczny CP, relacja czas–częstotliwość)<br>**2.3. Podstawy radaru pasywnego** (geometria bistatyczna, bilans mocy, DPI, clutter stacjonarny)<br>**2.4. Estymacja kanału** (paradygmat CIR vs funkcja CAF, estymator Zero-Forcing $H = Y ./ X$)<br>**2.5. Filtracja ech stałych** (filtr MTI w czasie wolnym, rekonstrukcja luki nośnych DC)<br>**2.6. Wyznaczanie mapy Range–Doppler** (analityczne okno 2D Blackmana–Harrisa, IFFT/FFT)<br>**2.7. Detekcja i ekstrakcja celów** (dekonwolucja koherentna Coherent CLEAN, próg szumu MAD) |
| **3** | `thesis/tex/30_radar_implementation.tex` | Implementacja radaru | 10–14 str. | Część inżynierska: jednoznaczność i czytelność. Raport ze środowiska i implementacji bloków.<br>**3.1. Środowisko symulacyjne MATLAB i toolboxy** (rola WLAN Toolbox, Communications Toolbox i wkład własny bez Radar Toolboxa)<br>**3.2. Implementacja kanału** (`step2_channel.m`, triada modeli TGax A/C/E, symulacja opóźnień i przesunięć Dopplera celów ruchomych)<br>**3.3. Implementacja odbiornika** (`step3_receiver.m`, demodulacja, estymator ZF, filtr MTI, interpolacja DC — Rys. 3.1)<br>**3.4. Implementacja interpretera** (`step4_interpreter.m`, okienkowanie 2D, mapa periodogramu Range–Doppler — Rys. 3.2, pętla Coherent CLEAN, osie fizyczne, listingi) |
| **4** | `thesis/tex/40_simulation_results.tex` | Badania symulacyjne | 12–16 str. | Rdzeń badawczy: ściśle zdefiniowane scenariusze, wyniki, opracowanie statystyczne Monte Carlo z miarami ufności.<br>**4.1. Scenariusze testowe** (założenia, parametryzacja w `get_wifi_params.m`, fizyka stałej mocy AP 100 mW EIRP i spadek SNR o 9 dB dla 160 MHz)<br>**4.2. Rozdzielczość odległościowa a szerokość pasma** (Eksperyment E1: 20, 40, 80, 160 MHz — Rys. 4.1)<br>**4.3. Długość symbolu OFDM a prędkość jednoznaczna** (Eksperyment E2: 802.11a vs 802.11ax, aliasing Dopplera — Rys. 4.2)<br>**4.4. Wpływ rzędu modulacji MCS i poziomu szumu na estymację ZF** (Eksperyment E3: współczynnik $\zeta_{\text{ZF}}$, kontrast PNFR — Rys. 4.3)<br>**4.5. Tłumienie stacjonarnego clutteru** (Eksperyment E4: modele TGax A, C, E, wycinanie $f_D = 0$ przez filtr MTI — Rys. 4.4)<br>**4.6. Skuteczność algorytmu Coherent CLEAN** (Eksperyment E5: dynamika >30 dB, odsłanianie pieszego, adaptacyjny stop MAD — Rys. 4.5; Eksperyment MC: analiza $P_D(\text{SNR})$ ze średnią i przedziałami — Rys. 4.6) |
| **5** | `thesis/tex/50_conclusion.tex` | Wnioski | 2–3 str. | Piszemy na samym końcu. Podsumowanie wyników z odniesieniem do tezy i celu.<br>**5.1. Podsumowanie uzyskanych wyników** (zestawienie wniosków z implementacji oraz badań symulacyjnych E1–E5 i MC)<br>**5.2. Ograniczenia metody i kierunki rozwoju** (kompromis $T_{\text{sym}}$ w 802.11ax, bilans mocy AP, multi-frame CPI, pomiary SDR/CSI) |

Front matter (strona tytułowa, oświadczenie, program pracy) znajduje się w plikach `01_`–`03_`, z danymi ze zgłoszenia i etykietą „praca inżynierska”.

Pliki rozdziałów (`10_introduction.tex` … `50_conclusion.tex`) znajdują się w `thesis/tex/` i są włączane przez `\include` w `thesis/main.tex`.

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

### 4.1. Architektura kodu i uzasadnienie wkładu własnego (podrozdział 3.1)

W rozdziale 3.1 wyraźnie rozgranicza się rolę toolboxów i wkładu własnego:
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
| **E3** | **Modulacja i szum** | Wzmocnienie szumu $\zeta_{\text{ZF}}$ i kontrast PNFR | MCS 0 (BPSK), MCS 3 (16-QAM), MCS 7 (64-QAM), MCS 11 (1024-QAM), stały czas ramki ($M = 280$ symboli) | Wzrost $\zeta_{\text{ZF}}$ z $0\ \text{dB}$ do $6{,}15\ \text{dB}$ oraz proporcjonalny spadek kontrastu celu PNFR o $5{,}65\ \text{dB}$ dla wyższych MCS |
| **E4** | **Clutter TGax i MTI** | Tłumienie stacjonarnego echa wielodrogowego | Modele TGax: Model-A, Model-C, Model-E | Wycięcie składowej stałej $f_D = 0$ o ponad $48\ \text{dB}$ przez filtr MTI; rola interpolacji luki DC |
| **E5** | **Dynamika i Coherent CLEAN** | Odkrywanie słabych celów i adaptacyjny warunek stopu | Cel silny ($0\,\mathrm{dB}$, pojazd), cel słaby ($-30\,\mathrm{dB}$, pieszy), Model-C | Odkrycie słabego celu w listkach bocznych; automatyczne przerwanie po 2 iteracjach dzięki progowi MAD (brak *over-cleaning*) |
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
   - Skrypty w `scripts/figures/` **bezwzględnie nie mogą powielać ani reimplementować logiki bloków DSP** (np. synchronizacji, demodulacji OFDM, usuwania CP, estymacji Zero-Forcing, filtracji MTI, okienkowania, transformacji FFT/IFFT czy pętli CLEAN).
   - Skrypt generatora **ma bezpośrednio uruchamiać autorski kod projektu**: fasady `step1_transmitter`, `step2_channel`, `step3_receiver`, `step4_interpreter` oraz wyspecjalizowane funkcje z `lib/`.
   - **Ekstrakcja stanów pośrednich przez rozszerzenie struktur wyjściowych**: Jeżeli eksperyment wymaga dostępu do danych pośrednich (np. macierzy $\hat{H}$ przed i po MTI), rozszerza się sygnaturę/strukturę zwracaną przez odpowiedni moduł produkcyjny (np. dodanie pól `H_raw`, `H_shifted` do struktury `radar_data` w `step3_receiver.m` lub zwrócenie drugiego argumentu w `estimate_channel_zf.m`), zamiast przepisywać wnętrze funkcji w skrypcie rysunku.

2. **Czystość kodu generatora**:
   - Skrypt figury pełni wyłącznie rolę **zwięzłego sterownika testowo-wizualizacyjnego**: przygotowanie parametrów wejściowych $\to$ wywołanie modułów $\to$ pobranie danych wyjściowych ze struktur $\to$ czyste wykreślenie i eksport grafiki przez `exportgraphics(fig, out_file, 'Resolution', 300)`.

**Katalog kluczowych rysunków do pracy**:

| Nr w pracy | Plik graficzny | Skrypt testowy / generator | Eksperyment i zawartość merytoryczna |
| :---: | :--- | :--- | :--- |
| **Rys. 3.1** | `thesis/img/ch3_impl/rys_3_1_macierz_transmitancji_h.png` | `scripts/figures/ch3_impl/gen_fig_3_1_channel_matrix_h.m` | **IMPL-1**: Estymowana macierz transmitancji $\hat{H}(k, l)$ w dziedzinie czas--częstotliwość przed i po filtracji MTI oraz z interpolacją luki DC (802.11ax, CBW80) |
| **Rys. 3.2** | `thesis/img/ch3_impl/rys_3_2_mapa_range_doppler.png` | `scripts/figures/ch3_impl/gen_fig_3_2_range_doppler.m` | **IMPL-2**: Mapa periodogramu Range--Doppler przed i po filtracji DSP w 3D (cała mapa) i 2D (zbliżenie na strefę celów z detekcją CLEAN, 802.11ax, CBW80) |
| **Rys. 3.3** | `thesis/img/ch3_impl/rys_3_3_etapy_przetwarzania_dsp.png` | `scripts/figures/ch3_impl/gen_fig_3_3_dsp_stages.m` | **IMPL-3**: Dekompozycja 4 kroków przetwarzania DSP w odbiorniku i interpreterze (Surowy $\to$ MTI $\to$ Okno 2D BH + DC $\to$ Ekstrakcja CLEAN, 802.11ax, CBW80) |
| **Rys. 4.1** | `thesis/img/ch4_sim/rys_4_1_przekroj_odleglosci_pasma.png` | `scripts/figures/ch4_sim/gen_fig_4_1_bandwidth_cut.m` | **SIM-1 (E1)**: Granica rozdzielczości odległościowej dla pasm 20, 40, 80, 160 MHz ($\Delta R = 3{,}75\ \text{m}$) a stała moc AP |
| **Rys. 4.2** | `thesis/img/ch4_sim/rys_4_2_aliasing_dopplera.png` | `scripts/figures/ch4_sim/gen_fig_4_2_doppler_aliasing.m` | **SIM-2 (E2)**: Granica prędkości jednoznacznej -- porównanie 802.11a i 802.11ax dla szybkiego celu $v = 20\ \text{m/s}$ (aliasing w ax) |
| **Rys. 4.3** | `thesis/img/ch4_sim/rys_4_3_wzmocnienie_szumu_mcs.png` | `scripts/figures/ch4_sim/gen_fig_4_3_noise_enhancement.m` | **SIM-3 (E3)**: Granica modulacji -- współczynnik wzmocnienia szumu $\zeta_{\text{ZF}}$ i kontrast celu PNFR w funkcji rzędu MCS (0, 3, 7, 11) |
| **Rys. 4.4** | `thesis/img/ch4_sim/rys_4_4_tlumienie_clutteru_mti.png` | `scripts/figures/ch4_sim/gen_fig_4_4_tgax_mti_cut.m` | **SIM-4 (E4)**: Wpływ otoczenia wielodrogowego -- tłumienie clutteru TGax (Modele A, C, E) przez filtr MTI w czasie wolnym |
| **Rys. 4.5** | `thesis/img/ch4_sim/rys_4_5_clean_prog_adaptacyjny.png` | `scripts/figures/ch4_sim/gen_fig_4_5_clean_cut.m` | **SIM-5 (E5)**: Granica dynamiki mocy -- dekonwolucja Coherent CLEAN (odkrycie pieszego $-30\ \text{dB}$) z adaptacyjnym progiem szumu MAD |
| **Rys. 4.6** | `thesis/img/ch4_sim/rys_4_6_statystyka_pd_vs_snr.png` | `scripts/figures/ch4_sim/gen_fig_4_6_stat_pd_vs_snr.m` | **SIM-6 (MC)**: Granica czułości -- prawdopodobieństwo prawidłowej detekcji $P_D(\text{SNR})$ w funkcji SNR dla silnego i słabego celu w kanale Model-C |

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
4. **Zwarte listingi do Rozdziału 3 pracy (`thesis/listings/`)**:
   - `listings/lst_channel.m` (rozdz. 3.2 — model kanału TGax i symulacja celów),
   - `listings/lst_receiver_zf_mti.m` (rozdz. 3.3 — estymacja Zero-Forcing, MTI i interpolacja DC),
   - `listings/lst_range_doppler.m` (rozdz. 3.4 — periodogram 2D i okno Blackmana–Harrisa),
   - `listings/lst_coherent_clean.m` (rozdz. 3.4 — pętla Coherent CLEAN z progiem MAD).

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

- `thesis/main.tex` — autor, tytuł, wydział (**WIEiT**), instytut (**Instytut Telekomunikacji i Cyberbezpieczeństwa**), kierunek (**Teleinformatyka**), opiekun, `\include` 5 rozdziałów (`10_introduction`, `20_passive_radar`, `30_radar_implementation`, `40_simulation_results`, `50_conclusion`)
- `thesis/tex/01_titlePage.tex` — etykieta **Praca inżynierska**, aktualna nazwa jednostki
- `thesis/tex/03_MasterThesisOutline.tex` — program pracy inżynierskiej ze zgłoszenia
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
