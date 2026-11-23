# Plan Redakcji Rozdziału 2: Podstawy teoretyczne pasywnego radaru OFDM Wi-Fi

Dokument stanowi kompletny, śledzony plan pisania **Rozdziału 2** pracy dyplomowej (plik źródłowy: [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex)). Zawiera rygorystyczne wytyczne objętościowe, kompletne mapowanie i uzasadnienie bibliograficzne na podstawie repozytorium Zotero ([`references/Zotero/`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/references/Zotero) / [`thesis/bibliography.bib`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/bibliography.bib)), plan korekt już napisanych podrozdziałów 2.1–2.2 (z zachowaniem ich treści i uwzględnieniem ewentualnych zmian zawartości), plan akapitów dla 2.3–2.7, gotowe wzory matematyczne, listę cięć oraz powiązania z kodem symulatora ([`lib/`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/)) i eksperymentami badawczymi E1–E5 w Rozdziale 4.

---

## 1. Tablica Śledzenia Postępów Redakcji

| Podrozdział | Tytuł roboczy / docelowy | Limit stron | Rysunki / Tabele | Równania | Status redakcji | Status weryfikacji |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: |
| **2.1** | Warstwa fizyczna standardu IEEE 802.11 | 1,5 str. | 1 rys. + 1 tab. | 0 | [x] **Zrealizowany** | [x] Zweryfikowany (tabela 20/40/80/160 MHz, czyste `\cite`, bez odwołań do kodu — pkt 4.1) |
| **2.2** | Model matematyczny sygnału OFDM | 1,2–1,5 str. | 0 rys. | 3 | [x] **Zrealizowany** | [x] Zweryfikowany (3 równania, uproszczony opis splotu kołowego, bez odwołań do kodu — pkt 4.2) |
| **2.3** | Geometria pomiarowa i parametry radaru (układ współlokowany/monostatyczny) | 1,5 str. | 0 rys. | 6–7 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.4** | Estymacja częstotliwościowej odpowiedzi kanału (CFR) | 2,0 str. | 1 tab. | 4–5 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.5** | Tłumienie ech stałych i kompensacja luki DC | 1,5 str. | 0 rys. | 3 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.6** | Wyznaczanie mapy Range–Doppler (RDM) | 1,5 str. | 1 tab. | 4 | [ ] Do napisania | [ ] Do weryfikacji |
| **2.7** | Detekcja progowa CFAR i iteracyjna ekstrakcja celów (Binary STC oraz Coherent STC) | 1,5 str. | 0 rys. | 6–8 | [ ] Do napisania | [ ] Do weryfikacji |
| **SUMA** | **Rozdział 2 (całość)** | **10,0–11,5 str.** | **1 rys., 3 tab.** | **~25–26** | **Postęp: 2/7 (29%)** | **2.1–2.2 zweryfikowane; 2.3–2.7 do napisania** |

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
3. **Most merytoryczny do dalszej części pracy** (1 akapit zamykający: zapowiedź kolejnego podrozdziału teoretycznego oraz zjawiska fizycznego badanego w eksperymentach E1–E5 w Rozdziale 4 — **bez nazw plików `.m` ani odwołań do architektury kodu symulatora**, które należą wyłącznie do Rozdziału 3).

### 2.4. Bezwzględna zasada pisania bez skrótów myślowych (Explicite Engineering Writing)
> [!CAUTION]
> **Zakaz skrótów myślowych:** Tekst pracy inżynierskiej musi charakteryzować się pełną ciągłością logiczną i przyczynowo-skutkową (wynikowością). Czytelnik nie może domyślać się genezy wzorów ani intencji autora:
> 1. **Każdy czynnik i stała liczbowa we wzorze musi być wyjaśniona fizycznie lub statystycznie:**
>    - Dlaczego we wzorze na zasięg $R = c\tau/2$ oraz rozdzielczość $\Delta R = c/(2B)$ występuje mianownik $2$? Bo fala pokonuje drogę dwudrożną (do celu i z powrotem).
>    - Dlaczego w maksymalnej prędkości $v_{\max} = c/(4 f_c T_{\mathrm{sym}})$ w mianowniku pojawia się $4$, a nie $2$? Ponieważ twierdzenie Nyquista wymaga $f_D \le 1/(2 T_{\mathrm{sym}})$, a przesunięcie Dopplera wynosi $f_D = 2 v f_c / c$; stąd $2 v_{\max} f_c / c = 1/(2 T_{\mathrm{sym}}) \implies v_{\max} = c / (4 f_c T_{\mathrm{sym}})$. Całkowita szerokość jednoznacznego pasma prędkości wynosi wówczas $v_{\text{unamb}} = 2 v_{\max} = c / (2 f_c T_{\mathrm{sym}})$.
>    - Dlaczego we wzorze na próg CFAR Brauna $\eta = -\hat{\sigma}^2 \ln\left(1 - (1 - p_{\mathrm{FA}})^{1/(NM)}\right)$ pojawia się logarytm naturalny oraz wykładnik $1/(NM)$, a nie $1/(N_{\mathrm{Per}} M_{\mathrm{Per}})$? Bo dla szumu Gaussa znormalizowana moc periodogramu ma rozkład wykładniczy $\chi_2^2$ ($P(\mathrm{Per} > \eta \mid \mathcal{H}_0) = e^{-\eta/\sigma^2}$), a dopełnianie zerami (*zero-padding*) jedynie interpoluje widmo i nie zwiększa liczby niezależnych stopni swobody wynoszącej $NM$.
> 2. **Niedopuszczalne zwroty uogólniające:** Zakaz stosowania zwrotów w stylu: *„jak łatwo zauważyć”*, *„z oczywistych względów”*, *„co wynika samo przez się”*, *„jak powszechnie wiadomo”*. Każde stwierdzenie ma opierać się na dowodzie, wyprowadzeniu lub konkretnym cytowaniu z literatury (`\cite{...}`).
> 3. **Ciągłość operacji DSP:** Każde przekształcenie macierzowe musi wskazywać: wymiar wejściowy $\to$ działanie operatora $\to$ wymiar wyjściowy $\to$ fizyczne znaczenie osi po transformacji.

### 2.5. Zasady cytowania, czystości teorii i zapożyczania wzorów w pracy inżynierskiej
> [!NOTE]
> **Spójna polityka cytowań dla przyszłych rozdziałów i poprawek:** W pracy inżynierskiej odwołania bibliograficzne mają wspierać wiarygodność modelu matematycznego, a nie obciążać czytelnika aparatem typowym dla artykułu przeglądowego.

1. **Czysta forma odwołań w tekście LaTeX (`\cite{klucz}`):** W plikach `.tex` stosujemy wyłącznie proste odwołania `\cite{klucz}` bez szczegółowych dopisków lokalizacyjnych typu `[rozdz.~X, tab.~Y, str.~Z]`. Dokładne numery rozdziałów, tabel i równań w źródłach przechowujemy wyłącznie w niniejszym planie jako dokumentację pomocniczą dla autora.
2. **Oszczędność i zasada jednego podstawowego źródła:** Przy pojedynczym wzorze, definicji lub wniosku podajemy **jedno najbardziej podstawowe i miarodajne źródło** (lub parę standardów `\cite{1999,2021}`). Unikamy grupowania 3–4 cytowań przy jednym zdaniu.
3. **Hierarchia autorytetu źródeł (zakaz cytowania prac wtórnych do teorii podstawowej):**
   - *Podstawy DSP i teorii OFDM* (transformata Fouriera, widmo $\mathrm{sinc}$, ortogonalność, synteza IFFT/FFT, splot kołowy, okienkowanie, zero-padding): cytujemy podręcznik akademicki **`zielinski2007`** lub monografię **`braun2014`**. Nie cytujemy prac aplikacyjnych ani dyplomowych (np. `sorbianWykorzystanieSieciWifi2025`) do elementarnych praw DSP.
   - *Parametry warstw fizycznych Wi-Fi*: cytujemy bezpośrednio standardy IEEE **`1999`** i **`2021`**.
   - *Zjawiska i algorytmy radaru pasywnego*: cytujemy pierwotną lub kluczową pracę dla danego zagadnienia (`sturm2011a`, `braun2014`, `wypich2026`, `colone2014`, `diseglioReducingComputationalComplexity2022`, `bradshawAlternativeDopplerExtraction`, `zhuCommodityWiFiBasedWireless2024`).
4. **Elastyczność budżetu równań i zapożyczanie wzorów:** Dopuszcza się odejście od pierwotnej liczby równań w poszczególnych podrozdziałach (dodanie lub pominięcie wzoru), jeżeli wzór jest dobrze umotywowany w bieżącym wywodzie i pochodzi z zaufanych, cytowalnych źródeł (w szczególności **`braun2014`**, **`zielinski2007`**, **`sturm2011a`**, **`wypich2026`**).
5. **Rozdział teorii od implementacji (brak odwołań do kodu w Rozdziale 2):** W rozdziałach teoretycznych nie umieszczamy nazw plików, funkcji ani opisów modułów symulatora (`*.m`, `\ref{sec:radar_implementation}`). Nazwy plików w katalogu `lib/` oraz `src/` podane w niniejszym planie stanowią wyłącznie **referencję roboczą dla autora**, gwarantującą pełną zgodność wzorów z implementacją omawianą w Rozdziale 3.

---

## 3. Zestawienie Tytułów i Uzasadnienie w Literaturze

