This script creates Ubuntu packages for
[dReal][dreal] and uploads them to
[launchpad.net](https://launchpad.net/~dreal/+archive/ubuntu/dreal/+packages).

Uploaded packages are available at

https://launchpad.net/~dreal/+archive/ubuntu/dreal/+packages

[dreal]: https://dreal.github.io


Required packages
-----------------

We assume that you have Ubuntu 14.04 LTS system. You need the
following packages:

```bash
sudo apt-get install git pbuilder build-essential ubuntu-dev-tool
```

Also we assume that you have created your GPG/PGP key and published to
launchpad.


How to use script
-----------------

```bash
./update.sh
```


How to install dReal using PPA
-----------------------------

```bash
sudo add-apt-repository ppa:dreal/dreal
sudo apt-get update
sudo apt-get install dreal
```

Once install dReal via PPA, you can use the standard `apt-get upgrade`
to get the latest version of dReal.
