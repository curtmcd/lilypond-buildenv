# lilypond-buildenv

> Docker project embodying a build environment for LilyPond

<table>
 <tr>
  <td><img src="lp-logo.gif"/></td>
  <td>
   <h1>LilyPond BuildEnv</h1>
   Version 0.1
  </td>
 </tr>
</table>

## Description

This image is for LilyPond software build and development. It contains a
complete build environment for LilyPond, including Ubuntu 16.04 and all
of the needed compilation programs, library packages, font packages,
etc. Some advantages are:

- Makes virtually no requirements on your build machine as to what O/S
  version or software packages are installed on it.  Use any machine to
  build LilyPond after installing only Docker (and git and wget).

- Doesn't require your modern O/S to have Guile 1.8 or other old
  packages no longer available.

- Much lighter weight than VM; uses under 1.5GB on disk and needs no
  extra memory beyond the usual compilation.

- Test arbitrary changes to the development environment by rebuilding it
  from scratch in a few minutes. No forgetting what's installed; the
  Dockerfile encapsulates the description of everything.

## System requirements

Any Linux platform with a reasonably modern kernel that runs Docker
should work. Actually, these days Docker can even run under Windows
business editions.

```bash
sudo apt install docker git wget
```

## Fetch the image

To build the image yourself, refer to instructions later on
below. Otherwise, grab mine from Docker Hub:

```bash
sudo docker pull curtmcd/lilypond-buildenv
```

## Check out the LilyPond repository

The script below assumes the git repository is somewhere under your home
directory. Skip this section if you already have the repository checked
out. See LilyPond on-line docs for information about using git to work
on LilyPond.

```bash
git clone git://git.sv.gnu.org/lilypond.git
cd lilypond
git config --local user.name "Curt McDowell"
git config --local user.email coder@fishlet.com
```

## Run the container

The following command starts a container with a shell running in it:

```bash
./run
```

The user's home directory is mounted in the usual place.  A few tools
like git and vim are included in the container.  "sudo" will also work,
so additional Ubuntu packages can be installed in the usual way.

When the shell exits, the contents of the container will disappear.  Any
changes made to the container (*outside* the mounted home directory)
will be lost, for example the results of "sudo make install".

## Build LilyPond

Run the usual build commands while inside the container shell.

```bash
cd lilypond
./autogen.sh --noconfigure
mkdir build
cd build
../configure
make all
make doc
make info
```

To build on 8 cores in parallel, use `make -j8 all`.

To disable building the documentation, which is the longest part of the
build, run `configure` with the `--disable-documentation` option.

To install the binaries and documentation to /usr/local for testing:

```bash
sudo make install
sudo make install-doc
sudo make install-info
```

To fully clean the repository back to scratch:

```bash
cd lilypond     (respository root)
git clean -fxd
```

## Open another shell in container

To open another shell in the container, find out the two-word name of
the running container.

```bash
sudo docker ps
```

Then run a shell in that container. Here, the name was gifted_bartik
(alternately, specify the first few characters of the container ID):

```bash
sudo docker exec -ti gifted_bartik /bin/bash
```

## Build the image

A script is provided to build the curtmcd/lilypond-buildenv:latest
Docker image. It only takes a few minutes and it can be customized by
modifying Dockerfile.

```bash
./build
```

The script will ask for your sudo password because all docker commands
must run as root.

Two of the prerequisite packages are not available as packages for
Ubuntu 16.04.  They are downloaded by the `build` script and built
during the container image construction:

- The extractpdfmark program
- The Ghostscript URW OTF fonts

### Caveats

The build does not attempt to remove previously built images, so after
iterating several times, untagged docker images may start to
accumulate. To see these and remove them:

```bash
sudo docker images
sudo docker rmi <name>
```

A dangling untagged <none> image may also be left behind if the build
script is interrupted. These can be removed using:

```bash
sudo docker rmi $(sudo docker images --filter dangling=true -q)
```

To clean up the git workarea completely:

```bash
git clean -dffx
```

## Publishing image to Docker Hub

Commands shown are for the curtmcd repository.

```bash
sudo docker tag curtmcd/lilypond-buildenv curtmcd/lilypond-buildenv:0.1
sudo docker push curtmcd/lilypond-buildenv:0.1
```

## Release History

* 0.1
    * Initial version

## Meta

Curt McDowell \<coder#fishlet,com\>

License: none

Source: https://github.com/curtmcd/lilypond-buildenv/
