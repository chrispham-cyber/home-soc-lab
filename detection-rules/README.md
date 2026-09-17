# Detection Rules

Custom rules I wrote to catch attacks the default ruleset missed.

## Wazuh custom rules
Wazuh local rules live on the server at `/var/ossec/etc/rules/local_rules.xml`.
Keep a copy of anything you write here so it is version-controlled.

Example skeleton (`local_rules.xml`):
```xml
<group name="local,custom,">
  <!-- Example: alert on many failed SSH logins in a short window -->
  <rule id="100001" level="10" frequency="8" timeframe="120">
    <if_matched_sid>5716</if_matched_sid>
    <description>Custom: possible SSH brute force (8+ failures in 120s)</description>
    <mitre>
      <id>T1110</id>
    </mitre>
  </rule>
</group>
```

## Sigma rules (portable)
For rules you want to be SIEM-agnostic, write them in [Sigma](https://github.com/SigmaHQ/sigma)
YAML under `sigma/` and note which SIEMs you converted them for.

## Rule index

| ID / file | Detects | ATT&CK | Tested |
|-----------|---------|--------|--------|
| 100010 (`local_rules.xml`) | whoami.exe execution | T1033 | ✅ confirmed firing |
