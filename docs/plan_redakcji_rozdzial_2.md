# Plan Redakcji Rozdziału 2: Podstawy teoretyczne pasywnego radaru OFDM Wi-Fi

Dokument stanowi kompletny, śledzony plan pisania **Rozdziału 2** pracy dyplomowej (plik źródłowy: [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex)). Zawiera rygorystyczne wytyczne objętościowe, kompletne mapowanie i uzasadnienie bibliograficzne na podstawie repozytorium Zotero ([`references/Zotero/`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/references/Zotero) / [`thesis/bibliography.bib`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/bibliography.bib)), plan korekt już napisanych podrozdziałów 2.1–2.2 (z zachowaniem ich treści i uwzględnieniem ewentualnych zmian zawartości), plan akapitów dla 2.3–2.7, gotowe wzory matematyczne, listę cięć oraz powiązania z kodem symulatora ([`lib/`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/)) i eksperymentami badawczymi E1–E5 w Rozdziale 4.

---

## 1. Tablica Śledzenia Postępów Redakcji

| Podrozdział | Tytuł roboczy / docelowy | Limit stron | Rysunki / Tabele | Równania | Status redakcji | Status weryfikacji |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: |
| **2.1** | Warstwa fizyczna standardu IEEE 802.11 | 1,5 str. | 1 rys. + 1 tab. | 0 | [x] **Zrealizowany** | [x] Zweryfikowany (tabela 20/40/80/160 MHz, interpolacja wielopunktowa, czyste `\cite` — pkt 4.1) |
| **2.2** | Model matematyczny sygnału OFDM | 1,2–1,5 str. | 0 rys. | 4 | [x] **Zrealizowany** | [x] Zweryfikowany (dodano równ. splotu kołowego z `zielinski2007`, czyste `\cite` — pkt 4.2) |
| **2.3** | Geometria pomiarowa i parametry radaru (układ współlokowany/monostatyczny) | 1,5 str. | 0 rys. | 6–7 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.4** | Estymacja częstotliwościowej odpowiedzi kanału (CFR) | 2,0 str. | 1 tab. | 4–5 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.5** | Tłumienie ech stałych i kompensacja luki DC | 1,5 str. | 0 rys. | 3 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.6** | Wyznaczanie mapy Range–Doppler (RDM) | 1,5 str. | 1 tab. | 4 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.7** | Detekcja progowa i iteracyjna ekstrakcja celów (algorytm Coherent CLEAN) | 1,5 str. | 0 rys. | 4 | [ ] Do napisania | [ ] Do weryfikacji |
| **SUMA** | **Rozdział 2 (całość)** | **10,0–11,5 str.** | **1 rys., 3 tab.** | **~26–27** | **Postęp: 2/7 (29%)** | **2.1–2.2 zweryfikowane; 2.3–2.7 do napisania** |

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

### 2.5. Zasady cytowania i zapożyczania wzorów w pracy inżynierskiej
> [!NOTE]
> **Spójna polityka cytowań dla przyszłych rozdziałów i poprawek:** W pracy inżynierskiej odwołania bibliograficzne mają wspierać wiarygodność modelu matematycznego, a nie obciążać czytelnika aparatem typowym dla artykułu przeglądowego.

1. **Czysta forma odwołań w tekście LaTeX (`\cite{klucz}`):** W plikach `.tex` stosujemy wyłącznie proste odwołania `\cite{klucz}` bez szczegółowych dopisków lokalizacyjnych typu `[rozdz.~X, tab.~Y, str.~Z]`. Dokładne numery rozdziałów, tabel i równań w źródłach przechowujemy wyłącznie w niniejszym planie jako dokumentację pomocniczą dla autora.
2. **Oszczędność i zasada jednego podstawowego źródła:** Przy pojedynczym wzorze, definicji lub wniosku podajemy **jedno najbardziej podstawowe i miarodajne źródło** (lub parę standardów `\cite{1999,2021}`). Unikamy grupowania 3–4 cytowań przy jednym zdaniu.
3. **Hierarchia autorytetu źródeł (zakaz cytowania prac wtórnych do teorii podstawowej):**
   - *Podstawy DSP i teorii OFDM* (transformata Fouriera, widmo $\mathrm{sinc}$, ortogonalność, synteza IFFT/FFT, splot kołowy, okienkowanie, zero-padding): cytujemy podręcznik akademicki **`zielinski2007`** lub monografię **`braun2014`**. Nie cytujemy prac aplikacyjnych ani dyplomowych (np. `sorbianWykorzystanieSieciWifi2025`) do elementarnych praw DSP.
   - *Parametry warstw fizycznych Wi-Fi*: cytujemy bezpośrednio standardy IEEE **`1999`** i **`2021`**.
   - *Zjawiska i algorytmy radaru pasywnego*: cytujemy pierwotną lub kluczową pracę dla danego zagadnienia (`sturm2011a`, `braun2014`, `wypich2026`, `colone2014`, `diseglioReducingComputationalComplexity2022`, `bradshawAlternativeDopplerExtraction`, `zhuCommodityWiFiBasedWireless2024`).
4. **Elastyczność budżetu równań i zapożyczanie wzorów:** Dopuszcza się odejście od pierwotnej liczby równań w poszczególnych podrozdziałach (dodanie lub pominięcie wzoru), jeżeli służy to przejrzystości wywodu lub bezpośrednio wyjaśnia operację w kodzie symulatora (`lib/`). Zapożyczane wzory muszą pochodzić z zaufanych, cytowalnych źródeł (w szczególności **`braun2014`**, **`zielinski2007`**, **`sturm2011a`**, **`wypich2026`**).

---

## 3. Zestawienie Tytułów i Uzasadnienie w Literaturze

| Nr | Tytuł w szablonie LaTeX | Rekomendowany tytuł w pracy | Kluczowe źródła bibliograficzne ([`thesis/bibliography.bib`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/bibliography.bib)) | Uzasadnienie w tekście, cel inżynierski i most badawczy |
| :---: | :--- | :--- | :--- | :--- |
| **2.1** | `Warstwa fizyczna standardu IEEE 802.11` | *jw.* | `1999` (rozdz. 17.3, tab. 78–79, rys. 107, 109), `2021` (rozdz. 27.3, tab. 27-10, 27-12, 27-13), `colone2014` (rozdz. I–II), `diseglioReducingComputationalComplexity2022` (rozdz. I–II), `zhuCommodityWiFiBasedWireless2024` (rozdz. 1, 5, tab. 12, 14), `sorbianWykorzystanieSieciWifi2025` (rozdz. 2.2–2.4), `sturm2011a` (rozdz. IV-B), `bradshawAlternativeDopplerExtraction` (rozdz. 2.1), `braun2014` (rozdz. 3.3.8, 3.6.2), `wypich2026` (rozdz. 1, 4.4) | Struktura ramki PPDU (preambuła L-STF/L-LTF/HE-LTF vs. pole DATA), alokacja podnośnych (52 w 802.11a vs. 242 w 802.11ax, skalowanie 40/80/160 MHz), podnośne zerowe DC i pasma ochronne; uzasadnienie użycia pola danych zamiast samej preambuły/pilotów. *(Zweryfikowano i zaktualizowano w tekście — pkt 4.1).* |
| **2.2** | `Model matematyczny sygnału OFDM` | *jw.* | `braun2014` (rozdz. 3.1–3.2, 3.6.2 tab. 3.7, Dodatek A), `sturm2011a` (rozdz. II równ. 2–3, rozdz. IV-C), `1999` (rozdz. 17.3.2.4 równ. 3, rozdz. 17.3.5.9 równ. 22), `2021` (rozdz. 27.3.10), `zielinski2007` (rozdz. 4.3, 8.1.4, 13.4, 23.2, 23.4 rys. 23.8), `sorbianWykorzystanieSieciWifi2025` (rozdz. 2.3 rys. 2.5–2.6), `wypich2026` (rozdz. 5) | Ortogonalność podnośnych $\Delta f = 1/T_u$, synteza IFFT/FFT, prefiks cykliczny $T_{\mathrm{CP}} \ge \tau_{\max}$ (w tym $1{,}6/3{,}2\ \mu\text{s}$ w 802.11ax), zamiana splotu liniowego na kołowy, właściwości amplitudowe symboli $X[k,l]$. *(Zweryfikowano i zaktualizowano w tekście — pkt 4.2).* |
| **2.3** | `Geometria pomiarowa i parametry radaru OFDM` | **Geometria pomiarowa i parametry radaru: konfiguracja współlokowana (monostatyczna)** | `sturm2011a` (rozdz. II rys. 2, rozdz. III-D równ. 11–12, rozdz. IV-C tab. 2, rozdz. VI równ. 35–37), `braun2014` (rozdz. 3.2 rys. 3.3 i równ. 3.14–3.15, rozdz. 3.2.2 równ. 3.25–3.26, rozdz. 3.3.1 równ. 3.35, rozdz. 3.6.1–3.6.2 tab. 3.6–3.7), `colone2014` (rozdz. III–IV rys. 3a, równ. 8–9), `diseglioReducingComputationalComplexity2022` (rozdz. II), `wypich2026` (rozdz. 2 równ. 1–3, rozdz. 4.2–4.3), `zhuCommodityWiFiBasedWireless2024` (rozdz. 2.1 równ. 2), `sorbianWykorzystanieSieciWifi2025` (rozdz. 1.2, 1.4), `zielinski2007` (rozdz. 4.5, 7.1) | Redukcja z układu bistatycznego ($L_B \to 0, \beta \to 0^\circ$) do konfiguracji współlokowanej (quasi-monostatycznej / ISAC); znany sygnał referencyjny bez szumu toru odniesienia; model kanału $h(\tau, t)$; moc szumu termicznego $P_N$ i rozgraniczenie komunikacyjnego $\text{CNR}$ / $\text{SNR}_{\mathrm{comm}}$ od radarowego $\text{SNR}_{\mathrm{target}}$; wyprowadzenie $\Delta R, \Delta R_{\mathrm{act}}, R_{\max}, \Delta v, v_{\mathrm{unamb}}, v_{\max}$ (dla $k_{\mathrm{PRI}}=1$ i czasu wolnego $T_{\mathrm{PRI}}=k_{\mathrm{PRI}}T_{\mathrm{sym}}$). **Podstawa pod E1 i E2.** |
| **2.4** | `Estymacja kanału` | **Estymacja częstotliwościowej odpowiedzi kanału (CFR)** | `sturm2011a` (rozdz. IV-A i IV-B równ. 15–20, rys. 9), `braun2014` (rozdz. 3.2 równ. 3.17–3.19, rozdz. 3.5, Dodatek A równ. A.1–A.2 rys. A.1), `diseglioReducingComputationalComplexity2022` (rozdz. III–IV równ. 11–13, rozdz. V), `colone2014` (rozdz. II równ. 6–7), `bradshawAlternativeDopplerExtraction` (rozdz. 1.1.3 równ. 1.2, rozdz. 2.1 równ. 2.14), `wypich2026` (rozdz. 1–2 równ. 4, rozdz. 4.3, rozdz. 5 rys. 16), `zhuCommodityWiFiBasedWireless2024` (rozdz. 2.1 równ. 1, 3–4), `sorbianWykorzystanieSieciWifi2025` (rozdz. 3.1 równ. 3.1–3.2), `zielinski2007` (rozdz. 9.5, 23.6.4 rys. 23.21) | Odejście od CAF na rzecz estymacji w dziedzinie podnośnych (eliminacja listków bocznych danych oraz redukcja złożoności z $O(N^2)$ do $O(KM\log_2(KM))$); estymatory Zero-Forcing (ZF / RpF) i Matched Filter (MF); analityczne zjawisko *noise enhancement* $\zeta_{\mathrm{ZF}} = \mathbb{E}[\|X\|^2]\mathbb{E}[1/\|X\|^2]$ dla QAM. **Podstawa pod E3.** |
| **2.5** | `Filtracja ech stałych` | **Tłumienie ech stałych i kompensacja luki DC** | `bradshawAlternativeDopplerExtraction` (rozdz. 1.1.3, rozdz. 3.4 równ. 3.9–3.10), `diseglioReducingComputationalComplexity2022` (rozdz. III rys. 2), `colone2014` (rozdz. II–III równ. 1–5, rys. 4, 8), `wypich2026` (rozdz. 2, 3.2, 4.2, rys. 16), `zhuCommodityWiFiBasedWireless2024` (rozdz. 4 str. 15), `braun2014` (rozdz. 3.3.8 równ. 3.104–3.113, rys. 3.16–3.18, rozdz. 3.6.2), `zielinski2007` (rozdz. 4.4, 8.5) | Tłumienie DPI i clutteru stacjonarnego w czasie wolnym po przejściu do dziedziny podnośnych (filtr MTI rzędu 0 / odjęcie średniej); mechanizm powstawania podłogi zakłóceń (*spur floor*) przez lukę DC oraz porównanie decymacji ($U=2$) z interpolacją liniową podnośnych DC. **Podstawa pod E4.** |
| **2.6** | `Wyznaczanie mapy Range–Doppler` | **Wyznaczanie mapy odległość–prędkość (Range–Doppler)** | `sturm2011a` (rozdz. IV-B równ. 21–27, rys. 10), `braun2014` (rozdz. 3.3 równ. 3.30–3.31, rozdz. 3.3.1 równ. 3.37–3.41, rozdz. 3.3.4 równ. 3.69–3.73, tab. 3.2), `wypich2026` (rozdz. 2 rys. 1), `zielinski2007` (rozdz. 8.3, 8.5.1 tab. 8-1 równ. 8.39–8.47 rys. 8.10, rozdz. 8.6, 9.7) | Dwuwymiarowy periodogram (IFFT po $k$, FFT po $l$ z dopełnianiem zerami), zysk przetwarzania koherentnego $G_p = 10\log_{10}(KM)$, dobór separowalnego okna Blackmana–Harrisa (PSLL $\approx -92\ \text{dB}$) eliminującego fałszywe alarmy kosztem poszerzenia listka głównego i straty przetwarzania. |
| **2.7** | `Detekcja i ekstrakcja celów` | **Detekcja progowa i iteracyjna ekstrakcja celów (algorytm Coherent CLEAN)** | `braun2014` (rozdz. 3.3.6 równ. 3.91–3.93, 3.98, rozdz. 3.3.7 równ. 3.99–3.102, rys. 3.15), `wypich2026` (rozdz. 4.3, 4.4 równ. 6, tab. 4), `colone2014` (rozdz. II str. 3489, rozdz. III str. 3491) | Ograniczenia progowania globalnego i zjawisko maskowania celów w CA-CFAR; odporna estymacja szumu tła (MAD, rozkład Rayleigha); algorytm Coherent CLEAN (iteracyjna dekompozycja i koherentne odejmowanie repliki celu z listkami); metryka kontrastu PNFR. **Podstawa pod E5.** |

