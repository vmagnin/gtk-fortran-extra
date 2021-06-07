#! /bin/bash
# Vincent Magnin, 2021-05-21
# Last modification: 2021-06-07
# MIT license
# Verified with shellcheck

# Strict mode:
set -euo pipefail

rm -f ./*.mod

# Allow override of default compiler. For example:
#  FC='ifort' ./with_GUI.sh
# Default:
: ${FC="gfortran"}

if [ "${FC}" = "ifort" ]; then
  FLAGS="-warn all -Ofast"
else
  FLAGS="-Wall -Wextra -Wno-unused-dummy-argument -fcheck=all -std=f2008 -pedantic -Ofast -march=native -mtune=native -fmax-stack-var-size=2000000"
fi

"${FC}" ${FLAGS} with_or_without_GUI.f90 hooks_GTK_with_GUI.f90 scientific_computing.f90 GUI_module.f90  main_with_GUI.f90 $(pkg-config --cflags --libs gtk-4-fortran) && ./a.out
