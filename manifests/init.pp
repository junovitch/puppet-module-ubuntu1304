################################################################################
##  Ubuntu 13.04 Puppet Manifest  ##############################################
################################################################################
# Copyright (C) 2013 Jason Unovitch, jason.unovitch@gmail.com                  #
#   https://github.com/junovitch                                               #
################################################################################
# Redistribution and use in source and binary forms, with or without           #
# modification, are permitted provided that the following conditions are met:  #
#                                                                              #
#    (1) Redistributions of source code must retain the above copyright        #
#    notice, this list of conditions and the following disclaimer.             #
#                                                                              #
#    (2) Redistributions in binary form must reproduce the above copyright     #
#    notice, this list of conditions and the following disclaimer in the       #
#    documentation and/or other materials provided with the distribution.      #
#                                                                              #
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED #
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF         #
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO   #
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,       #
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, #
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;  #
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,     #
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR      #
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF       #
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                                   #
################################################################################
#
# Purpose: Provides a one-stop shop manifest to cover a standard desktop
# configuration on my Ubuntu 13.04 Linux machines. This was my first experience
# learning Puppet for configuration management and it can be broken down to
# be smaller... But it works for me so I'll leave it as is. Feel free to use
# it however you see fit.
#
# Location:
# etc/puppet/modules/ubuntu1304/manifests/init.pp
#
# Prerequisites:
# Get the 'apt' module - `puppet module install puppetlabs/apt`
#
# Also, if you are looking to use this you'll need multiple installer packages
# that cannot be redistributed or you should be getting on your own from the
# trusted source. You'll have to review and update accordingly.
#
# Usage:
# Specify using the module in the site.pp manifest.
#   node mycomputer {
#     include ubuntu1304
#   }
#
# Warnings:
# Currently doesn't check for the PPA to be added before installing a package.
# This will cause an error when it first tries to install a package before
# adding the PPA. It will pick up the PPA and install during the next catalog
# run.
#
# As of writing Google Earth will be manually installed
# from a *.deb package after the first run.  Assuming the files are in place
# on the puppetmaster, they will be downloaded to the host to be installed by
# hand.
#
# cd /usr/local/puppet-pkgs
# dpkg -i google-earth-stable_current_amd64.deb
# apt-get -f install
#
################################################################################


class ubuntu1304 {

  ##############################################################################
  # Set defaults for all Files
  ##############################################################################

  File {
    owner      => root,
    group      => root,
  }

  ##############################################################################
  # Security sensitive and snapshot repositories.  These are always the latest
  # for security reasons or because they change so fast.
  ##############################################################################

  apt::ppa { 'ppa:stebbins/handbrake-snapshots': }
  package { [
      'firefox',
      'google-chrome-stable',
      'handbrake-cli', 'handbrake-gtk',
      'icedtea-plugin', 'icedtea-7-plugin', 'openjdk-7-jre',
      'skype',
      'thunderbird',
      'ubuntu-restricted-addons', 'ubuntu-restricted-extras', ]:
    ensure     => latest,
  }

  ##############################################################################
  # General Security tools
  ##############################################################################

  package { [
      'apparmor-profiles',
      'bleachbit',
      'chkrootkit',
      'clamav', 'clamtk',
      'ecryptfs-utils',
      'fail2ban',
      'gufw',
      'hping3',
      'kismet',
      'nmap',
      'openvpn',
      'putty',
      'sockstat',
      'tshark',
      'wireshark', 'wireshark-doc', ]:
    ensure     => installed,
  }

  ##############################################################################
  # Encfs Home directory support
  # http://wiki.debian.org/TransparentEncryptionForHomeFolder
  ##############################################################################

  package { [ 'fuse', 'encfs', 'libpam-encfs', 'libpam-mount', ]:
    ensure     => installed,
  }
  file { '/etc/fuse.conf':
    source     => 'puppet:///modules/ubuntu1304/common/etc/fuse.conf',
    group      => fuse,
    mode       => '0640',
    require    => Package['fuse'],
  }
  file { '/etc/security/pam_env.conf':
    source     => 'puppet:///modules/ubuntu1304/common/etc/security/pam_env.conf',
    mode       => '0644',
    require    => [ Package['libpam-encfs'], Package['encfs'] ],
  }
  file { '/etc/security/pam_encfs.conf':
    source     => 'puppet:///modules/ubuntu1304/common/etc/security/pam_encfs.conf',
    mode       => '0644',
    require    => [ Package['libpam-encfs'], Package['encfs'] ],
  }
  file { '/etc/pam.d/common-session':
    source     => 'puppet:///modules/ubuntu1304/common/etc/pam.d/common-session',
    mode       => '0644',
    require    => [ Package['libpam-encfs'], Package['encfs'] ],
  }

