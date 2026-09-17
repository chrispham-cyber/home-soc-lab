# Network Verification

Goal: confirm all three lab VMs can reach each other before deploying the SIEM.

## Topology

| VM       | IP            | Role     |
|----------|---------------|----------|
| Windows 11 | 192.168.3.131 | Victim (attacker's target) |
| Ubuntu   | 192.168.3.132 | Wazuh server + victim |
| Kali     | 192.168.3.135 | Attacker |

All VMs on VMware Fusion NAT (vmnet, `192.168.3.0/24`, gateway `.2`) — same
subnet, so they reach each other **and** the internet.

## Gotcha #1 — Linux ping syntax

`ping -n 3 <ip>` is **Windows** syntax. On Linux `-n` means "no DNS" (takes no
count), which makes the command appear to hang. Use `-c` for a count:

```bash
ping -c 3 192.168.3.132     # correct on Linux
```

## Gotcha #2 — Windows doesn't answer ping by default

Windows Firewall drops inbound ICMP echo on the Public profile. Fixed on the
Windows VM (PowerShell as Admin):

```powershell
netsh advfirewall firewall add rule name="Allow ICMPv4-In" protocol=icmpv4:8,any dir=in action=allow
```

## Results — all paths 0% loss

Kali → Ubuntu, Kali → Windows (captured over SSH):

```
--- 192.168.3.132 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss
--- 192.168.3.131 ping statistics ---   (ttl=128 => Windows)
3 packets transmitted, 3 received, 0% packet loss
```

Ubuntu → Kali, Ubuntu → Windows: 0% loss.
Windows → Ubuntu, Windows → Kali: 0% loss.

Full-mesh connectivity confirmed. ✅

## Screenshots

Saved in `../screenshots/`:

- `01-kali-ping.png` — Kali pinging Ubuntu and Windows
- `01-ubuntu-ping.png` — Ubuntu pinging Kali and Windows
- `01-windows-ping.png` — Windows pinging Ubuntu and Kali
