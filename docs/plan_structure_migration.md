# Plan Migracji Struktury Pracy Dyplomowej

Dokument określa kompletny plan przejścia z dotychczasowego układu 5-rozdziałowego na **docelową strukturę pracy inżynierskiej**, uwzględniającą wydzielenie rozdziału o sygnale 802.11, nienumerowane sekcje Wstępu i Wniosków końcowych oraz wyodrębnienie Dodatków.

> [!IMPORTANT]
> **Zasada bezpieczeństwa migracji:** W trakcie prac redakcyjnych zachowujemy w pełni istniejący dorobek napisany w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L16-L111) (dotychczasowe sekcje 2.1 i 2.2) oraz wszystkie dotychczasowe etykiety `\label{subsec:...}`, `\label{eq:...}`, `\label{tab:...}`, `\label{fig:...}`, aby nie zrywać odsyłaczy w tekście ani w planach rozdziałów.

---

## 1. Zestawienie Układu Pracy: Poprzedni vs. Docelowy

| Pozycja w spisie treści | Poprzedni układ | Docelowy układ pracy | Numeracja w LaTeX |
| :--- | :--- | :--- | :---: |
| Strona tytułowa | `01_titlePage.tex` + `03_MasterThesisOutline.tex` | **Strona tytułowa** (+ Program pracy wg wzoru WIEiT) | — |
| Spis treści | `\tableofcontents` | **Spis treści** | — |
| Wstęp | `1. Wstęp` (`10_introduction.tex`) | **Wstęp** | *nienumerowany* (`\section*`) |
| Rozdział 1 | *(część Rozdz. 2: 2.1–2.2)* | **1. Sygnał 802.11** | `1.` (`\section`) |
| Rozdział 2 | `2. Radar Pasywny` (`20_passive_radar.tex`) | **2. Radar pasywny** | `2.` (`\section`) |
| Rozdział 3 | `3. Implementacja radaru` (`30_radar_implementation.tex`) | **3. Opis oprogramowania** | `3.` (`\section`) |
| Rozdział 4 | `4. Badania symulacyjne` (`40_simulation_results.tex`) | **4. Opis eksperymentów** | `4.` (`\section`) |
| Wnioski | `5. Wnioski` (`50_conclusion.tex`) | **Wnioski końcowe** | *nienumerowane* (`\section*`) |
| Literatura | `Literatura` | **Literatura** | *nienumerowana* (`\section*` z `\addcontentsline`) |
| Dodatki | *(brak)* | **Dodatki** *(oraz Spis rysunków / Spis tabel)* | `Dodatek A, B...` (`\begin{appendices}`) |

---

## 2. Mapowanie Plików Źródłowych `.tex`

