# LeLoi Linux

[![Build Status](https://github.com/seungjin/leloi-linux/actions/workflows/daily-build.yml/badge.svg)](https://github.com/seungjin/leloi-linux/actions)

**LeLoi Linux** is a custom, container-native [bootc](https://containers.github.io/bootc/)-based Linux distribution tailored for the **ThinkPad P14s Gen 6 AMD** (code-named *LeLoi*). It provides a developer-centric, immutable, and fully reproducible environment based on Fedora 44.

## 🚀 Overview

LeLoi Linux leverages the power of `bootc` to manage the operating system as a container image. This allows for transactional updates, easy rollbacks, and a consistent environment across multiple machines or reinstalls.

- **Base OS:** Fedora 44 (via `fedora-bootc:44`)
- **Desktop:** [COSMIC Desktop Environment](https://github.com/pop-os/cosmic-epoch)
- **Philosophy:** Immutable core, containerized workloads, and hardware-optimized defaults.

## ✨ Key Features

- **Immutable & Atomic:** OS updates are delivered as container images, ensuring atomicity and easy rollbacks via `bootc` and `snapper`.
- **Advanced Storage:** Btrfs-focused layout with subvolumes (`/`, `/var`, `/var/home`) and full-disk encryption via LUKS2.
- **Developer First:** Pre-loaded with essential tools like Emacs, Zsh, Podman, Buildah, KVM/QEMU, and more.
- **Security Hardened:** 
  - Uses `sudo-rs` for safer privilege escalation.
  - Locked root account by default.
  - Firewalld enabled with sensible defaults.
- **Optimized Performance:** Tailored for AMD Ryzen™ AI 9 HX PRO 370 with specific kernel arguments and power management.
- **Modern Stack:** Uses `dnf5` for faster package management and `systemd-sysusers` for declarative user management.

## 💻 Hardware Specifications

Designed and optimized for the [ThinkPad P14s Gen 6 AMD](https://psref.lenovo.com/Product/ThinkPad/ThinkPad_P14s_Gen_6_AMD):

- **CPU:** AMD Ryzen™ AI 9 HX PRO 370
- **Display:** 14" WUXGA (1920 × 1200) IPS, 400nits, 60Hz
- **Memory:** 64GB LPDDR5x-7500
- **Keymap:** US Colemak (Software-level optimization)

## 🏗️ Project Architecture

The project uses a two-layer build strategy to optimize build times and separation of concerns:

1.  **Base Image (`leloi-linux-base`):** Contains the core Fedora 44 bootc system and the COSMIC Desktop Environment.
2.  **Final Image (`leloi-linux`):** Adds user-specific configurations, additional developer tools, and system overlays.

## 🛠️ Getting Started

This project uses `just` as a command runner.

### Prerequisites
- `podman`
- `just`
- `bootc-image-builder` (run via podman)

### 1. Build the Images

You can build and push the images to GHCR using the following shortcuts:

- **Build Base Image:**
  ```bash
  just a  # Increments version, builds, and pushes ghcr.io/seungjin/leloi-linux-base
  ```
- **Build Final Image:**
  ```bash
  just b  # Increments version, builds, and pushes ghcr.io/seungjin/leloi-linux
  ```

### 2. Generate Bootable Media (ISO)

To generate a bare-metal installation ISO:

- **From existing local image:**
  ```bash
  just build2  # Builds final image and then generates ISO
  ```
- **ISO Only (using base image):**
  ```bash
  just build iso
  ```
The output ISO will be placed in the `./output` directory.

### 3. Apply Updates to a Running System

If you are already running LeLoi Linux, you can "push" your local changes to your system:
```bash
just c  # Saves local image, loads it into system storage, and performs 'bootc switch'
```

## 📁 Project Structure

- `Containerfile-base`: Defines the Fedora 44 + COSMIC foundation.
- `Containerfile`: The final layer with extra packages and personal tweaks.
- `rootfs/`: A collection of overlay files (systemd services, configs, etc.) that are copied into the image.
- `config.toml`: Configuration for the `bootc-image-builder` (Kickstart logic, partitioning).
- `justfile`: Automation logic for the entire lifecycle.
- `scripts/`: Helper scripts for initial setup and user configuration.
- `.flow/`: Specialized build logic and alternative workflows.

## 📝 License

This project is licensed under the **MIT License**. See the `LICENSE` file for details.

---
*Last Updated: May 2026*
