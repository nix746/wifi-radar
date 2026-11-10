# Plan Redakcji Rozdziału 2: Podstawy teoretyczne pasywnego radaru OFDM Wi-Fi

Dokument stanowi kompletny, śledzony plan pisania **Rozdziału 2** pracy dyplomowej (plik źródłowy: [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex)). Zawiera rygorystyczne wytyczne objętościowe, uzasadnienie bibliograficzne, plan akapitów, gotowe wzory matematyczne, listę cięć oraz powiązania z kodem symulatora ([`lib/`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/)) i eksperymentami badawczymi E1–E5 w Rozdziale 4.

---

## 1. Tablica Śledzenia Postępów Redakcji

| Podrozdział | Tytuł roboczy / docelowy | Limit stron | Rysunki / Tabele | Równania | Status redakcji | Status weryfikacji |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: |
| **2.1** | Warstwa fizyczna standardu IEEE 802.11 | 1,5 str. | 1 rys. + 1 tab. | 0 | [x] **Zrealizowany** | [x] Zweryfikowany |
| **2.2** | Model matematyczny sygnału OFDM | 1,2–1,5 str. | 0 rys. | 3 | [x] **Zrealizowany** | [x] Zweryfikowany |
| **2.3** | Geometria pomiarowa i parametry radaru (układ współlokowany/monostatyczny) | 1,5 str. | 0 rys. | 5 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.4** | Estymacja transmitancji kanału (CFR) | 2,0 str. | 1 tab. | 4 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.5** | Tłumienie ech stałych i kompensacja luki DC | 1,5 str. | 0 rys. | 3 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.6** | Wyznaczanie mapy Range–Doppler (RDM) | 1,5 str. | 1 tab. | 3 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.7** | Detekcja adaptacyjna CFAR i ekstrakcja celów | 1,5 str. | 0 rys. | 4 | [ ] Do napisania | [ ] Do weryfikacji |
| **SUMA** | **Rozdział 2 (całość)** | **10,0–11,5 str.** | **1 rys., 3 tab.** | **~22** | **Postęp: 2/7 (29%)** | **W toku** |

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
2. **Model matematyczny** (1–3 zwarte równania o ujednoliconych oznaczeniach, bez wyprowadzania podręcznikowych tożsamości od zera).
3. **Most do symulacji i badań** (1 akapit zamykający: wskazanie funkcji w `lib/` oraz zapowiedź zjawiska badanego w eksperymentach E1–E5 w Rozdziale 4).

---

## 3. Zestawienie Tytułów i Uzasadnienie w Literaturze

