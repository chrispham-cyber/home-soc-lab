# Attack 01 — Network Scan (MITRE T1595 / T1046)

## Objective
Discover open ports/services on the victims and see how the SIEM reacts.

## Attack (from Kali)
```bash
nmap -sT -sV --top-ports 50 -T4 192.168.3.131 192.168.3.132
```

Results: both hosts up. On Ubuntu, nmap fingerprinted the Wazuh dashboard on
443 (HTTP 302 → /app/login, `osd-name: ubuntu-VMware20-1`). On Windows, open
services enumerated.

## Detections observed in Wazuh

**None specific to the scan.** This is an honest and important finding.

## Why nothing fired — and what it teaches

Wazuh is a **host-based** SIEM/EDR. It sees process, file, and log activity on
the endpoints, but it has **no network sensor**, so a stealthy TCP scan that
never touches a monitored log or process generates nothing to alert on. Without
one of:
- host **firewall logging** shipped to Wazuh, or
- a **network IDS** (e.g. Suricata) feeding alerts,

port scans are a blind spot.

## Follow-up / roadmap
Add **Suricata** on a mirror/monitor interface and forward its `eve.json` to
Wazuh. Then a scan trips Suricata signatures (e.g. `ET SCAN` rules) which Wazuh
ingests — closing this gap. Documented as future work.

**Takeaway for interviews:** knowing *what your tooling cannot see* is as
valuable as knowing what it can. A host-based stack needs a network layer for
full coverage.
