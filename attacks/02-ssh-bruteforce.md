# Attack 02 — SSH Brute Force (MITRE T1110)

## Objective
Brute-force SSH on the Ubuntu server and detect the failed-login pattern.
Ubuntu is the Wazuh manager, so it self-monitors as **agent 000** (reads
journald/auth) — no separate agent needed.

## Attack (from Kali)
```bash
# small wordlist of wrong passwords (see scripts/)
printf "%s\n" admin password 123456 root toor letmein qwerty ubuntu1 \
  password1 admin123 welcome test1234 changeme pass123 hunter2 secret1 \
  login123 raspberry monkey dragon > /tmp/pw.txt

hydra -l ubuntu -P /tmp/pw.txt ssh://192.168.3.132 -t 4
```
20 attempts, 0 valid (as expected).

## Detections observed in Wazuh (agent 000)

| Rule ID | Level | Description | MITRE |
|---------|-------|-------------|-------|
| **5763** | **10** | sshd: brute force trying to get access to the system | T1110 |
| 5758 |  8 | Maximum authentication attempts exceeded | T1110 |
| 5760 |  5 | sshd: authentication failed (x19) | T1110.001, T1021.004 |
| 2502 | 10 | User missed the password more than one time (x4) | T1110 |
| 5503 / 5557 | 5 | PAM / password check failed | T1110.001 |

## Result
✅ Brute force reliably detected. Rule **5763** (level 10) is the correlated
"brute force" alert; it fires after multiple 5760 failures within the time
window. Clean, textbook Credential Access detection.

## Notes
- Correlation works because the manager's default `sshd` decoders + rules
  (5710→5760→5763) chain failed auth events into a brute-force alert.
- Tuning idea: lower the frequency/timeframe on a custom child rule if you want
  faster alerting in a noisier environment.
