!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: vmagnin 2021-06-08
! MIT license
!------------------------------------------------------------------------------

module hooks_GTK
  use, intrinsic :: iso_c_binding
  use gtk, only: gtk_text_buffer_insert_at_cursor, gtk_widget_queue_draw, &
               & gtk_text_buffer_get_end_iter, gtk_text_iter_set_line_offset, &
               & gtk_text_buffer_move_mark, gtk_text_view_scroll_mark_onscreen
  use gtk_sup
  use g, only: g_main_context_iteration, g_main_context_pending
  use with_or_without_GUI, only: buffer, run_status

  implicit none

  type(c_ptr)    :: my_drawing_area1
  integer(c_int) :: boolresult
  type(c_ptr)    :: textView, text_mark
  ! That type is defined in the gtk_sup module:
  type(gtktextiter), target :: text_iter

contains

  subroutine hook_print_string(string)
    character(len=*), intent(in) :: string
    call gtk_text_buffer_insert_at_cursor(buffer, trim(string)//c_new_line//c_null_char, -1_c_int)

    ! Managing the scroll:
    call gtk_text_buffer_get_end_iter (buffer, c_loc(text_iter))
    ! To avoid horizontal scrolling:
    call gtk_text_iter_set_line_offset (c_loc(text_iter), 0_c_int)
    call gtk_text_buffer_move_mark (buffer, text_mark, c_loc(text_iter))
    call gtk_text_view_scroll_mark_onscreen (textView, text_mark)
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
