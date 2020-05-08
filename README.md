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
  from scratch in a few minutes. No forgetting what versions of what
  packages are installed on your build machine; the Dockerfile
  encapsulates the description of everything.

## System requirements

Any Linux platform with a reasonably modern kernel that runs Docker
should work. Actually, these days Docker can even run under Windows
business editions. I have not tried that.

```bash
sudo apt install docker.io git wget
sudo service docker start
```

## Fetch the image

To build the image yourself, refer to instructions later on
below. Otherwise, grab mine from Docker Hub:

```bash
sudo docker pull curtmcd/lilypond-buildenv:0.1
```

Here I have built the image and tagged it.

## Check out the LilyPond repository

The `./run` script below assumes the git repository is somewhere under
your home directory and mounts it as a Docker volume so it'll be
accessible from within the container. Skip this section if you already
have the repository checked out. See LilyPond on-line docs for
information about using git to work on LilyPond.

```bash
git clone git://git.sv.gnu.org/lilypond.git lilypond.git
cd lilypond.git
git config --local user.name "Your Name"
git config --local user.email your@email.com
```

## Run the container

The following command starts a container based on the Docker image, with
a shell running in it:

```bash
./run
```

The image name `curtmcd/lilypond-buildenv:1.0` is hardcoded in the
script. If you build your own image (instructions below), you'd need to
change it to the name of your container image to use this script.

The user's home directory is mounted in the usual place.  A few tools
like git and vim are included in the container.  `sudo` will also work,
so additional Ubuntu packages can be installed in the usual way. (Note:
the password file volume mapping doesn't work properly on Docker hosts
running Debian).

When the shell exits, the contents of the container will disappear.  Any
changes made to the container (*outside* the mounted home directory),
for example the results of `sudo make install`, will be lost. Here are
two ways to retain changes:

- See below for committing and tagging the image after LilyPond has been
  built and installed.

- Remove the `--rm` option from the `./run` script. Then when the shell
  exits, the container contents persist and the user can restart the
  container using `docker exec` or similar command.

In order to provide some level of networking, the existing Dockerfile
installs `openssh-client` so `ssh` can be used from inside the container
to transfer files in or out. To facilitate local usage, `./run` copies
local entries from `/etc/hosts` into the container `/etc/hosts` (DNS
hosts work normally).

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

Now you can run LilyPond.

```
csm@99ff5197b044:~$ lilypond --version
GNU LilyPond 2.21.0

Copyright (c) 1996--2020 by
  Han-Wen Nienhuys <hanwen@xs4all.nl>
  Jan Nieuwenhuizen <janneke@gnu.org>
  and others.

This program is free software.  It is covered by the GNU General Public
License and you are welcome to change it and/or distribute copies of it
under certain conditions.  Invoke as `lilypond --warranty' for more
information.
```

To fully clean a checked out LilyPond repository:

```bash
cd lilypond.git     (respository root)
git clean -xffd
```

## Open another shell in running container

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

## Commit and tag Docker image after modification

If you have created a Docker image and then done work in it (for
example, built LilyPond and run `make install` on it), you can create an
image from that running container so you can restart it in its current
state.

Find the ID for the running container you want to save, then commit it
to a new image name/tag:

```
sudo docker ps
sudo docker commit <containerid> lilypond-buildenv:installed
sudo docker images
```

Optionally modify the `./run` script to point to this new tagged image,
so that it can be restarted trivially.

## Build your own Docker image

A script is provided to build the curtmcd/lilypond-buildenv:latest
Docker image. It only takes a few minutes and it can be customized (such
as by adding additional Ubuntu packages) by modifying Dockerfile.

```bash
./build
```

The script will ask for your `sudo` password because all Docker commands
must run as `root`.

Two of the prerequisite packages are not available as packages for
Ubuntu 16.04.  They are downloaded by the `build` script and built
during the container image construction:

- The extractpdfmark program (currently at 1.1.0)
- The Ghostscript URW OTF fonts (urw-core35-fonts)

### Caveats

The build does not attempt to remove previously built images, so after
iterating several times, untagged Docker images may start to
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

## To Do

- Dockerfile should have only the bare minimum, then another Docker
  project (like "lilypond-dev") could use FROM lilypond-buildenv.
- Auto-build Docker Hub image from Git Hub project.
- Currently the auth file mapping does not work on Centos hosts for
  some reason (only verified on Ubuntu). Try something else, maybe
  useradd, or maybe have the `run` script build and run a final Docker
  layer that sets USER.

## Meta

Curt McDowell \<coder#fishlet,com\>

License: none

Source: https://github.com/curtmcd/lilypond-buildenv/
