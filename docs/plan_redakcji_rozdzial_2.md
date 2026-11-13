# Plan Redakcji Rozdziału 2: Podstawy teoretyczne pasywnego radaru OFDM Wi-Fi

Dokument stanowi kompletny, śledzony plan pisania **Rozdziału 2** pracy dyplomowej (plik źródłowy: [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex)). Zawiera rygorystyczne wytyczne objętościowe, uzasadnienie bibliograficzne, plan akapitów, gotowe wzory matematyczne, listę cięć oraz powiązania z kodem symulatora ([`lib/`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/)) i eksperymentami badawczymi E1–E5 w Rozdziale 4.

---

## 1. Tablica Śledzenia Postępów Redakcji

| Podrozdział | Tytuł roboczy / docelowy | Limit stron | Rysunki / Tabele | Równania | Status redakcji | Status weryfikacji |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: |
| **2.1** | Warstwa fizyczna standardu IEEE 802.11 | 1,5 str. | 1 rys. + 1 tab. | 0 | [x] **Zrealizowany** | [x] Zweryfikowany |
| **2.2** | Model matematyczny sygnału OFDM | 1,2–1,5 str. | 0 rys. | 3 | [x] **Zrealizowany** | [x] Zweryfikowany |
| **2.3** | Geometria pomiarowa i parametry radaru (układ współlokowany/monostatyczny) | 1,5 str. | 0 rys. | 5–6 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.4** | Estymacja częstotliwościowej odpowiedzi kanału (CFR) | 2,0 str. | 1 tab. | 4 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.5** | Tłumienie ech stałych i kompensacja luki DC | 1,5 str. | 0 rys. | 3 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.6** | Wyznaczanie mapy Range–Doppler (RDM) | 1,5 str. | 1 tab. | 4 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.7** | Detekcja progowa i iteracyjna ekstrakcja celów (algorytm Coherent CLEAN) | 1,5 str. | 0 rys. | 4 | [ ] Do napisania | [ ] Do weryfikacji |
| **SUMA** | **Rozdział 2 (całość)** | **10,0–11,5 str.** | **1 rys., 3 tab.** | **~24** | **Postęp: 2/7 (29%)** | **W toku** |

---

## 2. Kluczowe Zasady i Dyscyplina Objętościowa

### 2.1. Przestroga z prac referencyjnych (analiza błędów)
W analizowanych pracach dyplomowych z katalogu `references/TZ/` widoczny jest typowy błąd zaburzenia proporcji pracy:
* **Praca K. Szwej (2024):** Teoria radaru i standardu DVB-T2 zajęła aż **33 strony** (str. 5–37), a symulacje tylko **12 stron** (str. 38–49). Autorka szczegółowo opisała kodowanie wideo MPEG/HEVC, kody LDPC/BCH, przeplot bitowy i 8 wariantów pilotów PP1–PP8, mimo że symulator w ogóle z nich nie korzystał.
* **Praca W. Sorbiana (2024):** Wprowadziła obszerne rysy historyczne od 1904 roku oraz archiwalne warstwy fizyczne 802.11 (podczerwień IR, FHSS, DSSS z 802.11b).

### 2.2. Złota Zasada Selekcji Treści
> [!IMPORTANT]
> **Kryterium bezwzględne:** W Rozdziale 2 umieszczamy wyłącznie te pojęcia, wzory i zjawiska fizyczne, które:
> 1. Mają bezpośrednią reprezentację w kodzie symulatora w katalogu [`lib/`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/), **LUB**
> 2. Stanowią aparat pojęciowy niezbędny do interpretacji wyników eksperymentów **E1–E5** w Rozdziale 4.
> 
> Wszelkie inne właściwości standardu Wi-Fi (warstwa MAC, ramki Beacon/ACK, szyfrowanie WPA, kody korekcyjne LDPC, przeplot) pomijamy całkowicie lub ucinamy do jednego zdania wyjaśniającego, dlaczego radar ich nie potrzebuje.

### 2.3. Szablon 3-Krokowy Każdego Podrozdziału
Każdą z sekcji 2.2–2.7 należy redagować ściśle według poniższego schematu inżynierskiego:
1. **Problem fizyczny i cel w torze radarowym** (1 zwięzły akapit: dlaczego dany etap przetwarzania jest konieczny i jakie wyzwanie rozwiązuje).
2. **Model matematyczny** (1–4 zwarte równania o ujednoliconych oznaczeniach, bez wyprowadzania podręcznikowych tożsamości od zera, z pełnym objaśnieniem każdego symbolu).
3. **Most do symulacji i badań** (1 akapit zamykający: wskazanie funkcji w `lib/` oraz bezpośrednia zapowiedź zjawiska badanego w eksperymentach E1–E5 w Rozdziale 4).

