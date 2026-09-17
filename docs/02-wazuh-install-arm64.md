# Installing Wazuh on Apple Silicon (ARM64) — What Actually Worked

The lab runs on VMware Fusion on an Apple Silicon Mac, so every VM is **ARM64
(aarch64)**. This breaks the two "official" quick-start paths for Wazuh. Here is
the real troubleshooting trail and the fix — the kind of thing that never shows
up in a tutorial.

## Attempt 1 — Docker single-node (the documented default) ❌

```bash
git clone https://github.com/wazuh/wazuh-docker.git -b v4.9.0
cd wazuh-docker/single-node
docker compose -f generate-indexer-certs.yml run --rm generator
docker compose up -d
```

All three containers went into `Restarting (255)`. Logs:

```
wazuh.indexer-1  | exec /entrypoint.sh: exec format error
wazuh.manager-1  | exec /init: exec format error
```

**Diagnosis:** Wazuh's Docker images are published for `linux/amd64` only. On an
ARM64 host with no QEMU binfmt layer installed, the amd64 binaries cannot execute
at all — `exec format error`. Not a config issue; an architecture mismatch.

Cleaned up:
```bash
docker compose down -v
```

## Attempt 2 — Installation assistant, 4.9 branch ❌

```bash
curl -sO https://packages.wazuh.com/4.9/wazuh-install.sh
sudo bash wazuh-install.sh -a -i
```

```
ERROR: Uncompatible system. This script must be run on a 64-bit system.
```

**Diagnosis:** two separate problems.
1. The 4.9 assistant's arch check only accepts `x86_64` and wrongly rejects
   `aarch64` (which *is* 64-bit).
2. Even bypassing that, Wazuh only publishes **arm64** packages for
   `wazuh-indexer` and `wazuh-dashboard` from **4.12.0 onward**. 4.9.2 arm64
   simply does not exist for those two components — only `wazuh-manager` does.

Verified against the repo:
```bash
curl -s https://packages.wazuh.com/4.x/apt/dists/stable/main/binary-arm64/Packages \
  | grep -E "wazuh-(indexer|dashboard|manager)"
# indexer/dashboard arm64 start at 4.12.0; manager has full history
```

## Attempt 3 — Installation assistant, 4.14 branch ✅

The newer assistant already supports ARM64 natively (it detects `aarch64` and
pulls arm64 packages), and 4.14.7 has arm64 builds of all three components.

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash wazuh-install.sh -a -i        # -a all-in-one, -i skip hardware checks
```

Installs `wazuh-indexer`, `wazuh-manager` + Filebeat, and `wazuh-dashboard`
natively — no emulation.

## Takeaways

- On Apple Silicon, **skip Wazuh Docker** — the images are amd64-only.
- Use the **4.14+ installation assistant**, which is arm64-aware.
- Always check the package repo for your architecture before committing to a
  version; component arch support is not uniform across releases.
