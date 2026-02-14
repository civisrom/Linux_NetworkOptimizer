# Linux Network Optimizer (BBR)

Network optimization script for Linux servers with Google BBR congestion control, intelligent sysctl tuning, and MTU discovery.

## Quick Install

```bash
bash <(wget -qO- https://raw.githubusercontent.com/civisrom/Linux_NetworkOptimizer/main/install.sh)
```

or with `curl`:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/civisrom/Linux_NetworkOptimizer/main/install.sh)
```

> Requires root privileges. Prepend `sudo` if needed.

## Quick Run (without installation)

Run `bbr.sh` directly without installing:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/civisrom/Linux_NetworkOptimizer/main/bbr.sh)
```

```bash
bash <(curl -sSL https://raw.githubusercontent.com/civisrom/Linux_NetworkOptimizer/main/bbr.sh)
```

## Features

- **BBR Congestion Control** — enables Google BBR for better throughput on lossy/high-latency networks
- **Intelligent Tuning** — automatically adjusts TCP buffers, backlog, and queue discipline based on CPU/RAM
- **MTU Discovery** — binary-search tool to find the optimal MTU for your connection
- **System Preparation** — optional fixes for `/etc/hosts`, DNS (Cloudflare/Google), IPv4 APT, full system upgrade
- **Backup & Restore** — timestamped backups of `sysctl.conf` with one-click restore

## Hardware Profiles

| Profile | RAM | CPU Cores | Queue Discipline |
|---------|-----|-----------|-----------------|
| Low-end | < 2 GB | ≤ 2 | `fq_codel` |
| Mid-range | 2–4 GB | 2–4 | `fq_codel` |
| High-end | > 4 GB | > 4 | `cake` |

## Requirements

- Linux with kernel **4.9+** (for BBR support)
- Root access
- `wget` or `curl`

## Uninstall

```bash
sudo bash /opt/network-optimizer/bbr.sh   # use menu option 4 to restore sysctl first
sudo bash <(wget -qO- https://raw.githubusercontent.com/civisrom/Linux_NetworkOptimizer/main/install.sh) --uninstall
```

Or manually:

```bash
sudo rm -rf /opt/network-optimizer
sudo rm -f /usr/local/bin/network-optimizer
```

## License

MIT — see [LICENCE](LICENCE).
