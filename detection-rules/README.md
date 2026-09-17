# Detection rules

Custom Wazuh rules I wrote for this lab. On the server these live in `/var/ossec/etc/rules/local_rules.xml`; I keep a copy here in version control.

## What's here

`local_rules.xml` currently has one rule:

| ID     | Detects              | MITRE | Status              |
|--------|----------------------|-------|---------------------|
| 100010 | `whoami.exe` executed| T1033 | tested, confirmed firing |

Rule IDs from 100000 up are the range Wazuh reserves for user-defined rules.

## Why this one

Running the Windows attack script, almost everything got picked up by the default ruleset. `whoami` didn't, even though it's classic early recon. It only showed up as a generic Sysmon process-creation event. The rule matches that event where the image is `whoami.exe` and raises a real alert mapped to T1033.

## Deploy and test loop

1. Edit `local_rules.xml` on the manager.
2. `sudo /var/ossec/bin/wazuh-control restart`
3. Re-run the technique on the endpoint.
4. Check the alert shows up with the new rule ID.

## Next

Move rules toward [Sigma](https://github.com/SigmaHQ/sigma) so they aren't locked to Wazuh, and add rules for the techniques currently only caught at low severity.
