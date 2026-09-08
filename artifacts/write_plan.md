# Plan Realizacji Pracy Inżynierskiej: Wi-Fi Passive Radar

Plan działania opracowany w oparciu o analizę prac dyplomowych z folderu `references/TZ` (w szczególności pracy inżynierskiej **Katarzyny Szwej** pt. *"Radar OFDM z użyciem sygnału DVB-T2"*, AGH 2024, promotor: **prof. dr hab. inż. Tomasz Zieliński**) oraz pracy **Wojciecha Sorbiana** (WAT 2024).

---

## 1. Koncepcja i Analiza Porównawcza (DVB-T2 vs Wi-Fi)

Praca Katarzyny Szwej badała radar pasywny wykorzystujący sygnały telewizji naziemnej DVB-T2. Twój projekt realizuje **dokładnie ten sam paradygmat radarowy**, lecz w odniesieniu do sieci bezprzewodowych **Wi-Fi (IEEE 802.11a/g OFDM)**.

| Element metodologii | Praca K. Szwej (DVB-T2) | Twoja Praca (Wi-Fi 802.11a/g) | Stan w kodzie |
| :--- | :--- | :--- | :--- |
| **Iluminator sygnału** | Nadajnik DVB-T2 (np. RTCN Chorągwica, 650 MHz, $B=8\text{ MHz}$) | Punkt dostępowy Wi-Fi AP (5.5 GHz / 2.4 GHz, $B=20\text{ MHz}$) | `transmitter.m` (wlanNonHTConfig) |
| **Model kanału** | Wielodrogowość + Doppler + szum AWGN | Wielodrogowość + Doppler + szum AWGN | `channel.m` |
| **Metoda badana** | Odpowiedź impulsowa kanału (CIR / OFDM Division) | Estymacja kanału Zero-Forcing (CFR $\to$ CIR / 2D Periodogram) | `receiver_pipeline.m` |
| **Metoda odniesienia** | Cross-Ambiguity Function (CAF / Matched Filter) | Filtr dopasowany / korelacyjny w dziedzinie czasu (CAF) | `receiver_correlation.m` |
| **Kompensacja echa bezpośredniego** | Usunięcie składowej stałej (filtr MTI) | Filtr MTI w czasie wolnym (`mean subtraction`) | `receiver_pipeline.m` |
| **Łatanie nośnej DC** | Usunięcie podnośnej zerowej | Liniowa interpolacja podnośnej stałoprądowej (indeks 33) | `receiver_pipeline.m` |
| **Separacja słabych ech** | Analiza przekrojów i progowanie | Koherentny algorytm CLEAN (usuwanie listków bocznych) | `clean_interpreter.m` |

---

## 2. Sugerowana Struktura Rozdziałów Pracy

Struktura odpowiada układowi pracy dyplomowej z Katedry Telekomunikacji AGH:

```text
1. Wprowadzenie
   1.1. Cel i zakres pracy (pasywna detekcja celów z użyciem sygnałów Wi-Fi OFDM)
   1.2. Motywacja (wykorzystanie powszechnej infrastruktury Wi-Fi, brak dedykowanych nadajników)
   1.3. Zawartość i układ pracy

2. Koncepcja bistatycznego radaru pasywnego
   2.1. Geometria pasywnego radaru bistatycznego (linia bazowa d, zasięg bistatyczny, kąt bistatyczny)
   2.2. Zjawiska fizyczne (tłumienie sygnału bezpośredniego, efekt Dopplera i przesunięcie częstotliwości)
   2.3. Etapy przetwarzania sygnału w radarze pasywnym
   2.4. Metody wyznaczania mapy Range-Doppler:
        2.4.1. Klasyczna funkcja niejednoznaczności (CAF / Matched Filter) jako metoda odniesienia
        2.4.2. Metoda odpowiedzi częstotliwościowej i impulsowej kanału (CFR/CIR) w OFDM
   2.5. Zalety i ograniczenia pasywnego radaru Wi-Fi

3. Sygnał Wi-Fi IEEE 802.11 – właściwości i struktura warstwy fizycznej
   3.1. Standardy rodziny IEEE 802.11 (od 802.11a do 802.11be / Wi-Fi 7)
   3.2. Modulacja OFDM (ortogonalność podnośnych, prefiks cykliczny CP, FFT)
   3.3. Struktura ramki PPDU IEEE 802.11a Non-HT (preambuła: L-STF, L-LTF, pole SIGNAL, DATA)
   3.4. Parametry radarowe standardu (szerokość pasma B = 20 MHz, czas symbolu 4 us, rozdzielczość odległościowa 7.5 m, jednoznaczna prędkość ~68 m/s)
   3.5. Wzorzec pilotów i podnośnych danych (52 aktywne podnośne, podnośna DC)

4. Algorytmy przetwarzania sygnału radarowego Wi-Fi OFDM
   4.1. Synchronizacja pakietu (metoda Schmidl-Cox na sekwencji L-STF)
   4.2. Estymacja kanału metodą Zero-Forcing (usunięcie modulacji danych)
   4.3. Filtracja składowej bezpośredniej (filtr MTI w czasie wolnym)
   4.4. Okienkowanie 2D (Blackman-Harris) i tłumienie listków bocznych
   4.5. Algorytm koherentnego usuwania celów (Coherent CLEAN wg Martina Brauna)

5. Badania symulacyjne i analiza wyników
   5.1. Środowisko symulacji w MATLAB i scenariusze testowe (pojedynczy cel, wiele celów, różne prędkości i odległości)
   5.2. Porównanie map Range-Doppler: metoda CIR vs metoda CAF (wykresy 3D mesh, rzuty 2D, przekroje 1D)
   5.3. Badanie wpływu stosunku sygnału do szumu (SNR = -10 dB ... +60 dB) na jakość detekcji (SNRout vs SNRin)
   5.4. Wpływ parametrów transmisji (modulacje BPSK/QPSK/16QAM/64QAM, długość ramki M, tłumienie echa)
   5.5. Skuteczność algorytmu Coherent CLEAN w separacji słabych celów na tle silnych odbić

6. Wnioski i perspektywy rozwoju
   - Podsumowanie wyników i przewag metody CIR nad CAF przy średnich i wysokich SNR
   - Ograniczenia i kierunki dalszych prac (pomiary rzeczywiste SDR / CSI, sieci neuronowe)

Bibliografia
Spis rysunków i tabel
```