  ##############################################################################
  # Games
  ##############################################################################

  package { [
      'playonlinux',
      'openttd', 'openttd-opensfx', ]:
    ensure     => installed,
  }

  ##############################################################################
  # Steam + Dependencies
  ##############################################################################

  package { [ 'curl', 'jockey-common', 'nvidia-common', 'python-xkit', ]:
    ensure     => installed,
  }
  package { 'steam-launcher':
    ensure     => installed,
    provider   => dpkg,
    source     => '/usr/local/puppet-pkgs/steam.deb',
    require    => [ Package['curl'], Package['jockey-common'],
      Package['nvidia-common'], Package['python-xkit'],
      File['/usr/local/puppet-pkgs'] ],
  }

  ##############################################################################
  # Photography Applications
  ##############################################################################

  package { [
      'gimp', 'gimp-data', 'gimp-data-extras', 'gimp-help-en',
      'hugin',
      'mypaint',
      'pandora',
      'pinta',
      'shotwell', ]:
    ensure     => installed,
  }

  ##############################################################################
  # System Apps
  ##############################################################################

  apt::ppa { 'ppa:danielrichter2007/grub-customizer': }
  package { [
      'blueman',
      'clusterssh',
      'etherwake', 'wakeonlan',
      'gconf-editor',
      'gddrescue',
      'gparted',
      'grub-customizer',
      'htop',
      'preload',
      'remmina',
      'synaptic',
      'tcsh',
      'terminator',
      'traceroute',
      'tmux',
      'zsh', 'zsh-doc', ]:
    ensure     => installed,
  }

  ##############################################################################
  # Development Tools and Applications
  ##############################################################################

  package { [
      'build-essential',
      'byobu',
      'bzr', 'bzr-explorer', 'bzr-git',
      'charm-tools', 'charm-helper-sh',
      'check',
      'checkinstall',
      'cdbs',
      'devscripts',
      'dh-make',
      'eclipse',
      'fakeroot',
      'geany', 'geany-plugins',
      'git', 'git-core',
      'juju',
      'kexec-tools',
      'meld',
      'perl-tk',
      'qtcreator',
      'quickly',
      'subversion',
      'sharutils',
      'uudeview',
      'vim', 'vim-gnome', 'vim-doc', 'vim-scripts', 'vim-latexsuite', ]:
    ensure     => installed,
  }

  ##############################################################################
  # BlackBerry tools
  ##############################################################################

  package { 'barrydesktop':
    ensure     => installed,
  }

  ##############################################################################
  # HPLIP Printer Tools
  ##############################################################################

  package { 'hplip-gui':
    ensure     => installed,
  }

  ##############################################################################
  # Smartcard Support
  ##############################################################################

  package { [ 'libpcsclite1', 'pcscd', 'pcsc-tools', ]:
    ensure     => installed,
  }

  ##############################################################################
  # Media Players
  ##############################################################################

  apt::ppa { 'ppa:ehoover/compholio': }
  package { [
      'banshee', 'banshee-extension-ampache',
      'netflix-desktop',
      'vlc', ]:
    ensure     => installed,
  }

  ##############################################################################
  # Audio Tools
  ##############################################################################

  package { [
      'audacity',
      'icedax',
      'id3tool', 'id3v2',
      'pavucontrol',
      'sox',
      'tagtool', ]:
    ensure     => installed,
  }

  ##############################################################################
  # Video Tools
  ##############################################################################

  package { [
      'blender',
      'cheese',
      'devede',
      'openshot', 'openshot-doc',
      'mkvtoolnix', 'mkvtoolnix-gui', ]:
    ensure     => installed,
  }

  ##############################################################################
  # Web Applications & Tools
  ##############################################################################

  package { ['bluefish', 'clamz', 'mpack', ]:
    ensure     => installed,
  }

  ##############################################################################
  # Web Communication Apps
  ##############################################################################