### 2.4. Bezwzględna zasada pisania bez skrótów myślowych (Explicite Engineering Writing)
> [!CAUTION]
> **Zakaz skrótów myślowych:** Tekst pracy inżynierskiej musi charakteryzować się pełną ciągłością logiczną i przyczynowo-skutkową (wynikowością). Czytelnik nie może domyślać się genezy wzorów ani intencji autora:
> 1. **Każdy czynnik i stała liczbowa we wzorze musi być wyjaśniona fizycznie lub statystycznie:**
>    - Dlaczego we wzorze na zasięg $R = c\tau/2$ oraz rozdzielczość $\Delta R = c/(2B)$ występuje mianownik $2$? Bo fala pokonuje drogę dwudrożną (do celu i z powrotem).
>    - Dlaczego w maksymalnej prędkości $v_{\max} = c/(4 f_c T_{\mathrm{sym}})$ w mianowniku pojawia się $4$, a nie $2$? Ponieważ twierdzenie Nyquista wymaga $f_D \le 1/(2 T_{\mathrm{sym}})$, a przesunięcie Dopplera wynosi $f_D = 2 v f_c / c$; stąd $2 v_{\max} f_c / c = 1/(2 T_{\mathrm{sym}}) \implies v_{\max} = c / (4 f_c T_{\mathrm{sym}})$. Całkowita szerokość jednoznacznego pasma prędkości wynosi wówczas $v_{\text{unamb}} = 2 v_{\max} = c / (2 f_c T_{\mathrm{sym}})$.
>    - Dlaczego w estymatorze MAD pojawia się czynnik $0{,}6745$ (lub mnożnik $1{,}4826$)? Bo jest to normalizator skali przekształcający medianę odchyleń bezwzględnych na odchylenie standardowe $\sigma$ dla rozkładu normalnego/Rayleigha.
> 2. **Niedopuszczalne zwroty uogólniające:** Zakaz stosowania zwrotów w stylu: *„jak łatwo zauważyć”*, *„z oczywistych względów”*, *„co wynika samo przez się”*, *„jak powszechnie wiadomo”*. Każde stwierdzenie ma opierać się na dowodzie, wyprowadzeniu lub konkretnym cytowaniu z literatury (`\cite{...}`).
> 3. **Ciągłość operacji DSP:** Każde przekształcenie macierzowe musi wskazywać: wymiar wejściowy $\to$ działanie operatora $\to$ wymiar wyjściowy $\to$ fizyczne znaczenie osi po transformacji.

---

## 3. Zestawienie Tytułów i Uzasadnienie w Literaturze

| Nr | Tytuł w szablonie LaTeX | Rekomendowany tytuł w pracy | Kluczowe źródła bibliograficzne ([`thesis/bibliography.bib`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/bibliography.bib)) | Uzasadnienie w tekście, cel inżynierski i most badawczy |
| :---: | :--- | :--- | :--- | :--- |
| **2.1** | `Warstwa fizyczna standardu IEEE 802.11` | *jw.* | `1999`, `2021`, `colone2014`, `storrer2021`, `sorbianWykorzystanieSieciWifi2025`, `wypich2026` | Struktura ramki PPDU (preambuła L-STF/L-LTF vs. DATA), alokacja podnośnych (52 w 802.11a vs. 242 w 802.11ax), podnośne zerowe DC i pasma ochronne. |
| **2.2** | `Modulacja OFDM` | **Model matematyczny sygnału OFDM** | `braun2014` (rozdz. 3.1, 3.6.1), Szwej (rozdz. 3.2), Sorbian (rozdz. 2.3) | Ortogonalność podnośnych $\Delta f = 1/T_u$, synteza IFFT/FFT, prefiks cykliczny $T_{\text{CP}} \ge \tau_{\max}$, zamiana splotu liniowego na kołowy (baza pod 2.4). |
| **2.3** | `Podstawy radaru pasywnego` | **Geometria pomiarowa i parametry radaru: konfiguracja współlokowana (monostatyczna)** | `braun2014` (rozdz. 3.2, 3.6.1), `colone2014`, Szwej (rozdz. 2.1–2.2), Sorbian (rozdz. 1.1–1.2) | Redukcja z układu bistatycznego ($L_B \to 0, \beta \to 0^\circ$) do układu współlokowanego (Wi-Fi Sensing / ISAC); znany sygnał referencyjny bez szumu toru odniesienia; model kanału $h(\tau, t)$; analityczne wyprowadzenie $\Delta R, R_{\max}, \Delta v, v_{\max}, v_{\text{unamb}}$. **Podstawa teoretyczna pod Eksperyment E1 (szerokość pasma a $\Delta R$) oraz E2 (czas symbolu a aliasing $v_{\max}$).** |
| **2.4** | `Estymacja kanału` | **Estymacja częstotliwościowej odpowiedzi kanału (CFR)** | `braun2014` (rozdz. 3.2, 3.5, App. A), `diseglioReducingComputationalComplexity2022`, `wypich2026` | Odejście od CAF na rzecz estymacji w dziedzinie podnośnych; estymatory Zero-Forcing (ZF) i Matched Filter (MF); analityczne zjawisko *noise enhancement* $\zeta_{\mathrm{ZF}} = \mathbb{E}[\|X\|^2]\mathbb{E}[1/\|X\|^2]$ dla konstelacji QAM. **Podstawa teoretyczna pod Eksperyment E3 (wpływ MCS 0..11 na szum i PNFR).** |
| **2.5** | `Filtracja ech stałych` | **Tłumienie ech stałych i kompensacja luki DC** | `braun2014` (rozdz. 3.3.8 – *Influence of DC carrier*), `diseglioReducingComputationalComplexity2022`, `colone2014` | Tłumienie DPI i celów stacjonarnych w czasie wolnym (filtr MTI rzędu 0 / odjęcie średniej); mechanizm powstawania listków bocznych przez lukę DC i jej interpolacja liniowa. **Podstawa teoretyczna pod Eksperyment E4 (tłumienie DPI i clutteru wielodrożnego TGax).** |
| **2.6** | `Wyznaczanie mapy Range–Doppler` | **Wyznaczanie mapy odległość–prędkość (Range–Doppler)** | `braun2014` (rozdz. 3.3.1–3.3.4, tab. 3.2 i 3.3), `wypich2026`, Szwej (rozdz. 2.3, 5) | Dwuwymiarowy periodogram (IFFT po $k$, FFT po $l$), zysk przetwarzania koherentnego $G_p = 10\log_{10}(KM)$, dobór okna Blackmana-Harrisa (PSLL = -92 dB) eliminującego fałszywe alarmy kosztem straty SNR $\approx 3\ \text{dB}$. |
| **2.7** | `Detekcja i ekstrakcja celów` | **Detekcja progowa i iteracyjna ekstrakcja celów (algorytm Coherent CLEAN)** | `braun2014` (rozdz. 3.3.6, 3.3.7 – *Coherent Cancellation*), `wypich2026` | Ograniczenia progowania globalnego i zjawisko maskowania celów w CA-CFAR; odporna estymacja szumu tła (MAD); algorytm Coherent CLEAN (iteracyjna dekompozycja i koherentne odejmowanie piku); metryka kontrastu PNFR. **Podstawa teoretyczna pod Eksperyment E5 (odsłanianie pieszego przy dynamice >30 dB).** |

