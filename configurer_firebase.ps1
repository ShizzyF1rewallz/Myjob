# Script pour configurer Firebase avec FlutterFire (projet myjob-42033)
# Execute ce script dans PowerShell : .\configurer_firebase.ps1

Write-Host "=== Configuration Firebase pour MyJob ===" -ForegroundColor Cyan
Write-Host ""

# Ajouter le chemin des binaires Dart/FlutterFire
$pubBin = "$env:LOCALAPPDATA\Pub\Cache\bin"
if ($env:Path -notlike "*$pubBin*") {
    $env:Path = "$pubBin;$env:Path"
}

# Activer la CLI FlutterFire
Write-Host "1. Activation de la CLI FlutterFire..." -ForegroundColor Yellow
dart pub global activate flutterfire_cli
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors de l'activation de flutterfire_cli." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Configuration Firebase (projet myjob-42033)..." -ForegroundColor Yellow
Write-Host "   Plateforme Android uniquement (evite le bug 'UnsupportedError' sur web/windows)." -ForegroundColor Gray
Write-Host ""

Set-Location $PSScriptRoot
# --platforms=android seul evite le crash "UnsupportedError not found in web" de la CLI
flutterfire configure --project=myjob-42033 --yes --platforms=android

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Configuration terminee ! Le fichier lib/firebase_options.dart a ete genere." -ForegroundColor Green
    Write-Host "Tu peux maintenant lancer : flutter run" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "La CLI FlutterFire a rencontre une erreur (bug connu avec plusieurs plateformes)." -ForegroundColor Yellow
    Write-Host "Le fichier lib/firebase_options.dart a ete rempli avec les identifiants de google-services.json." -ForegroundColor Gray
    Write-Host "Tu peux lancer l'app avec : flutter run" -ForegroundColor Green
}
