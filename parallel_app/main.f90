!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: 2022-05-30
! MIT license
!------------------------------------------------------------------------------

program Parallel_Buddhabrot
  use GUI_and_computation
  use g, only: g_usleep
  use, intrinsic :: iso_c_binding

  integer :: counter

  print '(A, I3, A, I3)', "Launching image ", this_image(), " over ", num_images()

  !*****************************************************************************
  ! All the calls to GTK must me made by image 1 (which will also participate
  ! to the scientific computation):
  !*****************************************************************************
  if (this_image() == 1) then
    call initialize_GUI
  end if

  !*****************************************************************************
  ! Let's call our scientific computation on each Fortran image:
  !*****************************************************************************
  call my_computation()

  !*****************************************************************************
  ! The window will stay opened after the computation, but we need to verify
  ! that the user has not closed the window during the computation.
  ! https://docs.gtk.org/glib/main-loop.html
  !*****************************************************************************
  if (run_status /= FALSE) then
    if (this_image() == 1) then
      print '(A, I3, A)', "I am image", this_image(), " and this is the final update"
      ! Final update of the display:
      call gtk_widget_queue_draw(my_drawing_area1)
      ! Saves the picture in a PNG file:
      call save_pixbuf(my_pixbuf1, "buddhabrot.png")

      call gtk_text_buffer_insert_at_cursor (buffer, &
          & "Done!"//c_new_line//c_null_char, -1_c_int)

      ! Creates a GTK main loop to keep the window opened:
      my_gmainloop = g_main_loop_new(c_null_ptr, FALSE)
      call g_main_loop_run(my_gmainloop)
    else
      ! Other images must stay idle waiting for image 1 to stop, else they
      ! will burn 100% of their CPU:
      do
        ! Stay idle for 0.1 s:
        call g_usleep(100000_c_long)
        ! If image 1 closed the GTK window we can exit the loop:
        call event_query(stop_notification, counter)
        if (counter /=0) exit
      end do
    end if
  end if

  print '(A, I3, A)', "I am image", this_image(), " at end program"

end program Parallel_Buddhabrot
