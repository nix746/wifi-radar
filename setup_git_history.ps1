# ==============================================================================
# setup_git_history.ps1
# Automatyczny skrypt do inicjalizacji repozytorium Git i odtworzenia historii
# z folderu archiwalnego (_archive_original) BEZ usuwania jakichkolwiek plików z dysku!
# ==============================================================================

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  Inicjalizacja i Odtworzenie Historii Gita WiFi Radar " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

$UserName = "nix746"
$UserEmail = "tym.wozniak@gmail.com"
$ArchiveDir = "_archive_original"

if (-not (Test-Path "$ArchiveDir")) {
    Write-Host "Katalog $ArchiveDir nie istnieje, uzywam bezposrednich draftow jako zrodla..." -ForegroundColor Yellow
}

# 1. Konfiguracja tozsamosci Git
git config user.name "$UserName"
git config user.email "$UserEmail"

Write-Host "[1/7] Inicjalizacja repozytorium Git..." -ForegroundColor Yellow
if (-not (Test-Path ".git")) {
    git init
}

# ------------------------------------------------------------------------------
# Commit 1: Baza poczatkowa (Patryk Pajerski)
# ------------------------------------------------------------------------------
Write-Host "[2/7] Tworzenie Commita 1 (Initial baseline - Patryk Pajerski)..." -ForegroundColor Yellow
$commit1_files = @(
    "wifi_params.m",
    "wifi_signal_generation.m",
    "wifi_channel_doppler.m",
    "wifi_procesing.m",
    "find_packet_start.m"
)

foreach ($f in $commit1_files) {
    if (Test-Path "$ArchiveDir\Patryka\WiFi\$f") {
        Copy-Item "$ArchiveDir\Patryka\WiFi\$f" ".\$f" -Force
        git add "$f"
    } elseif (Test-Path "Patryka\WiFi\$f") {
        Copy-Item "Patryka\WiFi\$f" ".\$f" -Force
        git add "$f"
    }
}

git commit --author="Patryk Pajerski" -m "feat: initial Wi-Fi signal generation, packet synchronization and basic Doppler processing"

# ------------------------------------------------------------------------------
# Commit 2: Draft 1 (Ręczna demodulacja OFDM i osie fizyczne)
# ------------------------------------------------------------------------------
Write-Host "[3/7] Tworzenie Commita 2 (Draft 1 - OFDM Demod & 2D Periodogram)..." -ForegroundColor Yellow
$commit2_files = @(
    "wifi_doppler.m",
    "wifi_radar_processing.m",
    "wifi_radar_processing_v1.m",
    "wifi_radar_visualization.m"
)

foreach ($f in $commit2_files) {
    if (Test-Path "$ArchiveDir\Draft_1\WiFi\$f") {
        Copy-Item "$ArchiveDir\Draft_1\WiFi\$f" ".\$f" -Force
        git add "$f"
    } elseif (Test-Path "Draft_1\WiFi\$f") {
        Copy-Item "Draft_1\WiFi\$f" ".\$f" -Force
        git add "$f"
    }
}
git commit -m "feat(draft-1): implement manual OFDM demodulation and physical Range-Doppler periodogram"

# ------------------------------------------------------------------------------
# Commit 3: Draft 2 (Modularyzacja i algorytmy Brauna)
# ------------------------------------------------------------------------------
Write-Host "[4/7] Tworzenie Commita 3 (Draft 2 - Modular TX/RX & Cancellation)..." -ForegroundColor Yellow
# Usuniecie starych plikow skryptowych z indeksu Gita
foreach ($f in ($commit1_files + $commit2_files)) {
    git rm -f --cached "$f" 2>$null
    if (Test-Path ".\$f") { Remove-Item -Force ".\$f" 2>$null }
}

$commit3_files = @(
    "Transmitter.m",
    "Channel.m",
    "demodulate.m",
    "Reciever.m",
    "Reciever_cross.m",
    "Reciever_branun.m"
)

foreach ($f in $commit3_files) {
    if (Test-Path "$ArchiveDir\Draft_2\$f") {
        Copy-Item "$ArchiveDir\Draft_2\$f" ".\$f" -Force
        git add "$f"
    } elseif (Test-Path "Draft_2\$f") {
        Copy-Item "Draft_2\$f" ".\$f" -Force
        git add "$f"
    }
}
git commit -m "refactor(draft-2): modularize architecture and introduce Braun's cancellation algorithms"

