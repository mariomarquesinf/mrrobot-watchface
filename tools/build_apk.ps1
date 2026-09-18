$buildTools = "C:\Program Files (x86)\Android\android-sdk\build-tools\36.0.0"
$platformJar = "C:\Program Files (x86)\Android\android-sdk\platforms\android-35\android.jar"

Write-Host "1. Compiling resources..." -ForegroundColor Cyan
& "$buildTools\aapt2.exe" compile --dir "app\src\main\res" -o "compiled_res.zip"

Write-Host "2. Linking resources with --no-compress-fonts..." -ForegroundColor Cyan
& "$buildTools\aapt2.exe" link -I "$platformJar" --manifest "app\src\main\AndroidManifest.xml" "compiled_res.zip" -o "app_unaligned.apk" --no-compress-fonts --min-sdk-version 33 --target-sdk-version 34

Write-Host "3. 4-byte ZipAligning..." -ForegroundColor Cyan
& "$buildTools\zipalign.exe" -f -p 4 "app_unaligned.apk" "mrrobot_aligned.apk"

Write-Host "4. Signing APK with apksigner..." -ForegroundColor Cyan
cmd /c "`"$buildTools\apksigner.bat`" sign --ks debug.keystore --ks-pass pass:android --key-pass pass:android --ks-key-alias androiddebugkey --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true --out mrrobot_watchface.apk mrrobot_aligned.apk"

Write-Host "5. Verifying signature..." -ForegroundColor Cyan
cmd /c "`"$buildTools\apksigner.bat`" verify -v mrrobot_watchface.apk"

Write-Host "6. Verifying uncompressed fonts..." -ForegroundColor Cyan
& "$buildTools\zipalign.exe" -c -v 4 mrrobot_watchface.apk | Select-String "res/font"

# Mirror to standard Gradle output location as fallback
$gradleOut = "app\build\outputs\apk\debug"
if (-not (Test-Path $gradleOut)) { New-Item -ItemType Directory -Path $gradleOut -Force | Out-Null }
Copy-Item "mrrobot_watchface.apk" "$gradleOut\app-debug.apk" -Force

Write-Host ""
Write-Host "BUILD COMPLETE: mrrobot_watchface.apk ready!" -ForegroundColor Green
