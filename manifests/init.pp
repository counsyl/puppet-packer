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
#  The version of Packer to install, defaults to '0.7.1'.
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
  $version   = '0.7.1',
  $bin_dir   = '/usr/local/bin',
  $cache_dir = '/usr/local/packer',
  $base_url  = 'https://dl.bintray.com/mitchellh/packer/',
){
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
        require     => File[$cache_dir],
      }

      # Unzip directly into the binary directory, overwriting previous files.
      exec { 'install-packer':
        command => "${sys::unzip::path} -o ${packer_zip}",
        path    => [$bin_dir, '/usr/bin', '/bin'],
        cwd     => $bin_dir,
        user    => 'root',
        unless  => "test -x packer && packer --version | grep '^Packer v${version}$'",
        require => Sys::Fetch['download-packer'],
      }
    }
    'absent', 'uninstalled': {
      # Ensure the binaries are removed.
      file {["${bin_dir}/packer",
             "${bin_dir}/packer-builder-amazon-chroot",
             "${bin_dir}/packer-builder-amazon-ebs",
             "${bin_dir}/packer-builder-amazon-instance",
             "${bin_dir}/packer-builder-digitalocean",
             "${bin_dir}/packer-builder-docker",
             "${bin_dir}/packer-builder-googlecompute",
             "${bin_dir}/packer-builder-null",
             "${bin_dir}/packer-builder-openstack",
             "${bin_dir}/packer-builder-parallels-iso",
             "${bin_dir}/packer-builder-parallels-pvm",
             "${bin_dir}/packer-builder-qemu",
             "${bin_dir}/packer-packer-builder-qemu",
             "${bin_dir}/packer-builder-virtualbox-iso",
             "${bin_dir}/packer-builder-virtualbox-ovf",
             "${bin_dir}/packer-builder-vmware-iso",
             "${bin_dir}/packer-builder-vmware-ovf",
             "${bin_dir}/packer-builder-vmware-vmx",
             "${bin_dir}/packer-command-build",
             "${bin_dir}/packer-command-fix",
             "${bin_dir}/packer-command-inspect",
             "${bin_dir}/packer-command-validate",
             "${bin_dir}/packer-post-processor-compress",
             "${bin_dir}/packer-post-processor-docker-import",
             "${bin_dir}/packer-post-processor-docker-push",
             "${bin_dir}/packer-post-processor-docker-save",
             "${bin_dir}/packer-post-processor-docker-tag",
             "${bin_dir}/packer-post-processor-vagrant",
             "${bin_dir}/packer-post-processor-vagrant-cloud",
             "${bin_dir}/packer-post-processor-vsphere",
             "${bin_dir}/packer-provisioner-ansible-local",
             "${bin_dir}/packer-provisioner-chef-client",
             "${bin_dir}/packer-provisioner-puppet-server",
             "${bin_dir}/packer-provisioner-chef-solo",
             "${bin_dir}/packer-provisioner-file",
             "${bin_dir}/packer-provisioner-puppet-masterless",
             "${bin_dir}/packer-provisioner-salt-masterless",
             "${bin_dir}/packer-provisioner-shell"
             ]:
               ensure => absent,
      }
    }
    default: {
      fail("Invalid ensure value for packer: ${ensure}.\n")
    }
  }
}
