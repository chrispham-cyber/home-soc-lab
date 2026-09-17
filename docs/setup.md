# Setup Guide

Step-by-step build log. Update the checkboxes as you go — this doubles as your
progress tracker and the source material for the write-up.

## 0. Environment

- Host: macOS + VMware Fusion
- VMs: Kali, Windows 11, Ubuntu 22.04 (all NAT — same vmnet, can reach each other + internet)
- [x] Clean baseline snapshots taken (Kali, Ubuntu via CLI; Windows via GUI)

## 1. Network sanity check

- [ ] All 3 VMs powered on
- [ ] Record IPs: Kali `ip a`, Ubuntu `ip a`, Windows `ipconfig`
- [ ] `ping` works between all VMs (allow ICMP through Windows Firewall if needed)

| VM       | IP address |
|----------|------------|
| Kali     |            |
| Windows  |            |
| Ubuntu   |            |

## 2. Install Wazuh (on the Ubuntu server VM)

```bash
# Install Docker if needed
sudo apt update && sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker $USER   # then log out/in

# Deploy Wazuh single-node
git clone https://github.com/wazuh/wazuh-docker.git -b v4.9.0
cd wazuh-docker/single-node
docker compose -f generate-indexer-certs.yml run --rm generator
docker compose up -d
```

- [ ] Dashboard reachable at `https://<ubuntu-ip>`
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