| Nr | Tytuł w szablonie LaTeX | Rekomendowany tytuł w pracy | Kluczowe źródła bibliograficzne ([`thesis/bibliography.bib`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/bibliography.bib)) | Uzasadnienie w tekście i cel inżynierski |
| :---: | :--- | :--- | :--- | :--- |
| **2.1** | `Warstwa fizyczna standardu IEEE 802.11` | *jw.* | `1999`, `2021`, `colone2014`, `storrer2021`, `sorbianWykorzystanieSieciWifi2025`, `wypich2026` | Struktura ramki PPDU (preambuła L-STF/L-LTF vs. DATA), alokacja podnośnych (52 w 802.11a vs. 242 w 802.11ax), podnośne zerowe DC i pasma ochronne. |
| **2.2** | `Modulacja OFDM` | **Model matematyczny sygnału OFDM** | `braun2014` (rozdz. 3.1, 3.6.1), Szwej (rozdz. 3.2), Sorbian (rozdz. 2.3) | Ortogonalność podnośnych $\Delta f = 1/T_u$, synteza IFFT/FFT, prefiks cykliczny $T_{\text{CP}} \ge \tau_{\max}$, zamiana splotu liniowego na kołowy. |
| **2.3** | `Podstawy radaru pasywnego` | **Geometria pomiarowa i parametry radaru: konfiguracja współlokowana (monostatyczna)** | `braun2014` (rozdz. 3.2, 3.6.1), `colone2014`, Szwej (rozdz. 2.1–2.2), Sorbian (rozdz. 1.1–1.2) | Redukcja z ogólnego przypadku bistatycznego ($L_B \to 0, \beta \to 0^\circ$) do układu współlokowanego (monostatycznego / ISAC); znany sygnał referencyjny bez szumu toru odniesienia; model kanału $h(\tau, t)$, rozdzielczości $\Delta R, \Delta v$ oraz granice jednoznaczności $R_{\max}, v_{\max}$ tożsame z implementacją w `lib/calculate_physical_axes.m`. |
| **2.4** | `Estymacja kanału` | **Estymacja częstotliwościowej odpowiedzi kanału (CFR)** | `braun2014` (rozdz. 3.2, 3.5, App. A), `diseglioReducingComputationalComplexity2022`, `wypich2026` | Odejście od CAF na rzecz estymacji w dziedzinie podnośnych; estymatory Zero-Forcing (ZF) i Matched Filter (MF); analiza zjawiska *noise enhancement* dla konstelacji QAM (podstawa pod **E3**). |
| **2.5** | `Filtracja ech stałych` | **Tłumienie ech stałych i kompensacja luki DC** | `braun2014` (rozdz. 3.3.8 – *Influence of DC carrier*), `diseglioReducingComputationalComplexity2022`, `colone2014` | Tłumienie DPI i celów stacjonarnych w czasie wolnym (filtr MTI / odjęcie średniej); analityczny wpływ luki DC na tło listków bocznych i jej interpolacja (podstawa pod **E1** i **E4**). |
| **2.6** | `Wyznaczanie mapy Range–Doppler` | **Wyznaczanie mapy odległość–prędkość (Range–Doppler)** | `braun2014` (rozdz. 3.3.1–3.3.4, tab. 3.2 i 3.3), `wypich2026`, Szwej (rozdz. 2.3, 5) | Dwuwymiarowy periodogram (IFFT po $k$, FFT po $l$), zysk przetwarzania $G_p = 10\log_{10}(KL)$, dobór okien wagowych (Blackman-Harris vs. Hamming) – kompromis PSLL vs. strata SNR (podstawa pod **E2**). |
| **2.7** | `Detekcja i ekstrakcja celów` | **Detekcja adaptacyjna CFAR i iteracyjna ekstrakcja celów (CLEAN)** | `braun2014` (rozdz. 3.3.6, 3.3.7 – *Coherent Cancellation*), Szwej (rozdz. 2.2) | Odporna estymacja tła szumowego (MAD), próg adaptacyjny 2D CA-CFAR, problem maskowania słabych celów przez listki boczne, algorytm Coherent CLEAN (podstawa pod **E5**). |

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
- [x] **Status:** Napisany w całości w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L72-L93).
- **Docelowa objętość:** 1,2–1,5 strony (~400–500 słów).
- **Budżet:** 3 równania, 0 rysunków.
- **Plan akapitów:**
  - [x] **Akapit 1: Idea ortogonalności i równanie sygnału ciągłego.**
    - Definicja odstępu podnośnych $\Delta f = 1/T_u$ gwarantującego zerowanie się interferencji międzykanałowej (ICI).
    - Równanie transmitowanego $l$-tego symbolu OFDM w pasmie podstawowym:
      $$s_l(t) = \frac{1}{\sqrt{N_{\mathrm{FFT}}}} \sum_{k \in \mathcal{K}_{\mathrm{act}}} X[k,l] e^{j 2\pi k \Delta f (t - T_{\mathrm{CP}})}, \quad t \in [0, T_{\mathrm{sym}}]$$
    - Wskazanie, że operacja ta odpowiada dyskretnej transformacie IFFT realizowanej na wektorze symboli konstelacji $X[k,l]$.
  - [x] **Akapit 2: Rola prefiksu cyklicznego (CP) w radarze pasywnym.**
    - Definicja prefiksu cyklicznego jako powtórzenia końcowego fragmentu symbolu użytecznego o czasie trwania $T_{\mathrm{CP}}$.
    - Warunek bezkolizyjnego odbioru: $T_{\mathrm{CP}} \ge \tau_{\max}$, gdzie $\tau_{\max}$ to maksymalne opóźnienie wielodrogowe w kanale.
    - Kluczowa konsekwencja matematyczna: zamiana splotu liniowego sygnału z odpowiedzią impulsową kanału na **splot kołowy** (ang. *circular convolution*). Dzięki temu w dziedzinie częstotliwości (po usunięciu CP i wykonaniu FFT) splot staje się prostym mnożeniem próbek.
  - [x] **Akapit 3: Właściwości symboli konstelacji $X[k,l]$.**
    - Podział na symbole preambuły (BPSK, stała amplituda $|X[k,l]|=1$) oraz symbole danych (QPSK, 16-QAM, 64-QAM o zmiennej amplitudzie).
    - Zapowiedź: zmienność modułu $|X[k,l]|$ w polu danych będzie kluczowa przy analizie szumu estymacji kanału w podrozdziale 2.4.
