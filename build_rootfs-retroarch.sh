packages=(
	# Basics
	base
	linux-firmware
	linux
	linux-headers
	intel-ucode
	amd-ucode

	# ostree-related
	efibootmgr
	grub
	ostree
	which

	# Useful filesystem and partitioning utils
	btrfs-progs
	cryptsetup
	dosfstools
	lvm2
	xfsprogs

	# Security
	apparmor
	sudo

	# Utilities
	bash-completion
	man-db
	neovim
	tmux
	usbutils

	# Containers
	podman
	toolbox

	# GPU
	glxinfo
	vulkan-icd-loader
	vulkan-intel
	vulkan-radeon
	vulkan-tools

	# Networking
	networkmanager

	# Bluetooth
	bluez
	bluez-utils

	fwupd

	retroarch
	retroarch-assets-xmb
	retroarch-assets-ozone
)

prepare() {
	install -d "$rootfs/etc"
	install -m 0644 files/mkinitcpio-retroarch.conf "$rootfs/etc/mkinitcpio.conf"
	install -m 0644 files/vconsole.conf "$rootfs/etc/"

	install -d "$rootfs/etc/systemd/network-initramfs"
	install -m 0644 files/20-wired.network "$rootfs/etc/systemd/network-initramfs/"
}

post_install_early() {
	echo 'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' > /etc/pacman.d/mirrorlist
	pacman-key --init
	pacman-key --populate
}

post_install() {
	mkdir /efi

	ln -sf /usr/share/zoneinfo/UTC /etc/localtime
	sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen

	sed -i 's/^#\(write-cache\)/\1/' /etc/apparmor/parser.conf

	echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

	locale-gen
	systemctl enable apparmor.service
	systemctl enable bluetooth.service
	systemctl enable fwupd.service
	systemctl enable NetworkManager.service
	systemctl enable sshd.service
	systemctl enable systemd-timesyncd.service
}
