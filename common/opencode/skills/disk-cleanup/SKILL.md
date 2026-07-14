# Skill: Disk Cleanup Guide

This skill provides a structured approach to identifying reclaimable disk space.

## Cleanup Candidates
1. **Installer Files**: Look for large `.dmg`, `.pkg`, or `.iso` files in `~/Downloads` and `~/Documents`.
2. **Caches**: Target `~/Library/Caches/*`. Prioritize large app-specific folders (e.g., `Yarn`, `Arc`, `Brave`, `Firefox`).
3. **Build Artifacts**: Target `go/pkg`, `node_modules` (in older project folders), and build/dist directories.
4. **Log Files**: Search for large `.log` files in `~/.local/state/` or application-specific directories.
5. **Orphaned Application Data**: If an application is confirmed uninstalled, remove its corresponding directory in `~/Library/Application Support/` and `~/Library/Containers/`.

## Safety Protocols
- **NEVER** delete system-critical directories in `~/Library` without verifying the application is removed.
- **ALWAYS** check `docker system df` and use `docker system prune` rather than manual folder deletion for Docker data.
- **CRITICAL**: Before deleting personal user directories (Music, Photos), verify if they are backed up or synced to other devices (Phone/Cloud).