---

## 4. Szczegółowy Plan Redakcji Podrozdziałów (Krok po Kroku)

### Podrozdział 2.1: Warstwa fizyczna standardu IEEE 802.11
- [x] **Status:** Napisany w całości w pliku [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L16-L70).
- **Objętość:** ~1,5 strony.
- **Zrealizowana zawartość:**
  - Tabela `tab:wifi_params`: Zestawienie 802.11a (Non-HT) vs. 802.11ax (HE-SU, 20 MHz).
  - Rysunek `fig:subcarrier_allocation`: Widmo podnośnych (dane, piloty, pasma ochronne, luka DC).
  - Opis podziału ramki PPDU (preambuła vs. pole DATA) i uzasadnienie wykorzystania pola danych (za Wypich & Zieliński 2026).
  - Wykaz bezpośrednich konsekwencji alokacji podnośnych dla parametrów radaru.

---

### Podrozdział 2.2: Model matematyczny sygnału OFDM
- [x] **Status:** Napisany w całości w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L72-L111).
- **Docelowa objętość:** 1,2–1,5 strony (~450 słów).
- **Budżet:** 3 równania, 0 rysunków.
- **Zrealizowana zawartość:**
  - Akapit 1: Definicja ortogonalności $\Delta f = 1/T_u$ i równanie sygnału ciągłego $s_l(t)$ pasma podstawowego.
  - Akapit 2: Dyskretna postać IFFT $s[n,l]$, definicja $T_{\mathrm{sym}} = T_u + T_{\mathrm{CP}}$ oraz dowód zamiany splotu liniowego na splot kołowy dzięki prefiksowi cyklicznemu.
  - Akapit 3: Właściwości symboli $X[k,l]$ — stała energia w preambule/pilotach ($|X|=1$) vs. zmienna energia w konstelacjach QAM pola danych.

---

### Podrozdział 2.3: Geometria pomiarowa i parametry radaru: konfiguracja współlokowana (monostatyczna)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L112).
- **Docelowa objętość:** 1,5 strony (~500 słów).
- **Budżet:** 5–6 równań, 0 rysunków.
- **Plan akapitów (z zachowaniem wynikowości i bez skrótów myślowych):**
  - [ ] **Akapit 1: Od układu bistatycznego do konfiguracji współlokowanej (monostatycznej).**
    - Wyjaśnienie: W dalekosiężnych radarach PBR (iluminatory FM/DVB-T) nadajnik Tx i odbiornik Rx dzieli duża odległość bazowa $L_B$, co wymusza dedykowany kanał referencyjny z anteną kierunkową skierowaną na nadajnik i prowadzi do skomplikowanej geometrii eliptycznej.
    - W radarze Wi-Fi oraz systemach ISAC/JCAS (*Braun 2014, Colone 2014, Wypich & Zieliński 2026*): odbiornik radarowy jest **współlokowany z punktem dostępowym Wi-Fi** (wspólna obudowa, te same oscylatory) lub odległość do celów wielokrotnie przewyższa rozstaw anten ($R \gg L_B$, przybliżenie quasi-monostatyczne).
    - Bezpośrednie konsekwencje inżynierskie: baza $L_B \to 0$ oraz kąt bistatyczny $\beta \to 0^\circ$. Wektor symboli referencyjnych $X[k,l]$ jest znany bezpośrednio z pamięci nadajnika (lub idealnej lokalnej demodulacji), co eliminuje szum toru odniesienia oraz zniekształcenia geometrii bistatycznej.
  - [ ] **Akapit 2: Model kanału wielodrogowego w konfiguracji współlokowanej.**
    - Dwudrożne opóźnienie echa dla odległości radialnej $R_p$: $\tau_p = \frac{2 R_p}{c}$ (czynnik 2 wynika z propagacji fali tam i z powrotem), stąd zależność pomiarowa: $R_p = \frac{c \tau_p}{2}$.
    - Przesunięcie Dopplera dla prędkości radialnej $v_p$: $f_{D,p} = \frac{2 v_p f_c}{c} = \frac{2 v_p}{\lambda}$.
    - Czasowo-zmienna odpowiedź impulsowa kanału w obecności przesłuchu bezpośredniego (DPI) i $P$ celów ruchomych:
      $$h(\tau, t) = A_{\mathrm{DPI}} \delta(\tau) + \sum_{p=1}^P A_p e^{j 2\pi f_{D,p} t} \delta(\tau - \tau_p)$$
      gdzie przesłuch bezpośredni (DPI) między anteną nadawczą a odbiorczą pojawia się przy opóźnieniu zerowym $\tau = 0$ i zerowym przesunięciu Dopplera ($f_D = 0$).
  - [ ] **Akapit 3: Parametry siatki czas–częstotliwość i granice jednoznaczności.**
    - Pełne wyprowadzenie 5 parametrów, w 100% zgodnych z kodem [`lib/calculate_physical_axes.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/calculate_physical_axes.m):
      1. Rozdzielczość odległościowa: $\Delta R = \frac{c}{2 B_{\mathrm{act}}}$ (dla pasma aktywnego $B_{\mathrm{act}} = K_{\mathrm{act}} \Delta f$).
      2. Maksymalny zasięg jednoznaczny: $R_{\max} = \frac{c}{2 \Delta f}$ (wynikający z próbkowania widma co $\Delta f$).
      3. Rozdzielczość prędkości radialnej: $\Delta v = \frac{\lambda}{2 T_{\mathrm{CPI}}} = \frac{c}{2 f_c M T_{\mathrm{sym}}}$ (gdzie $M$ to liczba symboli w ramce CPI, $T_{\mathrm{CPI}} = M T_{\mathrm{sym}}$).
      4. Pełna szerokość jednoznacznego okna prędkości: $v_{\text{unamb}} = \frac{\lambda}{2 T_{\mathrm{sym}}} = \frac{c}{2 f_c T_{\mathrm{sym}}}$ (wynikająca z twierdzenia Nyquista dla próbkowania w czasie wolnym z krokiem $T_{\mathrm{sym}}$: $|f_D| \le \frac{1}{2 T_{\mathrm{sym}}}$).
      5. Maksymalna mierzalna prędkość radialna (symetryczna): $v_{\max} = \frac{v_{\text{unamb}}}{2} = \frac{c}{4 f_c T_{\mathrm{sym}}}$, odpowiadająca przedziałowi jednoznaczności $v \in [-v_{\max}, +v_{\max}]$.
    - Porównanie parametrów dla 802.11a ($\Delta R \approx 8{,}9\ \text{m}$, $v_{\max} \approx 34{,}1\ \text{m/s}$ przy $v_{\text{unamb}} \approx 68{,}2\ \text{m/s}$) oraz 802.11ax ($\Delta R \approx 7{,}8\ \text{m}$, $v_{\max} \approx 10{,}0\ \text{m/s}$ przy $v_{\text{unamb}} \approx 20{,}0\ \text{m/s}$).
  - [ ] **Akapit 4: Most do symulacji i badań.**
    - Wskazanie, że wyznaczone relacje stanowią podstawę implementacji osi w [`lib/calculate_physical_axes.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/calculate_physical_axes.m) oraz są bezpośrednio weryfikowane eksperymentalnie w:
      - **Eksperymencie E1 (Rozdział 4):** badanie skalowania rozdzielczości $\Delta R$ dla pasm $B \in \{20, 40, 80, 160\}\ \text{MHz}$ (Rys. 4.1),
      - **Eksperymencie E2 (Rozdział 4):** weryfikacja zawijania widma Dopplera (aliasingu prędkości) przy przekroczeniu $v_{\max}$ dla 802.11a vs 802.11ax (Rys. 4.2).
