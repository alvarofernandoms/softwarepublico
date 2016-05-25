# Building Packages

This path and scripts automates the build and update the packages for SPB project.
It's can be done manually, but we don't recommend.

## Requirements

First, this will only works (at least was tested) on a RedHat based system
(Fedora, CentOS, etc). Everything you need to know about packing for the system
is available [here](https://fedoraproject.org/wiki/How_to_create_an_RPM_package/pt)

Dependency packages

```
# yum install @development-tools
# yum install fedora-packager
# yum install copr-cli
# yum install git
```

You need a account on [Copr Fedora](https://copr.fedorainfracloud.org) and the api token to
authenticate when upload. Just follow the instruction on the
[API](https://copr.fedorainfracloud.org/api/).

You need your GPG key in the machine. If you don't have one follow the
instruction [here](https://fedoraproject.org/wiki/Creating_GPG_Keys/pt-br)

## Usage

### Make Release

Make Release are made to build *colab-spb-plugin*, *colab-spb-theme* e 
*noosfero-spb*. Bump the VERSION file on the root directory and runs
into the src/ directory:

```
$ make release
```

Follow the instructions and done :).
Don't forget to push the changes to the repository.

### Build Packages

To build the others packages.

**First**: Build the **tarball** of the
core project. Pay attention to how to build this, some projects needs
requirements or pre-command before create the **tarball**.

In most of the cases you just needs to run into the project repository:
```
 $ git archive --format=tar.gz --prefix=<pkg-name>-<pkg-version>/ <tag or branch> > <pkg-name>-<pkg-version>.tar.gz
 or
 $ make sdist
```

**Second**: Copy the **tarball** into the pkg-rpm/<project>/

**Third**: Runs into the src/pkg-rpm/:
```
 $ make <project>-build
 and
 $ make <project>-upload
```

The first will build the package and the second will upload to
the copr repository using copr-cli.

**Note**: the copr repository is defined into *src/pkg-rpm/Makefile*.

**Important**: Make sure that you have all the build dependencies installed.
Just check the .spec file to verify which are.
