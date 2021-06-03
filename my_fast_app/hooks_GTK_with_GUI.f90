!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: vmagnin 2021-05-26
! MIT license
!------------------------------------------------------------------------------

module hooks_GTK
  use, intrinsic :: iso_c_binding
  use gtk, only: gtk_text_buffer_insert_at_cursor
  use with_or_without_GUI, only: buffer

  implicit none

contains

  subroutine hook_print_string(string)
    character(len=*), intent(in) :: string
    call gtk_text_buffer_insert_at_cursor(buffer, trim(string)//c_new_line//c_null_char, -1_c_int)
  end subroutine

end module hooks_GTK