- **Równania do wklejenia:**
  1. Równanie sygnału OFDM czasu ciągłego $s_l(t)$.
  2. Zależność dyskretna IFFT: $s[n, l] = \frac{1}{\sqrt{N}} \sum_k X[k, l] e^{j 2\pi k n / N}$.
  3. Relacja czasowa: $T_{\mathrm{sym}} = T_u + T_{\mathrm{CP}}$.
- **Rysunki:**
  - *Brak (0 rysunków)* — podręcznikowy schemat symbolu z doklejonym blokiem CP usunięto jako zapychacz; relacje czasowe i warunek splotu kołowego są w pełni i precyzyjnie zdefiniowane wzorami i tekstem.
- **Czego NIE pisać (lista zakazów):**
  - [ZAKAZ] Nie wyprowadzać całki ortogonalności funkcji harmonicznych od zera.
  - [ZAKAZ] Nie omawiać algorytmów synchronizacji Schmidla & Coxa ani estymacji błędu CFO/SFO w odbiorniku komunikacyjnym.
  - [ZAKAZ] Nie analizować problemu wysokiego współczynnika PAPR ani metod jego redukcji (np. clipping, SLM).
- **Odniesienie do kodu:** Moduł nadajnika OFDM w symulatorze.

---

### Podrozdział 2.3: Geometria pomiarowa i parametry radaru: konfiguracja współlokowana (monostatyczna)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L75).
- **Docelowa objętość:** 1,5 strony (~450–550 słów).
- **Budżet:** 5 równań, 0 rysunków.
- **Plan akapitów:**
  - [ ] **Akapit 1: Od układu bistatycznego do konfiguracji współlokowanej (monostatycznej).**
    - Nakreślenie ogólnego kontekstu radaru pasywnego (PBR): w dalekosiężnych radarach z iluminatorami FM/DVB-T nadajnik Tx i odbiornik Rx są rozdzielone przestrzennie bazą $L_B$, co wymusza dedykowaną antenę referencyjną i prowadzi do skomplikowanej geometrii eliptycznej.
    - Specyfika radaru Wi-Fi i systemów ISAC/JCAS (*Braun 2014, Wypich & Zieliński 2026*): w aplikacjach bliskiego zasięgu oraz Wi-Fi Sensing odbiornik radarowy jest **współlokowany z nadajnikiem Wi-Fi** (ten sam punkt dostępowy / to samo urządzenie) lub odległość do celów wielokrotnie przewyższa bazę między antenami ($R \gg L_B$, przybliżenie quasi-monostatyczne).
    - Kluczowa konsekwencja: baza $L_B \to 0$ oraz kąt bistatyczny $\beta \to 0^\circ$. Wektor symboli referencyjnych $X[k,l]$ jest znany bezpośrednio z pamięci nadajnika (lub idealnej lokalnej demodulacji), co eliminuje szum toru odniesienia i zniekształcenia bistatyczne.
  - [ ] **Akapit 2: Model kanału wielodrogowego w konfiguracji współlokowanej.**
    - Dwudrożne opóźnienie echa dla odległości radialnej $R_p$: $\tau_p = \frac{2 R_p}{c}$, stąd relacja pomiarowa: $R_p = \frac{c \tau_p}{2}$.
    - Przesunięcie Dopplera dla prędkości radialnej $v_p$: $f_{D,p} = \frac{2 v_p}{\lambda} = \frac{2 v_p f_c}{c}$.
    - Odpowiedź impulsowa kanału w obecności przesłuchu bezpośredniego (DPI) i $P$ celów ruchomych:
      $$h(\tau, t) = A_{\mathrm{DPI}} \delta(\tau) + \sum_{p=1}^P A_p e^{j 2\pi f_{D,p} t} \delta(\tau - \tau_p)$$
      gdzie przesłuch bezpośredni (DPI) między antenami nadawczą a odbiorczą pojawia się przy opóźnieniu zerowym $\tau = 0$.
  - [ ] **Akapit 3: Zależności rozdzielczości i granic jednoznaczności radaru OFDM.**
    - Ścisłe wyprowadzenie 4 podstawowych parametrów radaru wynikających ze struktury siatki czas--częstotliwość, w 100% zgodnych z implementacją w [`lib/calculate_physical_axes.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/calculate_physical_axes.m):
      1. Rozdzielczość odległościowa: $\Delta R = \frac{c}{2 B_{\mathrm{act}}}$
      2. Maksymalny zasięg jednoznaczny: $R_{\max} = \frac{c}{2 \Delta f}$ (wynikający z próbkowania widma co $\Delta f$)
      3. Rozdzielczość prędkości radialnej: $\Delta v = \frac{\lambda}{2 M T_{\mathrm{sym}}} = \frac{c}{2 f_c T_{\mathrm{CPI}}}$ (gdzie $M$ to liczba symboli w ramce CPI)
      4. Maksymalna prędkość jednoznaczna: $v_{\max} = \frac{\lambda}{4 T_{\mathrm{sym}}} = \frac{c}{4 f_c T_{\mathrm{sym}}}$ (twierdzenie Nyquista dla próbkowania w czasie wolnym co $T_{\mathrm{sym}}$)
    - Porównanie liczbowe dla 802.11a ($\Delta R \approx 7{,}5\text{--}9\ \text{m}$, $v_{\max} \approx 68{,}2\ \text{m/s}$) oraz 802.11ax ($\Delta R \approx 7{,}8\ \text{m}$, $v_{\max} \approx 20{,}0\ \text{m/s}$) jako fizyczne uzasadnienie kompromisu wyboru standardu w symulatorze.
- **Rysunki:**
  - *Brak (0 rysunków)* — rysunek geometrii bistatycznej usunięto, ponieważ symulator implementuje geometrię współlokowaną/monostatyczną; relacje geometryczno-czasowe są w pełni opisane równaniami.
- **Czego NIE pisać (lista zakazów):**
  - [ZAKAZ] Nie opisywać historii radaru (Hülsmeyer, Watson-Watt, bitwa o Anglię).
  - [ZAKAZ] Nie wyprowadzać pełnego równania radiolokacji z zyskami anten i całkowaniem po kącie bryłowym (w symulatorze operujemy na SNR i względnych amplitudach ścieżek).
  - [ZAKAZ] Nie rozpisywać radarów pasywnych z innymi iluminatorami (FM, DVB-T, GSM).
  - [ZAKAZ] Nie rysować trójkątów bistatycznych ani nie wyprowadzać geometrii elips bistatycznych, które nie mają zastosowania w zrealizowanym symulatorze.
- **Odniesienie do kodu:** Parametry w [`lib/calculate_physical_axes.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/calculate_physical_axes.m) oraz model celów w [`src/step2_channel.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/src/step2_channel.m).

---

### Podrozdział 2.4: Estymacja częstotliwościowej odpowiedzi kanału (CFR)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L78).
- **Docelowa objętość:** 2,0 strony (~600–700 słów).
- **Budżet:** 4 równania, 1 tabela porównawcza (ZF vs. MF).
- **Plan akapitów:**
  - [ ] **Akapit 1: Model odebranej macierzy podnośnych.**
    - Po usunięciu CP i operacji FFT w odbiorniku, sygnał w kanale obserwacyjnym przyjmuje postać macierzy $Y[k,l]$ dla $k \in \mathcal{K}_{\mathrm{act}}$ oraz $l = 0, \dots, M-1$:
      $$Y[k,l] = H[k,l] X[k,l] + W[k,l]$$
      gdzie $X[k,l]$ to zdemodulowane symbole odniesienia z kanału referencyjnego, $H[k,l]$ to poszukiwana częstotliwościowa odpowiedź kanału (CFR), a $W[k,l]$ to addytywny szum Gaussa (AWGN).
  - [ ] **Akapit 2: Paradygmat dziedziny podnośnych (CFR) a funkcja niejednoznaczności (CAF).**
    - Porównanie z klasycznym podejściem korelacyjnym (CAF w dziedzinie czasu ciągłego).
    - Dlaczego w radarze OFDM estymacja w dziedzinie podnośnych jest nadrzędna: operacja dzielenia/mnożenia eliminuje niekorzystną strukturę modulacji losowej danych, zapobiega powstawaniu wysokich listków bocznych autokorelacji sygnału komunikacyjnego oraz dramatycznie redukuje złożoność obliczeniową (z $O(N^2)$ do operacji punktowych na macierzy $K \times M$). Cytowanie: *Braun (2014)*, *Di Seglio et al. (2022)*.
  - [ ] **Akapit 3: Estymatory Zero-Forcing (ZF) oraz Matched Filter (MF).**
    - Definicja estymatora Zero-Forcing (filtr odwrotny):
      $$\hat{H}_{\mathrm{ZF}}[k,l] = \frac{Y[k,l]}{X[k,l]} = H[k,l] + \frac{W[k,l]}{X[k,l]}$$
    - Definicja estymatora Matched Filter (filtr dopasowany):
      $$\hat{H}_{\mathrm{MF}}[k,l] = Y[k,l] X^*[k,l] = H[k,l] |X[k,l]|^2 + W[k,l] X^*[k,l]$$
  - [ ] **Akapit 4: Analiza szumowa i zjawisko wzmocnienia szumu (Noise Enhancement).**
    - Wariancja szumu resztkowego w estymatorze ZF wynosi $\sigma^2_{\mathrm{ZF}}[k,l] = \frac{\sigma_W^2}{|X[k,l]|^2}$.
    - Dla konstelacji o stałej obwiedni (BPSK/QPSK, np. preambuła) $|X[k,l]|^2 = 1$, więc estymatory ZF i MF są tożsame co do modułu.
    - Dla konstelacji wielopoziomowych (16-QAM, 64-QAM w polu danych) wewnętrzne punkty konstelacji mają małą energię ($|X[k,l]|^2 \ll 1$), co przy dzieleniu w ZF powoduje gwałtowne wzmocnienie szumu (*noise enhancement*). W estymatorze MF nie ma dzielenia, lecz modulacja amplitudy $|X[k,l]|^2$ podnosi podłogę listków bocznych.
    - **Zapowiedź eksperymentu:** Efekt degradacji współczynnika PNFR w funkcji rzędu modulacji MCS badany jest w Eksperymencie E3 (Rozdział 4).
- **Tabela:**
  - [ ] Porównanie cech estymatorów ZF i MF (złożoność, odporność na szum, wpływ rzędu modulacji, zachowanie dla BPSK vs 64-QAM).
- **Czego NIE pisać (lista zakazów):**
  - [ZAKAZ] Nie wyprowadzać estymatorów LMMSE wymagających a priori macierzy kowariancji kanału i znajomości SNR.
  - [ZAKAZ] Nie opisywać systemów CSI-only bezkanałowych (karty Intel 5300 / Nexmon).
- **Odniesienie do kodu:** Implementacja obu estymatorów w [`lib/channel_estimation.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/channel_estimation.m).

