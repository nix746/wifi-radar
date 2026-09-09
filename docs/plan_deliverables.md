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
| 3 | `thesis/tex/30_wifi_phy.tex` | Sygnał Wi-Fi IEEE 802.11 | Rodzina 802.11, OFDM i CP, ramka Non-HT (L-STF, L-LTF, SIGNAL, DATA), parametry radarowe ($B=20\,\mathrm{MHz}$, $\Delta R=7.5\,\mathrm{m}$, $v_{\mathrm{unamb}}\approx 68\,\mathrm{m/s}$), siatka 52 podnośnych i DC |
| 4 | `thesis/tex/40_radar_dsp.tex` | Algorytmy przetwarzania | Schmidl–Cox, Zero-Forcing, MTI, interpolacja DC, okno 2D Blackman–Harris, periodogram 2D, Coherent CLEAN |
| 5 | `thesis/tex/50_simulation_results.tex` | Badania symulacyjne | 5.1 środowisko MATLAB i scenariusze; 5.2 CIR vs CAF; 5.3 $SNR_{\mathrm{out}}(SNR_{\mathrm{in}})$; 5.4 modulacja / tłumienie echa / długość ramki; 5.5 CLEAN |
| 6 | `thesis/tex/99_conclusion.tex` | Wnioski | Podsumowanie, ograniczenia, dalsze prace (SDR/CSI — jako perspektywa, nie jako niedokończony rozdział) |

Front matter (strona tytułowa, oświadczenie, program pracy) zostaje w istniejących plikach `01_`–`03_`, ale z danymi ze zgłoszenia i z poprawką „inżynierska”.

`thesis/tex/20_first_chapter_RENAME_ME.tex` znika na rzecz `20_pbr.tex`. W `thesis/main.tex` wszystkie sześć rozdziałów są `\include`.

Wzory i liczby w rozdziałach 3–4 mają być zgodne z [`theory_notes.md`](theory_notes.md) oraz z `src/` (`receiver_pipeline.m`, `clean_interpreter.m`, `receiver_correlation.m`). Notatki teoretyczne **nie** są drugim szkicem pracy: nie powstaje obowiązkowy `docs/theory_deep_dive.md`.

---

## 3. Bibliografia

Źródło prawdy metadanych: kolekcja Zotero *Wi-Fi Radar*. Git trzyma eksport i inwentarz.

| Warstwa | Gdzie | Rola |
| :--- | :--- | :--- |
| Metadane + PDF | Zotero | Rekord, stały klucz cytowania (Better BibTeX), DOI/URL, załącznik |
| Eksport LaTeX | `thesis/bibliography.bib` | Tylko eksport z Zotero, bez ręcznego klepania rekordów gdy da się je pobrać |
| Inwentarz | `docs/references.md` | Tabela: klucz, tytuł, plik w `references/`, DOI/URL, status |
| Kopie robocze | `references/` | PDF-y (`compendiums/`, `shorts/`, `TW/`, `TZ/`) — import do Zotero |

Status w inwentarzu: `pdf+meta` \| `pdf-only` \| `link-only`. Szablon ma `\bibliographystyle{plain}` — URL/DOI trzeba umieścić tak, żeby weszły do Literatury (`note` / `howpublished`, albo późniejsza zmiana stylu).

**Rekordy obowiązkowe w kolekcji**

- Braun, M. — *OFDM Radar Algorithms in Mobile Communication Networks*, KIT, 2014 (`braun2014`)
- IEEE 802.11a / 802.11-2012 (PHY OFDM); IEEE 802.11bf tylko jeśli naprawdę cytowany (kontekst, nie rdzeń metody)
- Schmidl, Cox — synchronizacja OFDM (1997)
- Prace prof. Zielińskiego cytowane w tekście
- Przeglądy Wi-Fi sensing / ISAC użyte w rozdz. 1–2 (nie lista „na zapas”)
- Szwej (AGH 2024) i Sorbian (WAT 2024) — jeśli wolno je cytować jako prace dyplomowe; w przeciwnym razie pozostają materiałem roboczym w `references/TZ/`

Materiały z `references/TW/` i `TZ/` cytujemy w Literaturze tylko wtedy, gdy faktycznie wchodzą do tekstu.

---

## 4. Kod i rysunki do rozdziału 5

Istniejący łańcuch zostaje: `transmitter` → `channel` → `receiver_pipeline` → `clean_interpreter`, plus `receiver_correlation` jako CAF. Bez przebudowy modułów.

Do dopisania są **dwa skrypty badawcze** (nie nowy pipeline):

| Skrypt | Po co |
| :--- | :--- |
| `scripts/generate_szwej_comparison_plots.m` | Para CIR vs CAF: mesh 3D, `imagesc` 2D, przekroje 1D; stany przed/po MTI i CLEAN; kilka wartości SNR |
| `scripts/evaluate_snr_curves.m` | Krzywe $SNR_{\mathrm{out}}=f(SNR_{\mathrm{in}})$ dla CIR i CAF, warianty tłumienia echa i MCS |

Zapis figur:

- roboczy: `results/figures/`
- do składu: `thesis/img/` (PNG i/lub PDF), nazwy stabilne, gotowe do `\includegraphics`

Istniejący zapis z `clean_interpreter.m` (przed/po CLEAN) zostaje; skrypty badawcze go uzupełniają, a nie zastępują całego `run_full_simulation.m`.

**Katalog rysunków, które rozdział 5 musi mieć** (odpowiedniki zestawu Szwej, nie kopia 1:1 numeracji):

1. Mapa Range–Doppler 2D/3D, metoda CIR, wysoki SNR
2. Ta sama scena, metoda CAF
3. Przekrój 1D w osi prędkości (albo odległości) przez wykryty cel, CIR vs CAF
4. Ta sama para przy średnim i niskim SNR
5. Mapa przed MTI vs po MTI
6. Mapa przed CLEAN vs po CLEAN (scena wielocelowa)
7. $SNR_{\mathrm{out}}$ vs $SNR_{\mathrm{in}}$, CIR i CAF na jednym wykresie
8. Wariant: tłumienie echa i/lub BPSK vs 64-QAM, jeśli krzywa 7 nie pokazuje tego sama

Każdy rysunek w `thesis/img/` ma krótki, powtarzalny stem: `ch5_cir_caf_snr25_mesh.png`, `ch5_snr_curves.png`, itd.

---

## 5. Stan szablonu LaTeX do domknięcia

To nie jest treść naukowa, ale jest częścią dostarczenia pracy:

- `thesis/main.tex` — autor, tytuł, wydział, kierunek, opiekun, recenzent (gdy znany), `\include` wszystkich rozdziałów
- `thesis/tex/01_titlePage.tex` — etykieta **Praca inżynierska** zamiast magisterskiej
- `thesis/tex/03_MasterThesisOutline.tex` — program pracy inżynierskiej ze zgłoszenia
- Spis rysunków / tabel, jeśli szablon i regulamin tego wymagają

---

## 6. Poza zakresem

Celowo **nie** wchodzi do tej pracy (chyba że pojawi się w wnioskach jako perspektywa):

- pomiary rzeczywiste SDR / CSI z karty Wi-Fi
- przebudowa `src/` pod nową architekturę
- drugi, pełny skrypt teorii w Markdown równoległy do rozdziałów 2–4
- osobny rozdział implementacyjny i osobny rozdział wyników
- domykanie bibliografii „na wszystkie artykuły ISAC”, które nie są cytowane