### 3.1. Kompletna Mapa Źródeł Bibliograficznych z `references/Zotero/` (11 pozycji)

Wszystkie 11 pozycji zapisanych w [`references/Zotero/Zotero.bib`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/references/Zotero/Zotero.bib) (oraz w [`thesis/bibliography.bib`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/bibliography.bib)) musi zostać jawnie zacytowanych w pracy (`\cite{...}`), aby żadna pozycja nie pozostała „wisząca”. Poniższa tabela stanowi pełne mapowanie zweryfikowanych plików PDF z [`references/Zotero/files/`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/references/Zotero/files):

| Klucz BibTeX (`Zotero.bib`) | Autorzy / Dokument (Rok) | Plik PDF w `references/Zotero/files/` | Zweryfikowane rozdziały, wzory, tabele i rysunki w źródle | Podrozdziały w Rozdz. 2 |
| :--- | :--- | :--- | :--- | :---: |
| `1999` | IEEE Std 802.11a (1999) | `30/1999 - IEEE standard...` | Rozdz. 17.3: tab. 78–79 (parametry OFDM i MCS), rys. 107 (PPDU), rys. 109 (52 podnośne), rozdz. 17.3.2.4 równ. (3), rozdz. 17.3.5.8–17.3.5.9 równ. (22) | 2.1, 2.2 |
| `2021` | IEEE Std 802.11ax (2021) | `32/2021 - IEEE standard...` | Rozdz. 27.3.2.3–27.3.2.4 (tab. 27-10 podnośne zerowe), rozdz. 27.3.4 (HE-SU PPDU), rozdz. 27.3.9 (tab. 27-12–27-13: 256-FFT, 242 aktywne, 3 DC, $\Delta f = 78{,}125\ \text{kHz}$), rozdz. 27.3.10, 27.5 (MCS 0..11 do 1024-QAM) | 2.1, 2.2 |
| `bradshawAlternativeDopplerExtraction` | Bradshaw (2021) | `4/Bradshaw - 2021...` | Rozdz. 1.1.3 (str. 3, równ. 1.2 CAF i limitacja SIR przez DPI), rozdz. 2.1 (str. 12–15, równ. 2.14 ekstrakcja Dopplera przez dzielenie przez symbole bez anteny ref.), **rozdz. 3.4 *DC Component Removal*** (str. 42–44, równ. 3.9–3.10 odejmowanie średniej w oknie) | 2.1, 2.4, 2.5 |
| `braun2014` | Braun (2014) | `38/Braun - 2014...` | Rozdz. 3.1 (str. 11–18), rozdz. 3.2 (str. 18–24, rys. 3.3, równ. 3.14–3.19, 3.25–3.26), rozdz. 3.3.1–3.3.4 (str. 26–45, równ. 3.30–3.41, 3.69–3.73, tab. 3.2), rozdz. 3.3.6–3.3.7 (str. 52–63, równ. 3.91–3.93, 3.98–3.102, rys. 3.15), rozdz. 3.3.8 (str. 62–68, równ. 3.104–3.113, rys. 3.16–3.18), rozdz. 3.5 (str. 77–78), rozdz. 3.6.1–3.6.2 (str. 79–90, tab. 3.6–3.7), Dodatek A (str. 147–149, równ. A.1–A.2, rys. A.1) | 2.1–2.7 |
| `colone2014` | Colone, Pastina, Falcone, Lombardo (2014) | `48/Colone et al. - 2014...` | Rozdz. I–II (str. 3486–3489: Wi-Fi PBR krótkiego zasięgu, pobór ref. z łącza lub demodulacji, maskowanie i silny clutter, ECA/ECA-B równ. 1–5, 2D-CCF równ. 6–7, CA-CFAR), rozdz. III–IV (str. 3490–3493: geometria quasi-monostatyczna $\beta=0^\circ$ rys. 3a, równ. 8–9, mapa z clutterem $>50\ \text{dB}$ rys. 4 i 8, cross-shape CA-CFAR str. 3491) | 2.1, 2.3, 2.4, 2.5, 2.7 |
| `diseglioReducingComputationalComplexity2022` | Di Seglio, Filippini, Chetty, Colone (2022) | `17/Di Seglio et al. - 2022...` | Rozdz. I–II (str. 1–2: Wi-Fi PBR krótkiego zasięgu, scenariusz semi-kooperacyjny z dostępem do AP lub demodulacją), rozdz. III (str. 3, rys. 2: odwrócenie kolejności kompresja odległościowa $\to$ redukcja clutteru, redukcja FLOP o 53%), rozdz. IV–V (str. 4–6, równ. 11–13, rys. 3, 5: *Reciprocal Filter* RpF $S^{(p)}/R^{(p)}$ w paśmie użytecznym $B=16{,}6\ \text{MHz}$, strata SNR vs MF) | 2.1, 2.3, 2.4, 2.5 |
| `sorbianWykorzystanieSieciWifi2025` | Sorbian (2025) *(w Zotero przypięty plik źródłowy pracy końcowej WAT 2024 o tym samym tytule)* | `25/Sorbian - 2025...` | Rozdz. 1.2 i 1.4 (str. 8–12: monostatyczny vs bistatyczny/pasywny, detekcja z estymacji CSI bez osobnej anteny ref.), rozdz. 2.2–2.4 (str. 14–20: tab. 2.2 ewolucja PHY, rys. 2.5 $\mathrm{sinc}$ i ortogonalność, rys. 2.6 IDFT/DFT, rys. 2.7 podnośne 802.11a, tab. 2.3 MCS, rys. 2.8–2.9 PPDU), rozdz. 3.1 (str. 21–22, równ. 3.1–3.2 model wielodrogowy i CSI) | 2.1, 2.2, 2.3, 2.4 |
| `sturm2011a` | Sturm & Wiesbeck (2011) | `65/Sturm i Wiesbeck - 2011...` | Rozdz. II (str. 1238–1240, równ. 2–3, rys. 1–2: sygnał ciągły OFDM, $\Delta f = 1/T$, CP), rozdz. III-D (str. 1244, równ. 11–12: dwudrożny Doppler), rozdz. IV-A/B (str. 1245–1250, równ. 13–27, rys. 8–10: paradygmat *Modulation Symbol Domain*, brak listków korelacji danych $-15/-30\ \text{dB}$, $(\mathbf{D}_{\mathrm{div}})$, IDFT/DFT, $G_P = N_c N_{\mathrm{sym}}$), rozdz. IV-C i VI (str. 1248–1249, 1256–1257, tab. 2–3, równ. 35–38: kompromis $R_{\max}$ vs $v_{\mathrm{unamb}}$ i szum termiczny $P_N = k B T_{\mathrm{abs}} NF$) | 2.1, 2.2, 2.3, 2.4, 2.6 |
| `wypich2026` | Wypich & Zieliński (2026) | `36/Wypich i Zielinski - 2026...` | Rozdz. 1–2 (str. 1–6, równ. 1–4, rys. 1: model kanału LTV z LOS $p=0$, estymacja TV-CFR z danych i pilotów, RVM przez IFFT/FFT), rozdz. 3.2 (str. 9: interpolacja liniowa brakujących próbek CFR, clutter zerowego Dopplera), rozdz. 4.2–4.4 (str. 13–20: wady CAF na powtarzalnych strukturach, wzrost POD 24–32% $\to$ 77–78%, równ. 6 definicja PNFR), rozdz. 5 (str. 23–25, rys. 16: spadek PNFR o ~4,5 dB dla 256-QAM vs 4-QAM) | 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7 |
| `zhuCommodityWiFiBasedWireless2024` | Zhu et al. (2024) | `7/Zhu et al. - 2024...` | Rozdz. 1 i 2.1 (str. 1–3, równ. 1–4: przegląd Wi-Fi Sensing/ISAC i 802.11bf, $Y=HX+N$, CIR i próbkowana CFR), rozdz. 4 (str. 14–15: ograniczenie zasięgu przez silny sygnał bezpośredni LOS i szum sprzętowy), rozdz. 5 (str. 16–17, tab. 12, 14: narzędzia CSI dla 802.11ax, nierównomierny/niski odstęp pakietowy a przepływność) | 2.1, 2.3, 2.4, 2.5 |
| `zielinski2007` | Zieliński (2007) | `63/Zieliński - 2007...` | Rozdz. 4.3–4.5 (str. 79–96: transformaty, widmo iloczynu i splotu, twierdzenie o próbkowaniu), rozdz. 7.1 (str. 173–178: aliasing), rozdz. 8.1.4, 8.3, 8.5.1, 8.6 (str. 198–225: DFT, przeciek widmowy, okna kosinusowe tab. 8-1 równ. 8.39–8.47 rys. 8.10, zero-padding str. 206 i 224–225), rozdz. 9.5 i 9.7 (str. 241–258: FFT i 2D DFT), rozdz. 13.4 (str. 364–370: splot liniowy a kołowy), rozdz. 23.2, 23.4, 23.6.4 (str. 745–770: wielotonowe OFDM/DMT, rola CP rys. 23.8, korekcja częstotliwościowa FEQ rys. 23.21) | 2.2, 2.3, 2.4, 2.5, 2.6 |

