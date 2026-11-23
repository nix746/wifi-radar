# Teoria i Podstawy Matematyczne Radaru OFDM (Wi-Fi Passive Radar)

Dokument podsumowuje model matematyczny i algorytmy zaimplementowane w projekcie, oparte na standardzie **IEEE 802.11a** oraz pracy doktorskiej **Martina Brauna** (*"OFDM Radar Algorithms in Mobile Communication Networks"*, KIT, 2014).

---

## 1. Parametry fizyczne sygnału IEEE 802.11a

- **Częstotliwość nośna**: $f_c = 5.5\ \text{GHz}$ ($\lambda = \frac{c}{f_c} \approx 0.0545\ \text{m}$)
- **Szerokość pasma**: $B = 20\ \text{MHz}$
- **Częstotliwość próbkowania**: $f_s = 20\ \text{MHz}$ ($T_s = 50\ \text{ns}$)
- **Liczba podnośnych FFT**: $N_{\text{fft}} = 64$
- **Odstęp między podnośnymi**: $\Delta f = \frac{B}{N_{\text{fft}}} = 312.5\ \text{kHz}$
- **Długość prefiksu cyklicznego (CP)**: $N_{\text{cp}} = 16$ ($T_{\text{cp}} = 0.8\ \mu\text{s}$)
- **Całkowity czas trwania symbolu OFDM**: $T_{\text{sym}} = \frac{N_{\text{fft}} + N_{\text{cp}}}{f_s} = 4.0\ \mu\text{s}$
- **Liczba aktywnych podnośnych**: 52 (48 danych + 4 piloty)

### Rozdzielczości radarowe:
- **Rozdzielczość odległościowa (Range resolution)**:
  $$\Delta R = \frac{c}{2 B} = \frac{3 \cdot 10^8}{2 \cdot 20 \cdot 10^6} = 7.5\ \text{m}$$
- **Maksymalna jednoznaczna prędkość (Unambiguous velocity)**:
  $$v_{\text{unamb}} = \frac{c}{2 f_c T_{\text{sym}}} = \frac{3 \cdot 10^8}{2 \cdot 5.5 \cdot 10^9 \cdot 4 \cdot 10^{-6}} \approx 68.18\ \text{m/s}\ (\approx 245.4\ \text{km/h})$$
- **Rozdzielczość prędkościowa (Doppler resolution)**:
  $$\Delta v = \frac{c}{2 f_c T_{\text{frame}}} = \frac{v_{\text{unamb}}}{M}$$
  gdzie $T_{\text{frame}} = M \cdot T_{\text{sym}}$, a $M$ to liczba przetwarzanych symboli OFDM.

---

## 2. Model matematyczny odbiornika OFDM

### 2.1. Demodulacja i estymacja kanału (Zero-Forcing)
Dla każdej podnośnej $k \in \{0, \dots, N_{\text{fft}}-1\}$ oraz każdego symbolu $l \in \{0, \dots, M-1\}$ macierz transmitowana $X_{k,l}$ i odebrana $Y_{k,l}$ wiążą się relacją:
$$Y_{k,l} = H_{k,l} X_{k,l} + W_{k,l}$$

Dzielenie symbol po symbolu (Zero-Forcing) eliminuje modulację danych:
$$H_{k,l} = \frac{Y_{k,l}}{X_{k,l} + \varepsilon}$$

### 2.2. Usuwanie echa bezpośredniego (MTI Filter)
Silna składowa bezpośrednia od nadajnika (oraz obiekty statyczne o $v = 0\ \text{m/s}$) jest tłumiona przez odjęcie wartości średniej w czasie wolnym:
$$\tilde{H}_{k,l} = H_{k,l} - \frac{1}{M} \sum_{m=0}^{M-1} H_{k,m}$$

### 2.3. Łatanie luki podnośnej DC (DC Carrier Gap)
W standardzie 802.11a podnośna stałoprądowa (DC, indeks $k=0$ w pasmie podstawowym, indeks 33 po `fftshift`) nie przenosi energii. Pozostawienie zera powoduje rozlewanie energii (spectral leakage) podczas okienkowania. Wartość jest aproksymowana liniowo:
$$H_{\text{shifted}}(33, l) = \frac{H_{\text{shifted}}(32, l) + H_{\text{shifted}}(34, l)}{2}$$

---