---

## 3. Minimalistyczny Plan Rozwoju Kodu ("Im mniej, tym lepiej")

Twój obecny kod w `src/` zawiera już **90% kluczowej fizyki i algorytmów** (nadajnik, kanał, demodulacja, MTI, okno 2D, periodogram, CLEAN, odbiornik korelacyjny).

Aby praca zawierała identyczny komplet wykresów i charakterystyk co praca Szwej, wystarczy dodać **zaledwie 2 zwięzłe skrypty badawcze w `scripts/`** (bez przebudowywania istniejących modułów):

### Skrypt 1: `scripts/generate_szwej_comparison_plots.m`
*Cel: Wygenerowanie zestawu rysunków 3D/2D oraz przekrojów 1D analogicznych do Rysunków 20, 21, 26–29 z pracy Szwej.*
- Uruchamia równolegle metodę CIR (`receiver_pipeline`) i metodę CAF (`receiver_correlation`) dla zadanych wartości SNR (np. 160 dB, 25 dB, 10 dB, 0 dB).
- Generuje:
  1. Wykresy 3D `mesh(velocity, range, power_dB)` obok siebie (CIR vs CAF).
  2. Przekroje 1D w osi prędkości dla odległości wykrytego celu.
  3. Zestawienie 2D `imagesc` przed i po MTI / CLEAN.
- Automatycznie zapisuje figury do `results/figures/chapter5_comparison_*.png`.

### Skrypt 2: `scripts/evaluate_snr_curves.m`
*Cel: Wygenerowanie krzywych $SNR_{out} = f(SNR_{in})$ analogicznych do Rysunków 23, 24, 25, 30 z pracy Szwej.*
- Wykonuje pętlę po $SNR_{in} \in [-10, 0, 10, 20, 30, 40, 50, 60]\text{ dB}$ oraz różnych wartościach tłumienia echa (np. 0.05, 0.01, 0.001) i modulacji MCS (BPSK vs 64QAM).
- Mierzy wysokość szczytu detekcyjnego ponad poziomem tła szumowego ($SNR_{out} = P_{peak} - P_{noise\_floor}$).
- Rysuje zbiorczy wykres liniowy porównujący metodę CIR i CAF.

---

## 4. Harmonogram Kroków do Napisania Pracy

### Krok 1: Automatyzacja wykresów symulacyjnych (1-2 dni)
- Stworzenie 2 wyżej wymienionych minimalistycznych skryptów w `scripts/`.
- Wygenerowanie i skatalogowanie wszystkich wykresów do rozdziału 5.

### Krok 2: Opracowanie Rozdziałów Teoretycznych (Rozdział 2, 3, 4) (3-5 dni)
- Wykorzystanie istniejącego `docs/theory_notes.md` oraz rozdziałów 2 i 3 z pracy Katarzyny Szwej i Wojciecha Sorbiana.
- Opisanie matematyki: geometria bistatyczna, OFDM, estymacja Zero-Forcing, okienkowanie Blackman-Harris, algorytm CLEAN.

### Krok 3: Opracowanie Rozdziału Wyników (Rozdział 5) (2-3 dni)
- Opisanie uzyskanych map Range-Doppler i wykresów $SNR_{out}$ vs $SNR_{in}$.
- Komentarz fizyczny: dlaczego CIR ma niższy poziom podłogi szumowej przy wyższych SNR, jak filtracja MTI usuwa sygnał bezpośredni, jak algorytm CLEAN odsłania słabe cele.

### Krok 4: Wstęp, Wnioski i Redakcja (Rozdział 1, 6 + Bibliografia) (1-2 dni)
- Sformułowanie wstępu i wniosków końcowych.
- Ujednolicenie bibliografii (wykorzystanie `docs/references.md` oraz bibliografii z prac referencyjnych).

---

## 5. Pytania Otwarte i Decyzje

> [!NOTE]
> 1. Czy praca dyplomowa będzie pisana w systemie **LaTeX** (np. szablon dyplomowy AGH / Overleaf) czy w programie **Microsoft Word**? (Mogę przygotować gotową strukturę plików `.tex` lub konspekt `.docx`).
> 2. Czy promotor wymaga porównania różnych modulacji MCS (np. BPSK vs 64QAM) lub różnych szerokości pasma Wi-Fi (np. 20 MHz vs 40 MHz)?
