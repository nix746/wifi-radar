@echo off
setlocal
echo ======================================================
echo   Inicjalizacja i Odtworzenie Historii Gita WiFi Radar
echo ======================================================

set USER_NAME=nix746
set USER_EMAIL=tym.wozniak@gmail.com
set ARCHIVE_DIR=_archive_original

git config user.name "%USER_NAME%"
git config user.email "%USER_EMAIL%"

if not exist ".git" (
    git init
)

:: Commit 1
echo [1/6] Tworzenie Commita 1 (Initial baseline - Patryk Pajerski)...
if exist "%ARCHIVE_DIR%\Patryka\WiFi\wifi_params.m" (
    copy /Y "%ARCHIVE_DIR%\Patryka\WiFi\wifi_params.m" ".\wifi_params.m" >nul 2>&1
    copy /Y "%ARCHIVE_DIR%\Patryka\WiFi\wifi_signal_generation.m" ".\wifi_signal_generation.m" >nul 2>&1
    copy /Y "%ARCHIVE_DIR%\Patryka\WiFi\wifi_channel_doppler.m" ".\wifi_channel_doppler.m" >nul 2>&1
    copy /Y "%ARCHIVE_DIR%\Patryka\WiFi\wifi_procesing.m" ".\wifi_procesing.m" >nul 2>&1
    copy /Y "%ARCHIVE_DIR%\Patryka\WiFi\find_packet_start.m" ".\find_packet_start.m" >nul 2>&1
) else (
    copy /Y "Patryka\WiFi\wifi_params.m" ".\wifi_params.m" >nul 2>&1
    copy /Y "Patryka\WiFi\wifi_signal_generation.m" ".\wifi_signal_generation.m" >nul 2>&1
    copy /Y "Patryka\WiFi\wifi_channel_doppler.m" ".\wifi_channel_doppler.m" >nul 2>&1
    copy /Y "Patryka\WiFi\wifi_procesing.m" ".\wifi_procesing.m" >nul 2>&1
    copy /Y "Patryka\WiFi\find_packet_start.m" ".\find_packet_start.m" >nul 2>&1
)

git add wifi_params.m wifi_signal_generation.m wifi_channel_doppler.m wifi_procesing.m find_packet_start.m
git commit --author="Patryk Pajerski" -m "feat: initial Wi-Fi signal generation, packet synchronization and basic Doppler processing"

:: Commit 2
echo [2/6] Tworzenie Commita 2 (Draft 1 - OFDM Demod ^& 2D Periodogram)...
if exist "%ARCHIVE_DIR%\Draft_1\WiFi\wifi_doppler.m" (
    copy /Y "%ARCHIVE_DIR%\Draft_1\WiFi\wifi_doppler.m" ".\wifi_doppler.m" >nul 2>&1
    copy /Y "%ARCHIVE_DIR%\Draft_1\WiFi\wifi_radar_processing.m" ".\wifi_radar_processing.m" >nul 2>&1
    copy /Y "%ARCHIVE_DIR%\Draft_1\WiFi\wifi_radar_processing_v1.m" ".\wifi_radar_processing_v1.m" >nul 2>&1
    copy /Y "%ARCHIVE_DIR%\Draft_1\WiFi\wifi_radar_visualization.m" ".\wifi_radar_visualization.m" >nul 2>&1
) else (
    copy /Y "Draft_1\WiFi\wifi_doppler.m" ".\wifi_doppler.m" >nul 2>&1
    copy /Y "Draft_1\WiFi\wifi_radar_processing.m" ".\wifi_radar_processing.m" >nul 2>&1
    copy /Y "Draft_1\WiFi\wifi_radar_processing_v1.m" ".\wifi_radar_processing_v1.m" >nul 2>&1
    copy /Y "Draft_1\WiFi\wifi_radar_visualization.m" ".\wifi_radar_visualization.m" >nul 2>&1
)

git add wifi_doppler.m wifi_radar_processing.m wifi_radar_processing_v1.m wifi_radar_visualization.m
git commit -m "feat(draft-1): implement manual OFDM demodulation and physical Range-Doppler periodogram"

:: Commit 3
echo [3/6] Tworzenie Commita 3 (Draft 2 - Modular TX/RX ^& Cancellation)...
git rm -f --cached wifi_params.m wifi_signal_generation.m wifi_channel_doppler.m wifi_procesing.m find_packet_start.m wifi_doppler.m wifi_radar_processing.m wifi_radar_processing_v1.m wifi_radar_visualization.m >nul 2>&1
del /F /Q wifi_params.m wifi_signal_generation.m wifi_channel_doppler.m wifi_procesing.m find_packet_start.m wifi_doppler.m wifi_radar_processing.m wifi_radar_processing_v1.m wifi_radar_visualization.m >nul 2>&1