## 3. Okienkowanie 2D i Zespolony Periodogram (2D Periodogram)

### 3.1. Okno Blackman-Harris 2D
Aby uzyskać tłumienie listków bocznych na poziomie $\approx 92\ \text{dB}$, stosowane jest 4-wyrazowe okno Blackman-Harris:
$$w[n] = a_0 - a_1 \cos\left(\frac{2\pi n}{N-1}\right) + a_2 \cos\left(\frac{4\pi n}{N-1}\right) - a_3 \cos\left(\frac{6\pi n}{N-1}\right)$$
gdzie $a_0 = 0.35875$, $a_1 = 0.48829$, $a_2 = 0.14128$, $a_3 = 0.01168$.

Okno 2D jest iloczynem tensorowym okna po częstotliwości i czasie:
$$W_{k,l} = w_f[k] \cdot w_t[l]$$

- *(Dla standardu **IEEE 802.11ax** w symulatorze obsługiwane są ponadto szerokości pasma $20, 40, 80, 160\ \text{MHz}$, rozmiar FFT $N_{\text{fft}} \in \{256, 512, 1024, 2048\}$, czas symbolu $T_{\text{sym}} = 13{,}6\ \mu\text{s}$ przy $T_{\text{cp}} = 0{,}8\ \mu\text{s}$ oraz odpowiadająca im liczba podnośnych aktywnych $N_{\text{act}} \in \{242, 484, 996, 1992\}$ i podnośnych zerowych DC.)*

### 3.2. Obliczenie Periodogramu
Dwuwymiarowa transformacja (IFFT po częstotliwości -> Range, FFT po czasie -> Doppler):
$$\text{CPer}(r, d) = \text{fftshift}\left( N_{\text{per}} \cdot \mathcal{F}_t \left\{ \mathcal{F}_f^{-1} \{ \tilde{H}_{k,l} \cdot W_{k,l} \} \right\} \right)$$

Znormalizowany periodogram mocy w skali liniowej i decybelowej (Braun równ. 3.31):
$$\text{Per}_{\mathbf{F}}(r, d) = \frac{1}{N_{\text{act}} M} |\text{CPer}(r, d)|^2, \qquad P(r, d) = 10 \log_{10}\left( \text{Per}_{\mathbf{F}}(r, d) \right)$$

---

## 4. Detekcja CFAR i Algorytmy Sekwencyjnej Eliminacji Celów (Binary STC i Coherent STC)

W scenariuszach wielocelowych listki boczne lub szeroki listek główny okna wagowego dominującego obiektu maskują słabsze cele. W projekcie zaimplementowano oba kanoniczne algorytmy sekwencyjnej eliminacji celów z pracy M. Brauna (*OFDM Radar Algorithms in Mobile Communication Networks*, 2014, rozdz. 3.3.5–3.3.7): **Binary STC** oraz **Coherent STC**.

### 4.1. Estymacja tła szumowego ML i próg CFAR $\eta$
- Dla zespolonego szumu AWGN moc periodogramu $\text{Per}_{\mathbf{F}}$ pod hipotezą $\mathcal{H}_0$ ma rozkład wykładniczy ($\chi_2^2$) o średniej $\sigma^2$.
- Moc szumu tła $\hat{\sigma}^2$ estymowana jest metodą największej wiarygodności (ML, Braun równ. 3.98) poprzez uśrednienie periodogramu w zakresie odległości poza $N_{\max} = \lceil (N_{\text{cp}} / N_{\text{fft}}) N_{\text{per}} \rceil$ z zachowaniem strefy ochronnej $n_{\text{guard}}$ (chroniącej przed wyciekiem z $N_{\max}$ oraz zawinięciem cyklicznym przy $R = 0$):
  $$\hat{\sigma}^2 = \frac{1}{(n_{\text{end}} - n_{\text{start}} + 1) M_{\text{per}}} \sum_{n=n_{\text{start}}}^{n_{\text{end}}} \sum_{m} \text{Per}_{\mathbf{F}}(n, m)$$
- Globalny próg CFAR $\eta$ dla zadanego prawdopodobieństwa fałszywego alarmu na ramkę $p_{\text{FA}}$ (domyślnie $10^{-3}$, Braun równ. 3.95):
  $$p_{\text{FA,bin}} = 1 - (1 - p_{\text{FA}})^{\frac{1}{N_{\text{act}} M}}, \qquad \eta = -\hat{\sigma}^2 \ln(p_{\text{FA,bin}})$$
  Wykładnik $\frac{1}{N_{\text{act}} M}$ odpowiada liczbie niezależnych komórek widma (dopełnianie zerami nie zwiększa liczby niezależnych stopni swobody).

