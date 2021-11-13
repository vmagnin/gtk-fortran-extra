#! /bin/bash
# Vincent Magnin, 2021-05-21
# Last modification: 2021-11-04
# Verified with shellcheck

# Strict mode:
set -euo pipefail

rm -f ./*.mod

# Allow override of default compiler. For example:
#  FC='ifort' ./with_GUI.sh
# Default:
: ${FC="gfortran"}

if [ "${FC}" = "ifort" ]; then
  FLAGS="-warn all"
else
  FLAGS="-Wall -Wextra -Wno-unused-dummy-argument -fcheck=all -std=f2008 -pedantic"
fi

"${FC}" ${FLAGS} random.f90 unknown_pleasures.f90 $(pkg-config --cflags --libs gtk-4-fortran)