---

### Podrozdział 2.5: Tłumienie ech stałych i kompensacja luki DC
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L81).
- **Docelowa objętość:** 1,5 strony (~450–550 słów).
- **Budżet:** 3 równania, 0 rysunków.
- **Plan akapitów:**
  - [ ] **Akapit 1: Problem zakłócenia bezpośredniego (DPI) i tła stacjonarnego.**
    - Moc sygnału bezpośredniego z nadajnika do odbiornika (DPI) oraz odbić od ścian i mebli przewyższa moc echa ruchomego celu o 40–80 dB.
    - Listki boczne transformaty Fouriera wzdłuż osi Dopplera dla składowych o zerowej prędkości całkowicie maskują obiekty ruchome o małym RCS.
  - [ ] **Akapit 2: Filtracja MTI w dziedzinie czasu wolnego (Slow-Time).**
    - W radarze pasywnym OFDM filtrację realizuje się bezpośrednio na wyestymowanej macierzy $\hat{\mathbf{H}}[k,l]$ wzdłuż wymiaru symboli $l$ (czasu wolnego), przed kompresją odległościową.
    - Odjęcie średniej stacjonarnej (filtr MTI rzędu 0):
      $$\tilde{H}_{\mathrm{MTI}}[k,l] = \hat{H}[k,l] - \frac{1}{M} \sum_{m=0}^{M-1} \hat{H}[k,m]$$
    - Wzmianka o filtrze różnicowym pierwszego rzędu $H[k,l] - H[k, l-1]$ oraz filtrach IIR o regulowanym paśmie zaporowym.
    - **Zapowiedź eksperymentu:** Wpływ filtracji MTI na tłumienie DPI i wykrywalność celów weryfikuje Eksperyment E4.
  - [ ] **Akapit 3: Kompensacja luki podnośnej DC (DC Carrier Gap).**
    - Wyjaśnienie mechanizmu fizycznego za *Braunem (rozdz. 3.3.8)*: wycięcie podnośnej centralnej $k=0$ (oraz $k=\pm 1$ w 802.11ax) w widmie odpowiada przemnożeniu idealnego profilu przez maskę z usuniętym punktem, co w dziedzinie odległości odpowiada splotowi z funkcją tworzącą wysoką, stałą podłogę listków bocznych (*range spur floor*).
    - Metoda eliminacji w symulatorze: interpolacja liniowa brakujących podnośnych DC z sąsiednich aktywnych prążków przed wykonaniem kompresji IFFT:
      $$\hat{H}[k_{\mathrm{DC}}, l] = \frac{\hat{H}[k_{\mathrm{DC}}-1, l] + \hat{H}[k_{\mathrm{DC}}+1, l]}{2}$$
    - **Zapowiedź eksperymentu:** Skuteczność obniżenia podłogi listków bocznych przez interpolację DC badana jest w Eksperymencie E1.
