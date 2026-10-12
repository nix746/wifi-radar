# Milestone 1
Implementacja i testowanie efektywności detekcji wybranego algorytmu radaru pasywnego używającego sygnału Wi-Fi
Tymon Woźniak 422842
### Cel Pracy
Głównym celem pracy inżynierskiej jest **zaprojektowanie, implementacja w środowisku MATLAB oraz weryfikacja eksperymentalna efektywności detekcji celów ruchomych w radarze pasywnym, monostatycznym**, wykorzystującym jako sygnały sondujące powszechne transmisje pakietowe standardów **IEEE 802.11a (Legacy)** oraz **IEEE 802.11ax (Wi-Fi 6)**.

1. **Deterministyczny tor przetwarzania w paradygmacie CIR (Zero-Forcing):**
   Zastąpienie obciążającej obliczeniowo dwuwymiarowej funkcji wzajemnej niejednoznaczności (CAF – *Cross-Ambiguity Function*) paradygmatem estymacji transmitancji kanału radiowego w dziedzinie częstotliwości (CFR/CIR) metodą **Zero-Forcing ($H = Y / X$)**. Pozwala to wyeliminować wpływ losowej modulacji transmitowanych danych telekomunikacyjnych i sprowadzić kompresję odległość-prędkość do szybkiej dwuwymiarowej transformaty Fouriera (2D Periodogram Range–Doppler).
2. **Kompensacja zakłóceń i artefaktów widmowych:**
   * Tłumienie stacjonarnego przesłuchu bezpośredniego (DPI) oraz echa ścian filtrem **MTI** (*Moving Target Indication*) w dziedzinie symboli (czasu wolnego).
   * Eliminacja wycieku widmowego (*spectral leakage*) poprzez **adaptacyjną interpolację wyzerowanych podnośnych stałoprądowych (DC carrier gap)** dla 1 podnośnej (802.11a) oraz poszerzonej luki 3 podnośnych (802.11ax).
   * Zastosowanie 4-wyrazowego okienkowania **Blackmana–Harrisa 2D** o tłumieniu listków bocznych rzędu $\approx 92\,\text{dB}$.
3. **Koherentne usuwanie listków bocznych (Coherent CLEAN):**
   Implementacja algorytmu dekonwolucyjnego *Coherent CLEAN* (wg M. Brauna), umożliwiającego odkrywanie słabych ech celów zamaskowanych w listkach bocznych dominujących obiektów o wysokim RCS w scenariuszach o dużej dynamice mocy ($>30\,\text{dB}$).
4. **Analiza kompromisów warstwy fizycznej (Trade-offs):**
   * Zbadanie wpływu 4-krotnie dłuższego symbolu OFDM w 802.11ax ($T_{\text{sym}} = 13.6\,\mu\text{s}$ vs $4.0\,\mu\text{s}$) na spadek prędkości jednoznacznej ($v_{\text{unamb}} \approx 16.7\,\text{m/s}$ vs $68.2\,\text{m/s}$) i zjawisko aliasingu Dopplera przy prędkościach drogowych.
   * Zbadanie wpływu szerokości pasma ($B = 20, 40, 80\,\text{MHz}$) na rozdzielczość odległościową ($\Delta R = 7.5, 3.75, 1.875\,\text{m}$).
   * Ocena zjawiska *noise enhancement* przy estymacji ZF dla różnych rzędów modulacji (BPSK, 16-QAM, 64-QAM).
5. **Weryfikacja w realistycznym kanale wielodrogowym:**
   Ocena odporności toru detekcji w znormalizowanych modelach kanału wewnątrzbudynkowego **TGax Model-B** oraz **Model-D** (`wlanTGaxChannel`) w zestawieniu z kanałem syntetycznym.

### 1.3. Uzasadnienie architektury i brak „czarnych skrzynek”
* **Rola toolboxów MathWorks:** Pakiety *WLAN Toolbox* i *Communications Toolbox* są wykorzystane wyłącznie w modułach nadawczych do syntezy wzorcowych ramek transmisyjnych 802.11a/ax oraz dodania szumu AWGN.
* **Wkład własny w algorytmy DSP:** Cały tor odbiorczy (demodulacja OFDM, estymacja Zero-Forcing, filtracja MTI, interpolacja DC, okno Blackmana-Harrisa 2D, periodogram Range-Doppler oraz pętla Coherent CLEAN) został zaimplementowany od podstaw w bazowym środowisku MATLAB w katalogu `lib/`, bez użycia komercyjnych gotowców z *Radar Toolboxa*.
* **Geometria monostatyczna:** Nadajnik i odbiornik są współumieszczone w jednym punkcie dostępowym (wspólny zegar, kąt bistatyczny $\beta = 0^\circ$). Eliminuje to asynchronizm oscylatorów (CFO), a droga fali jest dwukierunkowa ($\Delta R = c / 2B$).