| Nr | Tytuł w szablonie LaTeX | Rekomendowany tytuł w pracy | Kluczowe źródła bibliograficzne ([`thesis/bibliography.bib`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/bibliography.bib)) | Uzasadnienie w tekście, cel inżynierski i most badawczy |
| :---: | :--- | :--- | :--- | :--- |
| **2.1** | `Warstwa fizyczna standardu IEEE 802.11` | *jw.* | `1999` (rozdz. 17.3, tab. 78–79), `2021` (rozdz. 27.3, tab. 27-10, 27-12, 27-13), `colone2014` (rozdz. I–II), `sorbianWykorzystanieSieciWifi2025` (rozdz. 1), `zhuCommodityWiFiBasedWireless2024` (rozdz. 5, tab. 14), `sturm2011a` (rozdz. IV-B), `braun2014` (rozdz. 3.3.8, 3.6.2), `wypich2026` (rozdz. 1, 4.4) | Struktura ramki PPDU, pełna tabela parametrów dla 802.11a (20 MHz) i 802.11ax (20/40/80/160 MHz, luka DC $3/5/5/23$ + luki podkanałów), uzasadnienie użycia pola danych oraz kompensacja luki DC przez interpolację liniową — czysto teoretycznie, bez odwołań do kodu (`pkt 4.1`). |
| **2.2** | `Model matematyczny sygnału OFDM` | *jw.* | `zielinski2007` (rozdz. 4.3, 8.1.4, 13.4, 23.2, 23.4 rys. 23.8), `braun2014` (rozdz. 3.1–3.2, 3.6.2 tab. 3.7, Dodatek A), `1999`, `2021`, `wypich2026` (rozdz. 5) | Ortogonalność podnośnych $\Delta f = 1/T_u$ (`zielinski2007`), sygnał ciągły `eq:ofdm_continuous` (`braun2014`), synteza IFFT `eq:ofdm_discrete_ifft`, $T_{\mathrm{sym}}$, prefiks cykliczny ($0{,}8/1{,}6/3{,}2\ \mu\text{s}$), opis zamiany splotu liniowego w kołowy (zwięźle w 4 zdaniach), właściwości symboli $X[k,l]$ (`pkt 4.2`). |
| **2.3** | `Geometria pomiarowa i parametry radaru OFDM` | **Geometria pomiarowa i parametry radaru: konfiguracja współlokowana (monostatyczna)** | `sturm2011a` (rozdz. II rys. 2, rozdz. III-D równ. 11–12, rozdz. IV-C tab. 2, rozdz. VI równ. 35–37), `braun2014` (rozdz. 3.2 rys. 3.3 i równ. 3.14–3.15, rozdz. 3.2.2 równ. 3.25–3.26, rozdz. 3.3.1 równ. 3.35, rozdz. 3.6.1–3.6.2 tab. 3.6–3.7), `colone2014` (rozdz. III–IV rys. 3a, równ. 8–9), `diseglioReducingComputationalComplexity2022` (rozdz. II), `wypich2026` (rozdz. 2 równ. 1–3, rozdz. 4.2–4.3), `zhuCommodityWiFiBasedWireless2024` (rozdz. 2.1 równ. 2), `sorbianWykorzystanieSieciWifi2025` (rozdz. 1.2, 1.4), `zielinski2007` (rozdz. 4.5, 7.1) | Redukcja z układu bistatycznego ($L_B \to 0, \beta \to 0^\circ$) do konfiguracji współlokowanej (quasi-monostatycznej / ISAC); znany sygnał referencyjny bez szumu toru odniesienia; model kanału $h(\tau, t)$; moc szumu termicznego $P_N$ i rozgraniczenie komunikacyjnego $\text{CNR}$ / $\text{SNR}_{\mathrm{comm}}$ od radarowego $\text{SNR}_{\mathrm{target}}$; wyprowadzenie $\Delta R, \Delta R_{\mathrm{act}}, R_{\max}, \Delta v, v_{\mathrm{unamb}}, v_{\max}$ (dla $k_{\mathrm{PRI}}=1$ i czasu wolnego $T_{\mathrm{PRI}}=k_{\mathrm{PRI}}T_{\mathrm{sym}}$). **Podstawa pod E1 i E2.** |
| **2.4** | `Estymacja kanału` | **Estymacja częstotliwościowej odpowiedzi kanału (CFR)** | `sturm2011a` (rozdz. IV-A i IV-B równ. 15–20, rys. 9), `braun2014` (rozdz. 3.2 równ. 3.17–3.19, rozdz. 3.5, Dodatek A równ. A.1–A.2 rys. A.1), `diseglioReducingComputationalComplexity2022` (rozdz. III–IV równ. 11–13, rozdz. V), `colone2014` (rozdz. II równ. 6–7), `bradshawAlternativeDopplerExtraction` (rozdz. 1.1.3 równ. 1.2, rozdz. 2.1 równ. 2.14), `wypich2026` (rozdz. 1–2 równ. 4, rozdz. 4.3, rozdz. 5 rys. 16), `zhuCommodityWiFiBasedWireless2024` (rozdz. 2.1 równ. 1, 3–4), `sorbianWykorzystanieSieciWifi2025` (rozdz. 3.1 równ. 3.1–3.2), `zielinski2007` (rozdz. 9.5, 23.6.2 równ. 23.13–23.14, 23.6.4 rys. 23.21) | Odejście od CAF na rzecz estymacji w dziedzinie podnośnych (eliminacja listków bocznych danych oraz redukcja złożoności z $O(N^2)$ do $O(KM\log_2(KM))$); estymatory Zero-Forcing (ZF / FEQ / RpF) i Matched Filter (MF); analityczne zjawisko *noise enhancement* $\zeta_{\mathrm{ZF}} = \mathbb{E}[\|X\|^2]\mathbb{E}[1/\|X\|^2]$ dla QAM. **Podstawa pod E3.** |
| **2.5** | `Filtracja ech stałych` | **Tłumienie ech stałych i kompensacja luki DC** | `bradshawAlternativeDopplerExtraction` (rozdz. 1.1.3, rozdz. 3.4 równ. 3.9–3.10), `diseglioReducingComputationalComplexity2022` (rozdz. III rys. 2), `colone2014` (rozdz. II–III równ. 1–5, rys. 4, 8), `wypich2026` (rozdz. 2, 3.2, 4.2, rys. 16), `zhuCommodityWiFiBasedWireless2024` (rozdz. 4 str. 15), `braun2014` (rozdz. 3.3.8 równ. 3.104–3.113, rys. 3.16–3.18, rozdz. 3.6.2), `zielinski2007` (rozdz. 4.4, 8.5) | Tłumienie DPI i clutteru stacjonarnego w czasie wolnym po przejściu do dziedziny podnośnych (filtr MTI rzędu 0 / odjęcie średniej); mechanizm powstawania podłogi zakłóceń (*spur floor*) przez lukę DC oraz porównanie decymacji ($U=2$) z uogólnioną wielopunktową interpolacją liniową podnośnych DC. **Podstawa pod E4.** |
| **2.6** | `Wyznaczanie mapy Range–Doppler` | **Wyznaczanie mapy odległość–prędkość (Range–Doppler)** | `sturm2011a` (rozdz. IV-B równ. 21–27, rys. 10), `braun2014` (rozdz. 3.3 równ. 3.30–3.31, rozdz. 3.3.1 równ. 3.37–3.41, rozdz. 3.3.4 równ. 3.69–3.73, tab. 3.2), `wypich2026` (rozdz. 2 rys. 1), `zielinski2007` (rozdz. 8.3, 8.5.1 tab. 8-1 równ. 8.39–8.47 rys. 8.10, rozdz. 8.6, 9.7) | Dwuwymiarowy periodogram (IFFT po $k$, FFT po $l$ z dopełnianiem zerami), zysk przetwarzania koherentnego $G_p = 10\log_{10}(KM)$, dobór separowalnego okna Blackmana–Harrisa (PSLL $\approx -92\ \text{dB}$) eliminującego fałszywe alarmy kosztem poszerzenia listka głównego i straty przetwarzania; analityczne wyjaśnienie efektu rozmycia plamy celu w dziedzinie prędkości (asymetria komórki rozdzielczości Range–Doppler, krótki czas CPI pojedynczej ramki vs. poszerzenie listka przez okno 2D i wygładzenie przez zero-padding). |
| **2.7** | `Detekcja i ekstrakcja celów` | **Detekcja progowa CFAR i iteracyjna ekstrakcja celów (Binary STC oraz Coherent STC)** | `braun2014` (rozdz. 3.3.5 równ. 3.84–3.86, rozdz. 3.3.6 równ. 3.91–3.95, 3.98, rozdz. 3.3.7 str. 56–62, rys. 3.13 i 3.15, równ. 3.99–3.102, oraz równ. 3.32–3.34), `wypich2026` (rozdz. 4.3, 4.4 równ. 6, tab. 4), `colone2014` (rozdz. II str. 3489, rozdz. III str. 3491) | Estymacja tła szumowego ML poza $N_{\max}$ i globalny próg CFAR $\eta$; ograniczenia CA-CFAR; 2D interpolacja paraboliczna piku i estymacja $(\hat{d}, \hat{v}, \hat{\sigma}_{\mathrm{RCS}})$; porównanie Binary STC (maskowanie binarne elipsą *null-to-null*) i Coherent STC (koherentne odejmowanie repliki + odrzucanie rezyduów w elipsie $-3\ \text{dB}$); metryka PNFR. **Podstawa pod E5.** |

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
* **Zachowanie dorobku 2.1–2.2 i aktualizacje 2026-11-16/17:** Istniejąca struktura, tabela `tab:wifi_params` (rozbudowana o parametry 802.11ax dla 20/40/80/160 MHz), rysunek `fig:subcarrier_allocation` oraz trzy bazowe równania (`eq:ofdm_continuous`, `eq:ofdm_discrete_ifft`, `eq:ofdm_symbol_duration`) pozostają podstawą Rozdziału 2.
* **Korekta cytowań i separacja odwołań do kodu w 2.1–2.2:** Usunięto dwa martwe klucze (`storrer2021`, `zotero-item-46`), wprowadzono czystą notację `\cite{klucz}` bez dopisków lokalizacyjnych (sekcja 2.5), uproszczono opis splotu kołowego do 4 zwięzłych zdań oraz usunięto z tekstu teoretycznego wszystkie nazwy plików `.m` i odwołania do symulatora (Rozdział 3).
* **Ewentualne zmiany zawartości pod Rozdziały 3 i 4:** Możliwe doprecyzowanie spójności z parametrami skryptów eksperymentalnych (np. definicja kroku czasu wolnego $T_{\mathrm{PRI}} = k_{\mathrm{PRI}} T_{\mathrm{sym}}$ dla scenariusza E2, dopięcie etykiet `\ref{subsec:sim_...}` w `40_simulation_results.tex`, opis równoważności definicji PNFR w mocy vs amplitudzie oraz dobór ewentualnych dodatkowych wzorów źródłowych z `zielinski2007`/`braun2014`).