### 4.2. Interpolacja paraboliczna 2D i estymacja parametrów fizycznych
Dla wykrytego maksimum siatki $(\hat{n}, \hat{m})$ wyznaczane są poprawki podpikselowe $(\delta_n, \delta_m) \in [-0{,}5;\ 0{,}5]$ przez 2D interpolację kwadratową z czterech sąsiadów (Braun równ. 3.84–3.86):
$$\tilde{n} = \max(0, \hat{n} + \delta_n), \qquad \tilde{m} = \hat{m} + \delta_m$$
oraz przeliczane są fizyczne współrzędne $(\hat{d}, \hat{v})$ i skuteczna powierzchnia odbicia $\hat{\sigma}_{\text{RCS}}$ (Braun równ. 3.32–3.34).

### 4.3. Binary STC (*Binary Successive Target Cancellation*, Braun rys. 3.13)
1. Inicjalizacja maski binarnej $\mathbf{B} \equiv 1$ o rozmiarze $N_{\text{per}} \times M_{\text{per}}$.
2. Wyszukanie maksimum na periodogramie mocy $\text{Per}_{\mathbf{F}}$ w obszarze $\mathbf{B} = 1$; zatrzymanie pętli, jeśli wartość szczytu $< \eta$.
3. Interpolacja paraboliczna 2D i zapis parametrów wykrytego celu.
4. Wyzerowanie w masce $\mathbf{B}$ eliptycznego obszaru pełnego listka głównego (*null-to-null* o osiach $N_{\text{win}}, M_{\text{win}}$ okna $W$) w metryce cyklicznej:
   $$\left(\frac{\Delta n}{N_{\text{win}}/2}\right)^2 + \left(\frac{\Delta m}{M_{\text{win}}/2}\right)^2 \le 1$$
Metoda jest szybka i odporna na rezydua, lecz wyzerowany obszar tworzy strefę ślepą maskującą słabsze cele wewnątrz listka głównego obiektu silnego.

### 4.4. Coherent STC (*Coherent Successive Target Cancellation*, Braun rys. 3.15, równ. 3.99–3.102)
1. Wyszukanie globalnego maksimum w aktualnym periodogramie $\text{Per}_{\mathbf{F}}$; zatrzymanie, jeśli wartość szczytu $< \eta$.
2. **Krok 4 (identyfikacja rezyduów)**: sprawdzenie, czy pik leży wewnątrz elipsy zdefiniowanej przez $2\times$ szerokość $-3\ \text{dB}$ listka głównego wcześniej wykrytych celów. Jeśli tak, pik klasyfikuje się jako rezyduum dekonwolucji i odejmuje bez dopisywania do listy celów.
3. Dla celu właściwego (Krok 5): interpolacja paraboliczna 2D oraz zapis parametrów $(\hat{d}, \hat{v}, \hat{\sigma}_{\text{RCS}})$.
4. **Kroki 6–8 (koherentne odjęcie repliki)**: synteza idealnego reflektora pojedynczego celu $\mathbf{F}_{\text{target}}(k,l) = e^{-j2\pi k \hat{n}/N_{\text{per}}} e^{+j2\pi l \hat{m}/M_{\text{per}}}$, nałożenie tego samego okna wagowego $W$, wyznaczenie $\text{CPer}_{\text{target}}$, normalizacja do jedności w punkcie maksimum i koherentne odjęcie od widma zespolonego:
   $$\text{CPer}_{\mathbf{F}} \leftarrow \text{CPer}_{\mathbf{F}} - \text{CPer}_{\mathbf{F}}(\hat{n}, \hat{m}) \cdot \frac{\text{CPer}_{\text{target}}}{\text{CPer}_{\text{target}}(\hat{n}, \hat{m})}, \qquad \text{Per}_{\mathbf{F}} = \frac{1}{N_{\text{act}} M} |\text{CPer}_{\mathbf{F}}|^2$$
Na oczyszczonym periodogramie odsłaniają się słabe cele ukryte wcześniej wewnątrz listka głównego i listków bocznych silnego obiektu.
