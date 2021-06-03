!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: vmagnin 2021-05-25
! MIT license
!------------------------------------------------------------------------------

program with_GUI
  use with_or_without_GUI, only: GUI
  use GUI_module, only: initialize_GUI

  GUI = .true.
  print *, "GUI =", GUI
  call initialize_GUI
end program with_GUI
