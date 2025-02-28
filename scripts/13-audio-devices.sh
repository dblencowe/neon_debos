#!/bin/bash
# NEON AI (TM) SOFTWARE, Software Development Kit & Application Framework
# All trademark and other rights reserved by their respective owners
# Copyright 2008-2022 Neongecko.com Inc.
# Contributors: Daniel McKnight, Guy Daniels, Elon Gasper, Richard Leeds,
# Regina Bloomstine, Casimiro Ferreira, Andrii Pernatii, Kirill Hrymailo
# BSD-3 License
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
# OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE,  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Set to exit on error
set -Ee

# Configure user permissions
usermod -aG pulse root
usermod -aG pulse-access root
usermod -aG gpio root

# Disable userspace pulseaudio services
systemctl --global disable pulseaudio.service pulseaudio.socket


# Build and install tinyalsa
cd /tmp
git clone https://github.com/tinyalsa/tinyalsa
cd tinyalsa
make
make install
ldconfig
rm -rf /tmp/tinyalsa

# Clone and install ovos-i2csound
cd /tmp
git clone https://github.com/openvoiceos/ovos-i2csound
cd ovos-i2csound && git checkout 9f45e51
cd ..

cp ovos-i2csound/i2c.conf /etc/modules-load.d/
cp ovos-i2csound/ovos-i2csound /usr/libexec/
cp ovos-i2csound/99-i2c.rules /usr/lib/udev/rules.d/
rm -r ovos-i2csound

# Ensure execute permissions
chmod -R ugo+x /usr/libexec

# Enable system services
systemctl enable pulseaudio.service
systemctl enable configure-audio.service

# Ensure default config is removed
rm /etc/pulse/daemon.conf || echo "No daemon.conf to remove"
rm /etc/pulse/system.pa || echo "No system.pa to remove"

echo "Pulseaudio Setup Complete"
