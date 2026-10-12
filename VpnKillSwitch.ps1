# === НАСТРОЙКИ ===
$VpnAdapterName = "WireGuard"  # Имя вашего VPN адаптера
$RuleName = "KillSwitch_Block_All"
$CheckInterval = 0.5
$LogFile = "C:\Scripts\vpn_killswitch.log"
# =================

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $LogFile
}

function Show-Notification {
    param($Title, $Message)
    
    # Создаем toast-уведомление Windows
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $template = @"
<toast duration="long">
    <visual>
        <binding template="ToastGeneric">
            <text>$Title</text>
            <text>$Message</text>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:Notification.Default"/>
</toast>
"@
    
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($template)
    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("VPN Kill Switch").Show($toast)
}

function Enable-KillSwitch {
    # Проверяем, не включена ли уже блокировка вручную
    $manualLockFile = "C:\Scripts\manual_lock.txt"
    if (Test-Path $manualLockFile) {
        Write-Log "Блокировка уже активна (ручной режим)"
        return
    }
    
    # Создаем правило блокировки всего исходящего трафика
    $existingRule = Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue
    if (-not $existingRule) {
        New-NetFirewallRule -DisplayName $RuleName -Direction Outbound -Action Block -Enabled True -Profile Any | Out-Null
        Write-Log "Создано правило блокировки"
    } else {
        Set-NetFirewallRule -DisplayName $RuleName -Enabled True
    }
    
    # Также блокируем входящий (опционально)
    $inRule = Get-NetFirewallRule -DisplayName "$RuleName_In" -ErrorAction SilentlyContinue
    if (-not $inRule) {
        New-NetFirewallRule -DisplayName "$RuleName_In" -Direction Inbound -Action Block -Enabled True -Profile Any | Out-Null
    } else {
        Set-NetFirewallRule -DisplayName "$RuleName_In" -Enabled True
    }
    
    Write-Log "КILLSWITCH ВКЛЮЧЕН - VPN отключен"
    Show-Notification "VPN отключен!" "Весь интернет заблокирован. Откройте 'Unblock.bat' для восстановления."
}

function Disable-KillSwitch {
    Set-NetFirewallRule -DisplayName $RuleName -Enabled False -ErrorAction SilentlyContinue
    Set-NetFirewallRule -DisplayName "$RuleName_In" -Enabled False -ErrorAction SilentlyContinue
    Write-Log "КILLSWITCH ВЫКЛЮЧЕН"
}

Write-Log "=== VPN Kill Switch запущен ==="

while ($true) {
    try {
        $adapter = Get-NetAdapter -Name $VpnAdapterName -ErrorAction SilentlyContinue
        
        if ($adapter -and $adapter.Status -eq "Up") {
            # VPN подключен
            $manualLockFile = "C:\Scripts\manual_lock.txt"
            if (-not (Test-Path $manualLockFile)) {
                Disable-KillSwitch
            }
        } else {
            # VPN отключен
            Enable-KillSwitch
        }
    } catch {
        Write-Log "Ошибка: $_"
    }
    
    Start-Sleep -Seconds $CheckInterval
}