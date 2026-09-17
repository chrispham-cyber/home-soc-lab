# 01 - Network scan (nmap)

MITRE: T1595 / T1046

## What I ran (from Kali)

```bash
nmap -sT -sV --top-ports 50 -T4 192.168.3.131 192.168.3.132
```

Both hosts came back up. On Ubuntu it fingerprinted the Wazuh dashboard on 443 (a 302 redirect to `/app/login`). On Windows it enumerated the open services.

## What Wazuh caught

Nothing. No alert for the scan at all.

## Why

I expected at least something, but it makes sense once you think about where Wazuh sits. It's host-based: it watches processes, files, and logs on the endpoints. A TCP scan from another machine never runs a process or writes a log on the target, so there's nothing for Wazuh to key off of. Without host firewall logs being shipped in, or a network IDS feeding it, scans are a blind spot.

## Fixing it later

Put Suricata on a monitoring interface and forward its `eve.json` into Wazuh. Then a scan trips Suricata signatures and those show up as Wazuh alerts. Noting it here as the next thing to add rather than pretending the coverage is there.
