@echo off
title usbOS.ai - Windows Portable Runner (Open Source)
color 0b

echo ===================================================================
echo    usbOS.ai v1.0 - Portable AI Operating System
echo    Open Source Project licensed under GNU General Public License v3
echo ===================================================================
echo.

set ISO=usbOS-v1.0-amd64.iso
set DATA=usbOS_data.img

REM 1. 공식 ISO 파일 존재 여부 확인
if not exist "%ISO%" (
    echo [!] 현재 폴더에 "%ISO%" 파일이 없습니다.
    echo     공식 웹사이트(https://gubin0425a-creator.github.io/usbOS.ai/) 에서
    echo     ISO 파일을 다운로드하여 이 배치 파일과 같은 폴더에 넣어주세요.
    echo.
    pause
    exit /b 1
)

REM 2. 데이터 영구 저장 금고(Persistence Vault) 자동 생성 (1GB)
if not exist "%DATA%" (
    echo [*] usbOS.ai 데이터 영구 저장 금고(%DATA%)를 최초 생성하는 중...
    fsutil file createnew "%DATA%" 1073741824 >nul 2>&1
    echo [*] 1GB 보안 데이터 볼륨 생성 완료! (대화 내역 및 설정 자동 보존)
    echo.
)

REM 3. VirtualBox 없는 윈도우 하이퍼바이저(WHPX) 네이티브 가속 실행
where qemu-system-x86_64 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [*] VirtualBox 없이 윈도우 프로그램 창으로 usbOS.ai를 1초 만에 실행합니다...
    qemu-system-x86_64.exe -m 3072 -accel whpx,tcg -cdrom "%ISO%" -hda "%DATA%" ^
                           -display sdl -name "usbOS.ai Desktop" -smp 2
    exit /b 0
)

REM 4. 윈도우에 VirtualBox가 이미 설치되어 있는 경우의 보조 자동 연동
where VBoxManage >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [*] VirtualBox 엔진을 감지했습니다. 창 모드로 가상 OS를 실행합니다...
    VBoxManage controlvm "usbOS.ai" poweroff >nul 2>&1
    VBoxManage unregistervm "usbOS.ai" --delete >nul 2>&1
    VBoxManage createvm --name "usbOS.ai" --ostype "Debian_64" --register
    VBoxManage modifyvm "usbOS.ai" --memory 3072 --cpus 2 --vram 128 --graphicscontroller vmsvga
    VBoxManage storagectl "usbOS.ai" --name "IDE" --add ide
    VBoxManage storageattach "usbOS.ai" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "%cd%\%ISO%"
    VBoxManage startvm "usbOS.ai"
    exit /b 0
)

echo [!] 가상화 엔진을 찾을 수 없습니다.
echo     Rufus 또는 Ventoy를 이용해 USB에 구워 실물 PC에서 100% 네이티브로 부팅하세요!
pause
