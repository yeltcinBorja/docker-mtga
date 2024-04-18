#	My attempt at building an ArchLinux Image with Wine to Play MTGA

# 	Set base image
FROM archlinux:base

# 	MultiLib Library for Wine
RUN echo "[multilib]" >> /etc/pacman.conf \
	&& echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

# 	Update Mirror List to AU, Upgrade Pacman DB & Do full upgrade
RUN rm /etc/pacman.d/mirrorlist \
	&& touch /etc/pacman.d/mirrorlist \
	&& echo "Server = http://archlinux.mirror.digitalpacific.com.au/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist \
	&& echo "Server = https://archlinux.mirror.digitalpacific.com.au/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist \
	&& echo "Server = https://sydney.mirror.pkgbuild.com/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist \
	&& pacman-db-upgrade \
	&& pacman -Syyu --noconfirm

# 	Pacman to install additional packages + Wine + PulseAudio
RUN pacman -S \
	wget \
	bash-completion \
	mesa-utils \
	jq \
	wine \
	winetricks \
	sudo \
	pulseaudio \
	--noconfirm

# 	Create user mtga, allow sudo
RUN useradd -m -s /bin/bash mtga \
	&& echo "mtga ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# 	--------------- Done Under mtga User ---------------
USER mtga
WORKDIR /home/mtga

#	Set ENV for new Wine Installation
ENV WINEARCH win64
ENV WINEPREFIX /home/mtga/.wine64_new

#	Download latest MSI of the MTGA Installer
RUN curl -s https://mtgarena.downloads.wizards.com/Live/Windows64/version | jq -r ".CurrentInstallerURL" > /tmp/mtga \
	&& wget `cat /tmp/mtga` \
	&& rm /tmp/mtga

#	Download wine-mono Version 7.4 as per wineHQ recommendations/workaround (https://appdb.winehq.org/objectManager.php?sClass=version&iId=37229)
RUN wget 'https://dl.winehq.org/wine/wine-mono/7.4.0/wine-mono-7.4.0-x86.msi'

#	Additional dlls and regkeys as per Lutris Install Script (https://lutris.net/games/magic-the-gathering-arena/)
RUN winetricks -q dotnet48 \
	&& winetricks -q arial d3dcompiler_47 win10 msxml3 nocrashdialog \
	&& wine reg ADD 'HKEY_CURRENT_USER\Software\Wine\X11 Driver' /v UseTakeFocus /d 'N' /f \
	&& wine reg ADD 'HKEY_CURRENT_USER\Software\Wine\X11 Driver' /v GrabFullscreen /d 'Y' /f

# Initialize Wine then Install wine-mono & MTGA
RUN wineboot -i
RUN wine msiexec /i wine-mono-7.4.0-x86.msi \
	&& wine msiexec /i MTGAInstaller* \
	&& wineboot -r

#	Remove MSI files
RUN rm MTGAInstaller* \
	&& rm wine-mono-7.4.0-x86.msi

#	Switch to the MTGA directory
WORKDIR /home/mtga/.wine64_new/drive_c/Program\ Files/Wizards\ of\ the\ Coast/MTGA/