if exist "%ARCHIVE_DIR%\Draft_2\Transmitter.m" (
    copy /Y "%ARCHIVE_DIR%\Draft_2\Transmitter.m" ".\Transmitter.m" >nul 2>&1
    copy /Y "%ARCHIVE_DIR%\Draft_2\Channel.m" ".\Channel.m" >nul 2>&1
    copy /Y "%ARCHIVE_DIR%\Draft_2\demodulate.m" ".\demodulate.m" >nul 2>&1
    copy /Y "%ARCHIVE_DIR%\Draft_2\Reciever.m" ".\Reciever.m" >nul 2>&1
    copy /Y "%ARCHIVE_DIR%\Draft_2\Reciever_cross.m" ".\Reciever_cross.m" >nul 2>&1
    copy /Y "%ARCHIVE_DIR%\Draft_2\Reciever_branun.m" ".\Reciever_branun.m" >nul 2>&1
) else (
    copy /Y "Draft_2\Transmitter.m" ".\Transmitter.m" >nul 2>&1
    copy /Y "Draft_2\Channel.m" ".\Channel.m" >nul 2>&1
    copy /Y "Draft_2\demodulate.m" ".\demodulate.m" >nul 2>&1
    copy /Y "Draft_2\Reciever.m" ".\Reciever.m" >nul 2>&1
    copy /Y "Draft_2\Reciever_cross.m" ".\Reciever_cross.m" >nul 2>&1
    copy /Y "Draft_2\Reciever_branun.m" ".\Reciever_branun.m" >nul 2>&1
)

git add Transmitter.m Channel.m demodulate.m Reciever.m Reciever_cross.m Reciever_branun.m
git commit -m "refactor(draft-2): modularize architecture and introduce Braun's cancellation algorithms"

:: Commit 4
echo [4/6] Tworzenie Commita 4 (Draft 3 - DC gap fix ^& window alignment)...
if exist "%ARCHIVE_DIR%\Draft_3\Reciever_branun.m" (
    copy /Y "%ARCHIVE_DIR%\Draft_3\Reciever_branun.m" ".\Reciever_branun.m" >nul 2>&1
) else (
    copy /Y "Draft_3\Reciever_branun.m" ".\Reciever_branun.m" >nul 2>&1
)

if exist "%ARCHIVE_DIR%\Draft_3\results2.jpg" (
    copy /Y "%ARCHIVE_DIR%\Draft_3\results2.jpg" ".\results2.jpg" >nul 2>&1
    git add results2.jpg
) else if exist "Draft_3\results2.jpg" (
    copy /Y "Draft_3\results2.jpg" ".\results2.jpg" >nul 2>&1
    git add results2.jpg
)

git add Reciever_branun.m
git commit -m "fix(draft-3): fix 20us preamble cut, interpolate DC gap, and align 2D window FFT shifts"

:: Commit 5
echo [5/6] Tworzenie Commita 5 (Draft 4 - 2-stage Pipeline ^& CLEAN Interpreter)...
git rm -f --cached Reciever_branun.m >nul 2>&1
del /F /Q Reciever_branun.m >nul 2>&1

if exist "%ARCHIVE_DIR%\Draft_4\Reciever.m" (
    copy /Y "%ARCHIVE_DIR%\Draft_4\Reciever.m" ".\Reciever.m" >nul 2>&1
    copy /Y "%ARCHIVE_DIR%\Draft_4\Interpreter.m" ".\Interpreter.m" >nul 2>&1
) else (
    copy /Y "Draft_4\Reciever.m" ".\Reciever.m" >nul 2>&1
    copy /Y "Draft_4\Interpreter.m" ".\Interpreter.m" >nul 2>&1
)

git add Reciever.m Interpreter.m
git commit -m "feat(draft-4): decouple receiver pipeline from target interpreter and optimize Doppler resolution"

:: Commit 6
echo [6/6] Tworzenie Commita 6 (Clean Architecture ^& Documentation)...
git rm -f --cached Transmitter.m Channel.m Reciever.m Interpreter.m demodulate.m Reciever_cross.m results2.jpg >nul 2>&1
del /F /Q Transmitter.m Channel.m Reciever.m Interpreter.m demodulate.m Reciever_cross.m results2.jpg >nul 2>&1

git add .gitignore README.md src/ lib/ scripts/ docs/ results/
git commit -m "chore: finalize clean project structure, add .gitignore, utilities and documentation"
git branch -M main

echo.
echo Historia commitow zostala pomyslnie utworzona!
git log --graph --oneline --format="%%h [%%an] %%s"
echo.
echo ======================================================
echo Katalog _archive_original jest w pelni zachowany na dysku,
echo ale dzieki .gitignore NIE bedzie wysylany na zdalnego Gita.
echo.
echo Aby opublikowac repozytorium na GitHubie przez CLI, uruchom:
echo   gh repo create wifi-radar --private --source=. --remote=origin --push
echo ======================================================
pause
