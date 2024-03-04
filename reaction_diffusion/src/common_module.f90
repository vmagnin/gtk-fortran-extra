!------------------------------------------------------------------------------
! Contributed by Vincent Magnin, 2024-02-27
! Last modifications: vmagnin 2024-02-27
! MIT license
!------------------------------------------------------------------------------

module common_module
  use, intrinsic :: iso_c_binding
  use, intrinsic :: iso_fortran_env, only: wp=>real64, int64, int16
  use gtk, only: gtk_text_buffer_insert_at_cursor, gtk_widget_queue_draw, &
               & gtk_text_buffer_get_end_iter, gtk_text_iter_set_line_offset, &
               & gtk_text_buffer_move_mark, gtk_text_view_scroll_mark_onscreen
  use gtk_sup
  use g, only: g_main_context_iteration, g_main_context_pending

  implicit none
  type(c_ptr)    :: my_drawing_area1
  integer(c_int) :: boolresult
  type(c_ptr)    :: textView, text_mark
  ! That type is defined in the gtk_sup module:
  type(gtktextiter), target :: text_iter
  ! The pixbuffer and its parameters:
  type(c_ptr)    :: my_pixbuf1
  integer(c_int) :: nch, rowstride
  integer(c_int), parameter :: pixwidth  = 1280
  integer(c_int), parameter :: pixheight = 720
  character(kind=c_char), dimension(:), pointer :: pixels1
  ! Text buffer:
  type(c_ptr) :: buffer
  ! run_status is TRUE until the user closes the top window:
  integer(c_int) :: run_status = TRUE
  logical        :: computing = .false.

contains

  subroutine print_string(string)
    character(len=*), intent(in) :: string
    call gtk_text_buffer_insert_at_cursor(buffer, trim(string)//c_new_line//c_null_char, -1_c_int)

    ! Managing the scroll:
    call gtk_text_buffer_get_end_iter (buffer, c_loc(text_iter))
    ! To avoid horizontal scrolling:
    call gtk_text_iter_set_line_offset (c_loc(text_iter), 0_c_int)
    call gtk_text_buffer_move_mark (buffer, text_mark, c_loc(text_iter))
    call gtk_text_view_scroll_mark_onscreen (textView, text_mark)
  end subroutine

  ! This function is needed to update the GUI during long computations.
  ! https://docs.gtk.org/glib/main-loop.html
  subroutine pending_events()
    do while(IAND(g_main_context_pending(c_null_ptr), run_status) /= FALSE)
      ! FALSE for non-blocking:
      boolresult = g_main_context_iteration(c_null_ptr, FALSE)
    end do
  end subroutine

  ! Set the color of the pixel (i, j) in the pixels pixbuffer:
  subroutine set_pixel(pixels, i, j, red, green, blue)
    character(kind=c_char), dimension(:), pointer, intent(inout) :: pixels
    integer, intent(in)        :: i, j
    integer(int16), intent(in) :: red, green, blue     ! rgb color
    integer :: p

    ! We write in the pixbuffer:
    p = i * nch + j * rowstride + 1
    if ((p >= 1).and.(p <= size(pixels))) then
      pixels(p)   = char(red)
      pixels(p+1) = char(green)
      pixels(p+2) = char(blue)
    end if
  end subroutine
end module common_module
