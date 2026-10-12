@echo off
chcp 65001 >nul
echo.
echo ========================================
echo    РАЗБЛОКИРОВКА ИНТЕРНЕТА
echo ========================================
echo.

:: Создаем маркер ручного режима (чтобы скрипт не включал блокировку обратно)
echo MANUAL_LOCK > C:\Scripts\manual_lock.txt

:: Отключаем правила брандмауэра
netsh advfirewall firewall set rule name="KillSwitch_Block_All" new enable=no
netsh advfirewall firewall set rule name="KillSwitch_Block_All_In" new enable=no

echo.
echo ✓ Интернет разблокирован!
echo.
echo ВНИМАНИЕ: Теперь VPN Kill Switch отключен.
echo После завершения работы запустите "Включить защиту.bat"
echo.
pause