<!---
apt-fast v1.11
Use this just like aptitude or apt-get for faster package downloading.

Copyright: 2008-2012 Matt Parnell, http://www.mattparnell.com
Improvements, maintenance, revisions - 2012, 2017-2019 Dominique Lasserre

You may distribute this file under the terms of the GNU General
Public License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.
-->

apt-fast 1.9
============
apt-fast is a shell script wrapper for apt-get and aptitude that can drastically improve apt download times by downloading packages in parallel, with multiple connections per package.

## Table of Contents

- [Installation](#installation)
  - [Quick install](#quick-install)
  - [Manual](#manual)
- [Configuration](#configuration)
  - [Package manager](#package-manager)
  - [Confirmation dialog](#confirmation-dialog)
  - [Multiple mirrors](#multiple-mirrors)
  - [Maximum connections](#maximum-connections)
  - [Maximum connections per server](#maximum-connections-per-server)
  - [Maximum connections per file](#maximum-connections-per-file)
  - [File split size](#file-split-size)
  - [Piece selection algorithm](#piece-selection-algorithm)
  - [Downloadmanager file](#downloadmanager-file)
  - [Downloadmanager command](#downloadmanager-command)
    - [Proxy](#proxy)
  - [Download folder](#download-folder)
  - [APT archives cache](#apt-archives-cache)
  - [Verbose output](#verbose-output)
  - [Colors](#colors)
- [License](#license)
- [Special thanks](#special-thanks)

Installation
------------
This branch supports [Termux](https://termux.dev/) on Android only. No root
is required: Termux is single-user, so `apt-fast` never uses `sudo` there,
installs under `$PREFIX` (`$PREFIX/bin/apt-fast` with config in
`$PREFIX/etc/apt-fast.conf`), and keeps its lock/download-list files in
`$TMPDIR` (Termux has no `/tmp`).

### Quick install ###
Run (note: plain `bash`, there is no `/bin/bash` on Android):

```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/TheTechTiger/apt-fast/termux-support/quick-install.sh)"
```

To install from another fork/branch, override the download location:

```bash
APT_FAST_URL=https://raw.githubusercontent.com/<user>/apt-fast/<branch> bash quick-install.sh
```

### Manual ###
From a checkout of this repo:

```sh
make install PREFIX="$PREFIX"
```

You need [aria2c](http://aria2.sourceforge.net/) installed (both the quick
installer and `make install` take care of this via `apt-get install aria2`).

Then run `apt-fast` instead of `apt-get`, e.g. `apt-fast install <package>`.


Configuration
-------------
The apt-fast configuration file is located at: `$PREFIX/etc/apt-fast.conf`


### Package manager ###
```sh
_APTMGR=apt-get
```
Change package manager used for installation. Supported are `apt-get`, `aptitude`, `apt`.

Note: When using Linux Mint, don't use `apt` because the distributor provides a custom shell script with different functionality unsupported by apt-fast.


### Confirmation dialog ###
```sh
DOWNLOADBEFORE=true
```
Set this to any value to suppress the apt-fast confirmation dialog and download packages directly. Leave empty to ask for confirmation. This option doesn't affect package manager confirmation.


### Multiple mirrors ###
Adding multiple mirrors will further speed up downloads and distribute load. Be sure to add mirrors near your location.
Official mirror lists:

* Debian: <http://www.debian.org/mirror/list>
* Ubuntu: <https://launchpad.net/ubuntu/+archivemirrors>

Then add them to the whitespace- and comma-separated list in the config file, e.g.:

```sh
MIRRORS=( 'http://deb.debian.org/debian','http://ftp.debian.org/debian, http://ftp2.de.debian.org/debian, http://ftp.de.debian.org/debian, ftp://ftp.uni-kl.de/debian' )
```

```sh
MIRRORS=( 'http://archive.ubuntu.com/ubuntu, http://de.archive.ubuntu.com/ubuntu, http://ftp.halifax.rwth-aachen.de/ubuntu, http://ftp.uni-kl.de/pub/linux/ubuntu, http://mirror.informatik.uni-mannheim.de/pub/linux/distributions/ubuntu/' )
```

*NOTE:* To use any mirrors you may have in `sources.list` or `sources.list.d`, you will need to add them to the `apt-fast.conf` mirror list as well!


### Maximum connections ###
```sh
_MAXNUM=5
```
Set to the maximum number of connections aria2c uses.


### Maximum connections per server ###
```sh
_MAXCONPERSRV=10
```
Set to the maximum number of connections per server aria2c uses.


### Maximum connections per file ###
```sh
_SPLITCON=8
```
Set to the maximum number of connections per file aria2c uses.


### File split size ###
```sh
_MINSPLITSZ=1M
```
Set to the size of each split piece. Possible values: 1M-1024M


### Piece selection algorithm ###
```sh
_PIECEALGO=default
```
Set to the piece selection algorithm to use. Possible values: `default`, `inorder`, `geom`


### Downloadmanager file ###
```sh
DLLIST='/tmp/apt-fast.list'
```
Location of the aria2c input file, used to download the packages with options and checksums.


### Downloadmanager command ###
```sh
_DOWNLOADER='aria2c --no-conf -c -j ${_MAXNUM} -x ${_MAXCONPERSRV} -s ${_SPLITCON} -i ${DLLIST} --min-split-size=${_MINSPLITSZ} --stream-piece-selector=${_PIECEALGO} --connect-timeout=600 --timeout=600 -m0'
```
Change the download manager or add additional options to aria2c.

#### Proxy ####
apt-fast uses APT's proxy settings (`Acquire::http::proxy`, `Acquire::https::proxy`, `Acquire::ftp::proxy`) and if those are not available, the environment settings (`http_proxy`, `https_proxy`, `ftp_proxy`). Refer to APT's or the system's documentation.


### Download folder ###
```sh
DLDIR='/var/cache/apt/apt-fast'
```
Directory where apt-fast (temporarily) downloads the packages.


### APT archives cache ###
```sh
APTCACHE='/var/cache/apt/archives'
```
Directory where apt-get and aptitude download packages.


### APT authentication ###
```sh
APT_FAST_APT_AUTH=1
```
Try to authenticate packages from sources that require login.


### Verbose output ###
```sh
VERBOSE_OUTPUT=y
```
Show aria2 download file instead of package listing before download confirmation. Unset to show package listing.


### Colors ###
```sh
cGreen='\e[0;32m'
cRed='\e[0;31m'
cBlue='\e[0;34m'
endColor='\e[0m' 
```
Terminal colors used for dialogs. Refer to [ANSI Escape sequences](http://ascii-table.com/ansi-escape-sequences.php) for a list of possible values. Disabled when not using terminal.


License
-------
Consider apt-fast and all of its derivatives licensed under the GNU GPLv3+.

Copyright: 2008-2012 Matt Parnell

Improvements, maintenance, revisions - 2012, 2017-2019 Dominique Lasserre


Special thanks
--------------
 * Travis/travisn000 - support for complex apt-get commands
 * [Alan Hoffmeister](https://github.com/alanhoff) - aria2c support
 * Abhishek Sharma - aria2c with proxy support
 * Luca Marchetti - improvements on the locking system and downloader execution
 * Richard Klien - Autocompletion, Download Size Checking (made for on ubuntu, untested on other distros)
 * Patrick Kramer Ruiz - suggestions
 * Sergio Silva - test to see if axel is installed, root detection/sudo autorun, lock file check/creation
 * Waldemar {BOB}{Burnfaker} Wetzel - lockfile improvements, separate config file
 * maclarke - locking improvements
