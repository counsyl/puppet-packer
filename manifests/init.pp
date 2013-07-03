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
#  The version of Packer to install, defaults to '0.1.4'.
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
  $version   = '0.1.4',
  $bin_dir   = '/usr/local/bin',
  $cache_dir = '/usr/local/packer',
  $base_url  = 'https://dl.bintray.com/mitchellh/packer/',
){
  case $ensure {
    'present', 'installed': {
      # Need parameters from sys and unzip installed.
      include sys
      include sys::unzip

      if $::architecture in ['x86_64', 'amd64'] {
        $arch = 'amd64'
      } else {
        $arch = '386'
      }

      $packer_basename = inline_template(
        "<%= \"#{@version}_#{scope.lookupvar('::kernel').downcase}_#{@arch}.zip\" %>"
      )
      $packer_zip = "${cache_dir}/${packer_basename}"
      $packer_url = "${base_url}${packer_basename}"

      # Determining what command we need to download.
      case $::kernel {
        darwin: {
          $dl_cmd = '/usr/bin/curl -L -O'
        }
        linux, openbsd: {
          include sys::wget
          $dl_cmd = "${sys::wget::path} -q"
          Class['sys::wget'] -> Exec['download-packer']
        }
        default: {
          fail("Do not know how to install Packer on ${::kernel}\n.")
        }
      }

      # Ensure cache directory for Packer's zip archives exists.
      file { $cache_dir:
        ensure => directory,
        owner  => 'root',
        group  => $sys::root_group,
        mode   => '0644',
      }

      # Download the Packer zip archive to the cache.
      exec { 'download-packer':
        command => "${dl_cmd} ${packer_url}",
        cwd     => $cache_dir,
        user    => 'root',
        creates => $packer_zip,
        require => File[$cache_dir],
      }

      # Unzip directly into the binary directory, overwriting previous files.
      exec { 'install-packer':
        command => "${sys::unzip::path} -o ${packer_zip}",
        path    => [$bin_dir, '/usr/bin', '/bin'],
        cwd     => $bin_dir,
        user    => 'root',
        unless  => "test -x packer && packer --version | grep '^Packer v${version}$'",
        require => Exec['download-packer'],
      }
    }
    'absent', 'uninstalled': {
      # Ensure the binaries are removed.
      file {["${bin_dir}/packer",
             "${bin_dir}/packer-builder-amazon-ebs",
             "${bin_dir}/packer-builder-digitalocean",
             "${bin_dir}/packer-builder-virtualbox",
             "${bin_dir}/packer-builder-vmware",
             "${bin_dir}/packer-command-build",
             "${bin_dir}/packer-command-validate",
             "${bin_dir}/packer-post-processor-vagrant",
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
