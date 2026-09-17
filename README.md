# Home SOC Lab

A small security operations lab I built to learn detection engineering by doing it:
stand up a SIEM, put an endpoint under monitoring, attack it, and see what gets
caught. When the default rules missed something, I wrote and tested my own.

Author: Chris Pham ([chrispham-cyber.github.io](https://chrispham-cyber.github.io))

## Setup

Three VMs on VMware Fusion, on an isolated NAT network. Everything runs on Apple
Silicon, so all the guests are ARM64 (which caused most of the interesting problems,
see [docs/02-wazuh-install-arm64.md](docs/02-wazuh-install-arm64.md)).

```
 Kali (.135)  ── attacks ──►  Windows 11 (.131)   Sysmon + Wazuh agent
  attacker                          │
                                    ▼
                           Ubuntu (.132)  ── Wazuh server: indexer + manager + dashboard
                                             also monitors itself as agent 000
```

| VM         | IP    | Role              | Main software                      |
|------------|-------|-------------------|------------------------------------|
| Kali       | .135  | Attacker          | nmap, hydra                        |
| Windows 11 | .131  | Monitored endpoint| Sysmon (SwiftOnSecurity), Wazuh agent |
| Ubuntu     | .132  | SIEM server       | Wazuh 4.14 (native install)        |

## What's in here

```
docs/              build notes + the ARM64 troubleshooting write-up
detection-rules/   the custom rule I wrote (local_rules.xml)
attacks/           each attack I ran and what Wazuh did (or didn't) catch
scripts/           the PowerShell I used on the Windows box
screenshots/       dashboard evidence
writeups/          the long-form post
```

## Detections, mapped to MITRE ATT&CK

| Tactic            | Technique                       | Notes                                   |
|-------------------|---------------------------------|-----------------------------------------|
| Credential Access | Brute Force (T1110)             | caught: rule 5763, level 10             |
| Execution         | PowerShell / cmd (T1059)        | caught: rules 92004, 92032              |
| Execution         | Encoded PowerShell (T1059.001)  | caught: rule 92057, level 12            |
| Ingress Tool Xfer | certutil download (T1105)       | caught: rule 92213, level 15            |
| Discovery         | Account Discovery (T1087)       | caught: rule 92031                      |
| Discovery         | System Owner/User (T1033)       | not caught by default, so I wrote rule 100010 |
| Reconnaissance    | Active Scanning (T1595)         | not caught, and here's why: [attacks/01](attacks/01-nmap-scan.md) |

See the [attacks/](attacks/) folder for the exact commands and the alerts they
produced.

## Where it stands

Working end to end: SIEM is up, both agents report in, attacks generate real alerts,
and my custom rule fires. The nmap blind spot is documented rather than hidden, and
adding Suricata for network coverage is the obvious next step.
