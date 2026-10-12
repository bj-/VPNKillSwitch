# VPN Kill Switch

Как это работает:
Служба работает в фоне и проверяет VPN каждые 0.5 сек
При разрыве VPN → мгновенно блокируется весь исходящий трафик + показывается уведомление Windows
Пользователь видит уведомление и понимает, что интернет заблокирован из-за VPN
Для разблокировки пользователь запускает Разблокировать интернет.bat
После работы пользователь запускает Включить защиту.bat для возврата к автоматическому режиму

Логирование:
Все действия записываются в C:\Scripts\vpn_killswitch.log для отладки.

# Installation
Скачайте NSSM и выполните:
```
C:\nssm\win64\nssm.exe install VpnKillSwitch powershell.exe
```

В окне NSSM:
Path: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
Startup directory: C:\Windows\System32\WindowsPowerShell\v1.0
Arguments: -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Scripts\VpnKillSwitch.ps1"
Нажмите Install service, затем:

```
net start VpnKillSwitch
```

Создайте ярлыки для удобства:

Разблокировать интернет → C:\Scripts\Unblock.bat
Включить защиту → C:\Scripts\Enable VPN Kill Switch.bat

# Usage
