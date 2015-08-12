# == Class: packer
#
# Installs Packer, the modern automated machine image creation tool.
#
# === Parameters
#
# [*ensure*]
#  Defaults to 'installed', if set to 'absent' will remove Packer.
#
# [*version*]
#  The version of Packer to install, defaults to '0.8.5'.
#
# [*bin_dir*]
#  The binary directory to place Packer in.  Defaults to '/usr/local/bin'.
#
# [*cache_dir*]
#  The directory to cache Packer release archives in.  Defaults to
#  '/usr/local/packer'.
#
# [*base_url*]
#  The base download URL to retrieve Packer from, including a
#  a trailing '/'.  Defaults to: 'https://dl.bintray.com/mitchellh/packer/'.
#
class packer(
  $ensure    = 'installed',
  $version   = '0.8.5',
  $bin_dir   = '/usr/local/bin',
  $cache_dir = '/usr/local/packer',
  $base_url  = 'https://dl.bintray.com/mitchellh/packer/',
){
  validate_re($version, '^\d+\.\d+\.\d+$')
  validate_absolute_path([$bin_dir, $cache_dir])

  case $ensure {
    'present', 'installed': {
      # Need parameters from sys and unzip installed.
      include sys
      include sys::unzip

      if $::architecture in ['x86_64', 'amd64', 'x64'] {
        $arch = 'amd64'
      } else {
        $arch = '386'
      }

      if versioncmp($version, '0.7.0') >= 0 {
        $prefix = 'packer_'
      } else {
        $prefix = ''
      }

      # Escape periods in version for grep check.
      $version_escaped = join(split($version, '\.'), '\.')

      # In 0.8.0+ the `--version` option now works properly, and doesn't make
      # a network query for latest version like `packer version` does.
      if versioncmp($version, '0.8.0') >= 0 {
        $version_check = "packer --version | grep '^${version_escaped}$'"
      } else {
        $version_check = "packer version | grep '^Packer v${version_escaped}'"
      }

      $packer_basename = inline_template(
        "<%= \"#{@prefix}#{@version}_#{scope['::kernel'].downcase}_#{@arch}.zip\" %>"
      )

      $packer_zip = "${cache_dir}/${packer_basename}"
      $packer_url = "${base_url}${packer_basename}"

      # Ensure cache directory for Packer's zip archives exists.
      file { $cache_dir:
        ensure => directory,
        owner  => 'root',
        group  => $sys::root_group,
        mode   => '0644',
      }

      # Download the Packer zip archive to the cache.
      sys::fetch { 'download-packer':
        destination => $packer_zip,
        source      => $packer_url,
        cert_check  => true,
        require     => File[$cache_dir],
      }

      # Unzip directly into the binary directory, overwriting previous files.
      exec { 'install-packer':
        command => "${sys::unzip::path} -o ${packer_zip}",
        path    => [$bin_dir, '/usr/bin', '/bin'],
        cwd     => $bin_dir,
        user    => 'root',
        unless  => "test -x packer && ${version_check}",
        require => Sys::Fetch['download-packer'],
      }
    }
    'absent', 'uninstalled': {
      # Ensure the binaries are removed.
      $binaries = prefix(
        [
          'packer',
          'packer-builder-amazon-chroot',
          'packer-builder-amazon-ebs',
          'packer-builder-amazon-instance',
          'packer-builder-digitalocean',
          'packer-builder-docker',
          'packer-builder-file',
          'packer-builder-googlecompute',
          'packer-builder-null',
          'packer-builder-openstack',
          'packer-builder-parallels-iso',
          'packer-builder-parallels-pvm',
          'packer-builder-qemu',
          'packer-builder-virtualbox-iso',
          'packer-builder-virtualbox-ovf',
          'packer-builder-vmware-iso',
          'packer-builder-vmware-vmx',
          'packer-post-processor-artifice',
          'packer-post-processor-atlas',
          'packer-post-processor-compress',
          'packer-post-processor-docker-import',
          'packer-post-processor-docker-push',
          'packer-post-processor-docker-save',
          'packer-post-processor-docker-tag',
          'packer-post-processor-vagrant',
          'packer-post-processor-vagrant-cloud',
          'packer-post-processor-vsphere',
          'packer-provisioner-ansible-local',
          'packer-provisioner-chef-client',
          'packer-provisioner-chef-solo',
          'packer-provisioner-file',
          'packer-provisioner-powershell',
          'packer-provisioner-puppet-masterless',
          'packer-provisioner-puppet-server',
          'packer-provisioner-salt-masterless',
          'packer-provisioner-shell',
          'packer-provisioner-shell-local',
          'packer-provisioner-windows-restart',
          'packer-provisioner-windows-shell',
        ],
        "${bin_dir}/"
      )

      file { $binaries:
        ensure => absent,
        backup => false,
      }
    }
    default: {
      fail("Invalid ensure value for packer: ${ensure}.\n")
    }
  }
}