---

## 2. Dokładny plan pracy i przewidywany spis treści

### 2.1. Harmonogram realizacji (Work Plan)
Realizacja projektu podzielona jest na ustrukturyzowane tory zadaniowe:
* **Tor B (Scenariusze badawcze E1–E5):**
  * Implementacja 5 dedykowanych skryptów badawczych w `scripts/` badających zjawiska fizyczne.
  * Wygenerowanie i weryfikacja katalogu 9 figur scenariuszowych do `thesis/img/`.
* **Tor C (Redakcja tekstu w LaTeX):**
  * Opracowanie rozdziałów teoretycznych 2–4 z włączeniem wyodrębnionych listingów kodu.
  * Zredagowanie rozdziału 5 pod kątem uzyskanych wykresów z eksperymentów E1–E5.
* **Faza Domknięcia:** Zredagowanie Wstępu (rozdz. 1), Wniosków (rozdz. 6), formalnego programu pracy oraz domknięcie spisu literatury.

---

### 2.2. Matryca 5 eksperymentów badawczych
Badania symulacyjne w rozdziale 5 opierają się na **5 kluczowych scenariuszach fizycznych**:

| Nr | Skrypt badawczy | Cel eksperymentu | Parametry i zmienne | Obserwowane zjawisko fizyczne |
| :---: | :--- | :--- | :--- | :--- |
| **E1** | `exp1_bandwidth_resolution.m` | Wpływ pasma na zdolność rozdzielczą | $B = 20, 40, 80\,\mathrm{MHz}$ (802.11ax) | Dwa cele oddalone o $3\,\mathrm{m}$: zlanie ech w $20\,\mathrm{MHz}$ vs separacja w $80\,\mathrm{MHz}$. |
| **E2** | `exp2_doppler_aliasing.m` | Długość symbolu OFDM a prędkość jednoznaczna | 802.11a ($T_{\mathrm{sym}}=4\,\mu\mathrm{s}$) vs 802.11ax ($T_{\mathrm{sym}}=13.6\,\mu\mathrm{s}$) | Cel szybki ($v=25\,\mathrm{m/s}$): poprawna detekcja w 'a' vs fałszywy cel (aliasing) w 'ax'. |
| **E3** | `exp3_modulation_noise.m` | Wpływ modulacji na estymację ZF | MCS 0 (BPSK), MCS 3 (16-QAM), MCS 7 (64-QAM); SNR $+25, +10, -5\,\mathrm{dB}$ | Efekt *noise enhancement* przy wyższych rzędach MCS; granica zysku integracji. |
| **E4** | `exp4_tgax_clutter.m` | Tłumienie clutteru wielodrogowego | Kanał AWGN vs TGax Model-B vs Model-D | Wycinanie gęstego profilu kanału przez filtr MTI oraz rola interpolacji luki DC. |
| **E5** | `exp5_coherent_clean.m` | Ekstrakcja celów w dużej dynamice mocy | Cel silny ($0\,\mathrm{dB}$) + cel słaby ($-30\,\mathrm{dB}$) | Odkrycie słabego celu zamaskowanego w listkach bocznych dominującego obiektu. |

---

### 2.3. Przewidywany spis treści pracy inżynierskiej

