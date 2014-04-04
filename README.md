packer
=======

This Puppet module installs the Packer software package from the
[official releases](http://www.packer.io/downloads.html).  To install
Packer, just include this module in your manifests:

```puppet
include packer
```

To uninstall Packer, set the `ensure` parameter to `absent`:

```puppet
class { 'packer':
  ensure => absent,
}
```

By default, this module installs Packer into `/usr/local/bin` -- to
have it go elsewhere, use the `bin_dir` parameter:

```puppet
class { 'packer':
  bin_dir => '/opt/local/bin',
}
```

License
-------

Apache License, Version 2.0

Contact
-------

Justin Bronn <justin@counsyl.com>

Support
-------

Please log tickets and issues at https://github.com/counsyl/puppet-packer