| Docelowa kolejność w `thesis/main.tex` | Docelowy plik `.tex` | Pochodzenie / Zakres zmian |
| :--- | :--- | :--- |
| Strona tytułowa | `tex/01_titlePage.tex` | Bez zmian strukturalnych; na końcu weryfikacja aktualnej nazwy instytutu (**Instytut Telekomunikacji i Cyberbezpieczeństwa**). |
| Program pracy | `tex/03_MasterThesisOutline.tex` | Weryfikacja zgodności tytułu i spisu punktów na etapie końcowym. |
| **Wstęp** | `tex/05_introduction.tex` *(przeniesienie z `10_introduction.tex`)* | Przekształcenie na sekcję nienumerowaną `\section*{Wstęp}\addcontentsline{toc}{section}{Wstęp}` (patrz pułapka nr 1 w Sekcji 3). |
| **1. Sygnał 802.11** | `tex/10_wifi_signal.tex` *(nowy plik)* | Przeniesienie z `20_passive_radar.tex` (linie 16–111) już napisanych i zweryfikowanych podrozdziałów:<br>• `1.1 Warstwa fizyczna standardu IEEE 802.11` (`\label{subsec:wifi_signal}`)<br>• `1.2 Model matematyczny sygnału OFDM` (`\label{subsec:ofdm_modulation}`)<br>Wszystkie etykiety (`tab:wifi_params`, `fig:subcarrier_allocation`, `eq:ofdm_*`) pozostają bez zmian. |
| **2. Radar pasywny** | `tex/20_passive_radar.tex` | Po wydzieleniu 1.1–1.2 pozostają tu podrozdziały **2.1–2.5** (dawne 2.3–2.7):<br>• `2.1 Geometria pomiarowa i parametry radaru: konfiguracja współlokowana (monostatyczna)` (`\label{subsec:pbr_fundamentals}`)<br>• `2.2 Estymacja częstotliwościowej odpowiedzi kanału (CFR)` (`\label{subsec:channel_estimation}`)<br>• `2.3 Tłumienie ech stałych i kompensacja luki DC` (`\label{subsec:clutter_filtering}`)<br>• `2.4 Wyznaczanie mapy odległość–prędkość (Range–Doppler)` (`\label{subsec:range_doppler_map}`)<br>• `2.5 Detekcja progowa CFAR i iteracyjna ekstrakcja celów (Binary STC oraz Coherent STC)` (`\label{subsec:target_detection_extraction}`). |
| **3. Opis oprogramowania** | `tex/30_radar_implementation.tex` | Zmiana tytułu z `Implementacja radaru` na `\section{Opis oprogramowania}` (zachować `\label{sec:radar_implementation}`); realizacja ściśle według [`docs/plan_chapter_3.md`](plan_chapter_3.md) (podrozdziały `3.1`–`3.5` z `3.5.1`–`3.5.4`). |
| **4. Opis eksperymentów** | `tex/40_simulation_results.tex` | Zmiana tytułu z `Badania symulacyjne` na `\section{Opis eksperymentów}` (zachować `\label{sec:simulation_results}`); podrozdziały `4.1`–`4.6` bez zmiany etykiet `\label{subsec:sim_...}`. |
| **Wnioski końcowe** | `tex/50_conclusion.tex` | Przekształcenie na sekcję nienumerowaną `\section*{Wnioski końcowe}\addcontentsline{toc}{section}{Wnioski końcowe}` (patrz pułapka nr 1 w Sekcji 3). |
| **Literatura** | `bibliography.bib` (w `main.tex`) | Eksport z Zotero; po zakończeniu redakcji usunąć `\nocite{*}`, tak aby każda pozycja była jawnie zacytowana w tekście. |
| **Dodatki** | `tex/60_appendices.tex` *(nowy plik)* | Środowisko `\begin{appendices}` (pakiet `appendix` już załadowany w `00_preambule.tex`):<br>• **Dodatek A:** Wybrane listingi kodu MATLAB (w `minted`) i instrukcja uruchomienia symulatora (`\label{app:listings}`),<br>• **Dodatek B (opcjonalnie):** Rozszerzone tabele numeryczne wyników Monte Carlo lub parametry konfiguracji testów. |

---

## 3. Pułapki Techniczne LaTeX i Sposób Ich Rozwiązania