- **Czego NIE pisać:**
  - Nie opisywać historii radaru (Hülsmeyer, Watson-Watt).
  - Nie wyprowadzać ogólnego równania radiolokacji z zyskami anten i całkowaniem po kącie bryłowym.
  - Nie rysować trójkątów bistatycznych ani nie wyprowadzać równań elips bistatycznych.

---

### Podrozdział 2.4: Estymacja częstotliwościowej odpowiedzi kanału (CFR)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L115).
- **Docelowa objętość:** 2,0 strony (~600 słów).
- **Budżet:** 4 równania, 1 tabela porównawcza (ZF vs. MF).
- **Plan akapitów (z zachowaniem wynikowości i bez skrótów myślowych):**
  - [ ] **Akapit 1: Model odebranej macierzy podnośnych.**
    - Po usunięciu prefiksu cyklicznego CP i wykonaniu FFT w odbiorniku (zgodnie z dowiedzioną w 2.2 własnością splotu kołowego), sygnał w dziedzinie częstotliwości przyjmuje postać macierzy $Y[k,l]$ dla $k \in \mathcal{K}_{\mathrm{act}}$ oraz $l = 0, \dots, M-1$:
      $$Y[k,l] = H[k,l] X[k,l] + W[k,l]$$
      gdzie $X[k,l]$ to zdemodulowane symbole odniesienia, $H[k,l]$ to poszukiwana częstotliwościowa odpowiedź kanału (CFR), a $W[k,l]$ to addytywny szum Gaussa (AWGN) o wariancji $\sigma_W^2$.
  - [ ] **Akapit 2: Paradygmat dziedziny podnośnych (CFR) a funkcja niejednoznaczności (CAF).**
    - Porównanie z klasycznym radarem pasywnym wyznaczającym wzajemną funkcję niejednoznaczności (CAF) w czasie ciągłym przez dwuwymiarową korelację.
    - W radarze OFDM estymacja w dziedzinie podnośnych eliminuje modulację losowych danych bezpośrednio na macierzy $K \times M$, co radykalnie obniża złożoność obliczeniową z $O(N^2)$ do $O(K M \log(K M))$ oraz usuwa wysokie listki boczne autokorelacji sygnału komunikacyjnego (*Braun 2014, Di Seglio et al. 2022*).
  - [ ] **Akapit 3: Estymatory Zero-Forcing (ZF) oraz Matched Filter (MF).**
    - Estymator Zero-Forcing (filtr odwrotny ze współczynnikiem regularyzacji $\varepsilon = 10^{-9}$ dla stabilności numerycznej):
      $$\hat{H}_{\mathrm{ZF}}[k,l] = \frac{Y[k,l]}{X[k,l] + \varepsilon} = H[k,l] + \frac{W[k,l]}{X[k,l] + \varepsilon}$$
    - Estymator Matched Filter (korelator częstotliwościowy):
      $$\hat{H}_{\mathrm{MF}}[k,l] = Y[k,l] X^*[k,l] = H[k,l] |X[k,l]|^2 + W[k,l] X^*[k,l]$$
  - [ ] **Akapit 4: Zjawisko wzmocnienia szumu (Noise Enhancement) dla modulacji QAM.**
    - Wyjaśnienie bez skrótów myślowych: Wariancja szumu resztkowego w estymatorze ZF zależy od energii punktu konstelacji: $\sigma^2_{\mathrm{ZF}}[k,l] = \sigma_W^2 / |X[k,l]|^2$.
    - W preambule (BPSK) $|X|^2 = 1$ — estymatory ZF i MF są tożsame co do modułu.
    - W polu danych przy modulacjach wielopoziomowych (16-QAM, 64-QAM, 1024-QAM) wewnętrzne punkty konstelacji mają energię wielokrotnie mniejszą od jedności ($|X|^2 \ll 1$). Dzielenie przez małą amplitudę powoduje gwałtowny wzrost wariancji szumu.
    - Wyprowadzenie współczynnika degradacji szumowej Zero-Forcing:
      $$\zeta_{\mathrm{ZF}} = \mathbb{E}\left[|X|^2\right] \cdot \mathbb{E}\left[\frac{1}{|X|^2}\right], \quad \zeta_{\mathrm{ZF}}\,[\text{dB}] = 10 \log_{10} \zeta_{\mathrm{ZF}}$$
      który dla BPSK/QPSK wynosi $0\ \text{dB}$, a dla 64-QAM i 1024-QAM rośnie do wartości degradujących kontrast detekcji.
  - [ ] **Akapit 5: Most do symulacji i badań.**
    - Algorytm estymacji ZF oraz obliczanie współczynnika $\zeta_{\mathrm{ZF}}$ zaimplementowano w [`lib/estimate_channel_zf.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/estimate_channel_zf.m).
    - Analityczna zależność współczynnika $\zeta_{\mathrm{ZF}}$ oraz degradacja kontrastu PNFR w funkcji rzędu modulacji MCS 0..11 jest przedmiotem badań w **Eksperymencie E3 (Rozdział 4, Rys. 4.3)**.
- **Tabela:** Porównanie cech ZF i MF (odporność na szum, zachowanie dla BPSK vs 64-QAM/1024-QAM, złożoność).
- **Czego NIE pisać:** Nie wyprowadzać estymatorów LMMSE (brak estymacji macierzy kowariancji w odbiorniku).

---

### Podrozdział 2.5: Tłumienie ech stałych i kompensacja luki DC
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L118).
- **Docelowa objętość:** 1,5 strony (~450 słów).
- **Budżet:** 3 równania, 0 rysunków.
- **Plan akapitów (z zachowaniem wynikowości i bez skrótów myślowych):**
  - [ ] **Akapit 1: Problem przesłuchu bezpośredniego (DPI) i tła stacjonarnego.**
    - Wyjaśnienie fizyczne: Sygnał bezpośredni z nadajnika do odbiornika (DPI) oraz stacjonarne odbicia od ścian/mebli przewyższają moc echa małego celu ruchomego o 40–80 dB.
    - Z powodu skończonego czasu obserwacji $T_{\mathrm{CPI}}$ listki boczne transformaty Fouriera dla częstotliwości Dopplera $f_D = 0$ rozlewają się wzdłuż całej osi prędkości, całkowicie maskując obiekty ruchome.
  - [ ] **Akapit 2: Filtracja MTI w dziedzinie czasu wolnego.**
    - W architekturze radaru OFDM filtrację realizuje się bezpośrednio na wyestymowanej macierzy $\hat{H}[k,l]$ wzdłuż wymiaru symboli $l$ (czasu wolnego), przed wykonaniem kompresji odległościowej (*Di Seglio 2022*).
    - Filtr MTI rzędu zerowego (odjęcie wartości średniej po czasie wolnym dla każdej podnośnej niezależnie):
      $$\tilde{H}_{\mathrm{MTI}}[k,l] = \hat{H}[k,l] - \frac{1}{M} \sum_{m=0}^{M-1} \hat{H}[k,m]$$
    - Właściwość: operacja ta idealnie usuwa składowe o zerowym przesunięciu Dopplera ($f_D = 0$), zachowując nienaruszone przesunięcia fazowe celów ruchomych ($f_D \ne 0$).
  - [ ] **Akapit 3: Mechanizm powstawania listków bocznych przez lukę DC i jej interpolacja.**
    - Mechanizm fizyczny (*Braun 2014, rozdz. 3.3.8*): Brak transmisji na podnośnej centralnej $k=0$ (oraz $k=\pm 1$ w 802.11ax) odpowiada wymnożeniu idealnego widma przez funkcję maskującą z wyciętym środkiem. W dziedzinie odległości (po IFFT) odpowiada to splotowi profilu celu z funkcją tworzącą wysoką, stałą podłogę listków bocznych (*range spur floor*), pogarszającą kontrast detekcji.
    - Algorytm naprawy: Liniowa interpolacja brakujących podnośnych DC z sąsiednich aktywnych prążków przed kompresją IFFT:
      - Dla 802.11a (pojedyncza podnośna $k_{\mathrm{DC}}$):
        $$\tilde{H}[k_{\mathrm{DC}}, l] = \frac{\tilde{H}[k_{\mathrm{DC}}-1, l] + \tilde{H}[k_{\mathrm{DC}}+1, l]}{2}$$
      - Dla 802.11ax (luka o szerokości $G=3$ podnośnych $g \in \{1, \dots, G\}$ między lewą $k_L$ a prawą $k_R$ podnośną aktywną):
        $$\tilde{H}[k_L + g, l] = \tilde{H}[k_L, l] + \frac{g}{G+1} \left( \tilde{H}[k_R, l] - \tilde{H}[k_L, l] \right)$$
  - [ ] **Akapit 4: Most do symulacji i badań.**
    - Obie operacje zaimplementowano w [`lib/estimate_channel_zf.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/estimate_channel_zf.m).
    - Skuteczność wycinania przesłuchu DPI oraz clutteru stacjonarnego dla realistycznych modeli propagacyjnych TGax (Model-A, Model-C, Model-E) jest przedmiotem **Eksperymentu E4 (Rozdział 4, Rys. 4.4)**.
