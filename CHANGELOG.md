## 0.9.18 (07/05/2016)

IMPROVEMENTS:

* Change Packer download URL via Joshua Spence (GH-7)

## 0.9.17 (08/12/2015)

IMPROVEMENTS:

* Upgrade to Packer 0.8.5.
* Improve parameter validation.
* Validate SSL certificate for HTTPS downloads by default.
* Improve version checking by using `packer --version` on 0.8.0+.

## 0.9.16 (06/27/2015)

IMPROVEMENTS:

* Upgrade to Packer 0.8.0.

BUG FIXES:

* Fix version checking exec to not stall when there's a Packer update.
* Don't backup files removed when `ensure => absent`.

## 0.9.15 (05/08/2015)

BUG FIXES:

* Fix soft-tab linting issues via Dougal Scott (GH-4)
* Fix version detection exec via William Hutson (GH-3)

## 0.9.14 (01/06/2015)

IMPROVEMENTS:

* Upgrade to Packer 0.7.5.