### 3.2. Zasada ewolucji zawartości i synchronizacji z Rozdziałami 3 i 4
Zgodnie z kolejnością prac w [`docs/plan_work_order.md`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/docs/plan_work_order.md) (Kroki 10–12), finalne domknięcie Rozdziału 2 następuje po opracowaniu Rozdziałów 3 i 4. W związku z tym niniejszy plan uwzględnia **możliwe zmiany zawartości** zarówno w jeszcze nienapisanych sekcjach 2.3–2.7, jak i w zredagowanych już sekcjach 2.1–2.2 (`thesis/tex/20_passive_radar.tex`, linie 16–111):
* **Zachowanie dorobku 2.1–2.2:** Istniejąca struktura, tabela `tab:wifi_params`, rysunek `fig:subcarrier_allocation` oraz trzy równania (`eq:ofdm_continuous`, `eq:ofdm_discrete_ifft`, `eq:ofdm_symbol_duration`) pozostają nienaruszoną bazą merytoryczną.
* **Korekta cytowań i oznaczeń w 2.1–2.2:** Usunięcie dwóch martwych kluczy (`storrer2021`, `zotero-item-46`) nieistniejących w `Zotero.bib` oraz uzupełnienie odniesień do nowych pozycji (`sturm2011a`, `bradshawAlternativeDopplerExtraction`, `zhuCommodityWiFiBasedWireless2024`, `diseglioReducingComputationalComplexity2022`, `zielinski2007`).
* **Ewentualne zmiany zawartości pod Rozdziały 3 i 4:** Możliwe doprecyzowanie spójności z parametrami skryptów eksperymentalnych (np. obsługa pasm 40/80/160 MHz z `tab:wifi_params` w 2.1/2.3, definicja kroku czasu wolnego $T_{\mathrm{PRI}} = k_{\mathrm{PRI}} T_{\mathrm{sym}}$ dla scenariusza E2, dopięcie etykiet `\ref{subsec:sim_...}` w `40_simulation_results.tex` i opis równoważności definicji PNFR w mocy vs amplitudzie).

---

## 4. Szczegółowy Plan Redakcji Podrozdziałów (Krok po Kroku)

### Podrozdział 2.1: Warstwa fizyczna standardu IEEE 802.11
- [x] **Status tekstu bazowego:** Napisany w pliku [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L16-L70).
- **Objętość:** ~1,5 strony.
- **Zrealizowana zawartość (zachowana w całości):**
  - Tabela `tab:wifi_params`: Zestawienie 802.11a (Non-HT) vs. 802.11ax (HE-SU, 20 MHz).
  - Rysunek `fig:subcarrier_allocation`: Widmo podnośnych (dane, piloty, pasma ochronne, luka DC).
  - Opis podziału ramki PPDU (preambuła vs. pole DATA) i uzasadnienie wykorzystania pola danych (za Wypich & Zieliński 2026).
  - Wykaz bezpośrednich konsekwencji alokacji podnośnych dla parametrów radaru.
- **Zrealizowane korekty cytowań, uzupełnienia oraz korekty treści w `thesis/tex/20_passive_radar.tex` (linie 16–70):**
  - [x] **Linia 19 (usunięcie martwego klucza `storrer2021`):** Zastąpić `\cite{colone2014,storrer2021,sorbianWykorzystanieSieciWifi2025}` przez `\cite{colone2014,zhuCommodityWiFiBasedWireless2024,diseglioReducingComputationalComplexity2022,sorbianWykorzystanieSieciWifi2025}` (krótkiego zasięgu pasywny radar Wi-Fi i Wi-Fi Sensing we wnętrzach).
  - [x] **Linia 23 (`\caption` tabeli `tab:wifi_params`):** W razie rozszerzenia omówienia na pasma 40/80/160 MHz (E1) zachować obecne parametry dla 20 MHz i doprecyzować odwołanie do `\cite[rozdz.~17.3, tab.~78--79]{1999}` oraz `\cite[rozdz.~27.3.9, tab.~27-12 i~27-13]{2021}`.
  - [x] **Linia 46 (budowa PPDU i pola treningowe):** Obok `\cite{1999}` i `\cite{2021}` dodać `\cite[rozdz.~2.4, rys.~2.8--2.9]{sorbianWykorzystanieSieciWifi2025}` przy opisie L-STF/L-LTF/SIGNAL oraz `\cite[rozdz.~27.3.4]{2021}` dla HE-SU.
  - [x] **Linia 50 (usunięcie martwego klucza `zotero-item-46`):** Przy opisie wyłącznego użycia preambuły i nieregularnych przerw między pakietami zastąpić `\cite{zotero-item-46}` przez `\cite{zhuCommodityWiFiBasedWireless2024,wypich2026,colone2014}` (w `zhuCommodityWiFiBasedWireless2024` rozdz. 5 i tab. 14 opisano problem nieregularnej/niskiej częstości próbkowania pakietowego CSI i jej wpływ na przepływność, a w `wypich2026` rozdz. 1 str. 2 — ograniczenia rzadkich sygnałów pilotowych dla $v_{\max}$ i energii oświetlenia).
  - [x] **Linia 51–53 (wykorzystanie pola danych):** Obok `\cite{braun2014}` i `\cite{wypich2026}` dopisać pionierską pracę przetwarzania w dziedzinie symboli modulacji `\cite[rozdz.~IV-B]{sturm2011a}` oraz `\cite[rozdz.~2.1]{bradshawAlternativeDopplerExtraction}`.
  - [x] **Linia 62 (alokacja podnośnych i wyzerowanie DC):** Dodać `\cite[rozdz.~2.3, rys.~2.7]{sorbianWykorzystanieSieciWifi2025}` (indeksy podnośnych i piloty $\pm 7, \pm 21$ w 802.11a) oraz `\cite[rozdz.~27.3.2.3, tab.~27-10]{2021}` (3 puste podnośne DC w 802.11ax 20 MHz chroniące przed wyciekiem częstotliwości nośnej i offsetem DC).
  - [x] **Zrealizowana korekta treści (linie 66–70):** Przy ewentualnej aktualizacji pod Eksperyment E1 doprecyzować, że dla szerszych kanałów 802.11ax (40/80/160 MHz) liczba podnośnych aktywnych i szerokość luki DC rosną zgodnie z `tab. 27-13` w `\cite{2021}` (odpowiednio 484/5 DC, 996/5 DC, 1992/23 DC).

---

### Podrozdział 2.2: Model matematyczny sygnału OFDM
- [x] **Status tekstu bazowego:** Napisany w pliku [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L72-L111).
- **Docelowa objętość:** 1,2–1,5 strony (~450 słów).
- **Budżet:** 3 równania, 0 rysunków.
- **Zrealizowana zawartość (zachowana w całości):**
  - Akapit 1: Definicja ortogonalności $\Delta f = 1/T_u$ i widmo $\mathrm{sinc}$ podnośnych.
  - Akapit 2: Równanie sygnału ciągłego $s_l(t)$ pasma podstawowego (`eq:ofdm_continuous`).
  - Akapit 3–4: Dyskretna postać IFFT $s[n,l]$ (`eq:ofdm_discrete_ifft`), definicja $T_{\mathrm{sym}} = T_u + T_{\mathrm{CP}}$ (`eq:ofdm_symbol_duration`) oraz dowód ochrony przed ISI i zamiany splotu liniowego na kołowy dzięki prefiksowi cyklicznemu.
  - Akapit 5: Właściwości symboli $X[k,l]$ — stała energia w preambule/pilotach ($|X|=1$) vs. zmienna energia w konstelacjach QAM pola danych.
