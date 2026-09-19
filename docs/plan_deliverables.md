# Źródło prawdy: co ma powstać

Ten dokument rozstrzyga **co** jest celem pracy i repozytorium. Kolejność zadań jest w [`plan_work_order.md`](plan_work_order.md).

## 1. Praca

| Pole | Wartość |
| :--- | :--- |
| Typ | Praca **inżynierska** |
| Temat | Implementacja i testowanie efektywności detekcji wybranego algorytmu radaru pasywnego używającego sygnału Wi-Fi |
| Opiekun | prof. dr hab. inż. Tomasz Zieliński |
| Wzorzec układu | Prace z katedry / analogiczna inżynierska K. Szwej (*Radar OFDM z użyciem sygnału DVB-T2*), plus Sorbian (WAT) jako drugi punkt odniesienia rysunków i porównań |
| Wkład własny | Ten sam paradygmat co Szwej (CIR/CFR vs CAF, MTI, DC, mapa Range–Doppler), przeniesiony na **Wi-Fi 802.11a** i uzupełniony o **Coherent CLEAN** (Braun) |

Kod w `src/` jest już nośnikiem metody. Praca ma **opisać i zbadać** ten łańcuch, a nie przebudowywać go od zera.

---

## 2. Układ rozdziałów (obowiązujący)

Sześć rozdziałów. Nie ma osobnego rozdziału „implementacja MATLAB”: środowisko i architektura wchodzą w **5.1**. Nie łączy się geometrii PBR z PHY 802.11 w jednym rozdziale.

| Nr | Plik LaTeX | Tytuł | Zawartość |
| :--- | :--- | :--- | :--- |
| 1 | `thesis/tex/10_introduction.tex` | Wstęp | Cel i zakres, motywacja (iluminator Wi-Fi, brak dedykowanego radaru), teza / pytania badawcze, układ pracy |
| 2 | `thesis/tex/20_pbr.tex` | Koncepcja bistatycznego radaru pasywnego | Geometria bistatyczna, zjawiska fizyczne, etapy przetwarzania, **CAF vs CFR/CIR**, zalety i ograniczenia Wi-Fi PBR |
| 3 | `thesis/tex/30_wifi_phy.tex` | Sygnał Wi-Fi IEEE 802.11 | Rodzina 802.11, OFDM i CP, ramka Non-HT (L-STF, L-LTF, SIGNAL, DATA), parametry radarowe ($B=20\,\mathrm{MHz}$, $\Delta R=7.5\,\mathrm{m}$, $v_{\mathrm{unamb}}\approx 68\,\mathrm{m/s}$), siatka 52 podnośnych i luka DC |
| 4 | `thesis/tex/40_radar_dsp.tex` | Algorytmy przetwarzania radarowego | Zwięzła rola preambuły i synchronizacji w sprzęcie vs cięcie w symulacji; Zero-Forcing, MTI, interpolacja DC, okno 2D Blackman–Harris ze wzoru, periodogram 2D, Coherent CLEAN |
| 5 | `thesis/tex/50_simulation_results.tex` | Badania symulacyjne | 5.1 środowisko MATLAB (rola WLAN/Comm Toolbox vs wkład własny w DSP) i scenariusze; 5.2 CIR vs CAF; 5.3 $SNR_{\mathrm{out}}(SNR_{\mathrm{in}})$; 5.4 modulacja / tłumienie echa / długość ramki; 5.5 CLEAN |
| 6 | `thesis/tex/99_conclusion.tex` | Wnioski | Podsumowanie, ograniczenia, dalsze prace (SDR/CSI — jako perspektywa, nie jako niedokończony rozdział) |

Front matter (strona tytułowa, oświadczenie, program pracy) zostaje w istniejących plikach `01_`–`03_`, ale z danymi ze zgłoszenia i z poprawką „inżynierska”.

`thesis/tex/20_first_chapter_RENAME_ME.tex` znika na rzecz `20_pbr.tex`. W `thesis/main.tex` wszystkie sześć rozdziałów są `\include`.

