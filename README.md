# Zaatar Linux 1.0 — Desktop Edition

A Linux system based on Fedora 41 — KDE Plasma — Wayland.

## Features
- KDE Plasma (Wayland)
- Firefox
- WiFi + Bluetooth
- Flatpak + Flathub
- Firewall + Automatic Security Updates
- Full English language support
- Standard US Keyboard Layout
- System Name: Zaatar Linux across all interfaces

## Build Instructions
```bash
# Run on Fedora 41 as root
sudo bash build.sh
```

## Testing
```bash
qemu-system-x86_64 -m 4G -enable-kvm -boot d \
  -cdrom output/zaatar-desktop-1.0-x86_64.iso
```