- **Zrealizowane korekty cytowań, uzupełnienia oraz korekty treści w `thesis/tex/20_passive_radar.tex` (linie 72–111):**
  - [x] **Linia 75 (ortogonalność $\Delta f = 1/T_u$ i widmo $\mathrm{sinc}$):** Obok `\cite{braun2014}` i `\cite{sorbianWykorzystanieSieciWifi2025}` dodać `\cite[rozdz.~II, równ.~(3)]{sturm2011a}` oraz `\cite[rozdz.~4.3 i~23.2]{zielinski2007}`.
  - [x] **Linia 77–81 (sygnał ciągły `eq:ofdm_continuous`):** Obok `\cite[rozdz.~3.1]{braun2014}` dodać `\cite[rozdz.~II, równ.~(2)]{sturm2011a}` oraz `\cite[rozdz.~17.3.2.4, równ.~(3)]{1999}` (oraz dla 802.11ax `\cite[rozdz.~27.3.10]{2021}`).
  - [x] **Linia 92–96 (synteza dyskretna IFFT `eq:ofdm_discrete_ifft`):** Dodać `\cite[rozdz.~8.1.4 i~23.4]{zielinski2007}` przy przejściu z sygnału ciągłego na dyskretną syntezę IFFT.
  - [x] **Linia 106 (usunięcie martwego klucza `storrer2021` w punkcie 1 korzyści CP):** Przy $\Delta R_{\mathrm{CP}} = c T_{\mathrm{CP}}/2 \approx 120\ \text{m}$ zastąpić `\cite{storrer2021}` przez `\cite[rozdz.~3.6.2, tab.~3.7]{braun2014}` (gdzie wartość $d_{\max} \le 120\ \text{m}$ dla 802.11a wynika wprost z $T_{\mathrm{CP}} = 0{,}8\ \mu\text{s}$), uzupełniając o `\cite[rozdz.~IV-C]{sturm2011a}` oraz `\cite[rozdz.~4]{zhuCommodityWiFiBasedWireless2024}` (zasięg wewnątrzbudynkowy).
  - [x] **Linia 107 (punkt 2 korzyści CP — splot liniowy $\to$ kołowy):** Obok `\cite[rozdz.~3.2]{braun2014}` dodać odwołanie do podręcznika `\cite[rozdz.~13.4 i~23.4, rys.~23.8]{zielinski2007}` (gdzie rys. 23.8 bezpośrednio ilustruje zamianę splotu na kołowy dzięki skopiowaniu prefiksu).
  - [x] **Linia 110 (wzmocnienie szumu przy zmiennej amplitudzie QAM):** Obok `\cite{1999,2021}` i `\cite[rozdz.~5]{wypich2026}` dopisać `\cite[Dodatek~A, str.~147--149]{braun2014}`.
  - [x] **Zrealizowana korekta treści (linie 106–110):** W razie rozszerzenia dyskusji o dłuższe prefiksy cykliczne w 802.11ax ($T_{\mathrm{CP}} \in \{1{,}6;\ 3{,}2\}\ \mu\text{s}$) z `tab:wifi_params` można jednym zdaniem zaznaczyć, że zwiększa to $\Delta R_{\mathrm{CP}}$ odpowiednio do $240\ \text{m}$ i $480\ \text{m}$, lecz kosztem dłuższego symbolu $T_{\mathrm{sym}}$ i zwężenia okna prędkości jednoznacznej (co wiąże się bezpośrednio z podrozdziałem 2.3).

---