- **Równania:**
  1. Odjęcie średniej w czasie wolnym (MTI).
  2. Wzór interpolacji liniowej DC dla pojedynczej luki (802.11a) oraz wielopunktowej (802.11ax).
- **Rysunki:**
  - *Brak (0 rysunków)* — schemat blokowy przetwarzania CFR usunięto, aby nie dublować diagramu architektury i etapów DSP z Rozdziału 3 ([`rys_3_3_etapy_przetwarzania_dsp.png`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/img/ch3_impl/rys_3_3_etapy_przetwarzania_dsp.png)); w Rozdziale 2 operacje są w pełni zdefiniowane wzorami matematycznymi.
- **Czego NIE pisać (lista zakazów):**
  - [ZAKAZ] Nie opisywać adaptacyjnych filtrów czasowych na surowych próbkach IQ (ECA, ECA-B, LMS, RLS) — w architekturze OFDM filtrujemy macierz podnośnych za Di Seglio (2022).
- **Odniesienie do kodu:** Funkcja [`lib/channel_estimation.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/channel_estimation.m) (sekcja MTI oraz DC interpolation).

---

### Podrozdział 2.6: Wyznaczanie mapy odległość–prędkość (Range–Doppler)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L84).
- **Docelowa objętość:** 1,5 strony (~450–550 słów).
- **Budżet:** 3 równania, 1 tabela parametrów okien wagowych.
- **Plan akapitów:**
  - [ ] **Akapit 1: Dwuwymiarowa transformata Fouriera (2D Periodogram).**
    - Przejście z kondycjonowanej macierzy CFR $\tilde{\mathbf{H}}[k,l]$ o wymiarach $K \times M$ do zespolonej mapy Range–Doppler $\text{CPer}(r, d)$:
      $$\text{CPer}(r, d) = \sum_{l=0}^{M-1} \left( \sum_{k=0}^{K-1} \tilde{H}[k,l] W[k,l] e^{j 2\pi \frac{k r}{N_{\mathrm{range}}}} \right) e^{-j 2\pi \frac{l d}{N_{\mathrm{doppler}}}}$$
    - Zwrócenie uwagi na znaki transformacji: IFFT wzdłuż osi częstotliwości $k$ (odwzorowanie opóźnienia/odległości $\tau \to r$) oraz FFT ze znakiem minus wzdłuż osi czasu $l$ (odwzorowanie przesunięcia Dopplera $f_D \to d$).
    - Zysk przetwarzania koherentnego: $G_p = 10 \log_{10}(K \cdot M)$ dB.
  - [ ] **Akapit 2: Przeciek widmowy i dobór dwuwymiarowego okna wagowego.**
    - Zastosowanie okna separowalnego $W[k,l] = w_r[k] \cdot w_d[l]$.
    - Konsekwencje okna prostokątnego (wysokie listki boczne $-13\ \text{dB}$ maskujące cele o mniejszym echu).
    - Zastosowanie 4-wyrazowego okna Blackmana-Harrisa o tłumieniu listków bocznych na poziomie $-92\ \text{dB}$.
  - [ ] **Akapit 3: Kompromis okienkowania (Resolution vs. Dynamic Range).**
    - Trójstronny kompromis: poziom najwyższego listka bocznego (PSLL), poszerzenie listka głównego o współczynnik rozmycia (spadek rozdzielczości odległościowej i dopplerowskiej) oraz strata przetwarzania (*processing loss / SNR loss* rzędu 2–3 dB).
    - **Zapowiedź eksperymentu:** Szczegółowe badanie wpływu okien (prostokątne, Hamminga, Hanniga, Blackmana-Harrisa) na metryki PSLL, szerokość listka 3 dB i SNR stanowi treść Eksperymentu E2.
- **Tabela:**
  - [ ] Zestawienie okien wagowych (Rectangular, Hann, Hamming, Blackman-Harris): PSLL [dB], poszerzenie listka głównego (-3 dB bin width), strata SNR [dB] (na podstawie danych z tab. 3.2 i 3.3 u Brauna).
- **Rysunki:**
  - *Brak (0 rysunków)* — okna są stabelaryzowane i opisane analitycznie; ich profile 1D/2D badane są eksperymentalnie w Rozdziale 4 (E2).
- **Czego NIE pisać (lista zakazów):**
  - [ZAKAZ] Nie wyprowadzać algorytmów superrozdzielczych (MUSIC, ESPRIT, Capon), które nie wchodzą w zakres implementacji symulatora.
  - [ZAKAZ] Nie wyprowadzać wielomianów kosinusowych okien od zera.
- **Odniesienie do kodu:** Funkcja [`lib/range_doppler_processing.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/range_doppler_processing.m).