---

## 4. Szczegółowy Plan Redakcji Podrozdziałów (Krok po Kroku)

### Podrozdział 2.1: Warstwa fizyczna standardu IEEE 802.11
- [x] **Status tekstu bazowego:** Zredagowany w pliku [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L16-L71).
- **Objętość:** ~1,5 strony.
- **Zrealizowana zawartość:**
  - Tabela `tab:wifi_params`: Zestawienie **802.11a (Non-HT)** vs. **802.11ax (HE-SU)** dla wszystkich szerokości kanału **20 / 40 / 80 / 160 MHz** (FFT `256/512/1024/2048`, aktywne `242/484/996/1992`, piloty `8/16/16/32`, centralne DC `3/5/5/23`, pasma ochronne `6/5` dla 20~MHz i `12/11` dla pozostałych).
  - Rysunek `fig:subcarrier_allocation`: Widmo podnośnych (dane, piloty, pasma ochronne, luka DC) na przykładzie kanału 20~MHz.
  - Opis podziału ramki PPDU (preambuła vs. pole DATA) i uzasadnienie wykorzystania pola danych (krótsze zdania, brak odwołań do rozdziału implementacyjnego).
  - Wykaz bezpośrednich konsekwencji alokacji podnośnych dla parametrów radaru — z opisem teoretycznym kompensacji luki DC przez wielopunktową interpolację liniową (zamiast opisu implementacji symulatora).
- **Zrealizowane korekty w `thesis/tex/20_passive_radar.tex` (linie 16–71):**
  - [x] **Usunięcie martwych kluczy i uproszczenie cytowań (sekcja 2.5):** Wyeliminowano `storrer2021` i `zotero-item-46`, zamieniono wszystkie `\cite[...]` na czyste `\cite{klucz}` przy pojedynczym źródle podstawowym.
  - [x] **Rozbudowa tabeli `tab:wifi_params` i usunięcie powtórzeń:** Przeniesiono pełne parametry 20/40/80/160 MHz do tabeli, usunięto zawężenie `(kanał 20 MHz)` z podpisu/nagłówka oraz nadmiarowe wyliczenia z tekstu.
  - [x] **Rozbicie długich zdań i separacja odwołań do kodu:** Rozbito długie zdanie o polu danych na dwa krótsze oraz usunięto odwołanie do symulatora `(rozdział~\ref{sec:radar_implementation})` i opisu implementacyjnego w punkcie o luce DC.

---

### Podrozdział 2.2: Model matematyczny sygnału OFDM
- [x] **Status tekstu bazowego:** Zredagowany w pliku [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L73-L111).
- **Docelowa objętość:** 1,2–1,5 strony (~450 słów).
- **Budżet:** **3 równania** (`eq:ofdm_continuous`, `eq:ofdm_discrete_ifft`, `eq:ofdm_symbol_duration`), 0 rysunków.
- **Zrealizowana zawartość:**
  - Akapit 1: Definicja ortogonalności $\Delta f = 1/T_u$ i widmo $\mathrm{sinc}$ podnośnych oparta na `\cite{zielinski2007}` *(rozdz. 4.3 i 23.2)*.
  - Akapit 2: Równanie sygnału ciągłego $s_l(t)$ pasma podstawowego (`eq:ofdm_continuous`, `\cite{braun2014}` *(rozdz. 3.1)*).
  - Akapit 3–4: Dyskretna postać IFFT $s[n,l]$ (`eq:ofdm_discrete_ifft`, `\cite{zielinski2007}` *(rozdz. 8.1.4 i 23.4)*), definicja $T_{\mathrm{sym}} = T_u + T_{\mathrm{CP}}$ (`eq:ofdm_symbol_duration`), ochrona przed ISI ($\Delta R_{\mathrm{CP}} \in \{120, 240, 480\}\ \text{m}$ dla $T_{\mathrm{CP}} \in \{0{,}8;\ 1{,}6;\ 3{,}2\}~\mu\text{s}$, `\cite{braun2014}`) oraz zwięzły, 4-zdaniowy opis przejścia splotu liniowego w kołowy i mnożenia widm na podnośnych (`\cite{zielinski2007,braun2014}`).
  - Akapit 5: Właściwości symboli $X[k,l]$ — stała energia w preambule/pilotach vs. zmienna energia w konstelacjach QAM pola danych prowadząca do wzmocnienia szumu przy ZF (`\cite{braun2014,wypich2026}`).
- **Zrealizowane korekty w `thesis/tex/20_passive_radar.tex` (linie 73–116):**
  - [x] **Usunięcie martwego klucza `storrer2021` i uproszczenie cytowań (sekcja 2.5):** Zostawiono pojedyncze podstawowe `\cite{klucz}` (`zielinski2007`, `braun2014`, `1999`, `2021`, `wypich2026`).
  - [x] **Uproszczenie punktu o splocie kołowym:** Usunięto nieumotywowane w tym miejscu czwarte równanie oraz rozbito długie zdania na cztery zwięzłe zdania przyczynowo-skutkowe.
  - [x] **Usunięcie odwołań do kodu (sekcja 2.5 pkt 5):** Usunięto wzmianki o `kodzie symulatora`, `demodulate.m`, `step1_transmitter.m` oraz `\ref{sec:radar_implementation}`.

---