- **Czego NIE pisać:** Nie opisywać filtrów adaptacyjnych czasu ciągłego na surowych próbkach IQ (ECA, ECA-B, LMS).

---

### Podrozdział 2.6: Wyznaczanie mapy odległość–prędkość (Range–Doppler)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L121).
- **Docelowa objętość:** 1,5 strony (~450 słów).
- **Budżet:** 4 równania, 1 tabela parametrów okien wagowych.
- **Plan akapitów (z zachowaniem wynikowości i bez skrótów myślowych):**
  - [ ] **Akapit 1: Dwuwymiarowa transformata Fouriera (2D Periodogram).**
    - Przejście od skondycjonowanej macierzy CFR $\tilde{H}[k,l]$ o rozmiarze $K \times M$ do zespolonej mapy Range–Doppler $\text{CPer}(r, d)$:
      $$\text{CPer}(r, d) = \sum_{l=0}^{M-1} \left( \sum_{k=0}^{K-1} \tilde{H}[k,l] W[k,l] e^{j 2\pi \frac{k r}{N_{\mathrm{per}}}} \right) e^{-j 2\pi \frac{l d}{M_{\mathrm{per}}}}$$
      gdzie $N_{\mathrm{per}} = \xi_r N_{\mathrm{FFT}}$, $M_{\mathrm{per}} = \xi_d M$ to wymiary siatki po dopełnieniu zerami (ang. *zero-padding*, współczynnik $\xi_r = \xi_d = 4$).
    - Wyjaśnienie znaków: IFFT ze znakiem plus po osi częstotliwości $k$ (odwzorowanie opóźnienia/odległości $\tau \to r$) oraz FFT ze znakiem minus po osi czasu wolnego $l$ (odwzorowanie przesunięcia Dopplera $f_D \to d$).
    - Zysk przetwarzania koherentnego: $G_p = 10 \log_{10}(K \cdot M)\ \text{dB}$.
    - Moc periodogramu w skali logarytmicznej: $P(r, d) = 10 \log_{10} \left( \frac{1}{K M} |\text{CPer}(r, d)|^2 \right)\ \text{dB}$.
  - [ ] **Akapit 2: Przeciek widmowy i dobór okna separowalnego 2D.**
    - Okno separowalne $W[k,l] = w_r[k] \cdot w_d[l]$.
    - Konsekwencje okna prostokątnego: wysokie listki boczne (PSLL = $-13{,}3\ \text{dB}$), które maskują małe obiekty ruchome i generują fałszywe alarmy.
    - Zastosowanie 4-wyrazowego okna Blackmana-Harrisa:
      $$w[n] = a_0 - a_1 \cos\left(\frac{2\pi n}{N-1}\right) + a_2 \cos\left(\frac{4\pi n}{N-1}\right) - a_3 \cos\left(\frac{6\pi n}{N-1}\right)$$
      ze współczynnikami $a_0 = 0{,}35875$, $a_1 = 0{,}48829$, $a_2 = 0{,}14128$, $a_3 = 0{,}01168$, zapewniającego tłumienie listków bocznych na poziomie $-92\ \text{dB}$.
  - [ ] **Akapit 3: Trójstronny kompromis okienkowania.**
    - Analiza kompromisu: tłumienie listków bocznych (PSLL) vs. poszerzenie listka głównego o współczynnik rozmycia (spadek rozdzielczości z $1{,}0$ do $1{,}90$ binu) vs. strata przetwarzania koherentnego (ang. *processing loss* $\approx 3{,}0\ \text{dB}$).
    - Uzasadnienie: w pasywnym radarze Wi-Fi priorytetem jest wysoka dynamika detekcji (nawet kosztem 3 dB SNR), co czyni okno Blackmana-Harrisa standardem w całym torze DSP symulatora.
  - [ ] **Akapit 4: Most do kodu symulatora.**
    - Wskazanie implementacji w funkcji [`lib/compute_range_doppler_map.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/compute_range_doppler_map.m).
- **Tabela:** Zestawienie okien (Rectangular, Hann, Hamming, Blackman-Harris): PSLL [dB], szerokość -3 dB [biny], strata przetwarzania [dB] (dane z Brauna tab. 3.2 i 3.3).
- **Czego NIE pisać:** Nie wyprowadzać algorytmów superrozdzielczych (MUSIC, ESPRIT).

---

### Podrozdział 2.7: Detekcja progowa i iteracyjna ekstrakcja celów (algorytm Coherent CLEAN)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L124).
- **Docelowa objętość:** 1,5 strony (~500 słów).
- **Budżet:** 4 równania, 0 rysunków.
- **Plan akapitów (z zachowaniem wynikowości i bez skrótów myślowych):**
  - [ ] **Akapit 1: Odporna estymacja tła szumowego metodą MAD i metryka PNFR.**
    - Problem: Na mapie RDM po filtracji MTI poziom tła szumowego nie jest jednorodny, a obecność silnych pików od celów uniemożliwia wyznaczenie progu ze zwykłej średniej arytmetycznej.
    - Zastosowanie odpornego estymatora dyspersji MAD (*Median Absolute Deviation*):
      $$\hat{\sigma} = \frac{\text{median}\left(|\text{CPer}(r,d)|\right)}{0{,}6745}$$
      Czynnik $0{,}6745$ wynika z faktu, że dla zespolonego szumu Gaussa moduł $|\text{CPer}|$ ma rozkład Rayleigha, a mediana tego rozkładu przypada dokładnie na $\sqrt{\ln(4)} \cdot \sigma / \sqrt{2} \approx 0{,}6745 \sigma$. Estymator ten jest w 100% odporny na obecność ostrych szczytów radarowych.
    - Definicja metryki kontrastu detekcji PNFR (*Peak-to-Noise-Floor Ratio*):
      $$\text{PNFR}_k = 10 \log_{10} \left( \frac{P_{\mathrm{peak}, k}}{P_{\mathrm{floor}}} \right) \quad [\text{dB}]$$
      gdzie $P_{\mathrm{floor}} = \frac{1}{|\Omega_{\mathrm{noise}}|} \sum_{(r,d) \in \Omega_{\mathrm{noise}}} P(r,d)$ jest średnią mocą szumu wyznaczoną poza strefami ochronnymi (ang. *guard boxes*) wszystkich wykrytych obiektów ([`lib/compute_pnfr.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/compute_pnfr.m)).
  - [ ] **Akapit 2: Ograniczenia progowania klasycznego (CA-CFAR) w scenariuszach bliskiego zasięgu.**
    - Wyjaśnienie bez skrótów myślowych: W klasycznym detektorze CA-CFAR okno trenujące przesuwa się po mapie. W obecności dwóch obiektów o dużej różnicy mocy (np. samochód o SNR = 40 dB i pieszy o SNR = 15 dB) energia silnego celu wpada do komórek trenujących słabszego obiektu, sztucznie podnosząc próg i powodując zjawisko **maskowania celu** (*target masking / capture effect*).
    - W radarze OFDM o ograniczonej liczbie podnośnych resztkowe listki boczne silnego celu (nawet stłumione oknem) mogą przewyższać moc użyteczną małego obiektu (*Braun 2014, rozdz. 3.3.7*).
  - [ ] **Akapit 3: Algorytm Coherent CLEAN (Successive Target Cancellation).**
    - Zasada działania algorytmu dekompozycji koherentnej:
      1. Detekcja globalnego maksimum na aktualnej mapie rezydualnej:
         $$(r_i, d_i) = \arg\max_{r,d} |\text{CPer}^{(i)}(r,d)|, \quad A_i = \text{CPer}^{(i)}(r_i, d_i)$$
      2. Kryterium zatrzymania: jeśli $|A_i| < T_{\mathrm{stop}} = \hat{\sigma} \cdot 10^{\mathrm{margin\_dB}/20}$ lub osiągnięto zadaną liczbę celów, algorytm kończy działanie.
      3. Analityczna rekonstrukcja odpowiedzi impulsowej pojedynczego celu punktowego z uwzględnieniem identycznego okna wagowego 2D: $\mathbf{S}_{\mathrm{point}, i} = \mathcal{F}_{\text{2D}} \{ \mathbf{P}(r_i, d_i) \odot \mathbf{W}_{\text{2D}} \}$.
      4. Koherentne odjęcie znormalizowanej repliki wraz z jej listkami bocznymi od mapy:
         $$\text{CPer}^{(i+1)}(r,d) = \text{CPer}^{(i)}(r,d) - A_i \cdot \frac{\mathbf{S}_{\mathrm{point}, i}(r,d)}{\mathbf{S}_{\mathrm{point}, i}(r_i, d_i)}$$
      5. Na oczyszczonej mapie rezydualnej $\text{CPer}^{(i+1)}$ odsłaniają się słabe obiekty, które w kolejnej iteracji mogą zostać wykryte bez zniekształceń.
  - [ ] **Akapit 4: Most do symulacji i badań.**
    - Implementacja algorytmu CLEAN znajduje się w [`lib/run_coherent_clean.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/run_coherent_clean.m) oraz w module interpretatora [`src/step4_interpreter.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/src/step4_interpreter.m).
    - Zdolność algorytmu do demaskowania słabego echa pieszego w obecności dominującego pojazdu (dynamika >30 dB) jest badana w **Eksperymencie E5 (Rozdział 4, Rys. 4.5)**.
