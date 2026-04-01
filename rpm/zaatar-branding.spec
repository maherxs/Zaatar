Name:           zaatar-branding
Version:        1.0
Release:        1%{?dist}
Summary:        Branding assets for Zaatar Linux
License:        MIT
URL:            https://zaatar.linux
BuildArch:      noarch
Group:          System/Base

Requires:       filesystem

%description
Official branding package for Zaatar Linux 1.0 (Thyme).
Includes os-release, logos, wallpapers, and Plymouth theme files.

# ── Server subpackage ──
%package server
Summary:        Branding assets for Zaatar Linux Server Edition
BuildArch:      noarch

%description server
Server edition branding for Zaatar Linux 1.0 (Thyme).

%prep
# No setup needed

%install
rm -rf %{buildroot}

# os-release
install -Dm0644 %{_sourcedir}/os-release         %{buildroot}/etc/os-release

# Logos
install -Dm0644 %{_sourcedir}/zaatar-logo.png     %{buildroot}/usr/share/pixmaps/zaatar-logo.png
install -Dm0644 %{_sourcedir}/zaatar-logo.svg     %{buildroot}/usr/share/pixmaps/zaatar-logo.svg
install -Dm0644 %{_sourcedir}/zaatar-logo-128.png %{buildroot}/usr/share/icons/hicolor/128x128/apps/zaatar-logo.png
install -Dm0644 %{_sourcedir}/zaatar-logo-64.png  %{buildroot}/usr/share/icons/hicolor/64x64/apps/zaatar-logo.png
install -Dm0644 %{_sourcedir}/zaatar-logo-32.png  %{buildroot}/usr/share/icons/hicolor/32x32/apps/zaatar-logo.png

# Wallpapers
install -Dm0644 %{_sourcedir}/zaatar-wallpaper.jpg        %{buildroot}/usr/share/wallpapers/zaatar/zaatar-wallpaper.jpg
install -Dm0644 %{_sourcedir}/zaatar-wallpaper-dark.jpg   %{buildroot}/usr/share/wallpapers/zaatar/zaatar-wallpaper-dark.jpg

# Plymouth
install -Dm0644 %{_sourcedir}/plymouth/zaatar.plymouth      %{buildroot}/usr/share/plymouth/themes/zaatar/zaatar.plymouth
install -Dm0755 %{_sourcedir}/plymouth/zaatar.script        %{buildroot}/usr/share/plymouth/themes/zaatar/zaatar.script
install -Dm0644 %{_sourcedir}/plymouth/zaatar-logo.png      %{buildroot}/usr/share/plymouth/themes/zaatar/zaatar-logo.png
install -Dm0644 %{_sourcedir}/plymouth/progress_box.png     %{buildroot}/usr/share/plymouth/themes/zaatar/progress_box.png

# GRUB
install -Dm0644 %{_sourcedir}/grub/theme.txt           %{buildroot}/boot/grub2/themes/zaatar/theme.txt
install -Dm0644 %{_sourcedir}/grub/background.png      %{buildroot}/boot/grub2/themes/zaatar/background.png

# KDE
install -Dm0644 %{_sourcedir}/kde/kdeglobals           %{buildroot}/usr/share/kde-settings/kde-profile/default/share/config/kdeglobals
install -Dm0644 %{_sourcedir}/kde/plasma-workspace.conf %{buildroot}/usr/share/kde-settings/kde-profile/default/share/config/plasma-workspace.conf

# Desktop entry
install -Dm0644 %{_sourcedir}/zaatar-about.desktop     %{buildroot}/usr/share/applications/zaatar-about.desktop

# issue / motd
install -Dm0644 %{_sourcedir}/issue                    %{buildroot}/etc/issue
install -Dm0644 %{_sourcedir}/motd                     %{buildroot}/etc/motd

%files
%defattr(-,root,root,-)
/etc/os-release
/etc/issue
/etc/motd
/usr/share/pixmaps/zaatar-logo.png
/usr/share/pixmaps/zaatar-logo.svg
/usr/share/icons/hicolor/128x128/apps/zaatar-logo.png
/usr/share/icons/hicolor/64x64/apps/zaatar-logo.png
/usr/share/icons/hicolor/32x32/apps/zaatar-logo.png
/usr/share/wallpapers/zaatar/
/usr/share/plymouth/themes/zaatar/
/boot/grub2/themes/zaatar/
/usr/share/kde-settings/
/usr/share/applications/zaatar-about.desktop

%files server
%defattr(-,root,root,-)
/etc/os-release
/etc/issue
/etc/motd

%post
# Update icon cache
/bin/touch --no-create /usr/share/icons/hicolor &>/dev/null || :

# Set Plymouth theme
if command -v plymouth-set-default-theme &>/dev/null; then
    plymouth-set-default-theme zaatar -R 2>/dev/null || true
fi

# Update GRUB theme
if [ -f /etc/default/grub ]; then
    sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub2/themes/zaatar/theme.txt"|' /etc/default/grub
    grep -q "GRUB_THEME" /etc/default/grub || echo 'GRUB_THEME="/boot/grub2/themes/zaatar/theme.txt"' >> /etc/default/grub
fi

%postun
if [ $1 -eq 0 ]; then
    /bin/touch --no-create /usr/share/icons/hicolor &>/dev/null || :
fi

%changelog
* Thu Jan 01 2026 Zaatar Developer <dev@zaatar.linux> - 1.0-1
- Initial release of Zaatar Linux 1.0 (Thyme) branding
