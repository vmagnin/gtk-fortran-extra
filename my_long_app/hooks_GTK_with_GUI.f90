!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: vmagnin 2021-05-26
! MIT license
!------------------------------------------------------------------------------

module hooks_GTK
  use, intrinsic :: iso_c_binding
  use gtk, only: gtk_text_buffer_insert_at_cursor, gtk_widget_queue_draw
  use g, only: g_main_context_iteration, g_main_context_pending
  use with_or_without_GUI, only: buffer, FALSE, run_status

  implicit none

  type(c_ptr)    :: my_drawing_area1
  integer(c_int) :: boolresult

contains

  subroutine hook_print_string(string)
    character(len=*), intent(in) :: string
    call gtk_text_buffer_insert_at_cursor(buffer, trim(string)//c_new_line//c_null_char, -1_c_int)
  end subroutine

  subroutine hook_gtk_widget_queue_draw
    call gtk_widget_queue_draw(my_drawing_area1)
  end subroutine

  ! This function is needed to update the GUI during long computations.
  ! https://developer.gnome.org/glib/stable/glib-The-Main-Event-Loop.html
  subroutine hook_pending_events()
    do while(IAND(g_main_context_pending(c_null_ptr), run_status) /= FALSE)
      ! FALSE for non-blocking:
      boolresult = g_main_context_iteration(c_null_ptr, FALSE)
    end do
  end subroutine

end module hooks_GTK
