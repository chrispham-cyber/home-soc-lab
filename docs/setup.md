# Setup Guide

Step-by-step build log. Update the checkboxes as you go — this doubles as your
progress tracker and the source material for the write-up.

## 0. Environment

- Host: macOS + VMware Fusion
- VMs: Kali, Windows 11, Ubuntu 22.04 (all NAT — same vmnet, can reach each other + internet)
- [x] Clean baseline snapshots taken (Kali, Ubuntu via CLI; Windows via GUI)

## 1. Network sanity check

- [x] All 3 VMs powered on
- [x] Record IPs: Kali `ip a`, Ubuntu `ip a`, Windows `ipconfig`
- [x] `ping` works between all VMs (allow ICMP through Windows Firewall if needed)

| VM       | IP address |
|----------|------------|
| Kali     | 192.168.3.135           |
| Windows  | 192.168.3.131           |
| Ubuntu   | 192.168.3.132           |

## 2. Install Wazuh (on the Ubuntu server VM)

> **This lab is on Apple Silicon → ARM64.** Docker and the 4.9 assistant both
> fail on ARM64 (see [02-wazuh-install-arm64.md](02-wazuh-install-arm64.md)).
> The working path is the **4.14 installation assistant**, which is arm64-aware.

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash wazuh-install.sh -a -i     # -a all-in-one, -i skip hardware checks
```

Installs indexer + manager + Filebeat + dashboard natively (no emulation).

- [x] Dashboard reachable at `https://192.168.3.132` (admin / see install output)
- [x] All services active; indexer cluster health = green
- [ ] Changed default admin password

## 3. Deploy agents

- [ ] Wazuh agent installed on Windows 11
- [ ] Wazuh agent installed on Ubuntu victim
- [ ] Sysmon installed on Windows with SwiftOnSecurity config
- [ ] Confirm all agents show "Active" in the dashboard

## 4. Run attacks + build detections

Work through the files in `attacks/`. For each one:
1. Run the attack from Kali
2. Check what Wazuh caught
3. Screenshot the alert → `screenshots/`
4. If missed, write a rule in `detection-rules/` and re-test

## 5. Write it up

- [ ] Complete `writeups/building-a-home-soc.md`
- [ ] Publish to blog
- [ ] Push repo to GitHub, mark techniques ✅ in README
