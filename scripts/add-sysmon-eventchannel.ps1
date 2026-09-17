$cfg = "C:\Program Files (x86)\ossec-agent\ossec.conf"
$content = Get-Content $cfg -Raw
if ($content -notmatch 'Microsoft-Windows-Sysmon/Operational') {
    $block = @"
  <localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
  </localfile>
</ossec_config>
"@
    $content = $content -replace '</ossec_config>', $block
    Set-Content -Path $cfg -Value $content -Encoding UTF8
    Write-Host "ADDED sysmon eventchannel to ossec.conf"
} else {
    Write-Host "sysmon localfile already present"
}
Restart-Service WazuhSvc
Start-Sleep -Seconds 3
(Get-Service WazuhSvc).Status
