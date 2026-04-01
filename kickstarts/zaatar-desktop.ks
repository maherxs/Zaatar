# ============================================================
# Zaatar Linux 1.0 — Desktop Edition
# Based on Fedora 41 · KDE Plasma · Wayland · x86_64
# ============================================================


reboot

# ── Language ────────────────────────────────────────────────
lang en_US.UTF-8

keyboard --vckeymap=us
timezone UTC --utc

# ── Network ─────────────────────────────────────────────────
network --bootproto=dhcp --device=link --activate
network --hostname=zaatar

# ── Users ───────────────────────────────────────────────────
rootpw --lock
user --name=user --gecos="Zaatar User" --groups=wheel --password=changeme --plaintext

# ── Disk Partitioning ───────────────────────────────────────
part / --size=15360 --fstype=ext4
clearpart --all --initlabel
bootloader --location=mbr

# ── Repositories ────────────────────────────────────────────
url --metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-41&arch=$basearch
repo --name=fedora  --metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-41&arch=$basearch
repo --name=updates --metalink=https://mirrors.fedoraproject.org/metalink?repo=updates-released-f41&arch=$basearch
repo --name=rpmfusion-free    --baseurl=https://download1.rpmfusion.org/free/fedora/releases/41/Everything/x86_64/os/
repo --name=rpmfusion-nonfree --baseurl=https://download1.rpmfusion.org/nonfree/fedora/releases/41/Everything/x86_64/os/
repo --name=zaatar-local --baseurl=file:///root/rpmbuild/RPMS/

# ============================================================
# Packages
# ============================================================
%packages

# ── Core System ─────────────────────────────────────────────
@core
@hardware-support
@base-x
dracut-live

glibc-langpack-en
ibus
ibus-typing-booster

# ── KDE Plasma ──────────────────────────────────────────────
@kde-desktop
plasma-breeze
plasma-breeze-common
plasma-workspace
plasma-workspace-wayland
kwin
kwin-wayland
kscreen
sddm
sddm-kcm
polkit-kde
kde-settings-pulseaudio

# ── KDE Core Applications ───────────────────────────────────
dolphin
konsole
krunner
spectacle
kcalc

# ── Firefox ─────────────────────────────────────────────────
firefox

# ── WiFi + Bluetooth ────────────────────────────────────────
NetworkManager
NetworkManager-wifi
NetworkManager-bluetooth
NetworkManager-tui
bluez
bluez-tools
wpa_supplicant

# ── Audio (PipeWire) ────────────────────────────────────────
pipewire
pipewire-alsa
pipewire-pulseaudio
wireplumber

# ── Flatpak + Flathub ───────────────────────────────────────
flatpak
xdg-desktop-portal
xdg-desktop-portal-kde
xdg-user-dirs

# ── Multimedia Codecs ───────────────────────────────────────
gstreamer1-plugins-base
gstreamer1-plugins-good
gstreamer1-plugins-bad-free
gstreamer1-plugins-bad-freeworld
gstreamer1-plugin-openh264
gstreamer1-plugins-ugly-free
ffmpeg
vlc

# ── Firewall & Security ─────────────────────────────────────
firewalld
dnf-automatic
fwupd

# ── Basic System Tools ──────────────────────────────────────
curl
wget
zip
unzip
tar
bash-completion

# ── Fonts ───────────────────────────────────────────────────
google-noto-sans-fonts
liberation-fonts
dejavu-fonts-all

# ── Zaatar Branding ─────────────────────────────────────────
zaatar-branding

# ── Remove unnecessary packages ─────────────────────────────
-fedora-logos
-fedora-release-notes
-abrt
-abrt-cli
-abrt-desktop
-libreoffice*
-gimp
-inkscape
-thunderbird
-transmission*
-obs-studio
-elisa
-filelight
-okular
-gwenview
-ark
-kate
-kinfocenter

%end

# ============================================================
# Post-Install
# ============================================================
%post --log=/var/log/zaatar-post-install.log
set -e

echo "==> Zaatar Linux — Post Install Starting..."

# ── System Identity ─────────────────────────────────────────
cat > /etc/os-release << 'EOF'
NAME="Zaatar Linux"
VERSION="1.0 (Thyme)"
ID=zaatar
ID_LIKE=fedora
VERSION_ID="1.0"
PLATFORM_ID="platform:f41"
PRETTY_NAME="Zaatar Linux 1.0 (Thyme)"
ANSI_COLOR="0;36"
LOGO="zaatar-logo"
HOME_URL="https://zaatar.linux"
DOCUMENTATION_URL="https://zaatar.linux/docs"
SUPPORT_URL="https://zaatar.linux/support"
BUG_REPORT_URL="https://github.com/USERNAME/zaatar-linux/issues"
EOF

echo "zaatar" > /etc/hostname

cat > /etc/issue << 'EOF'
Zaatar Linux 1.0 (Thyme) - \l
EOF

cat > /etc/motd << 'EOF'

  Zaatar Linux 1.0 (Thyme)
  Welcome to Zaatar Linux

EOF

# ── Set system name in GRUB ─────────────────────────────────
sed -i 's/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="Zaatar Linux"/' /etc/default/grub 2>/dev/null || true

# ── Default Locale ──────────────────────────────────────────
cat > /etc/locale.conf << 'EOF'
LANG=en_US.UTF-8
EOF

# ── Keyboard Layout ─────────────────────────────────────────
cat > /etc/X11/xorg.conf.d/00-keyboard.conf << 'EOF'
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us"
EndSection
EOF

# ── KDE Locales ─────────────────────────────────────────────
mkdir -p /etc/xdg
cat > /etc/xdg/plasma-localerc << 'EOF'
[Formats]
LANG=en_US.UTF-8

[Translations]
LANGUAGE=en_US
EOF

# ── SDDM + Wayland ──────────────────────────────────────────
systemctl enable sddm
systemctl set-default graphical.target

mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/10-zaatar.conf << 'EOF'
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Theme]
Current=zaatar
EOF

# ── Flatpak + Flathub ───────────────────────────────────────
flatpak remote-add --system --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# ── Audio (PipeWire) ────────────────────────────────────────
systemctl --global enable pipewire pipewire-pulse wireplumber

# ── Firewall ────────────────────────────────────────────────
systemctl enable firewalld
firewall-offline-cmd --set-default-zone=public

# ── Automatic Security Updates ──────────────────────────────
cat > /etc/dnf/automatic.conf << 'EOF'
[commands]
upgrade_type = security
download_updates = yes
apply_updates = yes
random_sleep = 0

[emitters]
emit_via = stdio
EOF
systemctl enable dnf-automatic.timer

# ── fwupd ───────────────────────────────────────────────────
systemctl enable fwupd

# ── NetworkManager + Bluetooth ──────────────────────────────
systemctl enable NetworkManager
systemctl enable bluetooth

# ── Clean up ────────────────────────────────────────────────
dnf clean all

echo "==> Zaatar Linux — Post Install Done."
%end