**Zasada Single Source of Truth dla tekstu i wzorów**: Wszelka treść merytoryczna, wzory, wyprowadzenia i tabele powstają **od razu bezpośrednio w plikach `.tex` w `thesis/tex/`**. Nie tworzymy równoległych brudnopisów teorii w Markdownie. Wcześniejsze notatki (`theory_notes.md`) służą jedynie jako podręczna ściąga wyjściowa do zredagowania w LaTeX-u.

---

## 3. Bibliografia

Źródło prawdy metadanych: **kolekcja Zotero *Wi-Fi Radar***. Git trzyma wyłącznie bezpośredni eksport `.bib` oraz kopie robocze PDF.

| Warstwa | Gdzie | Rola |
| :--- | :--- | :--- |
| Metadane + PDF | Zotero | Rekord, stały klucz cytowania (Better BibTeX), DOI/URL, załączony plik |
| Eksport LaTeX | `thesis/bibliography.bib` | Bezpośredni eksport z Zotero — jedyne źródło literatury dla LaTeX-a |
| Kopie robocze PDF | `references/` | Materiały robocze (`compendiums/`, `shorts/`, `TW/`, `TZ/`) do importu do Zotero |

> [!NOTE]
> **Rezygnacja z `docs/references.md`**: Nie utrzymujemy ręcznej tabeli inwentarza w Markdownie — wprowadzała zbędne podwójne wprowadzanie danych i ryzyko desynchronizacji z bazą Zotero i plikiem `.bib`.

> [!IMPORTANT]
> **Status demonstracji i toolboxów MathWorks**: Przykłady demonstracyjne z `_archive_original/` oraz same pakiety narzędziowe (WLAN Toolbox, Communications Toolbox) **nie wchodzą do bibliografii jako artykuły naukowe**. Ich wykorzystanie opisuje się w tekście pracy w rozdziale **5.1** (z ewentualnym jednym ogólnym cytowaniem środowiska MATLAB, jeśli wymagane).

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

Istniejący łańcuch zostaje: `transmitter` → `channel` → `receiver_pipeline` → `clean_interpreter`, plus `receiver_correlation` jako CAF. Bez przebudowy modułów.

Do dopisania są **dwa skrypty badawcze**:

| Skrypt | Po co |
| :--- | :--- |
| `scripts/generate_szwej_comparison_plots.m` | Para CIR vs CAF: mesh 3D, `imagesc` 2D, przekroje 1D; stany przed/po MTI i CLEAN; kilka wartości SNR |
| `scripts/evaluate_snr_curves.m` | Krzywe $SNR_{\mathrm{out}}=f(SNR_{\mathrm{in}})$ dla CIR i CAF, warianty tłumienia echa i MCS |

Zapis figur:
- roboczy: `results/figures/`
- do składu: `thesis/img/` (PNG i/lub PDF), nazwy stabilne, gotowe do `\includegraphics`

**Katalog rysunków do rozdziału 5**:
1. Mapa Range–Doppler 2D/3D, metoda CIR, wysoki SNR
2. Ta sama scena, metoda CAF
3. Przekrój 1D w osi prędkości (albo odległości) przez wykryty cel, CIR vs CAF
4. Ta sama para przy średnim i niskim SNR
5. Mapa przed MTI vs po MTI
6. Mapa przed CLEAN vs po CLEAN (scena wielocelowa)
7. $SNR_{\mathrm{out}}$ vs $SNR_{\mathrm{in}}$, CIR i CAF na jednym wykresie
8. Wariant: tłumienie echa i/lub BPSK vs 64-QAM

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
- Przebudowa `src/` pod inną architekturę.
- Ręczny inwentarz literatury w Markdownie (`docs/references.md`) oraz równoległe brudnopisy teorii (`docs/theory_deep_dive.md`).
- Umieszczanie skryptów demonstracyjnych MathWorks w spisie literatury.
- Obszerne teoretyczne wywody o synchronizacji telekomunikacyjnej (Schmidl–Cox) — wystarczy zwięzły akapit uzasadniający a priori odcięcie preambuły w symulacji.
- Osobny rozdział implementacyjny (architektura i środowisko wchodzą do 5.1).
