FROM ubuntu:16.04

LABEL maintainer="Curt McDowell <coder@fishlet.com>"

RUN apt update && apt upgrade -y

#-----------------------------------------------------------------------------
# Utility
#
# If more packages are needed, it's best to add them as far down in this file
# as possible to invalidate less of the docker cache.
#----------------------------------------------------------------------------

RUN apt install -y --no-install-recommends \
    apt-utils \
    build-essential \
    gettext \
    libtool \
    automake \
    autopoint \
    astyle

#-----------------------------------------------------------------------------
# Build extractpdfmark since it's not available in 16.04
#-----------------------------------------------------------------------------

RUN apt install -y --no-install-recommends \
    libpoppler-glib-dev \
    libpoppler-private-dev

COPY extractpdfmark_1.1.0.orig.tar.gz /tmp

RUN cd /tmp && \
    tar -zxpf extractpdfmark_1.1.0.orig.tar.gz && \
    cd extractpdfmark-1.1.0 && \
    ./autogen.sh && \
    ./configure && \
    make install && \
    rm -rf /tmp/extractpdfmark*

#-----------------------------------------------------------------------------
# Install URW fonts
#-----------------------------------------------------------------------------

COPY urw-core35-fonts/ /usr/share/fonts/urw-core35-fonts
COPY 01-urw-otf.conf /etc/fonts/conf.d/01-urw-otf.conf

#-----------------------------------------------------------------------------
# Install things needed To build and run LilyPond
#
# texlive-generic-recommended - for epsf.tex
# fonts-lmodern - for xetex backend (make doc)
# libfl-dev - comes with flex for now; needs to be explicit in later Ubuntu
#-----------------------------------------------------------------------------

RUN apt install -y --no-install-recommends \
    zip \
    bison \
    flex \
    tidy \
    info \
    install-info \
    fontforge \
    ghostscript \
    python2.7 \
    python3.5 \
    guile-1.8-dev \
    libpango1.0-dev \
    dblatex \
    texinfo \
    texlive-metapost \
    texlive-xetex \
    texlive-lang-cyrillic \
    texlive-generic-recommended \
    fonts-dejavu \
    emacs-intl-fonts \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
    xfonts-bolkhov-75dpi \
    xfonts-cronyx-75dpi \
    xfonts-cronyx-100dpi \
    xfonts-intl-arabic \
    xfonts-intl-asian \
    xfonts-intl-chinese \
    xfonts-intl-chinese-big \
    xfonts-intl-european \
    xfonts-intl-japanese \
    xfonts-intl-japanese-big \
    xfonts-intl-phonetic \
    fonts-texgyre \
    fonts-lmodern

#-----------------------------------------------------------------------------
# To use lily-git.tcl
#-----------------------------------------------------------------------------

RUN apt install -y --no-install-recommends \
    tk

#-----------------------------------------------------------------------------
# To build documentation
#-----------------------------------------------------------------------------

RUN apt install -y --no-install-recommends \
    imagemagick \
    netpbm \
    rsync \
    texi2html \
    gsfonts \
    fonts-linuxlibertine \
    fonts-liberation \
    fonts-dejavu \
    fonts-freefont-otf \
    ttf-bitstream-vera \
    texlive-fonts-recommended \
    ttf-xfree86-nonfree

#-----------------------------------------------------------------------------
# Additional image customization
#
# git - for working on LilyPond repository from inside container
# sudo - so docker image can run as user but can still get to root
# ssh - for convenience's sake
#-----------------------------------------------------------------------------

RUN apt install -y --no-install-recommends \
    sudo \
    vim \
    less \
    git \
    xpdf \
    openssh-client

#-----------------------------------------------------------------------------

CMD /bin/bash
