# Zaatar Linux 1.0 — Desktop Edition

نظام لينكس مبني على Fedora 41 — KDE Plasma — Wayland

## ما يحتويه النظام
- KDE Plasma (Wayland)
- Firefox
- WiFi + Bluetooth
- Flatpak + Flathub
- جدار حماية + تحديثات أمان تلقائية
- دعم كامل للغة العربية والإنجليزية
- كيبورد عربي/إنجليزي (Alt+Shift للتبديل)
- اسم النظام: Zaatar Linux في كل مكان

## البناء
```bash
# على Fedora 41 كـ root
sudo bash build.sh
```

## الاختبار
```bash
qemu-system-x86_64 -m 4G -enable-kvm -boot d \
  -cdrom output/zaatar-desktop-1.0-x86_64.iso
```