- **Czego NIE pisać:** Nie opisywać rozbudowanych wariantów heurystycznych CFAR (OS/GO/SO/TM-CFAR) ani filtrów śledzenia wieloobiektowego (Kalman/JPDA) — radar operuje w pojedynczym oknie CPI.

---

## 5. Wytyczne redakcyjne, stylistyka i wymogi formalne (z plan_deliverables.md)

### 5.1. Stylistyka tekstu i język inżynierski
1. **Pisać „prosto z mostu”**: Unikać lania wody, ozdobników i rozwlekłych uogólnień typowych dla asystentów LLM. Każde zdanie ma wnosić konkretną informację techniczną, matematyczną lub fizyczną.
2. **Forma gramatyczna**: Opis prac własnych, implementacji i badań prowadzimy w **formie bezosobowej czasu przeszłego** (np. *„zaimplementowano”*, *„przeprowadzono”*, *„zbadano”*, *„wyznaczono”*, *„zastosowano”*), unikając formy pierwszoosobowej (*„zrobiłem”*, *„napisałem”*).
3. **Konkretne miary i odniesienia**: Aby rzetelnie ocenić wydajność toru radarowego, wszelkie parametry i wyniki odnosi się do pokrewnej literatury naukowej (Braun, Szwej, Sorbian, Wypich & Zieliński).
4. **Bezwzględny zakaz stosowania skrótów myślowych**: Każde przejście w wyprowadzeniach, każdy krok algorytmu i każde zjawisko fizyczne musi być wyjaśnione wprost (explicite), bez pozostawiania czytelnikowi domysłów. Niedopuszczalne są sformułowania w stylu: *„jak łatwo zauważyć”*, *„z oczywistych względów”*, *„co wynika samo przez się”*. Każde stałe i współczynniki liczbowe we wzorach muszą posiadać ścisłe uzasadnienie fizyczne lub statystyczne.

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
   - Wykresy złożone z podpaneli (`subplot`): `sgtitle('Główny tytuł wykresu', 'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none')`.
   - Wykresy jednopanelowe: `title('Tytuł wykresu', 'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none')`.
