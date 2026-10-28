# Milestone 1
Tymon Woźniak

## Cel Pracy
Implementacja i testowanie efektywności detekcji wybranego algorytmu radaru pasywnego używającego sygnału Wi-Fi

Zaprojektowanie, implementacja w MATLABie i testy efektywności detekcji celów ruchomych w radarze pasywnym bazującym na sygnałach WiFi. Idea polega na ustaleniu prędkości celu oraz odległości od odbiornika. Dzięki prostocie architektury quasi-monostatycznej oraz pasywnej charakterystyce radaru wdrożenie byłoby możliwe na istniejącym sprzęcie i jego oprogramowaniu, korzystając z dodatkowego odbiornika. 

## Spis treści
```text
Strona tytułowa
Spis treści

1. Wstęp
   1.1. Zakres pracy
   1.2. Motywacja
   1.3. Teza i pytania badawcze
   1.4. Układ pracy
   
2. Radar Pasywny
   3.1. Sygnał Wi-Fi 802.11
   3.2. Modulacja ODFM
   3.3. Podstawy radaru pasywnego
   3.4. Estymacja kanału
   3.5. Filtracja ech stałych
   3.6. Wyznaczanie mapy Range–Doppler
   3.7. Detekcja i ekstrakcja celów

3. Implementacja radaru
   3.1. Środowisko symulacyjne MATLAB i toolboxy
   3.2. Implementacja kanału
   3.3. Implementacja odbiornika
   3.4. Implementacja interpretera

4. Badania symulacyjne
   4.1. Scenariusze testowe
   4.2. Rozdzielczość odległościowa a szerokość pasma
   4.3. Długość symbolu OFDM a prędkość jednoznaczna
   4.4. Wpływ rzędu modulacji MCS i poziomu szumu na estymację ZF
   4.5. Tłumienie stacjonarnego clutteru
   4.6. Skuteczność algorytmu Coherent CLEAN

5. Wnioski
   5.1. Podsumowanie uzyskanych wyników
   5.2. Ograniczenia metody i kierunki rozwoju

Literatura
Spis rysunków
Spis tabel
```

## Plan pracy
1. Napisać pierwszy rozdział (802.11) do końca Października
2. Napisać drugi rozdział (radary)
3. Uzupełnić szczegóły bibliografii
4. Zaimplementować scenariusze testowe
5. Zebrać wykresy
6. Opisać część praktyczną
7. Napisać wstęp i zakończenie

## Literatura
1. IEEE Standard for Telecommunications and Information Exchange Between Systems - LAN/MAN Specific Requirements - Part 11: Wireless Medium Access Control (MAC) and physical layer (PHY) specifications: High Speed Physical Layer in the 5 GHz band
2. IEEE Standard for Information Technology–Telecommunications and Information Exchange between Systems Local and Metropolitan Area Networks–Specific Requirements Part 11: Wireless LAN Medium Access Control (MAC) and Physical Layer (PHY) Specifications Amendment 1: Enhancements for High-Efficiency WLAN
3. OFDM Radar Algorithms in Mobile Communication Networks, Martin Braun (2014)
4. Radar OFDM z użyciem sygnału DVB-T2, Katarzyna Szwej (2020)
5. Commodity Wi-Fi-Based Wireless Sensing Advancements over the Past Five Years, Zhu Hai (2024)
6. Wykorzystanie sieci wi-fi do pasywnej detekcji obiektów, Wojciech Sorbian (2025)
