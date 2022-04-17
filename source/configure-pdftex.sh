#!/bin/bash -e
# $Id$
# build pdftex from cut-down TeX Live sources (see sync-pdftex.sh).
# public domain.
# The only intended bash-ism is the use of PIPESTATUS near the end.
# Could rewrite, but no requests to do so ...

top_dir=$(cd $(dirname $0) && pwd)
pdftex_dir=$top_dir/src/texk/web2c/pdftexdir
if test ! -d $pdftex_dir; then
    echo "$0: $pdftex_dir not found, goodbye"
    exit 1
fi

# just build pdftex; normally disable poppler here since typically we
# want to build/debug with our own libxpdf.
# 
able_poppler=--disable-poppler
#
CFG_OPTS="\
    --without-x \
    --disable-shared \
    --disable-all-pkgs \
    --enable-pdftex \
    --disable-synctex \
    $able_poppler \
    --enable-native-texlive-build \
    --enable-cxx-runtime-hack \
"

# build with debugging only (no optimization).
DEBUG_OPTS="\
    CFLAGS=-g \
    CXXFLAGS=-g \
"

# disable system libraries for everything, so that configure does not
# report any "Assuming installed ...", only "Using ... from TL tree".
# 
# Sadly, --enable-native-texlive-build can't easily do it for cut-down
# source trees like this one.  For example, our tree does not include
# teckit, therefore configure thinks the system teckit should be used,
# therefore teckit dependencies should also be taken from the system,
# and that includes zlib -- even though we do have zlib present in the
# source tree here, and want to use it.  Sigh.
#
DISABLE_SYSTEM_LIBS="\
    --without-system-cairo \
    --without-system-freetype2 \
    --without-system-gd \
    --without-system-gmp \
    --without-system-graphite2 \
    --without-system-harfbuzz \
    --without-system-icu \
    --without-system-kpathsea \
    --without-system-libgs \
    --without-system-libpaper \
    --without-system-libpng \
    --without-system-mpfr \
    --without-system-pixman \
    --without-system-poppler \
    --without-system-potrace \
    --without-system-ptexenc \
    --without-system-teckit \
    --without-system-xpdf \
    --without-system-zlib \
    --without-system-zziplib \
"
CFG_OPTS="-C $CFG_OPTS $DEBUG_OPTS $DISABLE_SYSTEM_LIBS"

export CONFIG_SHELL=/bin/bash
build_dir=`pwd`/build-pdftex

set -x
rm -rf $build_dir && mkdir $build_dir && cd $build_dir

{
  echo "starting `date`"
  $top_dir/src/configure $CFG_OPTS "$@"
} 2>&1 | tee configure.log
if test ${PIPESTATUS[0]} -ne 0; then  # a bash feature
  set +x
  echo "$0: configure failed, goodbye (see log in $build_dir/configure.log)." >&2
  exit 1
fi

echo "finish configure"
exit 0