3. **Zasada minimalizmu i zakaz przeładowania tekstem na wykresie**:
   - Bezwzględny zakaz umieszczania na wykresach bloków tekstu czy ramek opisowych (`annotation('textbox')`).
   - Krótkie, techniczne tytuły podpaneli (np. `title('a) Przed MTI')`, `title('b) Po MTI')`).
   - Podpisy osi i etykiety paska kolorów: krótkie i precyzyjne z jednostką w nawiasie kwadratowym `[...]`.
   - Wszelkie objaśnienia i parametry scenariusza należą do tekstu rozdziału w LaTeX oraz podpisu pod rysunkiem (`\caption{...}`).
4. **100% język polski**: Tytuły, podpisy osi wraz z jednostkami w nawiasach kwadratowych `[...]`, etykiety pasków barwnych (`colorbar`) i legendy muszą być całkowicie w języku polskim.
5. **Eksport w wysokiej rozdzielczości**: Grafiki zapisywane funkcją `exportgraphics(fig, out_file, 'Resolution', 300)`.

### 5.4. Wytyczne uczelni dot. AI, stylometria i JSA
1. **Dozwolona rola narzędzi AI**: Zgodnie z wytycznymi uczelni narzędzia AI/LLM mogą być używane wyłącznie jako wsparcie techniczno-odtwórcze (*chores*: asysta w składzie LaTeX-a, sprawdzanie interpunkcji, drobne skrypty pomocnicze). Narzędzia AI **nie mogą być źródłem koncepcji merytorycznej (*concept*), tez ani wniosków badawczych**.
2. **Świadomość stylometrii i JSA**: Jednolity System Antyplagiatowy (JSA) analizuje jednorodność stylu tekstu. Tekst pracy musi być zredagowany spójnym, jednolitym, autorskim językiem inżynierskim. Zdania powinny być zwięzłe i przyczynowo-skutkowe.

