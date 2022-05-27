#! /bin/bash
# Vincent Magnin, 2021-05-21
# Last modification: 2022-05-27
# MIT license
# Verified with shellcheck

# Strict mode:
set -euo pipefail

rm -f ./*.mod

# Allow override of default compiler. For example:
#  FC='ifort' ./build.sh
# Default:
: ${FC="gfortran"}

if [ "${FC}" = "ifort" ]; then
  ifort -warn nounused -O3 -coarray GUI_and_computation.f90  main.f90 $(pkg-config --cflags --libs gtk-4-fortran) && ./a.out
else
  caf -O3 -std=f2018 -pedantic GUI_and_computation.f90  main.f90 $(pkg-config --cflags --libs gtk-4-fortran) && cafrun -n 4 ./a.out
fi
