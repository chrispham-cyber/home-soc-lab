# Build Notes

How I put the lab together, roughly in order.

## Environment

- Host: macOS on Apple Silicon, VMware Fusion.
- Guests: Kali, Windows 11, Ubuntu. All ARM64. All on the same NAT network so they
  can reach each other and the internet.
- Took a clean snapshot of each VM before touching anything.

## 1. Network

Confirmed the three VMs could reach each other before doing anything else.

| VM       | IP            |
|----------|---------------|
| Kali     | 192.168.3.135 |
| Windows  | 192.168.3.131 |
| Ubuntu   | 192.168.3.132 |

Two things tripped me up: on Linux the ping count flag is `-c`, not `-n` (that's
Windows), and Windows Firewall drops inbound ping on the Public profile by default.
Details in [01-network-verification.md](01-network-verification.md).

## 2. Wazuh server (on Ubuntu)

The documented Docker deploy and the 4.9 install script both fail on ARM64. The 4.14
install assistant is architecture-aware and works:

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash wazuh-install.sh -a -i     # -a = all-in-one, -i = skip hardware checks
```

That installs the indexer, manager, Filebeat, and dashboard natively. Dashboard came
up at `https://192.168.3.132`, cluster health green. First thing after login was
changing the admin password. Full ARM64 story in
[02-wazuh-install-arm64.md](02-wazuh-install-arm64.md).

## 3. Agents

- Windows: installed the Wazuh agent (the x86 MSI runs fine on ARM64 under emulation)
  and pointed it at the manager. It enrolled as `windows-victim` and went Active.
- Ubuntu: no separate agent. It's the manager, so it already monitors itself as
  agent 000 (reads journald/syslog). A second agent on the same box would fight over
  `/var/ossec`.
- Sysmon: installed the ARM64 build (`Sysmon64a.exe`) with the SwiftOnSecurity config,
  then added the Sysmon event channel to the agent's `ossec.conf` so Wazuh ingests it:

  ```xml
  <localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
  </localfile>
  ```

Within a minute of restarting the agent, Sysmon-based detections started showing up.

## 4. Attacks and detections

Ran the attacks in the [attacks/](../attacks/) folder from Kali (nmap, SSH brute
force) and on Windows (discovery and execution techniques). Each file has the exact
commands, the rules that fired, and the MITRE mapping. The one detection I had to
build myself is in [detection-rules/](../detection-rules/).

## 5. Left to do

- Write and publish the long-form post (draft in [writeups/](../writeups/)).
- Add Suricata for network visibility (nmap currently slips past a host-based SIEM).
