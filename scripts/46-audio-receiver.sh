#!/bin/bash
export LIBRESPOT_NAME=${1:-"Neon Mark 2"}
# Raspotify installation script
apt-get -y install curl && curl -sL https://dtcooper.github.io/raspotify/install.sh -o install.sh
## Sudo causes issues in build VM, so strip it out
sed -i '/SUDO="sudo"/c\SUDO=""' install.sh
sh install.sh
# Adjust the service file to wait for the network to be online and for avahi-daemon to be running
sed -i '/^Wants=network.target sound.target$/c\Wants=network-online.target sound.target avahi-daemon.service ntp.service' /lib/systemd/system/raspotify.service
sed -i '/^After=network.target sound.target$/c\After=network-online.target sound.target avahi-daemon.service ntp.service' /lib/systemd/system/raspotify.service
# Name the device for Spotify
sed -i '/LIBRESPOT_NAME/c\LIBRESPOT_NAME="Neon Mark 2"' /etc/raspotify/conf
# Set up Bluetooth audio permissions
usermod -aG bluetooth pulse
# Enable all services
systemctl enable uxplay.service
systemctl enable kdeconnect.service
systemctl enable bluetooth.service
systemctl enable raspotify.service
systemctl enable update_bt_config.service

# Fix permissions
chown -R neon:neon /home/neon/.cache
chmod +x /opt/neon/*.sh

# Install packages for Bluetooth pairing script
# TODO: Python packages to NeonCore dependencies(?)
if [ -e /home/neon/venv/bin/python ]; then
  /home/neon/venv/bin/python -m pip install /home/neon/.cache/pip/wheels/5a/83/f3/aa5c753e241ee76cc586065f88f0e750c9bb370c181f1ab40a/PyBluez-0.23-cp310-cp310-linux_aarch64.whl
  /home/neon/venv/bin/python -m pip install /home/neon/.cache/pip/wheels/33/99/2c/061d0c6934509a9cc08470980d68fbfc972bd22a45c3f306d6/PyGObject-3.44.1-cp310-cp310-linux_aarch64.whl
fi