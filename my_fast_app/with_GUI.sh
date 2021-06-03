#! /bin/bash
# Vincent Magnin, 2021-05-21
# Last modification: 2021-06-02
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
  FLAGS=""
else
  FLAGS="-Wall -Wextra -Wno-unused-dummy-argument -fcheck=all -std=f2008 -pedantic"
fi

"${FC}" ${FLAGS} with_or_without_GUI.f90 hooks_GTK_with_GUI.f90 scientific_computing.f90 GUI_module.f90  main_with_GUI.f90 $(pkg-config --cflags --libs gtk-4-fortran) && ./a.out