### 5.5. Kwestie formalne jednostki i szablonu
1. **Szablon WIEiT**: Bezwzględnie stosować szablon wydziałowy WIEiT AGH (unikać ogólnych, niezgodnych wzorców uczelnianych z Overleafa).
2. **Nazwa jednostki**: Należy stosować aktualną nazwę instytutu — **Instytut Telekomunikacji i Cyberbezpieczeństwa** (pamiętać o uwzględnieniu Cyberbezpieczeństwa).

---

## 6. Checklista Weryfikacji Spójności Przed Zamknięciem Rozdziału 2

Przed uznaniem Rozdziału 2 za w pełni ukończony, należy zweryfikować poniższe punkty kontrolne:

- [ ] **Kompilacja LaTeX:** Brak błędów kompilacji XeLaTeX/BibTeX w pliku [`thesis/main.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/main.tex).
- [ ] **Spójność oznaczeń matematycznych:**
  - [ ] Indeks podnośnej: konsekwentnie $k \in \{0, \dots, N_{\mathrm{FFT}}-1\}$, zbiór aktywnych $\mathcal{K}_{\mathrm{act}}$ o liczności $K$.
  - [ ] Indeks symbolu (czas wolny): konsekwentnie $l \in \{0, \dots, M-1\}$.
  - [ ] Wymiary macierzy CFR: $K \times M$ lub $N_{\mathrm{FFT}} \times M$.
  - [ ] Transmitowane symbole: $X[k,l]$, odebrane: $Y[k,l]$, estymata transmitancji: $\hat{H}[k,l]$, po filtracji: $\tilde{H}[k,l]$.
  - [ ] Zespolona mapa Range–Doppler: $\text{CPer}(r, d)$, moc: $P(r, d)$.
  - [ ] Wymiary siatki po zero-paddingu: $N_{\mathrm{per}} = 4 N_{\mathrm{FFT}}$, $M_{\mathrm{per}} = 4 M$.
- [ ] **Cytowania w tekście:**
  - [ ] Wszystkie odsyłacze `\cite{...}` korzystają wyłącznie z istniejących kluczy z [`thesis/bibliography.bib`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/bibliography.bib) (`braun2014`, `sorbianWykorzystanieSieciWifi2025`, `storrer2021`, `colone2014`, `diseglioReducingComputationalComplexity2022`, `wypich2026`, `1999`, `2021`).
  - [ ] Brak znaków zapytania `[?]` w skompilowanym pliku PDF.
- [ ] **Etykiety i odsyłacze skrośne:**
  - [ ] Wszystkie podrozdziały posiadają unikalne etykiety `\label{subsec:...}`.
  - [ ] Wszystkie równania, tabele i rysunki są przywołane przynajmniej raz w tekście (`\ref{...}`).
  - [ ] Odsyłacze do przyszłych rozdziałów (Rozdział 3: Implementacja, Rozdział 4: Eksperymenty E1–E5) są poprawnie spięte.
- [ ] **Objętość i proporcje:**
  - [ ] Całkowita liczba stron Rozdziału 2 w PDF mieści się w przedziale **10,0–11,5 stron** (dokładnie 1 merytoryczny rysunek alokacji podnośnych + 3 tabele parametrów, 0 rysunków-zapychaczy).
  - [ ] Żaden podrozdział nie przekracza limitu 2 stron.
  - [ ] Treści z "listy zakazów" (MAC, kody korekcyjne, historia radaru, inne iluminatory, elipsy bistatyczne) nie przedostały się do tekstu.