```text
Strona tytułowa (Praca inżynierska)
Oświadczenie studenta o samodzielnym wykonaniu pracy
Tematyka i program pracy inżynierskiej i praktyki dyplomowej
Spis treści

1. Wstęp
   1.1. Cel i zakres pracy
   1.2. Motywacja (wszechobecność Wi-Fi, nowsze generacje OFDM, IEEE 802.11bf)
   1.3. Teza i pytania badawcze
   1.4. Układ pracy

2. Koncepcja bistatycznego i monostatycznego radaru pasywnego
   2.1. Geometria bistatyczna a układ współumieszczony (monostatyczny)
   2.2. Zjawiska fizyczne (DPI, clutter stacjonarny, bilans mocy i równanie radaru)
   2.3. Etapy przetwarzania sygnału w radarze pasywnym
   2.4. Paradygmat CIR i estymacja Zero-Forcing a klasyczna funkcja CAF
   2.5. Zalety i ograniczenia radaru opartego o sygnały Wi-Fi

3. Sygnał Wi-Fi IEEE 802.11
   3.1. Rodzina standardów IEEE 802.11 i ewolucja warstwy fizycznej (802.11a -> 802.11ax)
   3.2. Struktura modulacji OFDM i prefiks cykliczny (ortogonalność, rola CP)
   3.3. Ramki Non-HT (802.11a) oraz HE-SU (802.11ax)
   3.4. Sprzężone relacje parametrów telekomunikacyjnych i radarowych (trade-offs)
   3.5. Siatka podnośnych OFDM i problem luki nośnych stałoprądowych (DC carrier gap)
   3.6. Transmisja pakietowa i perspektywy integracji Multi-Frame CPI

4. Algorytmy przetwarzania radarowego
   4.1. Synchronizacja pakietu (detekcja Schmidla-Coxa a wlanPacketDetect)
   4.2. Estymacja transmitancji kanału metodą Zero-Forcing (dynamiczna maska podnośnych)
   4.3. Tłumienie przesłuchu bezpośredniego i ech stałych (filtr MTI w czasie wolnym)
   4.4. Rekonstrukcja nośnych stałoprądowych (adaptacyjna interpolacja DC)
   4.5. Dwuwymiarowe okienkowanie Blackmana–Harrisa
   4.6. Dwuwymiarowy periodogram Range–Doppler (IFFT po podnośnych, FFT po symbolach)
   4.7. Koherentne usuwanie celów (algorytm Coherent CLEAN)

5. Badania symulacyjne
   5.1. Środowisko symulacyjne MATLAB i architektura eksperymentu
   5.2. Rozdzielczość odległościowa a szerokość pasma (scenariusz E1: 20, 40, 80 MHz)
   5.3. Długość symbolu OFDM a prędkość jednoznaczna (scenariusz E2: 802.11a vs 802.11ax)
   5.4. Wpływ rzędu modulacji MCS i poziomu szumu na estymację ZF (scenariusz E3)
   5.5. Tłumienie stacjonarnego clutteru w kanale TGax Model-B/D (scenariusz E4)
   5.6. Skuteczność algorytmu Coherent CLEAN w scenariuszach o dużej dynamice mocy (scenariusz E5)

6. Wnioski
   6.1. Podsumowanie uzyskanych wyników
   6.2. Ograniczenia zastosowanej metody i implementacji
   6.3. Kierunki dalszych prac (pomiary SDR, macierze CSI, standard IEEE 802.11bf)

Literatura
Spis rysunków (Katalog 9 rycin scenariuszowych)
Spis tabel
```

---

## 3. Przedstawienie zebranej literatury i uzasadnienie wyboru

Do projektu dobrano **5 recenzowanych, zweryfikowanych pozycji naukowych i norm technicznych**. Zgodnie z zasadami repozytorium źródłem prawdy jest baza Zotero powiązana z fizycznymi plikami w `references/` oraz zautomatyzowanym eksportem do `thesis/bibliography.bib`.

### 1. Martin Braun (2014) – Rozprawa doktorska KIT
* **Tytuł:** *OFDM Radar Algorithms in Mobile Communication Networks*
* **Autor i afiliacja:** Martin Braun, Karlsruher Institut für Technologie (KIT), Institut für Nachrichtentechnik.
* **Co w niej jest?**
  Kompletna teoria matematyczna radaru OFDM. Wyprowadza paradygmat estymacji transmitancji kanału (CIR/CFR) przez dzielenie Zero-Forcing, analizuje 2D-FFT do kompresji odległości i prędkości oraz szczegółowo opisuje procedurę dekonwolucyjną **Coherent CLEAN** (rozdział 3.3.7).
* **Dlaczego wybrana i istotna?**
  Jest bezpośrednim fundamentem algorytmicznym pracy. Zaimplementowane w projekcie funkcje `lib/estimate_channel_zf.m`, `lib/compute_range_doppler_map.m` oraz `lib/run_coherent_clean.m` bazują ściśle na matematyce Brauna. Udowadnia, że w sygnałach OFDM radar nie wymaga wyznaczania kosztownej korelacji CAF, lecz jest tożsamy z estymacją transmitancji kanału transmisyjnego.

### 2. Marco Di Seglio, Francesca Filippini, Kevin Chetty, Fabiola Colone (2022) – IEEE RadarConf
* **Tytuł:** *Reducing the Computational Complexity of WiFi-based Passive Radar Processing*
* **Publikacja:** *2022 IEEE Radar Conference (RadarConf22)*, Nowy Jork, DOI: 10.1109/RadarConf2248738.2022.9764350.
* **Co w niej jest?**
  Analiza optymalizacji przetwarzania sygnału radaru pasywnego Wi-Fi. Autorzy (zespół prof. Fabioli Colone z Rzymu) udowadniają wyższość filtracji odwrotnej (*reciprocal filter* – odpowiednik Zero-Forcing) nad tradycyjnym filtrem dopasowanym (*matched filter*) oraz odwrócenie kolejności operacji (najpierw usuwanie clutteru, potem kompresja).
