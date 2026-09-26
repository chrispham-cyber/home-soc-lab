# Adding a network IDS with Suricata

Attack 01 showed the blind spot: a plain nmap scan produced no Wazuh alert, because
Wazuh is host-based and never sees the scan traffic. This is how I closed that gap by
adding Suricata as a network IDS and feeding its alerts into Wazuh.

## Where it sits
Suricata runs on the Ubuntu box (the Wazuh server) and sniffs its `ens160` interface,
so anything aimed at that host, like an nmap scan, now passes in front of it. Suricata
writes alerts to `/var/log/suricata/eve.json`, and Wazuh tails that file.

```
Kali  --scan-->  Ubuntu (ens160)
                    |             \
               Suricata IDS      Wazuh manager
                    |                 ^
                eve.json  --tailed---->   ->  alert (rule 86601)
```

## Install (ARM64 Ubuntu)
```bash
sudo apt-get install -y suricata
sudo suricata-update
```

## Config
Edits in `/etc/suricata/suricata.yaml` plus one rule file:
- Point the capture interface at the real NIC: `af-packet: - interface: ens160`.
- HOME_NET already covered `192.168.3.0/24` (it includes `192.168.0.0/16`).
- Register a local rule file under `rule-files:` (`- local.rules`).

The ET Open rules did not fire on a plain internal `-sT` scan (many of those signatures
key on specific payloads or NSE user-agents), so I wrote a threshold rule that catches
the scan by behavior instead. Copy in
[../detection-rules/suricata-local.rules](../detection-rules/suricata-local.rules):

```
alert tcp any any -> $HOME_NET any (msg:"LOCAL SCAN Possible TCP port scan (30+ SYN from one source in 10s)"; flags:S; flow:to_server; threshold:type both, track by_src, count 30, seconds 10; classtype:attempted-recon; sid:1000001; rev:1;)
```

Validate and start:
```bash
sudo suricata -T -c /etc/suricata/suricata.yaml
sudo systemctl enable --now suricata
```

## Feed it into Wazuh
One block in `/var/ossec/etc/ossec.conf`, then restart the manager:
```xml
<localfile>
  <log_format>json</log_format>
  <location>/var/log/suricata/eve.json</location>
</localfile>
```
Wazuh ships decoders and rules for Suricata, so eve.json alerts come through as Wazuh
alerts (group 86600, e.g. rule 86601).

## Result
Re-ran the scan from Kali against the Ubuntu host:
```bash
nmap -sT -T4 -p 1-2000 192.168.3.132
```
Suricata fired my custom rule and Wazuh picked it up:
```
Suricata (eve.json): LOCAL SCAN Possible TCP port scan (30+ SYN from one source in 10s)
Wazuh alert:         rule 86601  ->  same signature
```
The scan that produced nothing in Attack 01 now shows up in the SIEM, which gives the
lab both host and network visibility.

## Next
- Mirror the Kali -> Windows path so Suricata also sees attacks against the Windows box,
  not just traffic to the Ubuntu host.
- Tune noisy ET rules and raise the Wazuh alert level for confirmed scans.