### Podrozdział 2.3: Geometria pomiarowa i parametry radaru: konfiguracja współlokowana (monostatyczna)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L113).
- **Docelowa objętość:** 1,5 strony (~500 słów).
- **Budżet:** ~6–7 równań (elastyczny wg sekcji 2.5), 0 rysunków.
- **Plan akapitów (z zachowaniem wynikowości, bez skrótów myślowych i wg zasad sekcji 2.5):**
  - [ ] **Akapit 1: Od układu bistatycznego do konfiguracji współlokowanej (quasi-monostatycznej).**
    - Wyjaśnienie: W klasycznych dalekosiężnych radarach pasywnych PBR (iluminatory FM/DVB-T) nadajnik Tx i odbiornik Rx dzieli duża odległość bazowa $L_B$, co wymusza dedykowany kanał referencyjny z anteną kierunkową i prowadzi do geometrii eliptycznej (`\cite{colone2014}` *(rozdz. I)*).
    - W radarze Wi-Fi krótkiego zasięgu oraz systemach RadCom/ISAC (`\cite{sturm2011a}` *(rozdz. I–II, rys. 2)*, `\cite{braun2014}` *(rozdz. 3.2, rys. 3.3)*): odbiornik radarowy jest **współlokowany z punktem dostępowym Wi-Fi** ($x_{\mathrm{RX}}=0, y_{\mathrm{RX}}=0$) albo odległość do celów znacznie przewyższa rozstaw anten ($R \gg L_B$, przybliżenie quasi-monostatyczne).
    - Bezpośrednie konsekwencje inżynierskie: baza $L_B \to 0$ oraz kąt bistatyczny $\beta \to 0^\circ$ (`\cite{colone2014}` *(rozdz. IV, równ. 9)*). W układzie semi-kooperacyjnym wektor symboli referencyjnych $X[k,l]$ jest znany bezpośrednio z nadajnika lub sprzęgacza (`\cite{diseglioReducingComputationalComplexity2022}` *(rozdz. II)*), co eliminuje szum toru odniesienia oraz zniekształcenia geometrii bistatycznej (wariant bez dostępu do nadajnika wymaga lokalnej demodulacji symboli `\cite{wypich2026}`).
  - [ ] **Akapit 2: Model kanału wielodrogowego oraz bilans mocy i szumu termicznego.**
    - Dwudrożne opóźnienie echa dla odległości radialnej $R_p$: $\tau_p = \frac{2 R_p}{c}$ (czynnik 2 wynika z propagacji fali tam i z powrotem), stąd zależność pomiarowa $R_p = \frac{c \tau_p}{2}$ (`\cite{braun2014}` *(rozdz. 3.2, równ. 3.14)*).
    - Dwudrożne przesunięcie Dopplera dla prędkości radialnej $v_p$: $f_{D,p} = \frac{2 v_p f_c}{c} = \frac{2 v_p}{\lambda}$, w odróżnieniu od jednodrożnego przesunięcia $v_p f_c / c$ w łączności bezprzewodowej (`\cite{sturm2011a}` *(rozdz. III-D, równ. 11–12)*).
    - Czasowo-zmienna odpowiedź impulsowa kanału w obecności przesłuchu bezpośredniego (DPI) i $P$ celów ruchomych (`\cite{wypich2026}` *(rozdz. 2, równ. 1–3)*):
      $$h(\tau, t) = A_{\mathrm{DPI}} \delta(\tau) + \sum_{p=1}^P A_p e^{j 2\pi f_{D,p} t} \delta(\tau - \tau_p)$$
      gdzie składowa bezpośrednia (DPI) oraz odbicia stacjonarne charakteryzują się zerowym przesunięciem Dopplera ($f_D = 0$), przy czym dla DPI opóźnienie wynosi $\tau = 0$.
    - Bilans mocy, szum termiczny odbiornika i rozgraniczenie pojęć SNR (`\cite{sturm2011a}` *(rozdz. VI, równ. 35–37, tab. 3)*, `\cite{2021}` *(rozdz. 27.3.18)*):
      $$P_N = k_B T_0 B \cdot \mathrm{NF}$$
      gdzie $k_B$ to stała Boltzmanna, $T_0$ to temperatura szumowa odniesienia ($290\ \text{K}$), $B$ to szerokość pasma odbiornika, a $\mathrm{NF}$ to współczynnik szumów (dla komercyjnych układów Wi-Fi $\mathrm{NF} \approx 6\text{--}8\ \text{dB}$, co daje $P_N \in [-95, -86]\ \text{dBm}$ dla pasm $20\text{--}160\ \text{MHz}$). Przy stałej dopuszczalnej mocy wypromieniowanej EIRP punktu dostępowego (np. $P_{\mathrm{tx}} = 100\ \text{mW} = 20\ \text{dBm}$ wg `\cite{braun2014}` *(rozdz. 3.6.2)*) dwukrotne poszerzenie kanału zwiększa $P_N$ o $+3\ \text{dB}$, co dla przejścia z 20 MHz na 160 MHz skutkuje wzrostem poziomu szumów o $10\log_{10}(160/20) \approx 9{,}03\ \text{dB}$.
    - **Rozgraniczenie aparatu pojęciowego (nomenklatura komunikacyjna vs. radarowa):**
      1. Komunikacyjny stosunek nośnej do szumu fali bezpośredniej: $\mathrm{CNR}$ (lub $\mathrm{SNR}_{\mathrm{comm}} = P_{\mathrm{rx, dir}} / P_N$), wynikający z bilansu łącza punktu dostępowego z odległości kilku metrów (moc odebrana $P_{\mathrm{rx, dir}} \approx -65\ \text{dBm}$, co przy $\mathrm{SNR} \approx 25\ \text{dB}$ odpowiada typowym warunkom odbioru wewnątrzbudynkowego; *referencja robocza dla autora: [`src/step2_channel.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/src/step2_channel.m)*).
      2. Stosunek fali bezpośredniej do echa celu: $\mathrm{DPR} = P_{\mathrm{rx, dir}} / P_{\mathrm{target}}$ (lub $\mathrm{SIR} = P_{\mathrm{target}} / P_{\mathrm{DPI}}$), rzędu $40\text{--}60\ \text{dB}$, gdzie fala bezpośrednia stanowi najsilniejsze zakłócenie maskujące (przesłuch bezpośredni DPI).
      3. Radarowy stosunek echa celu do szumu na wejściu: $\mathrm{SNR}_{\mathrm{target}} = P_{\mathrm{target}} / P_N = \mathrm{SNR}_{\mathrm{comm}} / \mathrm{DPR}$, który przed kompresją widma jest **ujemny** (typowo $-15$ do $-25\ \text{dB}$).
      4. Most do podrozdziału 2.6: uzasadnienie konieczności zysku całkowania koherentnego 2D-FFT $G_p = 10\log_{10}(K_{\mathrm{act}} M) \approx +38\ \text{dB}$, który wynosi echo celu z ujemnego $\mathrm{SNR}_{\mathrm{target}}$ ponad próg detekcji na wynikowej mapie Range–Doppler.
  - [ ] **Akapit 3: Parametry siatki czas–częstotliwość i granice jednoznaczności.**
    - Pełne wyprowadzenie 5 parametrów *(referencja robocza dla autora — zgodność z [`lib/calculate_physical_axes.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/calculate_physical_axes.m))*:
      1. Nominalny krok odległościowy siatki (dla częstotliwości próbkowania $f_s = B$): $\Delta R = \frac{c}{2 B}$, natomiast fizyczna rozdzielczość wynikająca z pasma aktywnych podnośnych $B_{\mathrm{act}} = K_{\mathrm{act}} \Delta f$ wynosi $\Delta R_{\mathrm{act}} = \frac{c}{2 B_{\mathrm{act}}}$ (z pominięciem czynnika poszerzenia od okna wagowego z pkt 2.6). Dla $B \in \{20, 40, 80, 160\}\ \text{MHz}$ krok nominalny wynosi odpowiednio $7{,}50\ \text{m}$, $3{,}75\ \text{m}$, $1{,}875\ \text{m}$ oraz $0{,}9375\ \text{m}$; dla 20 MHz pasma aktywnego odpowiada to $\Delta R_{\mathrm{act}} \approx 9{,}23\ \text{m}$ w 802.11a ($52$ podnośne, $16{,}25\ \text{MHz}$) oraz $\approx 7{,}93\ \text{m}$ w 802.11ax ($242$ podnośne, $18{,}91\ \text{MHz}$).
      2. Maksymalny zasięg jednoznaczny: $R_{\max} = \frac{c}{2 \Delta f}$ wynikający z próbkowania widma co $\Delta f$ (`\cite{braun2014}` *(rozdz. 3.2.2, równ. 3.25)*): $480\ \text{m}$ dla 802.11a i $1920\ \text{m}$ dla 802.11ax (przy czym granica bez ISI wyznaczona przez $T_{\mathrm{CP}} = 0{,}8\ \mu\text{s}$ to $\Delta R_{\mathrm{CP}} = 120\ \text{m}$).
      3. Rozdzielczość prędkości radialnej: $\Delta v = \frac{\lambda}{2 T_{\mathrm{CPI}}} = \frac{c}{2 f_c M T_{\mathrm{PRI}}}$ (gdzie $M$ to liczba próbek/symboli w oknie koherentnym CPI, $T_{\mathrm{CPI}} = M T_{\mathrm{PRI}}$, a $T_{\mathrm{PRI}} = k_{\mathrm{PRI}} T_{\mathrm{sym}}$ oznacza okres próbkowania w czasie wolnym).
         - **Fizyczne ograniczenie pojedynczej ramki Wi-Fi i geneza rozmycia prędkości:** W przetwarzaniu pojedynczej ramki (nawet długiego pakietu 802.11ax o $M \approx 280$ symbolach trwającego $T_{\mathrm{CPI}} \approx 3{,}8\ \text{ms}$) rozdzielczość Rayleigha wynosi zaledwie $\Delta v \approx 7{,}2\ \text{m/s}$ przy fali nośnej $5{,}5\ \text{GHz}$, co daje szerokość listka głównego okna prostokątnego między zerami rzędu $14{,}4\ \text{m/s}$.
         - **Drastyczna asymetria komórki rozdzielczości (Range–Doppler cell asymmetry):** O ile w osi odległości szerokie pasmo (np. $B = 80\ \text{MHz}$) zapewnia wysoką rozdzielczość $\Delta R \approx 1{,}88\ \text{m}$, o tyle w osi prędkości rozdzielczość jest zgrubna ($\sim 7\text{--}18\ \text{m/s}$). Sprawia to, że odpowiedź celu punktowego na mapie RDM ma z natury kształt silnie spłaszczonej, poziomej elipsy (smugi), a nie symetrycznego punktu („siatki”).
         - **Porównanie z integracją wieloramkową (inter-frame):** Uzyskanie wąskiego piku prędkości ($\Delta v < 0{,}5\ \text{m/s}$) typowego dla radarów impulsowych wymagałoby wydłużenia czasu obserwacji do $T_{\mathrm{CPI}} \sim 50\text{--}100\ \text{ms}$ poprzez integrację wielu kolejnych pakietów (*inter-frame / multi-packet processing*), podczas gdy przetwarzanie wewnątrz pojedynczej ramki charakteryzuje się nieuniknionym fizycznym rozmyciem prędkości.
      4. Pełna szerokość jednoznacznego okna prędkości: $v_{\text{unamb}} = \frac{\lambda}{2 T_{\mathrm{PRI}}} = \frac{c}{2 f_c T_{\mathrm{PRI}}}$ wynikająca z twierdzenia Nyquista–Shannona (`\cite{zielinski2007}` *(rozdz. 4.5 i 7.1)*) dla próbkowania w czasie wolnym z krokiem $T_{\mathrm{PRI}}$: $|f_D| \le \frac{1}{2 T_{\mathrm{PRI}}}$.
      5. Maksymalna mierzalna prędkość radialna (symetryczna): $v_{\max} = \frac{v_{\text{unamb}}}{2} = \frac{c}{4 f_c T_{\mathrm{PRI}}}$, odpowiadająca przedziałowi jednoznaczności $v \in [-v_{\max}, +v_{\max}]$.
    - Zestawienie liczbowe dla $f_c = 5{,}5\ \text{GHz}$ (ukazujące wpływ wydłużenia symbolu $T_{\mathrm{sym}}$ z $4{,}0\ \mu\text{s}$ w 802.11a do $13{,}6\ \mu\text{s}$ w 802.11ax — stosunek $3{,}4\times$):
      - Przy przetwarzaniu ciągłym symbol po symbolu ($k_{\mathrm{PRI}} = 1$): $v_{\max} \approx 3409{,}1\ \text{m/s}$ ($v_{\text{unamb}} \approx 6818{,}2\ \text{m/s}$, `\cite{braun2014}` *(tab. 3.7)*) w 802.11a oraz $v_{\max} \approx 1002{,}7\ \text{m/s}$ ($v_{\text{unamb}} \approx 2005{,}3\ \text{m/s}$) w 802.11ax.
      - Przy próbkowaniu okresowym w czasie wolnym z odstępem $T_{\mathrm{PRI}} = k_{\mathrm{PRI}} T_{\mathrm{sym}}$ (`\cite{colone2014}`, dla $k_{\mathrm{PRI}} = 60$): granica symetryczna spada do $\pm 56{,}82\ \text{m/s}$ ($v_{\text{unamb}} = 113{,}64\ \text{m/s}$) dla 802.11a oraz $\pm 16{,}71\ \text{m/s}$ ($v_{\text{unamb}} = 33{,}42\ \text{m/s}$) dla 802.11ax — przekroczenie $16{,}71\ \text{m/s}$ wywołuje **aliasing Dopplera** (`\cite{zielinski2007}` *(rozdz. 7.1)*). *(Uwaga terminologiczna do spięcia z Rozdz. 4: na wykresach E2 symetryczną granicę $\pm v_{\max}$ oznacza się skrótowo jako $\pm v_{\mathrm{unamb}}$ jako połowę pełnego pasma jednoznacznego).*
  - [ ] **Akapit 4: Most merytoryczny do badań w Rozdziale 4 *(bez nazw plików `.m` w tekście)*.**
    - Zapowiedź weryfikacji eksperymentalnej wyprowadzonych zależności granicznych w Rozdziale 4:
      - **Eksperyment E1 (`\ref{subsec:sim_bandwidth_resolution}`):** badanie skalowania rozdzielczości $\Delta R$ i wzrostu poziomu szumów $P_N$ o $9{,}03\ \text{dB}$ przy stałej mocy punktu dostępowego dla pasm $B \in \{20, 40, 80, 160\}\ \text{MHz}$,
      - **Eksperyment E2 (`\ref{subsec:sim_doppler_aliasing}`):** weryfikacja zawijania widma Dopplera (aliasingu prędkości) przy przekroczeniu granicy $\pm 16{,}71\ \text{m/s}$ dla 802.11ax względem 802.11a.
