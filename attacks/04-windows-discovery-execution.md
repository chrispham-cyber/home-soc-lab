# Attack 04 — Windows Discovery & Execution (Sysmon-detected)

## Objective
Run common host-based discovery and execution techniques on the Windows victim
and confirm Sysmon + Wazuh detect them, mapped to MITRE ATT&CK.

## Attack (run on Windows victim — see `scripts/attack-sim.ps1`)
Techniques executed:
- `whoami /all`, `net user`, `net localgroup administrators` — Account/User discovery
- `systeminfo` — System information discovery
- `ipconfig /all`, `arp -a` — Network configuration discovery
- `powershell -EncodedCommand <base64>` — encoded PowerShell execution
- `certutil -urlcache -split -f <url>` — ingress tool transfer (LOLBin)

## Detections observed in Wazuh (agent 001 = windows-victim)

| Rule ID | Level | Description | MITRE |
|---------|-------|-------------|-------|
| 92213 | 15 🔴 | Executable file dropped in folder commonly used by malware | T1105 |
| 92057 | 12 🟡 | Powershell executed an encoded/base64 command | T1059.001 |
| 92031 |  3 | Discovery activity executed | T1087 |
| 92032 |  3 | Suspicious Windows cmd shell execution | T1087, T1059.003 |
| 92036 |  3 | net.exe binary started by a Windows shell | T1059.003, T1574.001 |
| 92004 |  4 | Powershell process spawned Windows command shell | T1059.003 |
| **100010** | **8** | **Custom: whoami.exe executed (T1033)** — see below | **T1033** |

Notes:
- `certutil` download was blocked by Windows Defender ASR ("Access is denied"),
  which is itself a useful signal — Wazuh still recorded the dropped-file event
  (92213, critical).

## Detection engineering — custom rule 100010

The default ruleset logs `whoami` as a generic Sysmon process-creation event but
raises no dedicated alert. `whoami` is one of the first things an attacker runs,
so it is worth flagging. Rule written (`../detection-rules/local_rules.xml`):

```xml
<rule id="100010" level="8">
  <if_group>sysmon_event1</if_group>
  <field name="win.eventdata.image" type="pcre2">(?i)\\whoami\.exe$</field>
  <description>Custom: whoami.exe executed - System Owner/User Discovery (T1033)</description>
  <mitre><id>T1033</id></mitre>
</rule>
```

**Test result (confirmed firing):**
```
desc:  Custom: whoami.exe executed - System Owner/User Discovery (T1033)
level: 8
mitre: {'id': ['T1033'], 'tactic': ['Discovery'], 'technique': ['System Owner/User Discovery']}
image: C:\Windows\System32\whoami.exe
```

Deploy → test cycle: edit `local_rules.xml` → `wazuh-control restart` → re-run
the technique → confirm the alert appears with the new rule ID.