---

### Podrozdział 2.7: Detekcja adaptacyjna CFAR i iteracyjna ekstrakcja celów (CLEAN)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L87).
- **Docelowa objętość:** 1,5 strony (~500–600 słów).
- **Budżet:** 4 równania, 0 rysunków.
- **Plan akapitów:**
  - [ ] **Akapit 1: Estymacja poziomu szumu tła i metryka PNFR.**
    - Niejednorodność tła na mapie RDM po filtracji MTI i okienkowaniu.
    - Zastosowanie odpornego estymatora dyspersji szumu opartego na medianie odchyleń bezwzględnych (MAD – *Median Absolute Deviation*): $\hat{\sigma} = 1{,}4826 \cdot \text{median}(|P(r,d) - \text{median}(P)|)$, niewrażliwego na obecność ostrych pików od celów.
    - Definicja metryki PNFR (*Peak-to-Noise-Floor Ratio*): $\text{PNFR} = P_{\mathrm{peak}} - P_{\mathrm{noise\_floor}}$ [dB].
  - [ ] **Akapit 2: Dwuwymiarowy detektor adaptacyjny 2D CA-CFAR.**
    - Zasada stałego prawdopodobieństwa fałszywego alarmu ($P_{\mathrm{FA}}$).
    - Struktura okna przesuwnego 2D: komórka badana (CUT), komórki ochronne (Guard Cells zapobiegające wpływowi energii badanego celu na próg) oraz komórki referencyjne/trenujące (Training Cells).
    - Formuła adaptacyjnego progu detekcji:
      $$T_{\mathrm{CFAR}}[r,d] = \alpha \cdot \frac{1}{N_{\mathrm{train}}} \sum_{(i,j) \in \Omega_{\mathrm{train}}} P[r+i, d+j]$$
      gdzie $\alpha = N_{\mathrm{train}} (P_{\mathrm{FA}}^{-1/N_{\mathrm{train}}} - 1)$.
    - Grupowanie sąsiadujących pików (Non-Maximum Suppression / klastrowanie).
  - [ ] **Akapit 3: Maskowanie celów i algorytm Coherent CLEAN (Successive Target Cancellation).**
    - Problem: słaby cel ruchomy znajdujący się w pobliżu silnego celu może zostać zamaskowany przez resztkowe listki boczne silnego odbicia (nawet przy oknie Blackmana-Harrisa).
    - Algorytm Coherent CLEAN (*Braun 2014, rozdz. 3.3.7*):
      1. Detekcja najsilniejszego piku $(r_{\max>, d_{\max})$ o zespolonej amplitudzie $A_{\max}$.
      2. Wygenerowanie analitycznej odpowiedzi punktowej idealnego reflektora z uwzględnieniem identycznego okna wagowego: $\mathbf{S}_{\mathrm{point}}(r_{\max}, d_{\max})$.
      3. Koherentne odjęcie zespolonej odpowiedzi od mapy RDM:
         $$\text{CPer}^{(i+1)} = \text{CPer}^{(i)} - A_{\max} \cdot \frac{\mathbf{S}_{\mathrm{point}}}{\max |\mathbf{S}_{\mathrm{point}}|}$$
      4. Powtórzenie kroku detekcji na oczyszczonej mapie.
    - **Zapowiedź eksperymentu:** Zdolność algorytmu CLEAN do demaskowania słabych celów różniących się mocą o >20 dB weryfikuje Eksperyment E5.
- **Rysunki:**
  - *Brak (0 rysunków)* — schemat siatki okna 2D CFAR usunięto jako elementarz podręcznikowy; zbiory komórek $\Omega_{\mathrm{train}}$ i $\Omega_{\mathrm{guard}}$ oraz próg detekcji są w pełni zdefiniowane analitycznie.
- **Czego NIE pisać (lista zakazów):**
  - [ZAKAZ] Nie opisywać rozbudowanych wariantów CFAR (OS-CFAR, GO-CFAR, SO-CFAR, TM-CFAR, VI-CFAR) — wystarczy jedno zdanie uzasadnienia wyboru CA-CFAR.
  - [ZAKAZ] Nie wchodzić w śledzenie trajektorii wieloobiektowej w czasie (filtry Kalmana, JPDA, PHD, trackery wieloramkowe) — radar operuje w pojedynczym oknie CPI.
- **Odniesienie do kodu:** Algorytmy w [`lib/cfar_2d.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/cfar_2d.m) oraz [`lib/extract_targets.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/extract_targets.m).

---

## 5. Wytyczne redakcyjne, stylistyka i wymogi formalne (z plan_deliverables.md)

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
2. **Świadomość stylometrii i JSA**: Jednolity System Antyplagiatowy (JSA) analizuje jednorodność stylu tekstu. Tekst pracy musi być zredagowany spójnym, jednolitym, autorskim językiem inżynierskim. Zdania powinny być zwięzłe i przyczynowo-skutkowe, czyli powiązane ze sobą.

### 5.5. Opracowanie statystyczne w części badawczej
1. W Rozdziale 4 wyniki nie mogą ograniczać się do pojedynczych przypadków deterministycznych.
2. Scenariusz Monte Carlo musi zawierać rzetelne opracowanie statystyczne: wyznaczenie prawdopodobieństwa detekcji $P_D(\text{SNR})$, średnich wartości i przedziałów ufności dla zróżnicowanych celów.

### 5.6. Kwestie formalne jednostki i szablonu
1. **Szablon WIEiT**: Bezwzględnie stosować szablon wydziałowy WIEiT AGH (unikać ogólnych, niezgodnych wzorców uczelnianych z Overleafa).
2. **Nazwa jednostki**: Należy stosować aktualną nazwę instytutu — **Instytut Telekomunikacji i Cyberbezpieczeństwa** (pamiętać o uwzględnieniu Cyberbezpieczeństwa).

---

## 6. Checklista Weryfikacji Spójności Przed Zamknięciem Rozdziału 2

Przed uznaniem Rozdziału 2 za w pełni ukończony, należy zweryfikować poniższe punkty kontrolne:

- [ ] **Kompilacja LaTeX:** Brak błędów kompilacji XeLaTeX/BibTeX w pliku [`thesis/main.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/main.tex).
- [ ] **Spójność oznaczeń matematycznych:**
  - [ ] Indeks podnośnej: konsekwentnie $k \in \{0, \dots, K-1\}$.
  - [ ] Indeks symbolu (czas wolny): konsekwentnie $l \in \{0, \dots, M-1\}$.
  - [ ] Wymiary macierzy: $K \times M$ lub $N_{\mathrm{FFT}} \times M$.
  - [ ] Transmitowane symbole: $X[k,l]$, odebrane: $Y[k,l]$, estymata transmitancji: $\hat{H}[k,l]$.
  - [ ] Wszystkie oznaczenia są w 100% zgodne z [`docs/theory_notes.md`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/docs/theory_notes.md).
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
  - [ ] Żadne treści z "listy zakazów" (MAC, kody korekcyjne, historia radaru, inne iluminatory, elipsy bistatyczne) nie przedostały się do tekstu.
