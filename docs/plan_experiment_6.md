# Ostateczna Koncepcja Eksperymentu 6 (SIM-6 / Monte Carlo)

## Efektywność detekcji i ekstrakcji celów przez algorytm Coherent CLEAN w losowej scenie wieloobiektowej

---

## 1. Założenie przewodnie

W eksperymencie **nie tworzymy sztucznych wariantów gorszych detektorów** (brak alternatywnych baseline'ów w kodzie). Badamy wyłącznie **autorski, zaimplementowany łańcuch przetwarzania** (`step1_transmitter` $\to$ `step2_channel` $\to$ `step3_receiver` $\to$ `step4_interpreter` z algorytmem `run_coherent_clean.m`).

Celem eksperymentu jest precyzyjna inżynierska odpowiedź na pytanie:
> **Jak skutecznie algorytm Coherent CLEAN z adaptacyjnym progiem MAD wykrywa, rozdziela i zlicza obiekty w realistycznym kanale Wi-Fi (TGax Model-C) w miarę wzrostu zagęszczenia sceny ($K = 1, \dots, 5$ celów) przy całkowicie losowych położeniach i prędkościach?**

---

## 2. Modelowanie fizyczne losowej sceny wielocelowej

W każdej próbie Monte Carlo ($N_{\text{prób}} = 40$ dla każdego zagęszczenia $K \in \{1, 2, 3, 4, 5\}$):

1. **Struktura celów w scenie**:
   - **1 cel dominujący (pojazd, $0\ \text{dB}$ ref)**:
     - Odległość: $R_{\text{car}} \sim \mathcal{U}(10{,}0;\ 40{,}0)\ \text{m}$ (losowana jednostajnie),
     - Prędkość: $v_{\text{car}} \sim \pm \mathcal{U}(4{,}0;\ 14{,}0)\ \text{m/s}$ (losowy zwrot i wartość $14\text{--}50\ \text{km/h}$),
     - Współczynnik odbicia: $\text{gain}_{\text{car}} = 0{,}0500$.
   - **$K - 1$ celów słabych (piesi, $-30\ \text{dB}$ względem pojazdu)**:
     - Odległość: $R_{\text{ped}, i} \sim \mathcal{U}(5{,}0;\ 35{,}0)\ \text{m}$,
     - Prędkość: $v_{\text{ped}, i} \sim \pm \mathcal{U}(1{,}0;\ 3{,}5)\ \text{m/s}$ (realistyczny chód poza strefą ślepą MTI),
     - Współczynnik odbicia: $\text{gain}_{\text{ped}} = 0{,}00158$ (asymetria mocy $30\ \text{dB}$).

2. **Pełna swoboda losowania (Brak sztucznego zakazu kolizji)**:
   - Pozycje i prędkości są losowane **całkowicie niezależnie**.
   - Dopuszczamy sytuacje, w których obiekty znajdą się blisko siebie w odległości lub prędkości:
     - Jeśli dwa cele wylosują się wewnątrz tej samej komórki rozdzielczości Rayleigha ($\Delta R \le 1{,}88\ \text{m}$ i $\Delta v \le 0{,}02\ \text{m/s}$), fale zlewają się w jeden nierozróżnialny pik — co w naturalny, fizyczny sposób prowadzi do niewykrycia jednego z nich.
     - To właśnie ten mechanizm (wraz z interferencją listków bocznych) w realny sposób kształtuje spadek $P_D$ dla gęstych scen.

3. **Parametryzacja potoku radarowego (DRY)**:
   - Standard: IEEE 802.11ax, pasmo CBW80 (80 MHz), MCS 0, kanał TGax Model-C.
   - Stała moc nadajnika AP odpowiadająca typowym warunkom biurowo-przemysłowym ($\text{SNR}_{\text{rx}} = 35\ \text{dB}$ w odbiorniku).
   - CLEAN: `max_targets = 6`, adaptacyjny próg szumu MAD (`margin_dB = 22.0`).

4. **Bramka asocjacji (Kryterium prawidłowej detekcji)**:
   - Cel wzorcowy $k$ uznaje się za prawidłowo wykryty, jeśli wśród wykrytych pików istnieje punkt spełniający:
     $$|R_{\text{det}} - R_{k,\text{true}}| \le 1{,}875\ \text{m} \quad \wedge \quad |v_{\text{det}} - v_{k,\text{true}}| \le 0{,}5\ \text{m/s}$$
   - Każdy wykryty pik może zostać przypisany do co najwyżej jednego celu wzorcowego (najbliższy sąsiad).
   - Piki nieprzypisane do żadnego celu wzorcowego klasyfikowane są jako **fałszywe alarmy** ($N_{\text{fa}}$).

---

## 3. Układ wykresu: Rysunek 4.6

Wykres składa się z dwóch zsynchronizowanych podpaneli (`subplot(1, 2, ...)` z nadrzędnym `sgtitle`):

```text
                                  EFEKTYWNOŚĆ DETEKCJI I ZLICZANIA CELÓW PRZEZ COHERENT CLEAN
        Panel (a): Prawdopodobieństwo detekcji P_D vs Liczba celów K         Panel (b): Skuteczność zliczania i fałszywe alarmy
   1.0 |=========[ Pojazd (cel silny, 0 dB) ]==========|                100% | \                                          | 1.0
       |                                                               |              |   \  P(N_det == K) [%] [oś lewa]           |
   0.8 |      \                                                        |          80% |     \                                      | 0.8
P_D    |        \                                                      |              |       \                                    |     N_fa
   0.6 |          \--[ Piesi (cele słabe, -30 dB) ]                    |          60% |         \                                  | 0.6
       |             \                                                 |              |           \               /---[ N_fa ]---- |
   0.4 |               \                                               |          40% |             \            /  [oś prawa]     | 0.4
       +-------+-------+-------+-------+-------+                       |              +-------+-------+-------+-------+-------+    |
       1       2       3       4       5                                              1       2       3       4       5
              Liczba celów w scenie K                                                        Rzeczywista liczba celów K
```

### Panel (a): Prawdopodobieństwo detekcji w funkcji liczby celów w scenie
- **Oś X**: Rzeczywista liczba celów w scenie $K \in \{1, 2, 3, 4, 5\}$.
- **Oś Y**: Prawdopodobieństwo prawidłowej detekcji $P_D \in [0, 1]$.
- **Krzywa 1 (Niebieska, kwadraty)**: *Pojazd (cel silny)* — stabilna pozioma linia $P_D \approx 1{,}0$ ($100\%$) z wąskimi przedziałami ufności. Udowadnia, że radar natychmiast i bezbłędnie lokalizuje dominujące obiekty niezależnie od liczby innych celów.
- **Krzywa 2 (Czerwona, kółka)**: *Piesi (cele słabe)* — krzywa obrazująca rzeczywistą zdolność algorytmu do wyciągania małych obiektów spod listków bocznych i residuów pojazdu. Wskazuje łagodny spadek z $\sim 92\%$ przy 1 pieszym do $\sim 60\%$ przy 4 pieszych, wynikający z naturalnych kolizji przestrzennych oraz maskowania.
- **Słupki błędów**: Przedziały ufności Wilsona na poziomie 95%.

### Panel (b): Precyzja adaptacyjnego zliczania obiektów i kontrola szumu
- **Oś X**: Rzeczywista liczba celów $K \in \{1, 2, 3, 4, 5\}$.
- **Oś Y lewa (`yyaxis left`)**: Odsetek prób, w których CLEAN zatrzymał się dokładnie na właściwej liczbie celów: $P(N_{\text{det}} == K)$ [\%].
- **Oś Y prawa (`yyaxis right`)**: Średnia liczba fałszywych detekcji na ramkę $\bar{N}_{\text{fa}}$ (potwierdzająca, że adaptacyjny próg MAD skutecznie zabezpiecza przed generowaniem sztucznych duchów szumowych).

---

## 4. Dlaczego to idealnie puentuje całą pracę?

1. **Brak sztuczności**: Nie piszemy alternatywnego detektora tylko po to, żeby pokazać, że jest gorszy. Badamy w 100% zaimplementowany w pracy algorytm.
2. **Prawdziwa fizyka radaru**: Testujemy system w warunkach, w jakich pracowałby w rzeczywistości (ruch uliczny / monitoring biurowy z różną liczbą osób i pojazdów).
3. **Uwzględnienie naturalnych kolizji**: Gdy cele wylosują się zbyt blisko siebie, system zachowuje się realistycznie — ujawniając fizyczną granicę rozdzielczości standardu 802.11ax.
4. **Gotowość do wdrożenia**: Skrypt `scripts/figures/ch4_sim/gen_fig_4_6_stat_pd_vs_snr.m` wywołuje istniejący potok w pętli Monte Carlo i generuje grafikę o standardzie wydawniczym.
