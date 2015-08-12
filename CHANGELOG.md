## 0.9.17 (unreleased)

IMPROVEMENTS:

* Upgrade to Packer 0.8.5.
* Improve parameter validation.

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
