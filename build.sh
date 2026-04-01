#!/bin/bash
# ============================================================
# Zaatar Linux 1.0 — Build Script
# Usage: sudo bash build.sh
# Requirements: Fedora 41, run as root
# ============================================================

set -euo pipefail

# ── Config ──────────────────────────────────────────────────
NAME="Zaatar Linux"
ID="zaatar"
VERSION="1.0"
FEDORA_RELEASE="41"
ARCH="x86_64"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KS="${SCRIPT_DIR}/kickstarts/zaatar-desktop.ks"
RPM_SPEC="${SCRIPT_DIR}/rpm/zaatar-branding.spec"
BUILD_DIR="/var/tmp/zaatar-build"
OUT_DIR="${SCRIPT_DIR}/output"
ISO_NAME="${ID}-desktop-${VERSION}-${ARCH}.iso"

# ── Colors ──────────────────────────────────────────────────
R='\033[0;31m'; G='\033[0;32m'; C='\033[0;36m'; Y='\033[0;33m'; N='\033[0m'
log()  { echo -e "${C}==>${N} $1"; }
ok()   { echo -e "${G} ✓${N} $1"; }
err()  { echo -e "${R} ✗${N} $1"; exit 1; }
hr()   { echo -e "${C}$(printf '─%.0s' {1..60})${N}"; }

# ── Root check ──────────────────────────────────────────────
[[ $EUID -ne 0 ]] && err "شغّل كـ root: sudo bash build.sh"

hr
echo -e "${C}  ${NAME} ${VERSION} — Desktop Build${N}"
hr

# ── Step 1: تثبيت أدوات البناء ──────────────────────────────
log "تثبيت أدوات البناء..."
dnf install -y \
    lorax \
    livecd-tools \
    pykickstart \
    createrepo_c \
    isomd5sum \
    rpm-build \
    rpmdevtools \
    anaconda \
    anaconda-tui \
    2>/dev/null || err "فشل تثبيت الأدوات"
ok "الأدوات جاهزة"

# ── Step 2: بناء RPM Branding ────────────────────────────────
log "بناء حزمة Branding..."
rpmdev-setuptree 2>/dev/null || true

if [[ -f "$RPM_SPEC" ]]; then
    cp "$RPM_SPEC" ~/rpmbuild/SPECS/
    [[ -d "${SCRIPT_DIR}/rpm/SOURCES" ]] && \
        cp -r "${SCRIPT_DIR}/rpm/SOURCES/"* ~/rpmbuild/SOURCES/ 2>/dev/null || true
    rpmbuild -ba ~/rpmbuild/SPECS/zaatar-branding.spec 2>&1 | tail -3
    mkdir -p ~/rpmbuild/RPMS/repo
    find ~/rpmbuild/RPMS -name "*.rpm" -exec cp {} ~/rpmbuild/RPMS/repo/ \; 2>/dev/null || true
    createrepo_c ~/rpmbuild/RPMS/repo/ -q
    ok "RPM Branding جاهز"
else
    log "ملف .spec غير موجود — تجاوز (النظام سيعمل بدون برندينج مخصص)"
fi

# ── Step 3: التحقق من Kickstart ──────────────────────────────
log "التحقق من ملف Kickstart..."
[[ ! -f "$KS" ]] && err "الملف غير موجود: $KS"
ksvalidator "$KS" || err "خطأ في ملف Kickstart"
ok "Kickstart سليم"

# ── Step 4: البناء ──────────────────────────────────────────
log "بدء بناء ISO — قد يأخذ 30–90 دقيقة..."
mkdir -p "$OUT_DIR" "$BUILD_DIR"

livemedia-creator \
    --ks "$KS" \
    --no-virt \
    --resultdir "$OUT_DIR" \
    --project "${NAME} Desktop" \
    --make-iso \
    --volid "ZAATAR_DESKTOP" \
    --iso-only \
    --iso-name "$ISO_NAME" \
    --releasever "$FEDORA_RELEASE" \
    --tmp "$BUILD_DIR" \
    || err "فشل البناء — راجع /var/log/anaconda/"

# ── Step 5: Checksum ─────────────────────────────────────────
log "حساب Checksum..."
cd "$OUT_DIR"
sha256sum "$ISO_NAME" > "${ISO_NAME}.sha256"
SIZE=$(du -sh "$ISO_NAME" | cut -f1)

# ── ملخص ────────────────────────────────────────────────────
hr
ok "اكتمل البناء!"
echo ""
echo -e "  ${G}ISO:${N}    ${OUT_DIR}/${ISO_NAME} (${SIZE})"
echo -e "  ${G}SHA256:${N} $(cut -d' ' -f1 ${ISO_NAME}.sha256)"
echo ""
echo -e "  اختبر قبل التثبيت:"
echo -e "  ${C}qemu-system-x86_64 -m 4G -enable-kvm -boot d -cdrom ${OUT_DIR}/${ISO_NAME}${N}"
echo ""
hr
