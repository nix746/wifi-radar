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

### 3.2. Obliczenie Periodogramu
Dwuwymiarowa transformacja (IFFT po częstotliwości -> Range, FFT po czasie -> Doppler):
$$\text{CPer}(r, d) = \text{fftshift}\left( \mathcal{F}_t \left\{ \mathcal{F}_f^{-1} \{ \tilde{H}_{k,l} \cdot W_{k,l} \} \right\} \right)$$

Moc periodogramu wyrażona w dB:
$$P(r, d) = 10 \log_{10}\left( \frac{1}{N_{\text{fft}} M} |\text{CPer}(r, d)|^2 \right)$$

---

## 4. Algorytm Koherentnego Usuwania Celów (Coherent CLEAN)

W scenariuszach wielocelowych silne listki boczne dominującego celu maskują słabsze obiekty. Algorytm **Coherent CLEAN** (Braun, 2014, sekcja 3.3.7) usuwa interferencje krokowo:

1. **Detekcja szczytu**:
   $$(r_i, d_i) = \arg\max_{r, d} |\text{CPer}_{\text{current}}(r, d)|^2, \quad A_i = \text{CPer}_{\text{current}}(r_i, d_i)$$
2. **Rekonstrukcja idealnego modelu celu**:
   Generowana jest macierz odpowiedzi impulsowej idealnego reflektora w punkcie $(r_i, d_i)$ z uwzględnieniem identycznego okna $W_{k,l}$.
3. **Normalizacja i koherentne odjęcie**:
   $$\text{CPer}_{\text{next}}(r, d) = \text{CPer}_{\text{current}}(r, d) - A_i \cdot \frac{\text{CPer}_{\text{target}, i}(r, d)}{\text{CPer}_{\text{target}, i}(r_i, d_i)}$$
4. **Iteracja**: Proces powtarzany dla zadanej liczby celów lub do osiągnięcia progu szumu tła.
