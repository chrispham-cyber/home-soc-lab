# Home SOC Lab

A self-contained Security Operations Center (SOC) lab built to practice the full
detect-and-respond workflow: generate real attacks, collect host and network
telemetry into a SIEM, and write detection rules mapped to MITRE ATT&CK.

> Built and documented by Chris Pham — [chrispham-cyber.github.io](https://chrispham-cyber.github.io)

## Architecture

```
[Kali Linux]  ──attack──►  [Windows 11 + Sysmon + Wazuh agent]
   attacker                        │
                            [Wazuh Server / SIEM]  ◄──  [Ubuntu + Wazuh agent]
                                (Docker, single-node)

All VMs on an isolated VMware network. Wazuh ingests logs from every host.
```

| Role        | VM            | Key software                          |
|-------------|---------------|---------------------------------------|
| Attacker    | Kali Linux    | nmap, hydra, Metasploit, Atomic Red Team |
| Victim      | Windows 11    | Sysmon (SwiftOnSecurity config), Wazuh agent |
| Victim      | Ubuntu 22.04  | Wazuh agent, auditd                   |
| SIEM/Server | Ubuntu 22.04  | Wazuh (Docker single-node)            |

## What this lab demonstrates

- Deploying and operating a SIEM (Wazuh) from scratch
- Endpoint telemetry with Sysmon and log forwarding
- Executing common attack techniques safely in an isolated network
- Writing and testing **custom detection rules**
- Mapping detections to the **MITRE ATT&CK** framework

## Repository layout

```
home-soc-lab/
├── docs/              # architecture + step-by-step setup notes
├── detection-rules/   # custom Wazuh/Sigma rules I wrote
├── attacks/           # each attack: command run + what the SIEM detected
├── screenshots/       # dashboard evidence
└── writeups/          # long-form blog write-up
```

## Detection coverage (MITRE ATT&CK)

| Tactic              | Technique                    | Attack file | Detected? |
|---------------------|------------------------------|-------------|-----------|
| Reconnaissance      | Active Scanning (T1595)      | [01](attacks/01-nmap-scan.md) | ⬜ |
| Credential Access   | Brute Force (T1110)          | [02](attacks/02-ssh-bruteforce.md) | ⬜ |
| Execution           | Command & Scripting (T1059)  | [03](attacks/03-reverse-shell.md) | ⬜ |

_(Fill in ✅ as you complete each one.)_

## Status

🚧 In progress — see [docs/setup.md](docs/setup.md) for current step.