- **Czego NIE pisać:**
  - Nie opisywać historii radaru (Hülsmeyer, Watson-Watt).
  - Nie wyprowadzać ogólnego równania radiolokacji z zyskami anten i całkowaniem po kącie bryłowym.
  - Nie rysować trójkątów bistatycznych ani nie wyprowadzać równań elips bistatycznych.
  - Nie odwoływać się do nazw plików `.m` ani architektury programu.

---

### Podrozdział 2.4: Estymacja częstotliwościowej odpowiedzi kanału (CFR)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L116).
- **Docelowa objętość:** 2,0 strony (~600 słów).
- **Budżet:** 4–5 równań (elastyczny wg sekcji 2.5), 1 tabela porównawcza (ZF vs. MF).
- **Plan akapitów (z zachowaniem wynikowości, bez skrótów myślowych i wg zasad sekcji 2.5):**
  - [ ] **Akapit 1: Model odebranej macierzy podnośnych.**
    - Po usunięciu prefiksu cyklicznego CP i wykonaniu FFT w odbiorniku (zgodnie z opisaną w 2.2 własnością splotu kołowego), sygnał w dziedzinie częstotliwości w obecności szumu przyjmuje postać macierzy $Y[k,l]$ dla $k \in \mathcal{K}_{\mathrm{act}}$ oraz $l = 0, \dots, M-1$ (`\cite{sturm2011a}` *(rozdz. IV-B, równ. 15–17)*):
      $$Y[k,l] = H[k,l] X[k,l] + W[k,l]$$
      gdzie $X[k,l]$ to symbole odniesienia, $H[k,l]$ to poszukiwana częstotliwościowa odpowiedź kanału (CFR), a $W[k,l]$ to addytywny zespolony szum Gaussa (AWGN) o wariancji $\sigma_W^2$.
  - [ ] **Akapit 2: Paradygmat dziedziny podnośnych (CFR) a wzajemna funkcja niejednoznaczności (CAF).**
    - Porównanie z klasycznym radarem pasywnym wyznaczającym wzajemną funkcję niejednoznaczności (CAF) w czasie ciągłym przez dwuwymiarową korelację (`\cite{colone2014}` *(rozdz. II, równ. 6–7)*).
    - W radarze OFDM estymacja w dziedzinie podnośnych (przetwarzanie w dziedzinie symboli modulacji, `\cite{sturm2011a}` *(rozdz. IV-A/B, rys. 9)*) eliminuje losową modulację danych bezpośrednio na macierzy $K \times M$. Usuwa to listki boczne autokorelacji sygnału komunikacyjnego (sięgające $-15\ \text{dB}$ od kształtu impulsu prostokątnego i $-30\ \text{dB}$ od korelacji losowych danych w `\cite{sturm2011a}` oraz artefakty od powtarzalnych struktur ramki w `\cite{wypich2026}`). Dzięki zastosowaniu szybkich algorytmów FFT (`\cite{zielinski2007}` *(rozdz. 9.5)*) spada złożoność obliczeniowa z $O(N^2)$ do $O(K M \log_2(K M))$ (`\cite{braun2014}` *(rozdz. 3.5)*).
  - [ ] **Akapit 3: Estymatory Zero-Forcing (ZF / FEQ / RpF) oraz Matched Filter (MF).**
    - Zapożyczenie zasady dzielenia widm z podręcznika `\cite{zielinski2007}` *(rozdz. 23.6.2 równ. 23.13–23.14 oraz korektor FEQ rozdz. 23.6.4 równ. 23.26–23.27)*: estymacja odpowiedzi kanału przez iloraz widma odebranego i nadanego ($\hat{H}(k) = Y_N(k) / X_N(k)$), znana w literaturze radarowej jako *Reciprocal Filter* (RpF) (`\cite{diseglioReducingComputationalComplexity2022}` *(rozdz. IV, równ. 12–13)*):
      $$\hat{H}_{\mathrm{ZF}}[k,l] = \frac{Y[k,l]}{X[k,l] + \varepsilon} = H[k,l] + \frac{W[k,l]}{X[k,l] + \varepsilon}$$
      gdzie $\varepsilon \ll 1$ ($\varepsilon = 10^{-9}$) to niewielki parametr regularyzacji zapobiegający dzieleniu przez zero. Operację tę ogranicza się do aktywnych podnośnych $\mathcal{K}_{\mathrm{act}}$, zerując pasma ochronne aby nie wzmacniać szumu w pustych prążkach (`\cite{diseglioReducingComputationalComplexity2022}`).
    - Estymator Matched Filter (korelator częstotliwościowy odpowiadający klasycznemu dopasowaniu widmowemu `\cite{diseglioReducingComputationalComplexity2022}` *(rozdz. IV)*):
      $$\hat{H}_{\mathrm{MF}}[k,l] = Y[k,l] X^*[k,l] = H[k,l] |X[k,l]|^2 + W[k,l] X^*[k,l]$$
  - [ ] **Akapit 4: Zjawisko wzmocnienia szumu (*Noise Enhancement*) dla modulacji QAM.**
    - Wyjaśnienie bez skrótów myślowych: Wariancja szumu resztkowego w estymatorze ZF zależy od energii punktu konstelacji: $\sigma^2_{\mathrm{ZF}}[k,l] = \sigma_W^2 / |X[k,l]|^2$ (`\cite{braun2014}` *(Dodatek A, równ. A.1–A.2)*).
    - W preambule oraz dla modulacji BPSK/QPSK stała obwiednia daje $|X|^2 = 1$ — estymatory ZF i MF są tożsame co do modułu (`\cite{braun2014}` *(Dodatek A, str. 148)*).
    - W polu danych przy modulacjach wielopoziomowych (16-QAM, 64-QAM, 1024-QAM) wewnętrzne punkty konstelacji mają energię wielokrotnie mniejszą od średniej ($|X|^2 \ll 1$). Dzielenie przez małą amplitudę w ZF/RpF powoduje gwałtowny wzrost wariancji szumu oraz zmienia jego rozkład na niegaussowski (`\cite{braun2014}` *(Dodatek A, rys. A.1)*).
    - Wyprowadzenie bezwymiarowego, niezależnego od skali współczynnika degradacji szumowej Zero-Forcing *(referencja robocza dla autora: [`lib/estimate_channel_zf.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/estimate_channel_zf.m))*:
      $$\zeta_{\mathrm{ZF}} = \mathbb{E}\left[|X|^2\right] \cdot \mathbb{E}\left[\frac{1}{|X|^2}\right], \quad \zeta_{\mathrm{ZF}}\,[\text{dB}] = 10 \log_{10} \zeta_{\mathrm{ZF}}$$
      który dla BPSK/QPSK wynosi $0\ \text{dB}$, dla 16-QAM wzrasta o ok. $2{,}7\ \text{dB}$ (`\cite{braun2014}` *(Dodatek A, str. 149)*), a w literaturze dla przejścia z 4-QAM na 256-QAM wykazano spadek kontrastu PNFR o ok. $4{,}5\ \text{dB}$ (`\cite{wypich2026}` *(rozdz. 5, rys. 16)*). Natomiast w estymatorze MF mnożenie przez $|X|^2$ pozostawia losową fluktuację amplitudy w sygnale celu, generując podwyższoną podłogę listków bocznych (`\cite{diseglioReducingComputationalComplexity2022}` *(rozdz. I i IV)*).
  - [ ] **Akapit 5: Most merytoryczny do podrozdziału 2.5 i badań w Rozdziale 4 *(bez nazw plików `.m` w tekście)*.**
    - Wskazanie przejścia macierzy estymaty $\hat{H}[k,l]$ do etapu filtracji ech stałych (podrozdział 2.5) oraz zapowiedź **Eksperymentu E3 (`\ref{subsec:sim_mcs_noise_enhancement}`) w Rozdziale 4**, badającego zależność współczynnika $\zeta_{\mathrm{ZF}}$ i spadek PNFR dla schematów MCS 0..11.
- **Tabela:** Porównanie cech ZF (RpF) i MF (odporność na listki boczne modulacji, odporność na wzmocnienie szumu dla BPSK vs 16/64/1024-QAM, złożoność obliczeniowa).
- **Czego NIE pisać:** Nie wyprowadzać estymatorów LMMSE ani nie podawać nazw funkcji MATLAB-a.

---

### Podrozdział 2.5: Tłumienie ech stałych i kompensacja luki DC
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L119).
- **Docelowa objętość:** 1,5 strony (~450 słów).
- **Budżet:** 3 równania, 0 rysunków.
- **Plan akapitów (z zachowaniem wynikowości, bez skrótów myślowych i wg zasad sekcji 2.5):**
  - [ ] **Akapit 1: Problem przesłuchu bezpośredniego (DPI) i tła stacjonarnego.**
    - Wyjaśnienie fizyczne: Sygnał bezpośredni z nadajnika do odbiornika (DPI) oraz stacjonarne odbicia od ścian i mebli przewyższają moc echa małego celu ruchomego o 40–80 dB (`\cite{colone2014}` *(rozdz. III–IV, rys. 4a, 8)*).
    - Z powodu skończonego czasu obserwacji $T_{\mathrm{CPI}}$ listki boczne transformaty Fouriera dla częstotliwości Dopplera $f_D = 0$ rozlewają się wzdłuż osi prędkości (przeciek widmowy, `\cite{zielinski2007}` *(rozdz. 8.3)*), całkowicie maskując obiekty ruchome (`\cite{colone2014}` *(rozdz. III)*).
  - [ ] **Akapit 2: Filtracja MTI w dziedzinie czasu wolnego.**
    - W architekturze radaru OFDM tłumienie składowej stałej realizuje się bezpośrednio na wyestymowanej macierzy $\hat{H}[k,l]$ wzdłuż wymiaru symboli $l$ (czasu wolnego), przed kompresją odległościową (`\cite{diseglioReducingComputationalComplexity2022}` *(rozdz. III, rys. 2 — redukcja FLOP o 53% względem ECA/ECA-B z `\cite{colone2014}`)*).
    - Filtr MTI rzędu zerowego — odjęcie wartości średniej po czasie wolnym w obrębie CPI dla każdej podnośnej niezależnie (`\cite{bradshawAlternativeDopplerExtraction}` *(rozdz. 3.4, równ. 3.9–3.10)*):
      $$\tilde{H}_{\mathrm{MTI}}[k,l] = \hat{H}[k,l] - \frac{1}{M} \sum_{m=0}^{M-1} \hat{H}[k,m]$$
    - Właściwość: operacja ta w punkcie $f_D = 0$ tworzy głębokie zero charakterystyki (wycinając DPI i echa stacjonarne o $\ge 40\ \text{dB}$), zachowując niemal nienaruszone przesunięcia fazowe celów ruchomych ($f_D \ne 0$).
  - [ ] **Akapit 3: Mechanizm powstawania listków bocznych przez lukę DC i uogólniona interpolacja wielopunktowa.**
    - Mechanizm fizyczny (`\cite{braun2014}` *(rozdz. 3.3.8, równ. 3.104–3.113, rys. 3.16–3.18)* oraz własność splotu widm w `\cite{zielinski2007}` *(rozdz. 4.4 i 8.5)*): Brak transmisji na pustych podnośnych wewnętrznych odpowiada odjęciu delty/okna luk od funkcji wagowej w dziedzinie częstotliwości. Po IFFT na osi odległości powstaje stały człon zakłócający o poziomie $1/N$ (tzw. *constant spur floor*, ograniczający dynamikę 802.11a przy oknie Hamminga do $\mathrm{PSR} \approx 27\ \text{dB}$ wg `\cite{braun2014}` *(przypis 12, str. 67)*).
    - Porównanie metod naprawy: W pracy `\cite{braun2014}` *(rozdz. 3.3.8 i 3.6.2)* zaproponowano decymację co drugiej podnośnej ($U=2$), co jednak marnuje połowę energii użytecznej ($-3\ \text{dB}$) i skraca dwukrotnie jednoznaczny zasięg $R_{\max}$. Zamiast tego w niniejszej pracy zastosowano **uogólnioną wielopunktową interpolację liniową** brakujących podnośnych wewnątrz pasma aktywnego (`\cite{wypich2026}` *(rozdz. 3.2)*), zachowując pełną energię sygnału i pełny zasięg jednoznaczny.
    - Dla każdego spójnego przedziału zerowych podnośnych wewnętrznych $[k_L + 1, k_R - 1]$ o szerokości $G \in \{1, 3, 5, 23\}$ *(referencja robocza dla autora: pętla po spójnych lukach `diff(dc) > 1` w [`lib/estimate_channel_zf.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/estimate_channel_zf.m))*, obejmującego zarówno centralną lukę DC, jak i po 5 zerowych podnośnych w podkanałach 80 MHz dla szerokości 160 MHz, wyznacza się wartości zrekonstruowane ze skrajnych podnośnych aktywnych $k_L$ i $k_R$:
      $$\tilde{H}[k_L + g, l] = \tilde{H}[k_L, l] + \frac{g}{G+1} \left( \tilde{H}[k_R, l] - \tilde{H}[k_L, l] \right), \quad g \in \{1, \dots, G\}$$
      co dla pojedynczej podnośnej DC w standardzie 802.11a ($G=1$) redukuje się do średniej arytmetycznej $(\tilde{H}[k_L,l] + \tilde{H}[k_R,l])/2$.
  - [ ] **Akapit 4: Most merytoryczny do podrozdziału 2.6 i badań w Rozdziale 4 *(bez nazw plików `.m` w tekście)*.**
    - Wskazanie przekazania skondycjonowanej macierzy $\tilde{H}[k,l]$ do wyznaczenia dwuwymiarowej mapy Range–Doppler (podrozdział 2.6) oraz zapowiedź **Eksperymentu E4 (`\ref{subsec:sim_clutter_suppression}`) w Rozdziale 4**, weryfikującego skuteczność tłumienia clutteru w modelach propagacyjnych TGax (Model-A, Model-C, Model-E).
