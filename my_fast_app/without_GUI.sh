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
  FLAGS="-warn all"
else
  FLAGS="-Wall -Wextra -Wno-unused-dummy-argument -fcheck=all -std=f2008 -pedantic"
fi

"${FC}" ${FLAGS} with_or_without_GUI.f90 hooks_GTK_without_GUI.f90 scientific_computing.f90 main_without_GUI.f90 && ./a.out