  package { [ 'pidgin', 'pidgin-otr', 'pidgin-encryption', ]:
    ensure     => installed,
  }

  ##############################################################################
  # Virtualization
  ##############################################################################

  package { [ 'virtualbox-qt', 'virtualbox-guest-additions-iso', 'gns3', ]:
    ensure     => installed,
  }

  ##############################################################################
  # Document tools
  ##############################################################################

  package { [ 'lyx', 'pdfshuffler', ]:
    ensure     => installed,
  }

  ##############################################################################
  # Desktop Apps
  ##############################################################################

  package { [ 'conky-all', 'gtk-redshift', 'wbar', ]:
    ensure     => installed,
  }

  ##############################################################################
  # Google Earth
  ##############################################################################

  package { [ 'lsb-core', 'google-earth-stable', ]:
    ensure     => installed,
  }

  ##############################################################################
  # General File Manipulation Tools
  ##############################################################################

  package { [
      'cabextract',
      'mdbtools', 'mdbtools-doc', 'mdbtools-gmdb',
      'p7zip-full',
      'rar', 'unrar',
      'zip', 'unzip', ]:
    ensure     => installed,
  }

  ##############################################################################
  # Codecs and build library requirements for MakeMKV
  # Notes for Blu-ray:  http://vlc-bluray.whoknowsmy.name/
  ##############################################################################

  package { [
      'faac',
      'flac',
      'lame',
      'libc6-dev',
      'libexpat1-dev',
      'libgl1-mesa-dev',
      'libssl-dev',
      'libqt4-dev',
      'libmad0',
      'libquicktime2',
      'totem-mozilla', ]:
    ensure     => installed,
  }
  file { '/usr/lib64/libaacs.so.0':
    source     => 'puppet:///modules/ubuntu1304/common/usr/lib64/libaacs.so.0',
    mode       => '0644',
    require    => File['/usr/lib64'],
  }
  file { '/etc/skel/.config':
    ensure     => directory,
    mode       => '0755',
  }
  file { '/etc/skel/.config/aacs':
    ensure     => directory,
    recurse    => true,
    purge      => true,
    mode       => '0755',
    source     => 'puppet:///modules/ubuntu1304/common/etc/skel/.config/aacs',
    require    => File['/etc/skel/.config'],
  }

  ##############################################################################
  # Alternate Desktops
  ##############################################################################

  package { [ 'cinnamon', 'kde-standard', 'xfce4', ]:
    ensure     => installed,
  }
  package { [ 'unity', 'unity-tweak-tool', ]:
    ensure     => installed,
  }
  package { 'unity-lens-shopping':
    ensure     => absent,
  }

  ##############################################################################
  # OpenSSH Server, Unison, and associated configurations
  ##############################################################################

