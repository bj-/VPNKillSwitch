@echo off
chcp 65001 >nul
echo.
echo ========================================
echo    ВКЛЮЧЕНИЕ ЗАЩИТЫ
echo ========================================
echo.

:: Удаляем маркер ручного режима
del C:\Scripts\manual_lock.txt 2>nul

:: Отключаем правила (защита включится автоматически при разрыве VPN)
netsh advfirewall firewall set rule name="KillSwitch_Block_All" new enable=no
netsh advfirewall firewall set rule name="KillSwitch_Block_All_In" new enable=no

echo.
echo ✓ Защита активирована!
echo   При отключении VPN интернет будет заблокирован.
echo.
pause