* **Dlaczego wybrana i istotna?**
  Dostarcza najnowszego, renomowanego uzasadnienia teoretycznego i eksperymentalnego dla architektury przyjętej w pracy. Wykazuje redukcję złożoności obliczeniowej oraz eliminację listków bocznych wnoszonych przez losowe dane telekomunikacyjne.

### 3. Wojciech Sorbian (2025) – Przegląd Telekomunikacyjny / WAT
* **Tytuł:** *Wykorzystanie sieci Wi-Fi do pasywnej detekcji obiektów*
* **Publikacja:** *Przegląd Telekomunikacyjny – Wiadomości Telekomunikacyjne*, 2025, nr 1, s. 5–14, DOI: 10.15199/59.2025.1.1.
* **Co w niej jest?**
  Polska praca przeglądowo-badawcza opisująca architekturę pasywnego radaru Wi-Fi, tłumienie przesłuchu bezpośredniego (DPI), konstrukcję map Range–Doppler oraz modelowanie propagacji wewnątrzbudynkowej.
* **Dlaczego wybrana i istotna?**
  Pozycja rekomendowana bezpośrednio przez promotora (zespół prof. Zielińskiego / WAT, materiały w `references/TZ`). Stanowi aktualny krajowy punkt odniesienia do analizy problemów implementacyjnych radaru Wi-Fi w budynkach (niska moc AP, clutter wielodrogowy).

### 4. Normy techniczne: IEEE Std 802.11a-1999 oraz IEEE Std 802.11ax-2021
* **Tytuł:** *IEEE Standard for Information Technology – Telecommunications and Information Exchange Between Systems – LAN/MAN Specific Requirements – Part 11: Wireless LAN MAC and PHY Specifications* (DOI: 10.1109/IEEESTD.1999.90606).
* **Co w nich jest?**
  Ścisła specyfikacja parametrów fizycznych warstwy PHY: struktura preambuł (STF, LTF), siatka FFT ($N_{\text{fft}} = 64$ przy $\Delta f = 312.5\,\text{kHz}$ w 802.11a vs $N_{\text{fft}} = 256$ przy $\Delta f = 78.125\,\text{kHz}$ w 802.11ax), czasy trwania symboli ($4.0\,\mu\text{s}$ vs $13.6\,\mu\text{s}$), rozmieszczenie podnośnych aktywnych i pilotów oraz układ zerowanych podnośnych DC (1 vs 3).
* **Dlaczego wybrane i istotne?**
  Sygnał Wi-Fi jest sygnałem sondującym. Z parametrów normy bezpośrednio wynikają ograniczenia radarowe: rozdzielczość odległościowa $\Delta R = c/(2B) = 7.5\,\text{m}$ (dla $B=20\,\text{MHz}$) oraz maksymalna prędkość jednoznaczna $v_{\text{unamb}} = \lambda / (2 T_{\text{sym}})$, która dla 802.11ax drastycznie spada do $\approx 16.7\,\text{m/s}$, wywołując aliasing Dopplera.

### 5. Katarzyna Szwej (2020) – Praca inżynierska WIEiT AGH
* **Tytuł:** *Radar OFDM z użyciem sygnału DVB-T2* (opiekun: prof. dr hab. inż. Tomasz Zieliński).
* **Co w niej jest?**
  Projekt i implementacja toru radaru pasywnego dla sygnału telewizyjnego OFDM DVB-T2 opartego na estymacji transmitancji kanału (CIR), filtracji MTI i periodogramie 2D.
* **Dlaczego wybrana i istotna?**
  Formalny i metodyczny wzorzec katedralny AGH. Gwarantuje zachowanie spójności metodologicznej, aparatu pojęciowego i standardu weryfikacji wymaganego przez opiekuna pracy.

---



## 4. Krótkie State-of-the-Art i umiejscowienie pracy własnej

