# Architecture

## Network
All VMs run in VMware Fusion on NAT (vmnet8). On this network the VMs can reach
each other **and** the internet — enough for both attacks and downloading tools.
Switch to a host-only network only when analyzing real malware.

## Data flow
1. Sysmon (Windows) + auditd/syslog (Linux) generate detailed host events.
2. The Wazuh agent on each victim ships those events to the Wazuh server.
3. Wazuh decodes, matches against rules, and raises alerts in the dashboard.
4. Attacks from Kali produce events → alerts → (if missed) new custom rules.

## Diagram
```
                         ┌─────────────────────────┐
                         │   Wazuh Server (Ubuntu) │
                         │   SIEM + dashboard       │
                         └───────────▲─────────────┘
                                     │ agent logs
              ┌──────────────────────┼───────────────────────┐
              │                      │                        │
   ┌──────────┴─────────┐  ┌─────────┴──────────┐   ┌─────────┴────────┐
   │ Windows 11 victim  │  │ Ubuntu victim      │   │  Kali (attacker) │
   │ Sysmon + agent     │  │ auditd + agent     │   │  no agent        │
   └────────▲───────────┘  └─────────▲──────────┘   └────────┬─────────┘
            │                        │                        │
            └────────────── attacks ─┴────────────────────────┘
```