# ------------------------------------------------------------------------------
# Commit 4: Draft 3 (Poprawki teoretyczne: preambula 20us, dziura DC, okno 2D)
# ------------------------------------------------------------------------------
Write-Host "[5/7] Tworzenie Commita 4 (Draft 3 - DC gap fix & window alignment)..." -ForegroundColor Yellow
if (Test-Path "$ArchiveDir\Draft_3\Reciever_branun.m") {
    Copy-Item "$ArchiveDir\Draft_3\Reciever_branun.m" ".\Reciever_branun.m" -Force
    git add "Reciever_branun.m"
} elseif (Test-Path "Draft_3\Reciever_branun.m") {
    Copy-Item "Draft_3\Reciever_branun.m" ".\Reciever_branun.m" -Force
    git add "Reciever_branun.m"
}

if (Test-Path "$ArchiveDir\Draft_3\results2.jpg") {
    Copy-Item "$ArchiveDir\Draft_3\results2.jpg" ".\results2.jpg" -Force
    git add "results2.jpg"
} elseif (Test-Path "Draft_3\results2.jpg") {
    Copy-Item "Draft_3\results2.jpg" ".\results2.jpg" -Force
    git add "results2.jpg"
}
git commit -m "fix(draft-3): fix 20us preamble cut, interpolate DC gap, and align 2D window FFT shifts"

# ------------------------------------------------------------------------------
# Commit 5: Draft 4 (Dwuetapowy pipeline: Receiver -> Interpreter CLEAN)
# ------------------------------------------------------------------------------
Write-Host "[6/7] Tworzenie Commita 5 (Draft 4 - 2-stage Pipeline & CLEAN Interpreter)..." -ForegroundColor Yellow
git rm -f --cached "Reciever_branun.m" 2>$null
if (Test-Path ".\Reciever_branun.m") { Remove-Item -Force ".\Reciever_branun.m" 2>$null }

if (Test-Path "$ArchiveDir\Draft_4\Reciever.m") {
    Copy-Item "$ArchiveDir\Draft_4\Reciever.m" ".\Reciever.m" -Force
    git add "Reciever.m"
} elseif (Test-Path "Draft_4\Reciever.m") {
    Copy-Item "Draft_4\Reciever.m" ".\Reciever.m" -Force
    git add "Reciever.m"
}

if (Test-Path "$ArchiveDir\Draft_4\Interpreter.m") {
    Copy-Item "$ArchiveDir\Draft_4\Interpreter.m" ".\Interpreter.m" -Force
    git add "Interpreter.m"
} elseif (Test-Path "Draft_4\Interpreter.m") {
    Copy-Item "Draft_4\Interpreter.m" ".\Interpreter.m" -Force
    git add "Interpreter.m"
}

git commit -m "feat(draft-4): decouple receiver pipeline from target interpreter and optimize Doppler resolution"

# ------------------------------------------------------------------------------
# Commit 6: Finalna, uporządkowana architektura repozytorium
# ------------------------------------------------------------------------------
Write-Host "[7/7] Tworzenie Commita 6 (Clean Architecture & Documentation)..." -ForegroundColor Yellow

# Wyczyszczenie plikow tymczasowych w katalogu glownym z indeksu Gita
$old_root_files = @("Transmitter.m", "Channel.m", "Reciever.m", "Interpreter.m", "demodulate.m", "Reciever_cross.m", "results2.jpg")
foreach ($f in $old_root_files) {
    git rm -f --cached "$f" 2>$null
    if (Test-Path ".\$f") { Remove-Item -Force ".\$f" 2>$null }
}

# Dodanie nowej struktury katalogow i dokumentacji do Gita
git add .gitignore
git add README.md
git add src/
git add lib/
git add scripts/
git add docs/
git add results/

git commit -m "chore: finalize clean project structure, add .gitignore, utilities and documentation"
git branch -M main

Write-Host "`nHistoria commitow zostala pomyslnie utworzona!" -ForegroundColor Green
git log --graph --oneline --format="%h [%an] %s"

Write-Host "`n------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Katalog _archive_original jest w pelni zachowany na Twoim dysku," -ForegroundColor Green
Write-Host "ale dzieki .gitignore NIE bedzie wysylany na zdalnego Gita." -ForegroundColor Green
Write-Host "`nAby opublikowac repozytorium na GitHubie przez CLI, uruchom:" -ForegroundColor White
Write-Host "  gh repo create wifi-radar --private --source=. --remote=origin --push" -ForegroundColor Green
Write-Host "------------------------------------------------------`n" -ForegroundColor Cyan