### 4.1. Co w tej dziedzinie już zrobiono?
* **Ewolucja PBR:** Klasyczne radary pasywne bazowały na sygnałach ciągłych (FM, DVB-T) i obliczaniu dwuwymiarowej funkcji wzajemnej niejednoznaczności (CAF), co wiązało się z ogromną złożonością obliczeniową $\mathcal{O}(N^2)$ i wysokimi listkami bocznymi losowych danych.
* **Przełom OFDM CIR (Braun, Colone):** Wykazano, że dla sygnałów OFDM dzielenie $Y/X$ (Zero-Forcing) eliminuje modulację danych, sprowadzając kompresję do transformaty Fouriera $\mathcal{O}(N \log N)$ bez listków bocznych danych.
* **Zastosowanie Wi-Fi w budynkach:** Większość dotychczasowych prac koncentrowała się na starszym standardzie 802.11a/g w paśmie 20 MHz.
* **Standaryzacja IEEE 802.11bf (WLAN Sensing):** Grupa robocza IEEE standaryzuje kooperacyjny sensing w sieciach bezprzewodowych (ISAC – *Integrated Sensing and Communications*), wprowadzając dedykowane pakiety sondujące bez ładunku danych (NDP) i rezerwację medium w warstwie MAC.

### 4.2. Jak na tym tle lokuje się niniejsza praca?

| Wymiar badawczy | Typowe podejście w literaturze | Podejście i wkład w niniejszej pracy |
| :--- | :--- | :--- |
| **Generacja Wi-Fi** | Przeważnie starsze standardy **802.11a/g** ($N_{\text{fft}}=64$). | **Bezpośrednie porównanie 802.11a z Wi-Fi 6 (802.11ax)**. Identyfikacja kompromisu: 4-krotny wzrost $T_{\mathrm{sym}}$ ($13.6\,\mu\text{s}$) powoduje drastyczny spadek $v_{\text{unamb}}$ do $16.7\,\text{m/s}$ i aliasing Dopplera. |
| **Szerokość pasma** | Stałe pasmo 20 MHz ($\Delta R = 7.5\,\text{m}$). | **Badanie wpływu pasma 20, 40 i 80 MHz** (scenariusz E1) na rozdzielczość odległościową ($\Delta R$ do $1.875\,\text{m}$) i separację bliskich celów. |
| **Metoda estymacji** | Korelacja CAF lub biblioteki czarnoskrzynkowe. | **Deterministyczny tor CIR / Zero-Forcing** zaimplementowany od podstaw w czystym MATLAB-ie w `lib/` (100% jawny kod DSP). |
| **Modulacja i szum** | Pomijanie wpływu konstelacji danych. | **Badanie zjawiska *noise enhancement*** przy dzieleniu ZF dla MCS 0, 3 i 7 (scenariusz E3) oraz wyznaczenie granicy zysku integracji. |
| **Luka podnośnych DC** | Pomijana lub rozważana dla 1 nośnej w 802.11a. | **Adaptacyjna interpolacja DC** dla 1 podnośnej (802.11a) oraz poszerzonej luki 3 podnośnych (802.11ax), zapobiegająca wyciekowi widmowemu. |
| **Środowisko clutteru** | Uproszczone kanały syntetyczne AWGN. | **Weryfikacja w znormalizowanych modelach TGax Model-B oraz Model-D** z realistycznym profilem opóźnień i clutterem wewnątrzbudynkowym. |
| **Wielocelowość i dynamika** | Zwykłe progowanie CFAR. | **Implementacja algorytmu Coherent CLEAN**, pozwalającego odkryć słabe cele ($-30\,\text{dB}$) zamaskowane przez dominujące obiekty. |
| **Relacja do 802.11bf** | Sensing kooperacyjny (protokołowy ISAC). | **Pasywny odbiór oportunistyczny** – radar działa całkowicie potajemnie/niezależnie, podsłuchując zwykłe pakiety danych telekomunikacyjnych. |

---

## 5. Podsumowanie matematyczne w 3 zdaniach

1. **Eliminacja danych (Zero-Forcing):** Poprzez dzielenie odebranych symboli podnośnych przez symbole nadane ($H = Y/X$) usuwam modulację losowych danych telekomunikacyjnych, sprowadzając działanie radaru do czystej estymacji transmitancji kanału radiowego.
2. **Filtracja i kompresja (MTI + 2D FFT):** Po odjęciu wartości średniej w czasie wolnym w celu wycięcia nieruchomych ścian i przesłuchu bezpośredniego (filtr MTI), wykonuję dwuwymiarową transformację Fouriera — gdzie IFFT wzdłuż podnośnych wyznacza odległość do celu, a FFT wzdłuż kolejnych symboli wyznacza jego przesunięcie Dopplera i prędkość.
3. **Dekonwolucja wielocelowa (Coherent CLEAN):** Na wygenerowanej mapie Range–Doppler stosuję iteracyjny algorytm Coherent CLEAN, który lokalizuje dominujące piki i koherentnie odejmuje ich analityczne listki boczne (z uwzględnieniem okna Blackmana–Harrisa), odsłaniając słabsze cele wcześniej zamaskowane przez silne obiekty.