- **Czego NIE pisać:** Nie wyprowadzać filtrów adaptacyjnych czasu ciągłego na surowych próbkach IQ (LMS, szczegółowe warianty macierzowe ECA/ECA-B) — wspomnieć o nich jednym zdaniem porównawczym (`\cite{colone2014}`). Nie podawać nazw plików `.m`.

---

### Podrozdział 2.6: Wyznaczanie mapy odległość–prędkość (Range–Doppler)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L122).
- **Docelowa objętość:** 1,5 strony (~450 słów).
- **Budżet:** 4 równania (elastyczny wg sekcji 2.5), 1 tabela parametrów okien wagowych.
- **Plan akapitów (z zachowaniem wynikowości, bez skrótów myślowych i wg zasad sekcji 2.5):**
  - [ ] **Akapit 1: Dwuwymiarowa transformata Fouriera (2D Periodogram).**
    - Przejście od skondycjonowanej macierzy CFR $\tilde{H}[k,l]$ o rozmiarze $N_{\mathrm{FFT}} \times M$ (z niezerowymi elementami na paśmie aktywnym i zrekonstruowanej luce DC) do zespolonej mapy Range–Doppler $\text{CPer}(r, d)$ (`\cite{braun2014}` *(rozdz. 3.3, równ. 3.30–3.31, 3.69)*):
      $$\text{CPer}(r, d) = \sum_{l=0}^{M_{\mathrm{per}}-1} \left( \sum_{k=0}^{N_{\mathrm{per}}-1} \tilde{H}[k,l] W[k,l] e^{j 2\pi \frac{k r}{N_{\mathrm{per}}}} \right) e^{-j 2\pi \frac{l d}{M_{\mathrm{per}}}}$$
      gdzie $N_{\mathrm{per}} = \xi_r 2^{\lceil \log_2 N_{\mathrm{FFT}} \rceil}$, $M_{\mathrm{per}} = \xi_d 2^{\lceil \log_2 M \rceil}$ to wymiary siatki po dopełnieniu zerami (ang. *zero-padding*, współczynnik $\xi_r = \xi_d = 4$), które gęściej próbkuje widmo (interpolacja $\mathrm{sinc}$/Dirichleta) bez dodawania nowej informacji fizycznej (`\cite{zielinski2007}` *(rozdz. 8.3 i 8.6)*); operacja ta redukuje błąd kwantyzacji binów i eliminuje kanciastość/schodkowość siatki, nadając plamom celów gładki, ciągły obrys. *(Referencja robocza dla autora: [`lib/compute_range_doppler_map.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/compute_range_doppler_map.m)).*
    - Wyjaśnienie znaków: IFFT ze znakiem plus po osi częstotliwości $k$ kompensuje liniowy obrót fazy $e^{-j 2\pi k \Delta f \tau}$ (odwzorowanie opóźnienia/odległości $\tau \to r$), natomiast FFT ze znakiem minus po osi czasu wolnego $l$ kompensuje obrót $e^{+j 2\pi l T_{\mathrm{PRI}} f_D}$ (odwzorowanie przesunięcia Dopplera $f_D \to d$) (`\cite{sturm2011a}` *(rozdz. IV-B)*).
    - Zysk przetwarzania koherentnego wynikający z sumowania koherentnego sygnału użytecznego względem nieskorelowanego szumu: $G_p = 10 \log_{10}(K_{\mathrm{eff}} \cdot M)\ \text{dB}$ (`\cite{sturm2011a}` *(rozdz. IV-B, równ. 27)*).
    - Moc periodogramu w skali logarytmicznej (`\cite{braun2014}` *(rozdz. 3.3, równ. 3.31)*): $P(r, d) = 10 \log_{10} \left( \frac{1}{K_{\mathrm{eff}} M} |\text{CPer}(r, d)|^2 \right)\ \text{dB}$.
  - [ ] **Akapit 2: Przeciek widmowy i dobór okna separowalnego 2D.**
    - Okno separowalne $W[k,l] = w_r[k] \cdot w_d[l]$ (`\cite{braun2014}` *(rozdz. 3.3.4, równ. 3.70)*), przy czym okno częstotliwościowe $w_r[k]$ nakłada się wyłącznie na zbiór aktywnych podnośnych (z wyłączeniem pasm ochronnych).
    - Konsekwencje okna prostokątnego: najwyższy poziom listków bocznych ($\mathrm{PSLL} = -13{,}3\ \text{dB}$, `\cite{zielinski2007}` *(rozdz. 8.5.1, tab. 8-1)*), które maskują małe obiekty ruchome i generują fałszywe alarmy.
    - Zastosowanie 4-wyrazowego okna Blackmana–Harrisa (`\cite{braun2014}` *(rozdz. 3.3.4, równ. 3.73)*, uogólnienie sumy kosinusów z `\cite{zielinski2007}` *(rozdz. 8.5.1, równ. 8.46–8.47)*):
      $$w[n] = a_0 - a_1 \cos\left(\frac{2\pi n}{N-1}\right) + a_2 \cos\left(\frac{4\pi n}{N-1}\right) - a_3 \cos\left(\frac{6\pi n}{N-1}\right)$$
      ze współczynnikami $a_0 = 0{,}35875$, $a_1 = 0{,}48829$, $a_2 = 0{,}14128$, $a_3 = 0{,}01168$, zapewniającego tłumienie listków bocznych na poziomie $-92{,}1\ \text{dB}$ (`\cite{braun2014}` *(tab. 3.2)*).
  - [ ] **Akapit 3: Trójstronny kompromis okienkowania.**
    - Analiza kompromisu (`\cite{zielinski2007}` *(rozdz. 8.5.1, tab. 8-1, rys. 8.10)*): tłumienie listków bocznych (PSLL) vs. poszerzenie listka głównego (szerokość przy $-3\ \text{dB}$ rośnie z $0{,}89$ do $1{,}90$ binu, a szerokość do pierwszych zer $\Delta_{\mathrm{ml}}$ w 1D wzrasta z $4\pi/N$ do $16\pi/N$) vs. strata przetwarzania koherentnego (ang. *processing loss* $\approx 3{,}0\ \text{dB}$, `\cite{braun2014}` *(tab. 3.2)*).
    - **Analityczne wyjaśnienie morfologii plamy celu (efekt rozmycia prędkości):** W pasywnym radarze Wi-Fi przetwarzającym pojedynczą ramkę bazowa rozdzielczość wynosi zaledwie $\Delta v \approx 7{,}2\ \text{m/s}$ ($T_{\mathrm{CPI}} \approx 3{,}8\ \text{ms}$). Zastosowanie okna Blackmana–Harrisa powoduje 2,5–3-krotne poszerzenie listka głównego, w wyniku czego cel ruchomy tworzy plamę o szerokości rzędu $15\text{--}20\ \text{m/s}$. W połączeniu z gładką interpolacją sinc wynikającą z 4-krotnego zero-paddingu oraz wąską rozdzielczością odległości ($\Delta R \approx 1{,}88\ \text{m}$ dla 80 MHz), odpowiedź celu przyjmuje postać gładkiej, poziomo rozmytej elipsy zamiast ostrego punktu siatki. Jest to zamierzony i konieczny kompromis inżynierski: poświęcenie ostrości piku prędkości w zamian za zbicie listków bocznych o $80\ \text{dB}$ (eliminacja poziomych pasów przecieku i fałszywych detekcji).
    - Uzasadnienie: w pasywnym radarze Wi-Fi o dużej rozpiętości dynamiki między celami priorytetem jest tłumienie listków bocznych (nawet kosztem $\approx 3\ \text{dB}$ straty SNR i szerszego listka głównego).
  - [ ] **Akapit 4: Most merytoryczny do podrozdziału 2.7 *(bez nazw plików `.m` w tekście)*.**
    - Wyjaśnienie przekazania zespolonej mapy $\text{CPer}(r,d)$ do końcowego etapu detekcji i ekstrakcji celów opisanego w podrozdziale 2.7 *(uwaga robocza dla autora: spójność z [`lib/compute_range_doppler_map.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/compute_range_doppler_map.m))*.
