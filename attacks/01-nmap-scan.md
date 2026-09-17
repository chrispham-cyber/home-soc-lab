# Attack 01 — Network Scan (MITRE T1595 / T1046)

## Objective
Discover open ports/services on the victims and see how the SIEM reacts to scanning.

## Attack (from Kali)
```bash
nmap -sV -p- <victim-ip>        # full service/version scan
nmap -sS -T4 <victim-ip>        # SYN scan
```

## What to look for in Wazuh
- Bursts of connections to many ports from a single source
- Firewall / connection logs on the victim

## Evidence
_Add screenshot: `screenshots/01-nmap-*.png`_

## Detection
- Caught by default rules? ⬜ yes / ⬜ no
- Custom rule written: _link to `detection-rules/` if applicable_

## Notes
_What you learned, false positives, tuning._
