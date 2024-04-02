#!/bin/bash

set -eux

OPT=$(pwd)/.compilers
mkdir -p "${OPT}"
mkdir -p "${OPT}/tmp"

fetch() {
  # shellcheck disable=SC2154
  curl "${http_proxy:+--proxy "${http_proxy}"}" -sL "$*"
}

get_ghc() {
  local VER=$1
  local DIR=ghc-$VER

  pushd "${OPT}/tmp"
  fetch "https://downloads.haskell.org/~ghc/${VER}/ghc-${VER}-x86_64-deb10-linux.tar.xz" | tar Jxf -
  cd "${OPT}/tmp/ghc-${VER}"
  ./configure --prefix="${OPT}/ghc"
  make install
  rm -rf "${OPT}/ghc/lib/ghc-${VER}"/Cabal*
  rm -rf "${OPT}/ghc/share"
  popd
  rm -rf "${OPT}/tmp/ghc-${VER}"
}

get_gdc() {
  vers=$1
  build=$2
  mkdir "${OPT}/gdc"
  pushd "${OPT}/gdc"
  fetch "https://gdcproject.org/downloads/binaries/${vers}/x86_64-linux-gnu/gdc-${vers}+${build}.tar.xz" | tar Jxf -
  popd
}

CE_GHC_VER=9.0.1
if ! ("${OPT}/ghc/bin/ghc" --version | grep -q -F "${CE_GHC_VER}"); then
  get_ghc "${CE_GHC_VER}"
fi

CE_GDC_VER=5.2.0
if ! ("${OPT}/gdc/x86_64-pc-linux-gnu/bin/gdc" --version | grep -q -F "${CE_GDC_VER}"); then
  get_gdc "${CE_GDC_VER}" 2.066.1
fi