### Podrozdział 2.3: Geometria pomiarowa i parametry radaru: konfiguracja współlokowana (monostatyczna)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L112).
- **Docelowa objętość:** 1,5 strony (~500 słów).
- **Budżet:** 6–7 równań, 0 rysunków.
- **Plan akapitów (z zachowaniem wynikowości, bez skrótów myślowych i z pełnym cytowaniem Zotero):**
  - [ ] **Akapit 1: Od układu bistatycznego do konfiguracji współlokowanej (quasi-monostatycznej).**
    - Wyjaśnienie: W klasycznych dalekosiężnych radarach pasywnych PBR (iluminatory FM/DVB-T) nadajnik Tx i odbiornik Rx dzieli duża odległość bazowa $L_B$, co wymusza dedykowany kanał referencyjny z anteną kierunkową skierowaną na nadajnik i prowadzi do geometrii eliptycznej (`\cite[rozdz.~1.2 i~1.4]{sorbianWykorzystanieSieciWifi2025}`, `\cite[rozdz.~1.1.3]{bradshawAlternativeDopplerExtraction}`).
    - W radarze Wi-Fi krótkiego zasięgu oraz systemach RadCom/ISAC (`\cite[rozdz.~I--II, rys.~2]{sturm2011a}`, `\cite[rozdz.~3.2, rys.~3.3]{braun2014}`, `\cite[rozdz.~III--IV, rys.~3a, równ.~(8)--(9)]{colone2014}`): odbiornik radarowy jest **współlokowany z punktem dostępowym Wi-Fi** (wspólna platforma lub sprzęgacz kierunkowy, $x_{\mathrm{RX}}=0, y_{\mathrm{RX}}=0$) albo odległość do celów znacznie przewyższa rozstaw anten ($R \gg L_B$, przybliżenie quasi-monostatyczne).
    - Bezpośrednie konsekwencje inżynierskie: baza $L_B \to 0$ oraz kąt bistatyczny $\beta \to 0^\circ$ (`\cite[rozdz.~IV, równ.~(9)]{colone2014}`). W układzie semi-kooperacyjnym wektor symboli referencyjnych $X[k,l]$ jest znany bezpośrednio z nadajnika lub sprzęgacza (`\cite[rozdz.~II]{diseglioReducingComputationalComplexity2022}`, porównaj z idealnym odniesieniem *genie-aided* w `\cite[rozdz.~4.3]{wypich2026}`), co eliminuje szum toru odniesienia oraz zniekształcenia geometrii bistatycznej. (Wariant bez dostępu do nadajnika wymaga lokalnej demodulacji i rekonstrukcji symboli `\cite{colone2014,wypich2026}`).
  - [ ] **Akapit 2: Model kanału wielodrogowego oraz bilans mocy i szumu termicznego.**
    - Dwudrożne opóźnienie echa dla odległości radialnej $R_p$: $\tau_p = \frac{2 R_p}{c}$ (czynnik 2 wynika z propagacji fali tam i z powrotem), stąd zależność pomiarowa $R_p = \frac{c \tau_p}{2}$ (`\cite[rozdz.~3.2, równ.~(3.14)]{braun2014}`).
    - Dwudrożne przesunięcie Dopplera dla prędkości radialnej $v_p$: $f_{D,p} = \frac{2 v_p f_c}{c} = \frac{2 v_p}{\lambda}$, w odróżnieniu od jednodrożnego przesunięcia $v_p f_c / c$ w łączności bezprzewodowej (`\cite[rozdz.~III-D, równ.~(11)--(12)]{sturm2011a}`, `\cite[rozdz.~3.2, równ.~(3.15)]{braun2014}`).
    - Czasowo-zmienna odpowiedź impulsowa kanału w obecności przesłuchu bezpośredniego (DPI) i $P$ celów ruchomych (`\cite[rozdz.~2, równ.~(1)--(3)]{wypich2026}`, `\cite[rozdz.~2.1, równ.~(2)]{zhuCommodityWiFiBasedWireless2024}`):
      $$h(\tau, t) = A_{\mathrm{DPI}} \delta(\tau) + \sum_{p=1}^P A_p e^{j 2\pi f_{D,p} t} \delta(\tau - \tau_p)$$
      gdzie składowa bezpośrednia (DPI) oraz odbicia stacjonarne charakteryzują się zerowym przesunięciem Dopplera ($f_D = 0$), przy czym dla DPI opóźnienie wynosi $\tau = 0$.
    - Bilans mocy, szum termiczny odbiornika i rozgraniczenie pojęć SNR (`\cite[rozdz.~3.3.1, równ.~(3.35) i~rozdz.~3.6.2]{braun2014}`, `\cite[rozdz.~VI, równ.~(35)--(37), tab.~3]{sturm2011a}`, `\cite[rozdz.~27.3.18]{2021}`):
      $$P_N = k_B T_0 B \cdot \mathrm{NF}$$
      gdzie $k_B$ to stała Boltzmanna, $T_0$ to temperatura szumowa odniesienia ($290\ \text{K}$), $B$ to szerokość pasma odbiornika, a $\mathrm{NF}$ to współczynnik szumów (dla komercyjnych układów Wi-Fi $\mathrm{NF} \approx 6\text{--}8\ \text{dB}$, co zgodnie ze standardem IEEE 802.11ax daje poziom szumów $P_N \in [-95, -86]\ \text{dBm}$ dla pasm $20\text{--}160\ \text{MHz}$). Przy stałej dopuszczalnej mocy wypromieniowanej EIRP punktu dostępowego (np. $P_{\mathrm{tx}} = 100\ \text{mW} = 20\ \text{dBm}$ wg `\cite[rozdz.~3.6.2]{braun2014}`) dwukrotne poszerzenie kanału zwiększa $P_N$ o $+3\ \text{dB}$, co dla przejścia z 20 MHz na 160 MHz skutkuje wzrostem poziomu szumów o $10\log_{10}(160/20) \approx 9{,}03\ \text{dB}$.
    - **Rozgraniczenie aparatu pojęciowego (nomenklatura komunikacyjna vs. radarowa):**
      1. Komunikacyjny stosunek nośnej do szumu fali bezpośredniej: $\mathrm{CNR}$ (lub $\mathrm{SNR}_{\mathrm{comm}} = P_{\mathrm{rx, dir}} / P_N$), wynikający z bilansu łącza punktu dostępowego z odległości kilku metrów (moc odebrana $P_{\mathrm{rx, dir}} \approx -65\ \text{dBm}$). Uzasadnienie przyjęcia w symulatorze ([`src/step2_channel.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/src/step2_channel.m)) wartości bazowej $\mathrm{SNR} = 25\ \text{dB}$ jako realistycznego punktu pracy komercyjnego odbiornika z marginesem na tłumienie przeszkód i straty sprzęgacza.
      2. Stosunek fali bezpośredniej do echa celu: $\mathrm{DPR} = P_{\mathrm{rx, dir}} / P_{\mathrm{target}}$ (lub $\mathrm{SIR} = P_{\mathrm{target}} / P_{\mathrm{DPI}}$), rzędu $40\text{--}60\ \text{dB}$, gdzie fala bezpośrednia stanowi najsilniejsze zakłócenie maskujące (przesłuch bezpośredni DPI).
      3. Radarowy stosunek echa celu do szumu na wejściu: $\mathrm{SNR}_{\mathrm{target}} = P_{\mathrm{target}} / P_N = \mathrm{SNR}_{\mathrm{comm}} / \mathrm{DPR}$, który przed kompresją impulsów/widma jest **ujemny** (typowo $-15$ do $-25\ \text{dB}$ — cel znajduje się poniżej szumów termicznych odbiornika).
      4. Most do podrozdziału 2.6: uzasadnienie konieczności zysku całkowania koherentnego 2D-FFT $G_p = 10\log_{10}(K_{\mathrm{act}} M) \approx +38\ \text{dB}$, który wynosi echo celu z ujemnego $\mathrm{SNR}_{\mathrm{target}}$ ponad próg detekcji na wynikowej mapie Range-Doppler.
  - [ ] **Akapit 3: Parametry siatki czas–częstotliwość i granice jednoznaczności.**
    - Pełne wyprowadzenie 5 parametrów, w 100% zgodnych z kodem [`lib/calculate_physical_axes.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/calculate_physical_axes.m), `\cite[rozdz.~3.2.2, równ.~(3.25)--(3.26) oraz rozdz.~3.6.1, równ.~(3.136)--(3.139)]{braun2014}` oraz `\cite[rozdz.~IV-C, tab.~2]{sturm2011a}`:
      1. Nominalny krok odległościowy siatki (dla częstotliwości próbkowania $f_s = B$): $\Delta R = \frac{c}{2 B}$, natomiast fizyczna rozdzielczość wynikająca z pasma aktywnych podnośnych $B_{\mathrm{act}} = K_{\mathrm{act}} \Delta f$ wynosi $\Delta R_{\mathrm{act}} = \frac{c}{2 B_{\mathrm{act}}}$ (z pominięciem czynnika poszerzenia od okna wagowego z pkt 2.6). Dla $B \in \{20, 40, 80, 160\}\ \text{MHz}$ krok nominalny wynosi odpowiednio $7{,}50\ \text{m}$, $3{,}75\ \text{m}$, $1{,}875\ \text{m}$ oraz $0{,}9375\ \text{m}$; dla 20 MHz pasma aktywnego odpowiada to $\Delta R_{\mathrm{act}} \approx 9{,}23\ \text{m}$ w 802.11a ($52$ podnośne, $16{,}25\ \text{MHz}$ — `\cite[tab.~3.7]{braun2014}`) oraz $\approx 7{,}93\ \text{m}$ w 802.11ax ($242$ podnośne, $18{,}91\ \text{MHz}$).
      2. Maksymalny zasięg jednoznaczny: $R_{\max} = \frac{c}{2 \Delta f}$ wynikający z próbkowania widma co $\Delta f$ (`\cite[rozdz.~3.2.2, równ.~(3.25)]{braun2014}`, `\cite[rozdz.~4.5]{zielinski2007}`): $480\ \text{m}$ dla 802.11a i $1920\ \text{m}$ dla 802.11ax (przy czym granica bez ISI wyznaczona przez $T_{\mathrm{CP}} = 0{,}8\ \mu\text{s}$ to $\Delta R_{\mathrm{CP}} = 120\ \text{m}$, `\cite[tab.~3.7]{braun2014}`).
      3. Rozdzielczość prędkości radialnej: $\Delta v = \frac{\lambda}{2 T_{\mathrm{CPI}}} = \frac{c}{2 f_c M T_{\mathrm{PRI}}}$ (gdzie $M$ to liczba próbek/symboli w oknie koherentnym CPI, $T_{\mathrm{CPI}} = M T_{\mathrm{PRI}}$, a $T_{\mathrm{PRI}} = k_{\mathrm{PRI}} T_{\mathrm{sym}}$ oznacza okres próbkowania w czasie wolnym).
      4. Pełna szerokość jednoznacznego okna prędkości: $v_{\text{unamb}} = \frac{\lambda}{2 T_{\mathrm{PRI}}} = \frac{c}{2 f_c T_{\mathrm{PRI}}}$ wynikająca z twierdzenia Nyquista–Shannona (`\cite[rozdz.~4.5 i~7.1]{zielinski2007}`, `\cite[rozdz.~3.2.2, równ.~(3.26)]{braun2014}`) dla próbkowania w czasie wolnym z krokiem $T_{\mathrm{PRI}}$: $|f_D| \le \frac{1}{2 T_{\mathrm{PRI}}}$.
      5. Maksymalna mierzalna prędkość radialna (symetryczna): $v_{\max} = \frac{v_{\text{unamb}}}{2} = \frac{c}{4 f_c T_{\mathrm{PRI}}}$, odpowiadająca przedziałowi jednoznaczności $v \in [-v_{\max}, +v_{\max}]$.
    - Zestawienie liczbowe dla $f_c = 5{,}5\ \text{GHz}$ (ukazujące wpływ wydłużenia symbolu $T_{\mathrm{sym}}$ z $4{,}0\ \mu\text{s}$ w 802.11a do $13{,}6\ \mu\text{s}$ w 802.11ax — stosunek $3{,}4\times$):
      - Przy przetwarzaniu ciągłym symbol po symbolu ($k_{\mathrm{PRI}} = 1$, pojedyncza długa ramka): $v_{\max} \approx 3409{,}1\ \text{m/s}$ ($v_{\text{unamb}} \approx 6818{,}2\ \text{m/s}$, zgodnie z `\cite[tab.~3.7]{braun2014}`) w 802.11a oraz $v_{\max} \approx 1002{,}7\ \text{m/s}$ ($v_{\text{unamb}} \approx 2005{,}3\ \text{m/s}$) w 802.11ax.
      - Przy próbkowaniu okresowym w czasie wolnym z odstępem $T_{\mathrm{PRI}} = k_{\mathrm{PRI}} T_{\mathrm{sym}}$ (np. wybrane symbole/pakiety w ruchu Wi-Fi, `\cite{colone2014,diseglioReducingComputationalComplexity2022,wypich2026}`; w badaniu E2 przyjęto $k_{\mathrm{PRI}} = 60$): granica symetryczna spada do $\pm 56{,}82\ \text{m/s}$ ($v_{\text{unamb}} = 113{,}64\ \text{m/s}$) dla 802.11a oraz $\pm 16{,}71\ \text{m/s}$ ($v_{\text{unamb}} = 33{,}42\ \text{m/s}$) dla 802.11ax — przekroczenie $16{,}71\ \text{m/s}$ wywołuje **aliasing Dopplera** (`\cite[rozdz.~7.1]{zielinski2007}`). *(Uwaga terminologiczna do spięcia z Rozdz. 4: na wykresach E2 symetryczną granicę $\pm v_{\max}$ oznacza się skrótowo jako $\pm v_{\mathrm{unamb}}$ jako połowę pełnego pasma jednoznacznego).*
  - [ ] **Akapit 4: Most do symulacji i badań.**
    - Wskazanie, że wyznaczone relacje stanowią podstawę implementacji osi w [`lib/calculate_physical_axes.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/calculate_physical_axes.m) oraz są bezpośrednio weryfikowane eksperymentalnie w Rozdziale 4:
      - **Eksperyment E1 (`\ref{subsec:sim_bandwidth_resolution}`):** badanie skalowania rozdzielczości $\Delta R$ i wzrostu poziomu szumów $P_N$ o $9{,}03\ \text{dB}$ przy stałej mocy AP dla pasm $B \in \{20, 40, 80, 160\}\ \text{MHz}$,
      - **Eksperyment E2 (`\ref{subsec:sim_doppler_aliasing}`):** weryfikacja zawijania widma Dopplera (aliasingu prędkości) przy przekroczeniu granicy $\pm 16{,}71\ \text{m/s}$ dla 802.11ax względem 802.11a.
- **Czego NIE pisać:**
  - Nie opisywać historii radaru (Hülsmeyer, Watson-Watt).
  - Nie wyprowadzać ogólnego równania radiolokacji z zyskami anten i całkowaniem po kącie bryłowym (wystarczy zależność szumu termicznego $P_N$ przy stałym EIRP).
  - Nie rysować trójkątów bistatycznych ani nie wyprowadzać równań elips bistatycznych.

---

### Podrozdział 2.4: Estymacja częstotliwościowej odpowiedzi kanału (CFR)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L115).
- **Docelowa objętość:** 2,0 strony (~600 słów).
- **Budżet:** 4 równania, 1 tabela porównawcza (ZF vs. MF).
- **Plan akapitów (z zachowaniem wynikowości, bez skrótów myślowych i z pełnym cytowaniem Zotero):**
  - [ ] **Akapit 1: Model odebranej macierzy podnośnych.**
    - Po usunięciu prefiksu cyklicznego CP i wykonaniu FFT w odbiorniku (zgodnie z dowiedzioną w 2.2 własnością splotu kołowego), sygnał w dziedzinie częstotliwości przyjmuje postać macierzy $Y[k,l]$ dla $k \in \mathcal{K}_{\mathrm{act}}$ oraz $l = 0, \dots, M-1$ (`\cite[rozdz.~IV-B, równ.~(15)--(17)]{sturm2011a}`, `\cite[rozdz.~3.2, równ.~(3.17)--(3.18)]{braun2014}`, `\cite[rozdz.~2.1, równ.~(1)]{zhuCommodityWiFiBasedWireless2024}`, `\cite[rozdz.~3.1, równ.~(3.1)]{sorbianWykorzystanieSieciWifi2025}`):
      $$Y[k,l] = H[k,l] X[k,l] + W[k,l]$$
      gdzie $X[k,l]$ to symbole odniesienia, $H[k,l]$ to poszukiwana częstotliwościowa odpowiedź kanału (CFR), a $W[k,l]$ to addytywny zespolony szum Gaussa (AWGN) o wariancji $\sigma_W^2$.
  - [ ] **Akapit 2: Paradygmat dziedziny podnośnych (CFR) a wzajemna funkcja niejednoznaczności (CAF).**
    - Porównanie z klasycznym radarem pasywnym wyznaczającym wzajemną funkcję niejednoznaczności (CAF) w czasie ciągłym przez dwuwymiarową korelację (`\cite[rozdz.~II, równ.~(6)--(7)]{colone2014}`, `\cite[rozdz.~1.1.3, równ.~(1.2)]{bradshawAlternativeDopplerExtraction}`).
    - W radarze OFDM estymacja w dziedzinie podnośnych (zwana też przetwarzaniem w dziedzinie symboli modulacji, `\cite[rozdz.~IV-A i~IV-B, rys.~9]{sturm2011a}`) eliminuje losową modulację danych bezpośrednio na macierzy $K \times M$. Usuwa to listki boczne autokorelacji sygnału komunikacyjnego (sięgające $-15\ \text{dB}$ od kształtu impulsu prostokątnego i $-30\ \text{dB}$ od korelacji losowych danych w `\cite[rozdz.~IV-B, rys.~9]{sturm2011a}` oraz artefakty od powtarzalnych struktur ramki w `\cite[rozdz.~4.3]{wypich2026}`). Dzięki zastosowaniu szybkich algorytmów FFT (`\cite[rozdz.~9.5]{zielinski2007}`) radykalnie spada także złożoność obliczeniowa względem korelacji w dziedzinie czasu z $O(N^2)$ do $O(K M \log_2(K M))$ (`\cite[rozdz.~3.5]{braun2014}`, `\cite[rozdz.~III--IV]{diseglioReducingComputationalComplexity2022}`).
  - [ ] **Akapit 3: Estymatory Zero-Forcing (ZF / Reciprocal Filter) oraz Matched Filter (MF).**
    - Estymator Zero-Forcing (filtr odwrotny w dziedzinie częstotliwości ze współczynnikiem regularyzacji $\varepsilon = 10^{-9}$ dla stabilności numerycznej; w literaturze analogiczny do *Reciprocal Filter* RpF w `\cite[rozdz.~IV, równ.~(12)--(13)]{diseglioReducingComputationalComplexity2022}`, dzielenia symbol po symbolu w `\cite[rozdz.~IV-B, równ.~(20)]{sturm2011a}`, `\cite[rozdz.~3.2, równ.~(3.19)]{braun2014}`, `\cite[rozdz.~2, równ.~(4)]{wypich2026}`, `\cite[rozdz.~3.1, równ.~(3.2)]{sorbianWykorzystanieSieciWifi2025}`, `\cite[rozdz.~2.1, równ.~(2.14)]{bradshawAlternativeDopplerExtraction}` oraz korektora częstotliwościowego FEQ w `\cite[rozdz.~23.6.4, rys.~23.21]{zielinski2007}`):
      $$\hat{H}_{\mathrm{ZF}}[k,l] = \frac{Y[k,l]}{X[k,l] + \varepsilon} = H[k,l] + \frac{W[k,l]}{X[k,l] + \varepsilon}$$
      *(Zaznaczyć za `\cite[rozdz.~IV]{diseglioReducingComputationalComplexity2022}`, że operację tę ogranicza się do aktywnych podnośnych pasma użytecznego $\mathcal{K}_{\mathrm{act}}$, zerując pasma ochronne aby nie wzmacniać szumu w pustych prążkach).*
    - Estymator Matched Filter (korelator częstotliwościowy odpowiadający klasycznemu dopasowaniu widmowemu `\cite{colone2014,diseglioReducingComputationalComplexity2022}`):
      $$\hat{H}_{\mathrm{MF}}[k,l] = Y[k,l] X^*[k,l] = H[k,l] |X[k,l]|^2 + W[k,l] X^*[k,l]$$
  - [ ] **Akapit 4: Zjawisko wzmocnienia szumu (*Noise Enhancement*) dla modulacji QAM.**
    - Wyjaśnienie bez skrótów myślowych: Wariancja szumu resztkowego w estymatorze ZF zależy od energii punktu konstelacji: $\sigma^2_{\mathrm{ZF}}[k,l] = \sigma_W^2 / |X[k,l]|^2$ (`\cite[Dodatek~A, równ.~(A.1)--(A.2)]{braun2014}`).
    - W preambule oraz dla modulacji BPSK/QPSK stała obwiednia daje $|X|^2 = 1$ — estymatory ZF i MF są tożsame co do modułu (`\cite[Dodatek~A, str.~148]{braun2014}`).
    - W polu danych przy modulacjach wielopoziomowych (16-QAM, 64-QAM, 1024-QAM) wewnętrzne punkty konstelacji mają energię wielokrotnie mniejszą od średniej ($|X|^2 \ll 1$). Dzielenie przez małą amplitudę w ZF/RpF powoduje gwałtowny wzrost wariancji szumu oraz zmienia jego rozkład na niegaussowski (`\cite[Dodatek~A, rys.~A.1]{braun2014}`, `\cite[rozdz.~IV--V]{diseglioReducingComputationalComplexity2022}`).
    - Wyprowadzenie bezwymiarowego, niezależnego od skali współczynnika degradacji szumowej Zero-Forcing (zgodnie z implementacją w [`lib/estimate_channel_zf.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/estimate_channel_zf.m)):
      $$\zeta_{\mathrm{ZF}} = \mathbb{E}\left[|X|^2\right] \cdot \mathbb{E}\left[\frac{1}{|X|^2}\right], \quad \zeta_{\mathrm{ZF}}\,[\text{dB}] = 10 \log_{10} \zeta_{\mathrm{ZF}}$$
      który dla BPSK/QPSK wynosi $0\ \text{dB}$, dla 16-QAM wzrasta o ok. $2{,}7\ \text{dB}$ (`\cite[Dodatek~A, str.~149]{braun2014}`), a w literaturze dla przejścia z 4-QAM na 256-QAM wykazano spadek kontrastu PNFR o ok. $4{,}5\ \text{dB}$ (`\cite[rozdz.~5, rys.~16]{wypich2026}`). Natomiast w estymatorze MF mnożenie przez $|X|^2$ pozostawia losową fluktuację amplitudy w sygnale celu, generując podwyższoną podłogę listków bocznych (`\cite[rozdz.~I i~IV]{diseglioReducingComputationalComplexity2022}`).
  - [ ] **Akapit 5: Most do symulacji i badań.**
    - Algorytm estymacji ZF oraz obliczanie współczynnika $\zeta_{\mathrm{ZF}}$ zaimplementowano w [`lib/estimate_channel_zf.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/estimate_channel_zf.m).
    - Analityczna zależność współczynnika $\zeta_{\mathrm{ZF}}$ oraz lustrzana degradacja kontrastu PNFR w funkcji rzędu modulacji MCS 0..11 jest przedmiotem badań w **Eksperymencie E3 (`\ref{subsec:sim_mcs_noise_enhancement}`) w Rozdziale 4**.
- **Tabela:** Porównanie cech ZF (RpF) i MF (odporność na listki boczne modulacji, odporność na wzmocnienie szumu dla BPSK vs 16/64/1024-QAM, złożoność obliczeniowa).
- **Czego NIE pisać:** Nie wyprowadzać estymatorów LMMSE (brak estymacji macierzy kowariancji kanału i SNR na poziomie odbiornika radarowego).

---

### Podrozdział 2.5: Tłumienie ech stałych i kompensacja luki DC
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L118).
- **Docelowa objętość:** 1,5 strony (~450 słów).
- **Budżet:** 3 równania, 0 rysunków.
- **Plan akapitów (z zachowaniem wynikowości, bez skrótów myślowych i z pełnym cytowaniem Zotero):**
  - [ ] **Akapit 1: Problem przesłuchu bezpośredniego (DPI) i tła stacjonarnego.**
    - Wyjaśnienie fizyczne: Sygnał bezpośredni z nadajnika do odbiornika (DPI) oraz stacjonarne odbicia od ścian i mebli przewyższają moc echa małego celu ruchomego o 40–80 dB (`\cite[rozdz.~III, rys.~4a i~rozdz.~IV, rys.~8]{colone2014}`, `\cite[rozdz.~1.1.3 i~3.4]{bradshawAlternativeDopplerExtraction}`, `\cite[rozdz.~4, str.~15]{zhuCommodityWiFiBasedWireless2024}`, `\cite[rozdz.~5, rys.~16]{wypich2026}`).
    - Z powodu skończonego czasu obserwacji $T_{\mathrm{CPI}}$ (równoważnego wymnożeniu przez okno czasowe) listki boczne transformaty Fouriera dla częstotliwości Dopplera $f_D = 0$ rozlewają się wzdłuż osi prędkości (przeciek widmowy, `\cite[rozdz.~8.3]{zielinski2007}`), całkowicie maskując obiekty ruchome (`\cite[rozdz.~III, str.~3490]{colone2014}`).
  - [ ] **Akapit 2: Filtracja MTI w dziedzinie czasu wolnego.**
    - W architekturze radaru OFDM tłumienie składowej stałej realizuje się bezpośrednio na wyestymowanej macierzy $\hat{H}[k,l]$ wzdłuż wymiaru symboli $l$ (czasu wolnego), już po przejściu do dziedziny podnośnych i przed kompresją odległościową (`\cite[rozdz.~III, rys.~2]{diseglioReducingComputationalComplexity2022}`, gdzie wykazano korzyść obliczeniową takiego odwrócenia kolejności bloków względem klasycznego algorytmu ECA/ECA-B z `\cite{colone2014,wypich2026}`).
    - Filtr MTI rzędu zerowego — odjęcie wartości średniej po czasie wolnym w obrębie CPI dla każdej podnośnej niezależnie (`\cite[rozdz.~3.4 *DC Component Removal*, równ.~(3.9)--(3.10)]{bradshawAlternativeDopplerExtraction}`):
      $$\tilde{H}_{\mathrm{MTI}}[k,l] = \hat{H}[k,l] - \frac{1}{M} \sum_{m=0}^{M-1} \hat{H}[k,m]$$
    - Właściwość: operacja ta w punkcie $f_D = 0$ tworzy głębokie zero charakterystyki (wycinając DPI i echa stacjonarne o $\ge 40\ \text{dB}$), zachowując niemal nienaruszone przesunięcia fazowe celów ruchomych ($f_D \ne 0$).
  - [ ] **Akapit 3: Mechanizm powstawania listków bocznych przez lukę DC i jej interpolacja liniowa.**
    - Mechanizm fizyczny (`\cite[rozdz.~3.3.8 *Influence of the DC carrier*, równ.~(3.104)--(3.113), rys.~3.16--3.18]{braun2014}` oraz własność splotu widm w `\cite[rozdz.~4.4 i~8.5]{zielinski2007}`): Brak transmisji na podnośnej centralnej $k=0$ (oraz $k=\pm 1$ w 802.11ax) odpowiada odjęciu delty Diraca od funkcji okna w dziedzinie częstotliwości, $\tilde{w}(k) = w(k) - \delta(k)w(0)$. Po IFFT na osi odległości powstaje stały człon zakłócający o poziomie $1/N$ (tzw. *constant spur floor*, ograniczający dynamikę 802.11a przy oknie Hamminga do $\mathrm{PSR} \approx 27\ \text{dB}$ wg `\cite[przypis~12, str.~67]{braun2014}`).
    - Porównanie metod naprawy: W pracy `\cite[rozdz.~3.3.8 i~3.6.2]{braun2014}` zaproponowano decymację co drugiej podnośnej ($U=2$), co jednak marnuje połowę energii użytecznej ($-3\ \text{dB}$) i skraca dwukrotnie jednoznaczny zasięg $R_{\max}$. Zamiast tego w niniejszej pracy zastosowano **liniową interpolację brakujących podnośnych DC** w siatce CFR na podstawie sąsiednich aktywnych prążków (`\cite[rozdz.~2 i~3.2]{wypich2026}`), zachowując pełną energię sygnału i pełny zasięg jednoznaczny:
      - Dla 802.11a (pojedyncza podnośna $k_{\mathrm{DC}}$):
        $$\tilde{H}[k_{\mathrm{DC}}, l] = \frac{\tilde{H}[k_{\mathrm{DC}}-1, l] + \tilde{H}[k_{\mathrm{DC}}+1, l]}{2}$$
      - Dla 802.11ax (luka o szerokości $G \in \{3, 5, 23\}$ podnośnych dla CBW20/40–80/160, $g \in \{1, \dots, G\}$, między lewą $k_L$ a prawą $k_R$ podnośną aktywną):
        $$\tilde{H}[k_L + g, l] = \tilde{H}[k_L, l] + \frac{g}{G+1} \left( \tilde{H}[k_R, l] - \tilde{H}[k_L, l] \right)$$
  - [ ] **Akapit 4: Most do symulacji i badań.**
    - Obie operacje (MTI i adaptacyjną interpolację dowolnej ciągłej luki DC) zaimplementowano w [`lib/estimate_channel_zf.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/estimate_channel_zf.m).
    - Skuteczność wycinania przesłuchu DPI oraz clutteru wielodrogowego w realistycznych modelach propagacyjnych TGax (Model-A, Model-C, Model-E) jest przedmiotem **Eksperymentu E4 (`\ref{subsec:sim_clutter_suppression}`) w Rozdziale 4**.