Przed kompilacją i w trakcie migracji plików należy bezwzględnie uwzględnić poniższe szczegóły klasy `article` i preambuły [`thesis/tex/00_preambule.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/00_preambule.tex):

1. **Nienumerowane sekcje a podrozdziały (`\subsection` w Wstępie i Wnioskach końcowych):**
   - W klasie `article` użycie numerowanego `\subsection{...}` wewnątrz `\section*{Wstęp}` przed pierwszym `\section{...}` wygeneruje błędną numerację **`0.1`, `0.2`, ...**, natomiast wewnątrz `\section*{Wnioski końcowe}` po Rozdziale 4 wygeneruje numerację **`4.7`, `4.8`, ...**!
   - **Rozwiązanie:** W `05_introduction.tex` oraz `50_conclusion.tex` stosujemy albo ciągłą strukturę akapitową z śródtytułami `\paragraph{...}` / `\subsection*{...}`, bez numerowanych `\subsection{...}`. Jeżeli mają pojawiać się w spisie treści, można użyć `\subsection*{...}` bez wpisu do TOC lub zwięzłej struktury bez podrozdziałów (zalecane przy objętości 1–2 stron Wstępu i 2–3 stron Wniosków).
2. **Interakcja `\pretocmd{\section}{\cleardoublepage}` z `\section*` i `\include`:**
   - W `00_preambule.tex` (linia 26) znajduje się `\pretocmd{\section}{\cleardoublepage}{}{}`, a `main.tex` włącza rozdziały poleceniem `\include{...}` (które samo wstawia `\clearpage`). W połączeniu z `\section*` oraz środowiskiem `\begin{appendices}` należy przy próbnej kompilacji sprawdzić, czy między Wstępem / Rozdziałem 1 / Dodatkami nie powstają zbędne puste strony lub błędne nagłówki stron.
3. **Obsługa pakietu `appendix` w języku polskim:**
   - W `00_preambule.tex` załadowano `\usepackage[toc,page]{appendix}`. Domyślnie tworzy on stronę tytułową z angielskim napisem *Appendices* i wpis *Appendices* w spisie treści.
   - **Rozwiązanie:** Dodać w preambule przed `\begin{document}` (lub w `00_preambule.tex`):
     ```latex
     \renewcommand{\appendixpagename}{Dodatki}
     \renewcommand{\appendixtocname}{Dodatki}
     ```
     oraz zdecydować o kolejności sekcji końcowych w `main.tex`: najpierw `Literatura`, następnie `Dodatki` (zgodnie z listą użytkownika), a na końcu ewentualny `Spis rysunków` i `Spis tabel` (lub po Literatura / w Dodatkach — zweryfikować z wymogiem spójności szablonu WIEiT).
4. **Pakiety dla schematu blokowego (Rys. 3.1):**
   - W `00_preambule.tex` należy dodać obsługę **TikZ** (`\usepackage{tikz}` oraz `\usetikzlibrary{arrows.meta, positioning, fit, backgrounds, shapes.geometric}`), jeśli schemat blokowy w podrozdziale 3.2 będzie rysowany wektorowo bezpośrednio w LaTeX.
5. **Numeracja rysunków i tabel w Rozdziale 1 vs. nazwy plików na dysku:**
   - W aktualnej konfiguracji `main.tex` numeracja rysunków i tabel jest ciągła (`Rysunek 1`, `Rysunek 2`...) lub — jeśli zostanie włączona numeracja rozdziałowa (`\numberwithin{figure}{section}`) — wykres alokacji podnośnych z `thesis/img/ch2_theory/rys_2_1_alokacja_podnosnych.png` otrzyma w Rozdziale 1 numer `1.1`.
   - **Decyzja:** Fizyczne ścieżki plików graficznych (`ch2_theory/rys_2_1_...`, `ch3_impl/rys_3_...`, `ch4_sim/rys_4_...`) pozostawiamy bez zmian na dysku, aby nie psuć skryptów MATLAB (`run_all_figures.m`), a w LaTeX opieramy się wyłącznie na etykietach `\label{...}` i `\ref{...}`.
6. **Aktualizacja odsyłaczy w tekście Rozdziału 1 (`10_wifi_signal.tex`):**
   - W przeniesionych podrozdziałach `1.1` i `1.2` wszystkie wewnętrzne `\ref{subsec:ofdm_modulation}`, `\ref{subsec:pbr_fundamentals}`, `\ref{subsec:channel_estimation}`, `\ref{subsec:clutter_filtering}`, `\ref{subsec:sim_mcs_noise_enhancement}` używają niezmienionych etykiet logicznych, więc po przeniesieniu nie wymagają zmiany nazw etykiet — wystarczy zweryfikować słowo „podrozdział” vs „rozdział” tam, gdzie odwołanie przechodzi między Rozdziałem 1 a Rozdziałem 2 (np. w `1.1` odwołania do `\ref{subsec:pbr_fundamentals}`, `\ref{subsec:channel_estimation}`, `\ref{subsec:clutter_filtering}` wskazują teraz na podrozdziały Rozdziału 2, więc warto pisać np. `w~rozdziale~\ref{sec:passive_radar} (podrozdział~\ref{subsec:pbr_fundamentals})`).

---

## 4. Kolejność Wykonywania Migracji (Krok po Kroku)

1. **Krok M1 (Nowe i przeniesione pliki `.tex`):**
   - Utworzyć `thesis/tex/05_introduction.tex` na bazie `10_introduction.tex` (zamiana `\section{Wstęp}` na `\section*{Wstęp}` + `\addcontentsline{toc}{section}{Wstęp}` oraz usunięcie numerowanych `\subsection` na rzecz `\subsection*` lub akapitów). Usunąć stary plik `10_introduction.tex` (po upewnieniu się, że nie ma starych `.aux` w `thesis/build/`).
   - Utworzyć `thesis/tex/10_wifi_signal.tex` z `\section{Sygnał 802.11}\label{sec:wifi_signal}` i przenieść do niego linie 16–111 z `20_passive_radar.tex`.
   - Oczyścić `thesis/tex/20_passive_radar.tex` tak, aby zaczynał się od `\section{Radar pasywny}\label{sec:passive_radar}` i zawierał wyłącznie podrozdziały `2.1`–`2.5` (dawne `2.3`–`2.7`, z zachowanymi etykietami `\label`).
   - Zaktualizować nagłówki `\section{Opis oprogramowania}` w `30_radar_implementation.tex` oraz `\section{Opis eksperymentów}` w `40_simulation_results.tex`.
   - Zaktualizować `50_conclusion.tex` do formy nienumerowanej `\section*{Wnioski końcowe}\addcontentsline{toc}{section}{Wnioski końcowe}` (bez numerowanych `\subsection`).
   - Utworzyć szkielet `thesis/tex/60_appendices.tex` z blokiem `\begin{appendices} ... \end{appendices}`.
2. **Krok M2 (Aktualizacja `thesis/main.tex` i `thesis/tex/00_preambule.tex`):**
   - W `00_preambule.tex` dodać `tikz` (z potrzebnymi bibliotekami) oraz polskie nazwy dla `appendix` (`\appendixpagename`, `\appendixtocname`).
   - W `main.tex` uaktualnić listę `\include`:
     `05_introduction` $\to$ `10_wifi_signal` $\to$ `20_passive_radar` $\to$ `30_radar_implementation` $\to$ `40_simulation_results` $\to$ `50_conclusion` $\to$ `Literatura` $\to$ `60_appendices` (oraz `Spis rysunków` / `Spis tabel`).
   - Wyczyścić stare pliki pomocnicze kompilacji w `thesis/build/` i `thesis/tex/*.aux`.
3. **Krok M3 (Próbna kompilacja i weryfikacja spisu treści):**
   - Uruchomić `pdflatex -shell-escape` (wymagane przez `minted`) + `bibtex` + dwukrotny `pdflatex` i sprawdzić w `thesis/build/main.pdf`:
     - poprawność kolejności i numeracji w Spisie treści (Wstęp nienumerowany, `1.`–`4.`, Wnioski końcowe nienumerowane, Literatura, Dodatki),
     - brak stron o błędnej numeracji (`0.1`, `4.7`),
     - poprawne działanie odsyłaczy `\ref{...}` między Rozdziałem 1 a Rozdziałem 2.
4. **Krok M4 (Redakcja właściwej treści rozdziałów):**
   - Przejść kolejno do pisania: Rozdziału 3 ([`docs/plan_chapter_3.md`](plan_chapter_3.md)), Rozdziału 4, Rozdziału 2 ([`docs/plan_chapter_2.md`](plan_chapter_2.md)), a na końcu Wstępu, Wniosków końcowych, Dodatku A i weryfikacji bibliografii (usunięcie `\nocite{*}`).