  package { [
      'openssh-server',
      'openssh-blacklist',
      'openssh-blacklist-extra',
      'ssh-import-id',
      'unison', 'unison-gtk', ]:
    ensure     => installed,
  }
  file { '/etc/ssh/sshd_config':
    source     => 'puppet:///modules/ubuntu1304/common/etc/ssh/sshd_config',
    mode       => '0640',
    notify     => Service['ssh'],
    require    => Package['openssh-server'],
  }
  file { '/root/.ssh':
    ensure     => directory,
    mode       => '0700',
  }
  file { '/root/.ssh/authorized_keys':
    source     => 'puppet:///modules/ubuntu1304/common/root/.ssh/authorized_keys',
    mode       => '0600',
    require    => File['/root/.ssh'],
  }
  file { '/root/.ssh/id_ecdsa':
    source     => "puppet:///modules/ubuntu1304/common/root/.ssh/${hostname}-id_ecdsa",
    mode       => '0600',
    require    => File['/root/.ssh'],
  }
  file { '/root/.ssh/id_ecdsa.pub':
    source     => "puppet:///modules/ubuntu1304/common/root/.ssh/${hostname}-id_ecdsa.pub",
    mode       => '0644',
    require    => File['/root/.ssh'],
  }
  file { '/root/.unison':
    ensure     => directory,
    mode       => '0755',
  }
  file { '/root/.unison/accountSync.prf':
    source     => 'puppet:///modules/ubuntu1304/common/root/.unison/accountSync.prf',
    mode       => '0644',
    require    => File['/root/.unison'],
  }
  file { '/etc/cron.daily/accountSync.sh':
    mode       => '0755',
    source     => 'puppet:///modules/ubuntu1304/common/etc/cron.daily/accountSync.sh',
  }
  service { 'ssh':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  ##############################################################################
  # NFS client and Autofs with associated configurations
  ##############################################################################

  package { [ 'nfs-common', 'autofs', ]:
    ensure     => installed,
  }
  file { '/etc/idmapd.conf':
    mode       => '0644',
    source     => 'puppet:///modules/ubuntu1304/common/etc/idmapd.conf',
    notify     => Service['idmapd'],
    require    => Package['nfs-common'],
  }
  service { 'idmapd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
  file { '/etc/default/nfs-common':
    mode       => '0644',
    source     => 'puppet:///modules/ubuntu1304/common/etc/default/nfs-common',
    require    => Package['nfs-common'],
  }

  ##############################################################################
  # User Avatar Photos (purge => false to just put avatars in place)
  ##############################################################################

  file { '/var/lib/AccountsService':
    ensure     => directory,
    recurse    => true,
    purge      => false,
    mode       => '0644',
    source     => 'puppet:///modules/ubuntu1304/common/var/lib/AccountsService',
  }

  ##############################################################################
  # Scripts present on all systems
  ##############################################################################

  file { '/usr/local/bin':
    ensure     => directory,
    recurse    => true,
    purge      => false,
    source     => 'puppet:///modules/ubuntu1304/common/usr/local/bin',
    mode       => '0755',
  }

  ##############################################################################
  # LightDM conf to set Cinnamon as default and make login/logout scripts hot
  ##############################################################################

  file { '/etc/lightdm/lightdm.conf':
    mode       => '0644',
    source     => 'puppet:///modules/ubuntu1304/common/etc/lightdm/lightdm.conf',
    require    => [ File['/usr/local/bin'], Package['cinnamon'] ],
  }

  ##############################################################################
  # Local puppet installation files
  ##############################################################################

  file { '/usr/local/puppet-pkgs':
    ensure     => directory,
    recurse    => true,
    purge      => true,
    mode       => '0755',
    source     => 'puppet:///modules/ubuntu1304/common/usr/local/puppet-pkgs',
  }

  ##############################################################################
  # Keep /tmp in RAM
  ##############################################################################

  mount { '/tmp':
    ensure     => mounted,
    atboot     => true,
    device     => 'none',
    fstype     => 'tmpfs',
    options    => 'rw,nosuid,nodev,mode=01777',
  }

  ##############################################################################
  # CACKEY installation files and directory prerequisites
  ##############################################################################

  file { '/usr/lib64':
    ensure     => directory,
    mode       => '0755',
  }
  package { 'cackey':
    ensure     => latest,
    provider   => dpkg,
    source     => '/usr/local/puppet-pkgs/cackey_0.6.5-1_amd64.deb',
    require    => [ File['/usr/lib64'], File['/usr/local/puppet-pkgs'] ],
  }

  ##############################################################################
  # SCM Smart Card Drivers in place
  ##############################################################################

  file { '/usr/local/scm':
    ensure     => directory,
    recurse    => true,
    purge      => true,
    source     => 'puppet:///modules/ubuntu1304/common/usr/local/scm',
  }

  file { '/usr/local/pcsc':
    ensure     => directory,
    recurse    => true,
    purge      => true,
    source     => 'puppet:///modules/ubuntu1304/common/usr/local/pcsc',
  }

  file { '/usr/local/lib/pcsc':
    ensure     => directory,
    recurse    => true,
    purge      => true,
    source     => 'puppet:///modules/ubuntu1304/common/usr/local/lib/pcsc',
  }

  ##############################################################################
  # Truecrypt binary and support files in place
  ##############################################################################

  file { '/usr/bin/truecrypt':
    source     => 'puppet:///modules/ubuntu1304/common/usr/bin/truecrypt',
    mode       => '0755',
  }

  file { '/usr/bin/truecrypt-uninstall.sh':
    source     => 'puppet:///modules/ubuntu1304/common/usr/bin/truecrypt-uninstall.sh',
    mode       => '0754',
  }

  file { '/usr/share/applications/truecrypt.desktop':
    source     => 'puppet:///modules/ubuntu1304/common/usr/share/applications/truecrypt.desktop',
    mode       => '0644',
  }

  file { '/usr/share/pixmaps/truecrypt.xpm':
    source     => 'puppet:///modules/ubuntu1304/common/usr/share/pixmaps/truecrypt.xpm',
    mode       => '0644',
  }

  file { '/usr/share/truecrypt':
    ensure     => directory,
    recurse    => true,
    purge      => true,
    mode       => '0644',
    source     => 'puppet:///modules/ubuntu1304/common/usr/share/truecrypt',
  }
}

class ubuntu1304::devel {

  ##############################################################################
  # Development Stuff only
  ##############################################################################

}

class ubuntu1304::silverstone {

  ##############################################################################
  # Silverstone Specific
  ##############################################################################

  apt::ppa { 'ppa:zfs-native/stable': }
  package { 'ubuntu-zfs':
    ensure     => installed,
  }

  apt::ppa { 'ppa:happy-neko/ps3mediaserver': }
  package { 'ps3mediaserver':
    ensure     => installed,
  }
  file { '/etc/default/ps3mediaserver':
    mode       => '0644',
    source     => 'puppet:///modules/ubuntu1304/silverstone/etc/default/ps3mediaserver',
    notify     => Service['ps3mediaserver'],
    require    => Package['ps3mediaserver'],
  }
  file { '/etc/skel/.config/ps3mediaserver/PMS.conf':
    mode       => '0644',
    source     => 'puppet:///modules/ubuntu1304/silverstone/etc/skel/.config/ps3mediaserver/PMS.conf',
    require    => Package['ps3mediaserver'],
  }
  group { 'ps3mediaserver':
    ensure     => present,
    system     => true,
    require    => Package['ps3mediaserver'],
  }
  user { 'ps3mediaserver':
    ensure     => present,
    system     => true,
    gid        => 'ps3mediaserver',
    password   => '*',
    shell      => '/bin/false',
    home       => '/home/ps3mediaserver',
    comment    => 'PS3 Media Server User,,,',
    managehome => true,
    require    => [ Group['ps3mediaserver'],
      File['/etc/skel/.config/ps3mediaserver/PMS.conf'],
      File['/etc/default/ps3mediaserver'] ],
  }
  service { 'ps3mediaserver':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => User['ps3mediaserver'],
  }

  package { 'boinc':
    ensure     => installed,
  }

  file { '/etc/cron.daily/rollingsnap':
    mode       => '0755',
    source     => 'puppet:///modules/ubuntu1304/silverstone/etc/cron.daily/rollingsnap',
  }
}

class ubuntu1304::withautofs {

  ##############################################################################
  # Coolermaster Specific
  ##############################################################################

  file { '/etc/auto.master':
    mode       => '0644',
    source     => 'puppet:///modules/ubuntu1304/withautofs/etc/auto.master',
    notify     => Service['autofs'],
    require    => Package['autofs'],
  }

  file { '/etc/auto.home':
    mode       => '0644',
    source     => 'puppet:///modules/ubuntu1304/withautofs/etc/auto.home',
    notify     => Service['autofs'],
    require    => Package['autofs'],
  }

  service { 'autofs':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}

class ubuntu1304::withopenvpn {

  ##############################################################################
  # Include OpenVPN configuration Template
  ##############################################################################

  file { '/etc/openvpn/ca.crt':
    source     => 'puppet:///modules/ubuntu1304/common/etc/openvpn/ca.crt',
    mode       => '0644',
    require    => Package['openvpn'],
  }
  file { '/etc/openvpn/ta.key':
    source     => 'puppet:///modules/ubuntu1304/common/etc/openvpn/ta.key',
    mode       => '0600',
    require    => Package['openvpn'],
  }
  file { "/etc/openvpn/${hostname}.crt":
    source     => "puppet:///modules/ubuntu1304/common/etc/openvpn/${hostname}.crt",
    mode       => '0644',
    require    => Package['openvpn'],
  }
  file { "/etc/openvpn/${hostname}.key":
    source     => "puppet:///modules/ubuntu1304/common/etc/openvpn/${hostname}.key",
    mode       => '0600',
    require    => Package['openvpn'],
  }
  file { '/etc/openvpn/unovpn.conf':
    content    => template('ubuntu1304/etc/openvpn/unovpn.conf.erb'),
    mode       => '0600',
    require    => [ Package['openvpn'],
      File["/etc/openvpn/${hostname}.crt"],
      File["/etc/openvpn/${hostname}.key"] ],
  }
}
