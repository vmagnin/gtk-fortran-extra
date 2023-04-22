#! /bin/bash
# Vincent Magnin, 2023-03-26
# Last modification: 2023-04-21
# Verified with shellcheck

# Strict mode:
set -euo pipefail

rm -f ./*.mod

# Allow override of default compiler. For example:
#  FC='ifx' ./with_GUI.sh
# Default:
: ${FC="gfortran"}

if [ "${FC}" = "ifx" ]; then
  FLAGS="-warn all"
else
  FLAGS="-Wall -Wextra -Wno-unused-dummy-argument -fcheck=all -std=f2008 -pedantic"
fi

"${FC}" ${FLAGS} src/color_class.f90 src/glyph_class.f90 src/grapheme_class.f90 src/gui.f90 app/saville_code.f90 $(pkg-config --cflags --libs gtk-4-fortran)

# Shows the executable:
ls -oh a.out
