!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: vmagnin 2021-05-25
! MIT license
!------------------------------------------------------------------------------

program without_gui
  use with_or_without_GUI, only: GUI
  use scientific_computing, only: my_computation

  GUI = .false.
  print *, "GUI =", GUI
  call my_computation
end program without_gui
