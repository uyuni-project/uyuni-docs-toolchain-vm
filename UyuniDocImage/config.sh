#!/bin/bash
# Copyright (c) 2019 SUSE LLC
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

mkdir /var/lib/misc/reconfig_system

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$name]..."

#======================================
# add missing fonts
#--------------------------------------
CONSOLE_FONT="eurlatgr.psfu"

#======================================
# prepare for setting root pw, timezone
#--------------------------------------
echo ** "reset machine settings"

# FIXME: 
#sed -i 's/^root:[^:]*:/root:*:/' /etc/shadow
rm -f /etc/machine-id \
      /var/lib/zypp/AnonymousUniqueId \
      /var/lib/systemd/random-seed \
      /var/lib/dbus/machine-id

#======================================
# SuSEconfig
#--------------------------------------
echo "** Running suseConfig..."
suseConfig

echo "** Running ldconfig..."
/sbin/ldconfig

#======================================
# Setup baseproduct link
#--------------------------------------
suseSetupProduct

#======================================
# Specify default runlevel
#--------------------------------------
baseSetRunlevel 5

#======================================
# Add missing gpg keys to rpm
#--------------------------------------
suseImportBuildKey

#======================================
# Enable DHCP on eth0
#--------------------------------------
cat >/etc/sysconfig/network/ifcfg-eth0 <<EOF
BOOTPROTO='dhcp'
MTU=''
REMOTE_IPADDR=''
STARTMODE='auto'
ETHTOOL_OPTIONS=''
USERCONTROL='no'
EOF

#======================================
# Enable sshd
#--------------------------------------
chkconfig sshd on

#======================================
# Remove doc files
#--------------------------------------
baseStripDocs

#======================================
# Sysconfig Update
#--------------------------------------
echo '** Update sysconfig entries...'

baseUpdateSysConfig /etc/sysconfig/network/dhcp DHCLIENT_SET_HOSTNAME yes

# Enable firewalld
chkconfig firewalld on

# Set GRUB2 to boot graphically (bsc#1097428)
sed -Ei"" "s/#?GRUB_TERMINAL=.+$/GRUB_TERMINAL=gfxterm/g" /etc/default/grub
sed -Ei"" "s/#?GRUB_GFXMODE=.+$/GRUB_GFXMODE=auto/g" /etc/default/grub

# On UEFI machines use linuxefi entries
echo 'GRUB_USE_LINUXEFI="true"' >> /etc/default/grub

# Systemd controls the console font now
echo FONT="$CONSOLE_FONT" >> /etc/vconsole.conf

#======================================
# SSL Certificates Configuration
#--------------------------------------
echo '** Rehashing SSL Certificates...'
update-ca-certificates

if [ ! -s /var/log/zypper.log ]; then
	> /var/log/zypper.log
fi

# only for debugging
#systemctl enable debug-shell.service

systemd-machine-id-setup

# Doc tools #

npm i -g @antora/cli@2.2 @antora/site-generator-default@2.2
npm i -g antora-site-generator-lunr

su uyuni -c "
cd /home/uyuni
git clone https://github.com/rbenv/rbenv.git .rbenv
echo 'export PATH=\"/home/uyuni/.rbenv/bin:\$PATH\"' >> .bashrc
echo 'eval \"\$(rbenv init -)\"' >> ~/.bashrc
source ~/.bashrc
git clone https://github.com/rbenv/ruby-build.git .rbenv/plugins/ruby-build
rbenv install -l
rbenv install 2.6.6
rbenv global 2.6.6
ruby -v
gem install asciidoctor
gem install asciidoctor-pdf --pre
gem install rouge coderay rb-pygments concurrent-ruby asciidoctor-diagram
gem install prawn-gmagick
git clone https://github.com/uyuni-project/uyuni-docs.git
"

############
baseCleanMount

exit 0
