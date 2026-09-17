# 02 - SSH brute force (hydra)

MITRE: T1110

Target is the Ubuntu server. Since Ubuntu runs the manager, it watches its own auth
logs as agent 000, so I didn't need an agent on it to catch this.

## What I ran (from Kali)

```bash
printf "%s\n" admin password 123456 root toor letmein qwerty ubuntu1 \
  password1 admin123 welcome test1234 changeme pass123 hunter2 secret1 \
  login123 raspberry monkey dragon > /tmp/pw.txt

hydra -l ubuntu -P /tmp/pw.txt ssh://192.168.3.132 -t 4
```

20 wrong passwords, none valid (as expected).

## What Wazuh caught

| Rule  | Level | Description                                            | MITRE            |
|-------|-------|--------------------------------------------------------|------------------|
| 5763  | 10    | sshd: brute force trying to get access to the system   | T1110            |
| 5758  | 8     | Maximum authentication attempts exceeded               | T1110            |
| 5760  | 5     | sshd: authentication failed (fired ~19 times)          | T1110.001, T1021.004 |
| 2502  | 10    | User missed the password more than one time            | T1110            |

## Notes

The interesting part is rule 5763. Each failed login on its own is low signal (5760),
but Wazuh chains them: enough 5760s inside the time window escalates to the 5763
brute-force alert. That's frequency-based correlation, and it's the difference between
a wall of noise and one alert that says "someone is brute forcing you." If I wanted it
to alert faster I could write a child rule with a lower frequency threshold.
