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
| Reconnaissance      | Active Scanning (T1595)      | [01](attacks/01-nmap-scan.md) | ⚠️ gap — host-based SIEM, no net sensor |
| Credential Access   | Brute Force (T1110)          | [02](attacks/02-ssh-bruteforce.md) | ✅ 5763 (lvl 10) |
| Execution           | PowerShell / cmd (T1059)     | [04](attacks/04-windows-discovery-execution.md) | ✅ 92004/92032/92057 |
| Execution           | Encoded PowerShell (T1059.001)| [04](attacks/04-windows-discovery-execution.md) | ✅ 92057 (lvl 12) |
| Discovery           | Account Discovery (T1087)    | [04](attacks/04-windows-discovery-execution.md) | ✅ 92031 |
| Discovery           | System Owner/User (T1033)    | [04](attacks/04-windows-discovery-execution.md) | ✅ **custom 100010** |
| Ingress Tool Xfer   | certutil download (T1105)    | [04](attacks/04-windows-discovery-execution.md) | ✅ 92213 (lvl 15) |

## Status

- [x] Network: full-mesh connectivity across all 3 VMs
- [x] Wazuh SIEM deployed (native ARM64, all services green)
- [x] Agents enrolled: Windows (Sysmon + agent, Active) + Ubuntu server (agent 000)
- [x] Sysmon telemetry flowing; built-in detections firing
- [x] Attacks executed (Kali: nmap + SSH brute force; Windows: discovery/execution)
- [x] Custom detection rule written + tested (100010, T1033)
- [ ] Write-up published + repo pushed to GitHub

🚧 In progress — see [docs/setup.md](docs/setup.md) for current step.