- **Tabela:** Zestawienie okien (Prostokątne, Hanna, Hamminga, Blackmana–Harrisa): PSLL [dB], szerokość listka głównego ($\Delta_{\mathrm{ml}}$ / szerokość $-3\ \text{dB}$ [biny]), strata przetwarzania [dB] (dane z `braun2014` *(tab. 3.2)* i `zielinski2007` *(tab. 8-1)*).
- **Czego NIE pisać:** Nie wyprowadzać algorytmów superrozdzielczych (MUSIC, ESPRIT), chociaż o ich istnieniu można wspomnieć w 1 zdaniu jako o alternatywie (`\cite{braun2014}`). Nie podawać nazw plików `.m`.

---

### Podrozdział 2.7: Detekcja progowa CFAR i iteracyjna ekstrakcja celów (Binary STC oraz Coherent STC)
- [ ] **Status:** Do napisania w [`thesis/tex/20_passive_radar.tex`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/thesis/tex/20_passive_radar.tex#L125).
- **Docelowa objętość:** 1,5 strony (~550 słów).
- **Budżet:** 6–8 równań (elastyczny wg sekcji 2.5), 0 rysunków (ewentualnie 1 tabela porównawcza Binary STC vs Coherent STC).
- **Plan akapitów (z zachowaniem wynikowości, bez skrótów myślowych i wg zasad sekcji 2.5):**
  - [ ] **Akapit 1: Estymacja tła szumowego ML poza $N_{\max}$, próg CFAR $\eta$ oraz metryka PNFR.**
    - Rozkład statystyczny szumu na periodogramie: dla zespolonego szumu AWGN o wariancji $\sigma^2$ pod hipotezą zerową $\mathcal{H}_0$ znormalizowany periodogram mocy $\mathrm{Per}_{\mathbf{F}}(n,m) = \frac{1}{NM}|\mathrm{CPer}_{\mathbf{F}}(n,m)|^2$ ma rozkład wykładniczy ($\chi_2^2$) o średniej $\sigma^2$, stąd $P(\mathrm{Per}_{\mathbf{F}} > \eta \mid \mathcal{H}_0) = \exp(-\eta / \sigma^2)$ (`\cite{braun2014}` *(rozdz. 3.3.6, równ. 3.91–3.92)*).
    - Estymator maksymalnej wiarygodności (ML) mocy szumu $\hat{\sigma}^2$ wyznaczony poza maksymalnym jednoznacznym zasięgiem bez ISI wyznaczonym przez prefiks cykliczny $N_{\max} = \lceil (N_{\mathrm{CP}}/N_{\mathrm{FFT}})N_{\mathrm{Per}}\rceil$ z pasmem ochronnym $n_{\mathrm{guard}}$ chroniącym przed wyciekiem z $N_{\max}$ oraz zawinięciem cyklicznym FFT przy $R = 0$ (`\cite{braun2014}` *(równ. 3.98)*; *referencja robocza dla autora: [`lib/binary_successive_target_cancellation.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/binary_successive_target_cancellation.m), [`lib/coherent_successive_target_cancellation.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/coherent_successive_target_cancellation.m)*):
      $$\hat{\sigma}^2 = \frac{1}{(n_{\mathrm{end}} - n_{\mathrm{start}} + 1) M_{\mathrm{Per}}} \sum_{n=n_{\mathrm{start}}}^{n_{\mathrm{end}}} \sum_{m} \mathrm{Per}_{\mathbf{F}}(n,m)$$
    - Globalny próg CFAR dla zadanego prawdopodobieństwa fałszywego alarmu na całą ramkę $p_{\mathrm{FA}}$ (domyślnie $10^{-3}$, `\cite{braun2014}` *(równ. 3.95)*):
      $$p_{\mathrm{FA,bin}} = 1 - (1 - p_{\mathrm{FA}})^{\frac{1}{NM}}, \qquad \eta = -\hat{\sigma}^2 \ln(p_{\mathrm{FA,bin}})$$
      gdzie wykładnik $1/(NM)$ wynika z tego, że dopełnianie zerami (*zero-padding*) jedynie interpoluje widmo i nie zwiększa liczby statystycznie niezależnych komórek rozdzielczości ($NM$).
    - Definicja metryki kontrastu detekcji PNFR (*Peak-to-Noise-Floor Ratio*, `\cite{wypich2026}` *(rozdz. 4.4, równ. 6)*; *referencja robocza dla autora: [`lib/compute_pnfr.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/compute_pnfr.m)*):
      $$\text{PNFR}_k = 10 \log_{10} \left( \frac{P_{\mathrm{peak}, k}}{P_{\mathrm{floor}}} \right) \quad [\text{dB}]$$
      gdzie $P_{\mathrm{floor}} = \frac{1}{|\Omega_{\mathrm{noise}}|} \sum_{(r,d) \in \Omega_{\mathrm{noise}}} P(r,d)$ jest estymatorem mocy tła wyznaczonym poza strefami ochronnymi (*guard boxes*, domyślnie $\pm 16$ binów) wszystkich wykrytych obiektów (`\cite{wypich2026}`).
  - [ ] **Akapit 2: Ograniczenia klasycznego CA-CFAR oraz 2D interpolacja paraboliczna i estymacja parametrów fizycznych.**
    - Wyjaśnienie bez skrótów myślowych: W klasycznym detektorze CA-CFAR (`\cite{colone2014}` *(rozdz. II–III)*) okno trenujące przesuwa się po mapie. W obecności dwóch obiektów o dużej różnicy mocy (np. pojazd o $0\ \text{dB}$ i pieszy o $-30\ \text{dB}$) energia silnego celu wpada do komórek trenujących słabszego obiektu lub jego listek główny/listki boczne sztucznie podnoszą lokalny próg, powodując **maskowanie słabego celu** (`\cite{braun2014}` *(rozdz. 3.3.6–3.3.7)*).
    - Dwuwymiarowa interpolacja kwadratowa (paraboliczna) każdego wykrytego piku $(\hat{n}, \hat{m})$ dla uzyskania współrzędnych podpikselowych $(\tilde{n}, \tilde{m})$ i mocy piku $\mathrm{Per}_{\mathrm{interp}}$ (`\cite{braun2014}` *(rozdz. 3.3.5, równ. 3.84–3.86)*) oraz przeliczenie na estymaty fizyczne $(\hat{d}, \hat{v}, \hat{\sigma}_{\mathrm{RCS}})$ z uwzględnieniem wzmocnienia koherentnego okna $G_{\mathrm{win}}$ (`\cite{braun2014}` *(równ. 3.32–3.34)*):
      $$\hat{d} = \frac{\tilde{n}\,c_0}{2\Delta f N_{\mathrm{Per}}}, \qquad \hat{v} = \frac{\tilde{m}\,c_0}{2 f_c T_{\mathrm{sym}} M_{\mathrm{Per}}}, \qquad \hat{\sigma}_{\mathrm{RCS}} = c_{\mathrm{norm}} \cdot \frac{\mathrm{Per}_{\mathrm{interp}}}{P_{\mathrm{Tx}} NM} \cdot \frac{(4\pi)^3 f_c^2 \max(\hat{d},1)^4}{G c_0^2}$$
  - [ ] **Akapit 3: Iteracyjna ekstrakcja celów — Binary STC oraz Coherent STC.**
    - Porównanie obu algorytmów Brauna (`\cite{braun2014}` *(rozdz. 3.3.7, str. 56–62)*):
      1. **Binary STC (*Binary Successive Target Cancellation*, `\cite{braun2014}` *(rys. 3.13)*)**: działa na rzeczywistym periodogramie mocy $\mathrm{Per}_{\mathbf{F}}$ i masce binarnej $\mathbf{B}$ inicjalizowanej jedynkami. W każdej iteracji wyznacza globalne maksimum w obszarze $\mathbf{B}=1$; jeśli $\mathrm{Per}_{\mathbf{F}}(\hat{n},\hat{m}) < \eta$, przerywa pętlę; w przeciwnym razie wykonuje interpolację paraboliczną i zeruje w $\mathbf{B}$ eliptyczny obszar pełnego listka głównego (*null-to-null* o osiach $N_{\mathrm{win}}, M_{\mathrm{win}}$ okna $\mathbf{W}$) w metryce cyklicznej modulo $N_{\mathrm{Per}}, M_{\mathrm{Per}}$:
         $$\left(\frac{\Delta n}{N_{\mathrm{win}}/2}\right)^2 + \left(\frac{\Delta m}{M_{\mathrm{win}}/2}\right)^2 \le 1$$
         Algorytm cechuje się bardzo niską złożonością (brak ponownych 2D-FFT) i brakiem rezyduów fazy, lecz tworzy strefę ślepą $B=0$ maskującą słabsze cele położone wewnątrz listka głównego silnego obiektu.
      2. **Coherent STC (*Coherent Successive Target Cancellation*, `\cite{braun2014}` *(rys. 3.15, równ. 3.99–3.102)*)**: operuje na zespolonym periodogramie $\mathrm{CPer}_{\mathbf{F}}$ i jego widmie mocy $\mathrm{Per}_{\mathbf{F}}$. W każdej iteracji znajduje globalne maksimum (stop gdy $< \eta$), a następnie w **Kroku 4** sprawdza, czy pik leży w elipsie o półosiach równych szerokości $-3\ \text{dB}$ listka głównego wcześniej wykrytych celów — jeśli tak, kwalifikuje go jako rezyduum dekonwolucji (wynik błędu dyskretyzacji siatki lub odkształcenia MTI) i usuwa bez dopisywania do listy celów. Następnie dla celu właściwego (Krok 5: interpolacja paraboliczna i estymacja fizyczna) syntetyzuje zespoloną odpowiedź pojedynczego reflektora $\mathbf{F}_{\mathrm{target}}(k,l) = e^{-j2\pi k\hat{n}/N_{\mathrm{Per}}} e^{+j2\pi l\hat{m}/M_{\mathrm{Per}}}$, nakłada identyczne okno $\mathbf{W}$, wyznacza 2D-FFT $\mathrm{CPer}_{\mathrm{target}}$, normalizuje ją do jedności w $(\hat{n},\hat{m})$ i koherentnie odejmuje od periodogramu wraz z listkami bocznymi:
         $$\mathrm{CPer}_{\mathbf{F}}^{(i+1)} = \mathrm{CPer}_{\mathbf{F}}^{(i)} - \mathrm{CPer}_{\mathbf{F}}^{(i)}(\hat{n},\hat{m}) \cdot \frac{\mathrm{CPer}_{\mathrm{target}}}{\mathrm{CPer}_{\mathrm{target}}(\hat{n},\hat{m})}, \qquad \mathrm{Per}_{\mathbf{F}}^{(i+1)} = \frac{1}{NM}|\mathrm{CPer}_{\mathbf{F}}^{(i+1)}|^2$$
         Dzięki temu na mapie rezydualnej odsłaniają się słabsze cele ukryte wcześniej pod listkiem głównym i listkami bocznymi silnego obiektu, kosztem jednej 2D-FFT na iterację oraz konieczności tłumienia rezyduów w Kroku 4.
  - [ ] **Akapit 4: Most merytoryczny do badań w Rozdziale 4 *(bez nazw plików `.m` w tekście)*.**
    - Zapowiedź weryfikacji i bezpośredniego porównania algorytmów Binary STC oraz Coherent STC w scenariuszu o dynamice mocy $30\ \text{dB}$ (pojazd $0\ \text{dB}$ i pieszy $-30\ \text{dB}$ w paśmie $20\ \text{MHz}$) w **Eksperymencie E5 (`\ref{subsec:sim_clean_performance}`) w Rozdziale 4** *(uwaga robocza dla autora: spójność z [`lib/binary_successive_target_cancellation.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/binary_successive_target_cancellation.m), [`lib/coherent_successive_target_cancellation.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/coherent_successive_target_cancellation.m), [`lib/get_detection_algorithm.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/lib/get_detection_algorithm.m) oraz [`src/step4_interpreter.m`](file:///c:/Users/tymwo/Projects/MATLAB/WiFi%20Radar/src/step4_interpreter.m))*.
- **Czego NIE pisać:** Nie opisywać rozbudowanych wariantów heurystycznych CFAR (OS/GO/SO/TM-CFAR) ani filtrów śledzenia wieloobiektowego (Kalman/JPDA) — radar operuje w pojedynczym oknie CPI. Nie podawać nazw plików `.m`.

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
  - [x] Wprowadzono zwięzłą, jednorodną formę `\cite{klucz}` w sekcjach 2.1–2.2 oraz usunięto z nich odwołania do kodu symulatora zgodnie z sekcją 2.5 (pozostałe pozycje z `Zotero.bib`, tj. `diseglioReducingComputationalComplexity2022` oraz `bradshawAlternativeDopplerExtraction`, są zaplanowane w podrozdziałach 2.3–2.5).
  - [ ] Wszystkie 11 pozycji z `Zotero.bib` jest jawnie zacytowanych w pracy (0 pozycji „wiszących”) i brak znaków zapytania `[?]` w PDF.
- [ ] **Etykiety, odsyłacze skrośne i synchronizacja międzyrozdziałowa:**
  - [ ] Wszystkie podrozdziały posiadają unikalne etykiety `\label{subsec:...}`.
  - [ ] Wszystkie równania, tabele i rysunki są przywołane przynajmniej raz w tekście (`\ref{...}`).
  - [ ] Odsyłacze do przyszłych rozdziałów (`subsec:sim_bandwidth_resolution`, `subsec:sim_doppler_aliasing`, `subsec:sim_mcs_noise_enhancement`, `subsec:sim_clutter_suppression`, `subsec:sim_clean_performance`) są poprawnie spięte z finalną wersją Rozdziału 4 (bez odwołań do plików `.m` ani rozdziału implementacyjnego wewnątrz rozdziałów teoretycznych).
- [ ] **Objętość i proporcje:**
  - [ ] Całkowita liczba stron Rozdziału 2 w PDF mieści się w przedziale **10,0–11,5 stron** (dokładnie 1 merytoryczny rysunek alokacji podnośnych + 3 tabele parametrów, 0 rysunków-zapychaczy).
  - [ ] Żaden podrozdział nie przekracza limitu 2 stron.
  - [ ] Treści z „listy zakazów” (MAC, kody korekcyjne, historia radaru, inne iluminatory, elipsy bistatyczne) nie przedostały się do tekstu.
