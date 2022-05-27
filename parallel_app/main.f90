!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: 2022-05-27
! MIT license
!------------------------------------------------------------------------------

program Parallel_Buddhabrot
  use GUI_and_computation
  use, intrinsic :: iso_c_binding

  print *, this_image()

  if (this_image() == 1) then
    call initialize_GUI
  end if

  !******************************************************************
  ! Let's call our scientific computation on each Fortran image:
  !******************************************************************
  call my_computation()

  !******************************************************************
  ! The window will stay opened after the computation, but we need to verify
  ! that the user has not closed the window during the computation.
  ! https://developer.gnome.org/glib/stable/glib-The-Main-Event-Loop.html
  !******************************************************************
  if ((this_image() == 1) .and. (run_status /= FALSE)) then
    ! Final update of the display:
    call gtk_widget_queue_draw(my_drawing_area1)
    call save_pixbuf(my_pixbuf1, "buddhabrot.png")

    call gtk_text_buffer_insert_at_cursor (buffer, &
        & "Done!"//c_new_line//c_null_char, -1_c_int)

    my_gmainloop = g_main_loop_new(c_null_ptr, FALSE)
    call g_main_loop_run(my_gmainloop)
  end if

  print '(A, I3, A)', "I am image", this_image(), " at end program"
  sync all
  print '(A, I3, A)', "I am image", this_image(), " and I am after sync all"

end program Parallel_Buddhabrot
