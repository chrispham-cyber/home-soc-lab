# Building a home SOC lab and actually catching attacks with it

I've done a fair number of CTFs, but those put me on the attacker's side. I wanted to
see the other half: what an attack looks like from the defender's chair. So I built a
small security operations lab on my laptop, ran real attacks against it, and watched
what the SIEM caught. This is what I did and what I learned.

## The setup

Three VMs in VMware Fusion on an isolated network:

- Windows 11 as the endpoint I'd monitor, with Sysmon and a Wazuh agent.
- Ubuntu running Wazuh as the SIEM (indexer, manager, dashboard).
- Kali as the attacker.

The plan was simple: get logs flowing into Wazuh, attack the Windows box from Kali,
and see which techniques showed up as alerts.

## The part nobody warns you about: ARM64

My Mac is Apple Silicon, so every VM is ARM64, and that turned the "quick" install
into the most educational part of the project.

I started with Wazuh's Docker deploy. Every container immediately crash-looped. The
logs just said `exec format error` over and over. That error means the CPU can't
execute the binary, and once I checked, the reason was clear: Wazuh's images are built
for amd64, and my ARM host had no emulation layer to translate them.

So I tried the install script instead. The 4.9 version refused to run, claiming my
system wasn't 64-bit (it is, aarch64 just wasn't in its check). Digging into the
package repo, I also found the indexer and dashboard only have ARM64 builds from
version 4.12 on. The fix was the 4.14 install assistant, which knows about ARM64 and
pulled the right packages. It installed everything natively, no emulation, and the
cluster came up healthy.

The lesson stuck with me: read the actual error, then check whether the thing you're
installing even exists for your architecture, instead of retrying the same command and
hoping.

## Getting the endpoint talking

The Wazuh agent went on Windows without much drama (the x86 build runs on ARM Windows
through emulation). Then I added Sysmon with the SwiftOnSecurity config, because
Windows' built-in logging is too thin for good detections. Sysmon gives you detailed
process creation, network connections, and file events with hashes and parent-child
relationships, which is what most rules actually rely on.

The one step that's easy to miss: you have to tell the agent to read the Sysmon event
channel. One block in `ossec.conf` and a restart, and detections started appearing
within a minute.

## Attacking my own box

From Kali I ran an nmap scan and an SSH brute force with hydra. On the Windows side I
ran a script of common techniques: discovery commands like `whoami` and `net user`, an
encoded PowerShell command, and a certutil download.

Most of it lit up in the dashboard. The SSH brute force chained a pile of failed
logins into a single "brute force" alert (rule 5763). The encoded PowerShell fired a
level 12. The certutil download tripped a critical (level 15) for dropping a file in a
suspicious folder, and Windows Defender's ASR blocked it on top of that. Every alert
was tagged with its MITRE ATT&CK technique, so I could see the coverage as a map
rather than a pile of logs.

## Writing my own detection

One technique slipped through: `whoami`. It's one of the first things an attacker runs
to figure out who they are on a box, but the default rules only logged it as a generic
process event, no alert. That felt like exactly the kind of gap detection engineering
is supposed to close.

So I wrote a rule. It matches the Sysmon process-creation event where the image is
`whoami.exe`, gives it a severity, and maps it to T1033. I dropped it into the
manager's local rules, restarted, ran `whoami` again, and watched my own rule fire in
the alerts with the right technique attached. Small, but it's the whole loop: see the
gap, write the rule, prove it works.

## The blind spot I didn't expect

My nmap scan produced no alert at all. At first I assumed I'd misconfigured something.
I hadn't. Wazuh is host-based, so it watches processes, files, and logs on the
endpoints, but it has no view of the network itself. A quiet scan from another machine
never touches anything it monitors. To catch scans I'd need a network IDS like
Suricata feeding alerts in.

Honestly this was one of my favorite findings, because knowing what your tools can't
see is as important as knowing what they can. It's the next thing I want to add.

## What I took away

- SIEM concepts stop being abstract once you watch your own attack turn into an alert.
- Sysmon plus MITRE ATT&CK is how you make detections both detailed and measurable.
- Detection engineering isn't magic: it's a tight edit-restart-retest loop.
- Every stack has blind spots. Host-based tooling needs a network layer for real
  coverage.

Everything (the build notes, the attacks, the rule, and the ARM64 troubleshooting) is
in the repo.