- **Czego NIE pisać:** Nie wyprowadzać filtrów adaptacyjnych czasu ciągłego na surowych próbkach IQ (LMS, szczegółowe warianty macierzowe ECA/ECA-B) — wspomnieć o nich wyłącznie jednym zdaniem porównawczym w kontekście `\cite{colone2014,diseglioReducingComputationalComplexity2022}`.

---

### Podrozdział 2.6: Wyznaczanie mapy odległość–prędkość (Range–Doppler)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L121).
- **Docelowa objętość:** 1,5 strony (~450 słów).
- **Budżet:** 4 równania, 1 tabela parametrów okien wagowych.
- **Plan akapitów (z zachowaniem wynikowości, bez skrótów myślowych i z pełnym cytowaniem Zotero):**
  - [ ] **Akapit 1: Dwuwymiarowa transformata Fouriera (2D Periodogram).**
    - Przejście od skondycjonowanej macierzy CFR $\tilde{H}[k,l]$ o rozmiarze $N_{\mathrm{FFT}} \times M$ (z niezerowymi elementami na paśmie aktywnym i zrekonstruowanej luce DC) do zespolonej mapy Range–Doppler $\text{CPer}(r, d)$ (`\cite[rozdz.~IV-B, równ.~(23)--(26)]{sturm2011a}`, `\cite[rozdz.~3.3, równ.~(3.30)--(3.31), (3.69)]{braun2014}`, `\cite[rozdz.~2, rys.~1]{wypich2026}`, `\cite[rozdz.~9.7]{zielinski2007}`):
      $$\text{CPer}(r, d) = \sum_{l=0}^{M_{\mathrm{per}}-1} \left( \sum_{k=0}^{N_{\mathrm{per}}-1} \tilde{H}[k,l] W[k,l] e^{j 2\pi \frac{k r}{N_{\mathrm{per}}}} \right) e^{-j 2\pi \frac{l d}{M_{\mathrm{per}}}}$$
      gdzie $N_{\mathrm{per}} = \xi_r 2^{\lceil \log_2 N_{\mathrm{FFT}} \rceil}$, $M_{\mathrm{per}} = \xi_d 2^{\lceil \log_2 M \rceil}$ to wymiary siatki po dopełnieniu zerami (ang. *zero-padding*, współczynnik $\xi_r = \xi_d = 4$ w [`lib/compute_range_doppler_map.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/compute_range_doppler_map.m)), które interpoluje widmo bez dodawania nowej informacji i redukuje błąd kwantyzacji binów (`\cite[rozdz.~3.3, str.~25]{braun2014}`, `\cite[rozdz.~8.3 i~8.6]{zielinski2007}`).
    - Wyjaśnienie znaków: IFFT ze znakiem plus po osi częstotliwości $k$ kompensuje liniowy obrót fazy $e^{-j 2\pi k \Delta f \tau}$ (odwzorowanie opóźnienia/odległości $\tau \to r$), natomiast FFT ze znakiem minus po osi czasu wolnego $l$ kompensuje obrót $e^{+j 2\pi l T_{\mathrm{PRI}} f_D}$ (odwzorowanie przesunięcia Dopplera $f_D \to d$) (`\cite[rozdz.~IV-B]{sturm2011a}`, `\cite[rozdz.~3.3]{braun2014}`).
    - Zysk przetwarzania koherentnego wynikający z sumowania koherentnego sygnału użytecznego względem nieskorelowanego szumu: $G_p = 10 \log_{10}(K_{\mathrm{eff}} \cdot M)\ \text{dB}$ (`\cite[rozdz.~IV-B, równ.~(27)]{sturm2011a}`, `\cite[rozdz.~3.3.1, równ.~(3.37)--(3.41)]{braun2014}`).
    - Moc periodogramu w skali logarytmicznej (`\cite[rozdz.~3.3, równ.~(3.31)]{braun2014}`): $P(r, d) = 10 \log_{10} \left( \frac{1}{K_{\mathrm{eff}} M} |\text{CPer}(r, d)|^2 \right)\ \text{dB}$.
  - [ ] **Akapit 2: Przeciek widmowy i dobór okna separowalnego 2D.**
    - Okno separowalne $W[k,l] = w_r[k] \cdot w_d[l]$ (`\cite[rozdz.~3.3.4, równ.~(3.70)]{braun2014}`), przy czym okno częstotliwościowe $w_r[k]$ nakłada się wyłącznie na zbiór aktywnych podnośnych (z wyłączeniem pasm ochronnych, jak w [`lib/compute_range_doppler_map.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/compute_range_doppler_map.m)).
    - Konsekwencje okna prostokątnego: najwyższy poziom listków bocznych ($\mathrm{PSLL} = -13{,}3\ \text{dB}$, `\cite[rozdz.~8.5.1, tab.~8-1]{zielinski2007}`, `\cite[rozdz.~3.3.4, tab.~3.2]{braun2014}`), które maskują małe obiekty ruchome i generują fałszywe alarmy.
    - Zastosowanie 4-wyrazowego okna Blackmana–Harrisa (`\cite[rozdz.~3.3.4, równ.~(3.73)]{braun2014}`, uogólnienie sumy kosinusów w `\cite[rozdz.~8.5.1, równ.~(8.46)--(8.47)]{zielinski2007}`):
      $$w[n] = a_0 - a_1 \cos\left(\frac{2\pi n}{N-1}\right) + a_2 \cos\left(\frac{4\pi n}{N-1}\right) - a_3 \cos\left(\frac{6\pi n}{N-1}\right)$$
      ze współczynnikami $a_0 = 0{,}35875$, $a_1 = 0{,}48829$, $a_2 = 0{,}14128$, $a_3 = 0{,}01168$, zapewniającego tłumienie listków bocznych na poziomie $-92{,}1\ \text{dB}$ (`\cite[tab.~3.2]{braun2014}`).
  - [ ] **Akapit 3: Trójstronny kompromis okienkowania.**
    - Analiza kompromisu (`\cite[rozdz.~3.3.4, rys.~3.10, tab.~3.2]{braun2014}`, `\cite[rozdz.~8.5.1, tab.~8-1, rys.~8.10]{zielinski2007}`): tłumienie listków bocznych (PSLL) vs. poszerzenie listka głównego (szerokość przy $-3\ \text{dB}$ rośnie z $0{,}89$ do $1{,}90$ binu, a szerokość do pierwszych zer $\Delta_{\mathrm{ml}}$ w 1D wzrasta z $4\pi/N$ do $16\pi/N$ / $\Omega_s = 2\pi/N \to 8\pi/N$) vs. strata przetwarzania koherentnego (ang. *processing loss* $\approx 3{,}0\ \text{dB}$).
    - Uzasadnienie: w pasywnym radarze Wi-Fi o dużej rozpiętości dynamiki między celami priorytetem jest tłumienie listków bocznych (nawet kosztem $\approx 3\ \text{dB}$ straty SNR i szerszego listka głównego), co czyni okno Blackmana–Harrisa standardem w całym torze DSP symulatora.
  - [ ] **Akapit 4: Most do kodu symulatora.**
    - Wskazanie implementacji w funkcji [`lib/compute_range_doppler_map.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/compute_range_doppler_map.m).
- **Tabela:** Zestawienie okien (Prostokątne, Hanna, Hamminga, Blackmana–Harrisa): PSLL [dB], szerokość listka głównego ($\Delta_{\mathrm{ml}}$ / szerokość $-3\ \text{dB}$ [biny]), strata przetwarzania [dB] (dane z `\cite[tab.~3.2]{braun2014}` i `\cite[tab.~8-1]{zielinski2007}`).
- **Czego NIE pisać:** Nie wyprowadzać algorytmów superrozdzielczych (MUSIC, ESPRIT), chociaż o ich istnieniu można wspomnieć w 1 zdaniu jako o alternatywie nieparametrycznej/parametrycznej (`\cite[rozdz.~3.4]{braun2014}`, `\cite[rozdz.~16.3]{zielinski2007}`).

---

### Podrozdział 2.7: Detekcja progowa i iteracyjna ekstrakcja celów (algorytm Coherent CLEAN)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L124).
- **Docelowa objętość:** 1,5 strony (~500 słów).
- **Budżet:** 4 równania, 0 rysunków.
- **Plan akapitów (z zachowaniem wynikowości, bez skrótów myślowych i z pełnym cytowaniem Zotero):**
  - [ ] **Akapit 1: Odporna estymacja tła szumowego metodą MAD i metryka PNFR.**
    - Problem: Na mapie RDM po filtracji MTI obecność silnych pików od celów zawyża zwykłą średnią arytmetyczną z całej mapy, a wyznaczanie szumu z wydzielonych wierszy poza $N_{\max}$ (`\cite[rozdz.~3.3.6, równ.~(3.98)]{braun2014}`) wymaga znajomości górnej granicy zasięgu sceny.
    - Zastosowanie odpornego estymatora dyspersji MAD (*Median Absolute Deviation*) w [`lib/run_coherent_clean.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/run_coherent_clean.m):
      $$\hat{\sigma} = \frac{\text{median}\left(|\text{CPer}(r,d)|\right)}{0{,}6745}$$
      Czynnik $0{,}6745$ wywodzi się z normalizacji mediany dla rozkładu normalnego (dla pojedynczych części I/Q szumu Gaussa); przy module $|\text{CPer}|$ o rozkładzie Rayleigha (`\cite[rozdz.~3.3.6, równ.~(3.91)--(3.92)]{braun2014}`: moc $|\text{CPer}|^2$ ma rozkład wykładniczy $\chi_2^2$) estymator ten stanowi prostą, całkowicie odporną na obecność ostrych pików celów miarę poziomu tła do wyznaczenia progu zatrzymania.
    - Definicja metryki kontrastu detekcji PNFR (*Peak-to-Noise-Floor Ratio*, `\cite[rozdz.~4.4, równ.~(6)]{wypich2026}` oraz implementacja [`lib/compute_pnfr.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/compute_pnfr.m)):
      $$\text{PNFR}_k = 10 \log_{10} \left( \frac{P_{\mathrm{peak}, k}}{P_{\mathrm{floor}}} \right) = 20 \log_{10}\left(\frac{A_{\mathrm{peak}, k}}{A_{\mathrm{floor}}}\right) \quad [\text{dB}]$$
      gdzie $P_{\mathrm{floor}} = \frac{1}{|\Omega_{\mathrm{noise}}|} \sum_{(r,d) \in \Omega_{\mathrm{noise}}} P(r,d)$ jest estymatorem maksymalnej wiarygodności mocy szumu (`\cite[rozdz.~3.3.6, równ.~(3.98)]{braun2014}`) wyznaczonym poza strefami ochronnymi (ang. *guard boxes*, domyślnie $\pm 16$ binów) wszystkich wykrytych obiektów (`\cite[rozdz.~4, tab.~4]{wypich2026}`).
  - [ ] **Akapit 2: Ograniczenia progowania klasycznego (CA-CFAR) w scenariuszach bliskiego zasięgu.**
    - Wyjaśnienie bez skrótów myślowych: W klasycznym detektorze CA-CFAR (`\cite[rozdz.~II i~III, str.~3489, 3491]{colone2014}`, `\cite[rozdz.~4.3, tab.~4]{wypich2026}`) okno trenujące przesuwa się po mapie. W obecności dwóch obiektów o dużej różnicy mocy (np. pojazd o $0\ \text{dB}$ i pieszy o $-30\ \text{dB}$) energia silnego celu wpada do komórek trenujących słabszego obiektu lub resztkowe listki boczne zniekształcają jego otoczenie, sztucznie podnosząc próg i powodując **maskowanie słabego celu** (`\cite[rozdz.~3.3.6 i~3.3.7, str.~52, 56--58]{braun2014}`).
  - [ ] **Akapit 3: Algorytm Coherent CLEAN (Successive Target Cancellation).**
    - Zasada działania algorytmu dekompozycji koherentnej (`\cite[rozdz.~3.3.7 *Coherent Successive Target Cancellation*, równ.~(3.99)--(3.102), rys.~3.15]{braun2014}`):
      1. Detekcja globalnego maksimum na aktualnej mapie rezydualnej:
         $$(r_i, d_i) = \arg\max_{r,d} |\text{CPer}^{(i)}(r,d)|, \quad A_i = \text{CPer}^{(i)}(r_i, d_i)$$
      2. Kryterium zatrzymania: jeśli $|A_i| < T_{\mathrm{stop}} = \hat{\sigma} \cdot 10^{\mathrm{margin\_dB}/20}$ lub osiągnięto zadaną liczbę celów, algorytm kończy działanie (zapobiegając zjawisku *over-cleaning* na szumie tła).
      3. Analityczna rekonstrukcja odpowiedzi impulsowej pojedynczego celu punktowego w punkcie $(r_i, d_i)$ z uwzględnieniem identycznego okna wagowego 2D: $\mathbf{S}_{\mathrm{point}, i} = \mathcal{F}_{\text{2D}} \{ \mathbf{P}(r_i, d_i) \odot \mathbf{W}_{\text{2D}} \}$ (`\cite[równ.~(3.99)--(3.100)]{braun2014}`).
      4. Koherentne odjęcie znormalizowanej repliki wraz z jej listkami bocznymi od zespolonego periodogramu (`\cite[równ.~(3.101)]{braun2014}`):
         $$\text{CPer}^{(i+1)}(r,d) = \text{CPer}^{(i)}(r,d) - A_i \cdot \frac{\mathbf{S}_{\mathrm{point}, i}(r,d)}{\mathbf{S}_{\mathrm{point}, i}(r_i, d_i)}$$
      5. Na oczyszczonej mapie rezydualnej $\text{CPer}^{(i+1)}$ odsłaniają się słabe obiekty, które w kolejnej iteracji mogą zostać wykryte bez zniekształceń.
  - [ ] **Akapit 4: Most do symulacji i badań.**
    - Implementacja algorytmu CLEAN znajduje się w [`lib/run_coherent_clean.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/run_coherent_clean.m) oraz w module interpretatora [`src/step4_interpreter.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/src/step4_interpreter.m).
    - Zdolność algorytmu do demaskowania słabego echa pieszego w obecności dominującego pojazdu (dynamika >30 dB) oraz samoczynnego zatrzymania na progu MAD jest badana w **Eksperymencie E5 (`\ref{subsec:sim_clean_performance}`) w Rozdziale 4**.
- **Czego NIE pisać:** Nie opisywać rozbudowanych wariantów heurystycznych CFAR (OS/GO/SO/TM-CFAR) ani filtrów śledzenia wieloobiektowego (Kalman/JPDA) — radar operuje w pojedynczym oknie CPI.

---

## 5. Wytyczne redakcyjne, stylistyka i wymogi formalne (z plan_deliverables.md)

### 5.1. Stylistyka tekstu i język inżynierski
1. **Pisać „prosto z mostu”**: Unikać lania wody, ozdobników i rozwlekłych uogólnień typowych dla asystentów LLM. Każde zdanie ma wnosić konkretną informację techniczną, matematyczną lub fizyczną.
2. **Forma gramatyczna**: Opis prac własnych, implementacji i badań prowadzimy w **formie bezosobowej czasu przeszłego** (np. *„zaimplementowano”*, *„przeprowadzono”*, *„zbadano”*, *„wyznaczono”*, *„zastosowano”*), unikając formy pierwszoosobowej (*„zrobiłem”*, *„napisałem”*).
3. **Konkretne miary i odniesienia**: Aby rzetelnie ocenić wydajność toru radarowego, wszelkie parametry i wyniki odnosi się bezpośrednio do pozycji ze zbioru Zotero ([`thesis/bibliography.bib`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/bibliography.bib)): standardów IEEE (`1999`, `2021`), prac źródłowych o radarze OFDM (`sturm2011a`, `braun2014`, `wypich2026`), literatury o pasywnym radarze Wi-Fi (`colone2014`, `diseglioReducingComputationalComplexity2022`, `bradshawAlternativeDopplerExtraction`, `zhuCommodityWiFiBasedWireless2024`, `sorbianWykorzystanieSieciWifi2025`) oraz podstaw DSP (`zielinski2007`).
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
  - [ ] Wymiary siatki po zero-paddingu: $N_{\mathrm{per}} = 4 \cdot 2^{\lceil \log_2 N_{\mathrm{FFT}} \rceil}$, $M_{\mathrm{per}} = 4 \cdot 2^{\lceil \log_2 M \rceil}$.
- [ ] **Cytowania w tekście i czystość bibliografii:**
  - [ ] Wszystkie odsyłacze `\cite{...}` korzystają wyłącznie z 11 istniejących kluczy w [`thesis/bibliography.bib`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/bibliography.bib) / [`references/Zotero/Zotero.bib`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/references/Zotero/Zotero.bib): `1999`, `2021`, `bradshawAlternativeDopplerExtraction`, `braun2014`, `colone2014`, `diseglioReducingComputationalComplexity2022`, `sorbianWykorzystanieSieciWifi2025`, `sturm2011a`, `wypich2026`, `zhuCommodityWiFiBasedWireless2024`, `zielinski2007`.
  - [x] Martwe klucze `storrer2021` (2.1, 2.2) oraz `zotero-item-46` (2.1) zostały usunięte i zastąpione w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex).
  - [x] Wprowadzono brakujące odwołania w już napisanych sekcjach 2.1–2.2 (`sturm2011a`, `bradshawAlternativeDopplerExtraction`, `zielinski2007`, `zhuCommodityWiFiBasedWireless2024`, `diseglioReducingComputationalComplexity2022`).
  - [ ] Wszystkie 11 pozycji z `Zotero.bib` jest jawnie zacytowanych w pracy (0 pozycji „wiszących”) i brak znaków zapytania `[?]` w PDF.
- [ ] **Etykiety, odsyłacze skrośne i synchronizacja międzyrozdziałowa:**
  - [ ] Wszystkie podrozdziały posiadają unikalne etykiety `\label{subsec:...}`.
  - [ ] Wszystkie równania, tabele i rysunki są przywołane przynajmniej raz w tekście (`\ref{...}`).
  - [ ] Odsyłacze do przyszłych rozdziałów (`sec:radar_implementation`, `subsec:sim_bandwidth_resolution`, `subsec:sim_doppler_aliasing`, `subsec:sim_mcs_noise_enhancement`, `subsec:sim_clutter_suppression`, `subsec:sim_clean_performance`) są poprawnie spięte z finalną wersją Rozdziałów 3 i 4.
- [ ] **Objętość i proporcje:**
  - [ ] Całkowita liczba stron Rozdziału 2 w PDF mieści się w przedziale **10,0–11,5 stron** (dokładnie 1 merytoryczny rysunek alokacji podnośnych + 3 tabele parametrów, 0 rysunków-zapychaczy).
  - [ ] Żaden podrozdział nie przekracza limitu 2 stron.
  - [ ] Treści z „listy zakazów” (MAC, kody korekcyjne, historia radaru, inne iluminatory, elipsy bistatyczne) nie przedostały się do tekstu.
