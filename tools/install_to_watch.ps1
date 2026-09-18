# Script de Instalação no Pixel Watch via Wi-Fi (ADB)
param (
    [string]$WatchIP = "",
    [string]$Port = "5555"
)

$adb = "C:\Program Files (x86)\Android\android-sdk\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
    $adb = "adb"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$apkPath = "$repoRoot\mrrobot_watchface.apk"
if (-not (Test-Path $apkPath)) {
    $apkPath = "$repoRoot\app\build\outputs\apk\debug\app-debug.apk"
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Mr. Robot Watch Face Installer (Wear OS)" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "APK: $apkPath" -ForegroundColor Gray

if ([string]::IsNullOrWhiteSpace($WatchIP)) {
    Write-Host ""
    Write-Host "Certifica-te de que no Pixel Watch:" -ForegroundColor Yellow
    Write-Host "1. As 'Opcoes de programador' estao ativas (Definicoes > Sistema > Acerca de > Versoes > Clica 7x em 'Numero de compilacao')"
    Write-Host "2. Em 'Opcoes de programador':"
    Write-Host "   - Ativa 'Depuracao ADB'"
    Write-Host "   - Ativa 'Depuracao sem fios' (Wireless debugging)"
    Write-Host "3. O relogio e o PC estao ligados a mesma rede Wi-Fi."
    Write-Host ""
    $WatchIP = Read-Host "Introduz o endereco IP do Pixel Watch (ex: 192.168.1.150)"
    $PortInput = Read-Host "Introduz a Porta (pressione Enter para padrao 5555)"
    if (-not [string]::IsNullOrWhiteSpace($PortInput)) {
        $Port = $PortInput
    }
}

$target = "${WatchIP}:${Port}"
Write-Host ""
Write-Host "A ligar ao Pixel Watch em $target..." -ForegroundColor Cyan
& $adb connect $target

Write-Host ""
Write-Host "Dispositivos detetados:" -ForegroundColor Cyan
& $adb devices

Write-Host ""
Write-Host "A instalar o mostrador Mr. Robot..." -ForegroundColor Cyan
& $adb -s $target install -r -d $apkPath

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[OK] Instalado com sucesso no Pixel Watch!" -ForegroundColor Green
    
    Write-Host "A limpar a cache de mostradores do Wear OS..." -ForegroundColor Cyan
    & $adb -s $target shell am force-stop com.fsociety.mrrobotwatchface 2>$null
    & $adb -s $target shell am force-stop com.google.android.wearable.watchface.rwf 2>$null

    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Yellow
    Write-Host " [!] PASSO OBRIGATORIO NO RELOGIO PARA APLICAR A ATUALIZACAO:" -ForegroundColor Yellow
    Write-Host " 1. O Wear OS guarda o mostrador em memoria (cache)." -ForegroundColor White
    Write-Host " 2. Mantem o ecra pressionado, desliza para a esquerda/direita" -ForegroundColor White
    Write-Host "    e seleciona OUTRO mostrador qualquer (ex: Digital padrão)." -ForegroundColor White
    Write-Host " 3. De seguida, volta a selecionar o 'Mr. Robot Terminal'." -ForegroundColor White
    Write-Host "    (Isto forca o Pixel Watch a recarregar o novo XML sem cache!)" -ForegroundColor White
    Write-Host "=================================================================" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "[!] Se a instalacao falhou, verifica se autorizaste a ligacao do PC no ecra do relogio ('Permitir depuracao')." -ForegroundColor Red
}
