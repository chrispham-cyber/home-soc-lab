# Attack 02 — SSH Brute Force (MITRE T1110)

## Objective
Brute-force SSH on the Ubuntu victim and detect the failed-login pattern.

## Attack (from Kali)
```bash
hydra -l <user> -P /usr/share/wordlists/rockyou.txt ssh://<ubuntu-ip>
```

## What to look for in Wazuh
- Repeated authentication failures (sshd)
- Wazuh rule group `authentication_failed` / `sshd`
- Whether it fires a "multiple failed logins" correlated alert

## Evidence
_Add screenshot: `screenshots/02-bruteforce-*.png`_

## Detection
- Caught by default rules? ⬜ yes / ⬜ no
- Custom rule written: _link if applicable_

## Notes
_Threshold tuning, time window, level assigned._
