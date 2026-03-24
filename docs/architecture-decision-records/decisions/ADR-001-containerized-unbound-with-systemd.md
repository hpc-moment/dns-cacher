# ADR-001: Containerized Unbound DNS Resolver with Systemd

## Status
Accepted

## Date
2026-03-22

## Context
Deploying an Unbound DNS resolver requires robust service management, typically handled by `systemd`. However, running `systemd` inside a Docker container presents challenges due to cgroups, hardware-specific targets, and log management. We need a solution that allows Unbound to run as a systemd service within a Docker container while remaining compatible with any Linux host (NixOS, Ubuntu, Debian, etc.), handling initialization gracefully, and ensuring logs are accessible via standard Docker commands.

## Decision
We elected to containerize the Unbound DNS resolver system using Docker with the following architecture:
1. **Ubuntu 22.04 Base Image:** Used as the foundation with `systemd` installed.
2. **Systemd Integration:** The container is run with `privileged: true`, and `tmpfs` mounts (`/run`, `/run/lock`, `/tmp`) to allow `systemd` to manage processes natively.
3. **Compatibility Hack:** We actively remove hardware-specific and UI `systemd` targets (e.g., `multi-user.target.wants`, `local-fs.target.wants`, `udev`, `graphical.target`, `getty.target`) during the Docker build. We also explicitly set the default target to `multi-user.target`.
4. **Log Forwarding:** `systemd` journal logs and Unbound output are forwarded to the Docker console (`stdout`) by modifying `/etc/systemd/journald.conf.d/docker-console.conf`.
5. **Automated Validation:** Implement both internal Docker `healthcheck` (via `dig`) and an external `check.sh` script to verify system state, service health, and configuration parity automatically.

## Rationale
- **Service Management:** `systemd` provides native and reliable management of the `unbound` daemon, handling restarts, dependencies, and graceful shutdowns.
- **Portability:** Stripping out physical hardware targets and forcing `multi-user.target` stops `systemd` from hanging or failing when it attempts to interact with nonexistent devices or UI subsystems, enabling true cross-platform Linux host compatibility (NixOS, WSL2, Ubuntu).
- **Observability:** By redirecting the journal to the console and implementing automated healthchecks, we maintain a production-grade monitoring experience.

## Consequences
- The container must be run in `privileged` mode, which expands the attack surface. This is an acceptable trade-off for an isolated DNS lab environment.
- The `Dockerfile` requires manual pruning of `systemd` services to maintain host-agnosticity without relying on advanced Docker Compose features like `cgroupns: host`.
- Configuration updates are managed smoothly via read-only bind mounts, and their integrity is verified by the automated check system.

## Alternatives Considered
- **Plain Entrypoint:** Running Unbound directly via the Docker `ENTRYPOINT` or `CMD` without systemd. Evaluated but rejected, as it skips the native daemonization lifecycle and validation steps that systemd unit files provide.
- **Alpine Linux with OpenRC:** Evaluated but rejected to retain standard Ubuntu tooling and 1:1 parity with typical production VM deployments of `systemd` that teams are already familiar with.
