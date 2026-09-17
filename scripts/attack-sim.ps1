# Home SOC Lab - Windows attack simulation (safe, self-contained)
Write-Host "[T1033/T1087] Account/User discovery"
cmd /c "whoami /all" | Out-Null
cmd /c "net user" | Out-Null
cmd /c "net localgroup administrators" | Out-Null

Write-Host "[T1082] System information discovery"
cmd /c "systeminfo" | Out-Null

Write-Host "[T1016] Network configuration discovery"
cmd /c "ipconfig /all" | Out-Null
cmd /c "arp -a" | Out-Null

Write-Host "[T1059.001] Encoded PowerShell execution"
$b = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes("Write-Host SIMULATED_ATTACK_PAYLOAD"))
powershell -EncodedCommand $b

Write-Host "[T1105] Ingress tool transfer via certutil"
cmd /c "certutil -urlcache -split -f https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/README.md C:\Users\tpham\down_test.txt" | Out-Null

Write-Host "ALL_ATTACKS_DONE"
